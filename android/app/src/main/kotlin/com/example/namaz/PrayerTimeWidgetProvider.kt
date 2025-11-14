package com.example.namaz

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class PrayerTimeWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.prayer_time_widget).apply {
                val widgetData = HomeWidgetPlugin.getData(context)
                val nextPrayer = widgetData.getString("next_prayer", "Yükleniyor...")
                val timeRemaining = widgetData.getString("time_remaining", "--:--")
                
                setTextViewText(R.id.next_prayer, "Bir sonraki: $nextPrayer")
                setTextViewText(R.id.time_remaining, timeRemaining)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
