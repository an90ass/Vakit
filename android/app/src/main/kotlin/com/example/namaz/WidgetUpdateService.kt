package com.example.namaz

import android.app.*
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.os.Handler
import android.os.Looper
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import androidx.core.app.NotificationCompat

/**
 * Foreground Service that updates the widget every second for accurate countdown
 * This is the most reliable way to keep the widget updated when the app is closed
 */
class WidgetUpdateService : Service() {

    companion object {
        const val CHANNEL_ID = "widget_update_channel"
        const val NOTIFICATION_ID = 1001
        private const val UPDATE_INTERVAL = 1000L // 1 second
        private const val PREFS_NAME = "HomeWidgetPreferences"
        
        fun start(context: Context) {
            val intent = Intent(context, WidgetUpdateService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }
        
        fun stop(context: Context) {
            context.stopService(Intent(context, WidgetUpdateService::class.java))
        }
    }

    private val handler = Handler(Looper.getMainLooper())
    private lateinit var updateRunnable: Runnable

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        startForeground(NOTIFICATION_ID, createNotification())
        startPeriodicUpdates()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        handler.removeCallbacks(updateRunnable)
        super.onDestroy()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Widget Update Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Keeps prayer time widget updated"
                setShowBadge(false)
            }
            
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        val intent = packageManager.getLaunchIntentForPackage(packageName)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Vakit")
            .setContentText("Namaz vakti takip ediliyor")
            .setSmallIcon(android.R.drawable.ic_menu_recent_history)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setSilent(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    private fun startPeriodicUpdates() {
        updateRunnable = object : Runnable {
            override fun run() {
                updateWidgetCountdown()
                handler.postDelayed(this, UPDATE_INTERVAL)
            }
        }
        handler.post(updateRunnable)
    }

    private fun updateWidgetCountdown() {
        try {
            val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val flutterPrefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            
            // Get prayer end time from either preference source
            var prayerEndTime = prefs.getLong("prayer_end_time", 0L)
            if (prayerEndTime == 0L) {
                prayerEndTime = flutterPrefs.getLong("flutter.prayer_end_time", 0L)
            }
            
            val now = System.currentTimeMillis()
            
            if (prayerEndTime > 0 && prayerEndTime > now) {
                val remaining = prayerEndTime - now
                val hours = (remaining / (1000 * 60 * 60)).toInt()
                val minutes = ((remaining % (1000 * 60 * 60)) / (1000 * 60)).toInt()
                val seconds = ((remaining % (1000 * 60)) / 1000).toInt()
                
                val timeString = String.format("%02d:%02d:%02d", hours, minutes, seconds)
                
                // Update the time_remaining in HomeWidget preferences
                prefs.edit().putString("time_remaining", timeString).apply()
                
                // Trigger widget update
                triggerWidgetUpdate()
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun triggerWidgetUpdate() {
        val appWidgetManager = AppWidgetManager.getInstance(this)
        val widgetComponent = ComponentName(this, PrayerTimeWidgetProvider::class.java)
        val widgetIds = appWidgetManager.getAppWidgetIds(widgetComponent)
        
        if (widgetIds.isNotEmpty()) {
            val intent = Intent(this, PrayerTimeWidgetProvider::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, widgetIds)
            }
            sendBroadcast(intent)
        }
    }
}
