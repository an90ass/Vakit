package com.example.namaz

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import androidx.work.Constraints
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.Worker
import androidx.work.WorkerParameters
import androidx.work.WorkManager
import java.util.concurrent.TimeUnit

/**
 * WorkManager Worker that updates the widget every minute
 * This ensures the countdown timer stays accurate even when the app is closed
 */
class WidgetUpdateWorker(
    private val context: Context,
    workerParams: WorkerParameters
) : Worker(context, workerParams) {

    companion object {
        const val WORK_NAME = "prayer_widget_update"
        private const val PREFS_NAME = "FlutterSharedPreferences"
        
        /**
         * Schedule periodic widget updates
         */
        fun schedule(context: Context) {
            val constraints = Constraints.Builder()
                .setRequiresBatteryNotLow(false)
                .build()

            val updateRequest = PeriodicWorkRequestBuilder<WidgetUpdateWorker>(
                15, TimeUnit.MINUTES, // Minimum interval for periodic work
                5, TimeUnit.MINUTES   // Flex interval
            )
                .setConstraints(constraints)
                .build()

            WorkManager.getInstance(context).enqueueUniquePeriodicWork(
                WORK_NAME,
                ExistingPeriodicWorkPolicy.KEEP,
                updateRequest
            )
            
            // Also schedule a one-time immediate update
            scheduleImmediateUpdate(context)
        }
        
        /**
         * Schedule an immediate one-time update
         */
        fun scheduleImmediateUpdate(context: Context) {
            val updateRequest = OneTimeWorkRequestBuilder<WidgetUpdateWorker>()
                .build()
            
            WorkManager.getInstance(context).enqueue(updateRequest)
        }
        
        /**
         * Cancel all scheduled updates
         */
        fun cancel(context: Context) {
            WorkManager.getInstance(context).cancelUniqueWork(WORK_NAME)
        }
    }

    override fun doWork(): androidx.work.ListenableWorker.Result {
        return try {
            updateWidget()
            androidx.work.ListenableWorker.Result.success()
        } catch (e: Exception) {
            e.printStackTrace()
            androidx.work.ListenableWorker.Result.retry()
        }
    }

    private fun updateWidget() {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        
        // Get stored prayer end time
        val prayerEndTime = prefs.getLong("flutter.prayer_end_time", 0L)
        val now = System.currentTimeMillis()
        
        if (prayerEndTime > 0 && prayerEndTime > now) {
            val remaining = prayerEndTime - now
            val hours = (remaining / (1000 * 60 * 60)).toInt()
            val minutes = ((remaining % (1000 * 60 * 60)) / (1000 * 60)).toInt()
            val seconds = ((remaining % (1000 * 60)) / 1000).toInt()
            
            val timeString = String.format("%02d:%02d:%02d", hours, minutes, seconds)
            
            // Update widget data using HomeWidget format
            val homeWidgetPrefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
            homeWidgetPrefs.edit().putString("time_remaining", timeString).apply()
        }
        
        // Trigger widget update
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val widgetComponent = ComponentName(context, PrayerTimeWidgetProvider::class.java)
        val widgetIds = appWidgetManager.getAppWidgetIds(widgetComponent)
        
        if (widgetIds.isNotEmpty()) {
            val provider = PrayerTimeWidgetProvider()
            provider.onUpdate(context, appWidgetManager, widgetIds)
        }
    }
}
