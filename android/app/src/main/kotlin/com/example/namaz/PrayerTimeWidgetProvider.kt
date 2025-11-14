package com.example.namaz

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.graphics.*
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import java.text.SimpleDateFormat
import java.util.*
import kotlin.math.*

class PrayerTimeWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        appWidgetIds.forEach { widgetId ->
            val widgetData = HomeWidgetPlugin.getData(context)
            val nextPrayer = widgetData.getString("next_prayer", "Loading...")
            val timeRemaining = widgetData.getString("time_remaining", "--:--")
            val nextPrayerLabel = widgetData.getString("next_prayer_label", "Next prayer")
            val remainingLabel = widgetData.getString("remaining_label", "remaining")
            
            // Namaz vakitleri
            val fajr = widgetData.getString("fajr", "05:30") ?: "05:30"
            val sunrise = widgetData.getString("sunrise", "07:00") ?: "07:00"
            val dhuhr = widgetData.getString("dhuhr", "12:30") ?: "12:30"
            val asr = widgetData.getString("asr", "15:30") ?: "15:30"
            val maghrib = widgetData.getString("maghrib", "18:00") ?: "18:00"
            val isha = widgetData.getString("isha", "19:30") ?: "19:30"
            
            // Çember görselini oluştur
            val circleBitmap = createDynamicPrayerCircle(
                context,
                nextPrayer ?: "Loading...",
                timeRemaining ?: "--:--",
                nextPrayerLabel ?: "Next prayer",
                remainingLabel ?: "remaining",
                fajr, sunrise, dhuhr, asr, maghrib, isha
            )
            
            // Widget'a tıklayınca uygulamayı aç
            val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            val pendingIntent = android.app.PendingIntent.getActivity(
                context,
                0,
                intent,
                android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
            )
            
            val views = RemoteViews(context.packageName, R.layout.prayer_time_widget).apply {
                setImageViewBitmap(R.id.prayer_circle_image, circleBitmap)
                setOnClickPendingIntent(R.id.prayer_circle_image, pendingIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
    
    private fun createDynamicPrayerCircle(
        context: Context,
        nextPrayer: String,
        timeRemaining: String,
        nextPrayerLabel: String,
        remainingLabel: String,
        fajr: String,
        sunrise: String,
        dhuhr: String,
        asr: String,
        maghrib: String,
        isha: String
    ): Bitmap {
        val size = 800 // Yüksek çözünürlük
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        
        val centerX = size / 2f
        val centerY = size / 2f
        val outerRadius = size / 2f - 20f // Minimum padding
        val innerRadius = outerRadius * 0.95f
        
        // Tamamen şeffaf arka plan
        canvas.drawColor(Color.TRANSPARENT)
        
        // Çember maskesi oluştur (sadece çember içini çiz)
        val clipPath = Path().apply {
            addCircle(centerX, centerY, outerRadius, Path.Direction.CW)
        }
        canvas.clipPath(clipPath)
        
        // Dış beyaz çember
        val outerCirclePaint = Paint().apply {
            color = Color.WHITE
            style = Paint.Style.FILL
            isAntiAlias = true
        }
        canvas.drawCircle(centerX, centerY, outerRadius, outerCirclePaint)
        
        // Namaz vakitlerini hesapla (Maghrib'den başlayarak)
        val prayerNames = listOf("Fajr", "Sunrise", "Dhuhr", "Asr", "Maghrib", "Isha")
        val prayerTimesStr = listOf(fajr, sunrise, dhuhr, asr, maghrib, isha)
        val angles = calculateAngles(prayerTimesStr, maghrib)
        
        // Gradient renkler (her namaz için 5 renk tonu)
        val gradientColors = mapOf(
            "Isha" to listOf("#3E2723", "#5C4033", "#654321", "#8B4513", "#A0522D"),
            "Fajr" to listOf("#85929E", "#5D6D7E", "#2C3E50", "#34495E", "#1F2A37"),
            "Sunrise" to listOf("#F6DDCC", "#FDEBD0", "#F9E79F", "#F4D03F", "#F0E68C"),
            "Dhuhr" to listOf("#98d038", "#b4f544", "#b4f544", "#BDB76B", "#FFD700"),
            "Asr" to listOf("#FFC0CB", "#FF7C41", "#FC7E4B", "#F76328", "#F6510F"),
            "Maghrib" to listOf("#FFDAB9", "#F4A460", "#D2691E", "#A0522D", "#654321")
        )
        
        // Her namaz için gradient segment çiz
        for (i in prayerNames.indices) {
            val startAngle = if (i == 0) angles.last() else angles[i - 1]
            val endAngle = angles[i]
            val sweepAngle = calculateSweep(startAngle, endAngle)
            
            val colors = gradientColors[prayerNames[i]]?.map { Color.parseColor(it) } 
                ?: listOf(Color.GRAY)
            
            drawGradientSegment(canvas, centerX, centerY, innerRadius, startAngle, sweepAngle, colors)
        }
        
        // Vakit ayırım noktaları (her vaktin kendi rengiyle)
        val prayerColors = mapOf(
            "Maghrib" to Color.parseColor("#6F4C3E"),
            "Isha" to Color.parseColor("#295e9c"),
            "Fajr" to Color.parseColor("#A3C1DA"),
            "Sunrise" to Color.parseColor("#9CB86B"),
            "Dhuhr" to Color.parseColor("#FFD700"),
            "Asr" to Color.parseColor("#FFA07A")
        )
        
        for (i in angles.indices) {
            val sx = centerX + innerRadius * cos(Math.toRadians(angles[i].toDouble())).toFloat()
            val sy = centerY + innerRadius * sin(Math.toRadians(angles[i].toDouble())).toFloat()
            
            val separatorPaint = Paint().apply {
                color = prayerColors[prayerNames[i]] ?: Color.GRAY
                style = Paint.Style.FILL
                isAntiAlias = true
            }
            canvas.drawCircle(sx, sy, 10f, separatorPaint)
        }
        
        // Şu anki zamanı hesapla
        val currentAngle = calculateCurrentTimeAngle(maghrib)
        
        // Şu anki zaman çizgisi (kırmızı)
        val lineEndX = centerX + innerRadius * cos(Math.toRadians(currentAngle.toDouble())).toFloat()
        val lineEndY = centerY + innerRadius * sin(Math.toRadians(currentAngle.toDouble())).toFloat()
        
        val linePaint = Paint().apply {
            color = Color.RED
            strokeWidth = 6f
            isAntiAlias = true
        }
        canvas.drawLine(centerX, centerY, lineEndX, lineEndY, linePaint)
        
        // Kırmızı nokta
        val dotPaint = Paint().apply {
            color = Color.RED
            style = Paint.Style.FILL
            isAntiAlias = true
        }
        canvas.drawCircle(lineEndX, lineEndY, 18f, dotPaint)
        
        // Kerahat işaretleri (siyah noktalar)
        val kerahatPaint = Paint().apply {
            color = Color.BLACK
            style = Paint.Style.FILL
            isAntiAlias = true
        }
        val kerahatLinePaint = Paint().apply {
            color = Color.BLACK
            strokeWidth = 4f
            isAntiAlias = true
        }
        
        // Kerahat vakitleri: Güneş+45dk, Öğle-45dk, Akşam-45dk
        val kerahatAngles = listOf(
            calculateAngleWithOffset(sunrise, maghrib, 45),
            calculateAngleWithOffset(dhuhr, maghrib, -45),
            calculateAngleWithOffset(maghrib, maghrib, -45)
        )
        
        for (kAngle in kerahatAngles) {
            val kx = centerX + innerRadius * cos(Math.toRadians(kAngle.toDouble())).toFloat()
            val ky = centerY + innerRadius * sin(Math.toRadians(kAngle.toDouble())).toFloat()
            canvas.drawLine(centerX, centerY, kx, ky, kerahatLinePaint)
            canvas.drawCircle(kx, ky, 12f, kerahatPaint)
            
            // "K" harfi
            val textPaint = Paint().apply {
                color = Color.WHITE
                textSize = 16f
                textAlign = Paint.Align.CENTER
                typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
                isAntiAlias = true
            }
            canvas.drawText("K", kx, ky + 6f, textPaint)
        }
        
        // Ortada bilgi metinleri
        drawCenterText(canvas, centerX, centerY, nextPrayerLabel, nextPrayer, timeRemaining, remainingLabel)
        
        return bitmap
    }
    
    private fun calculateAngles(prayerTimes: List<String>, maghribTime: String): List<Float> {
        val maghribMinutes = timeToMinutes(maghribTime)
        val totalMinutes = 24 * 60
        
        return prayerTimes.map { time ->
            val minutes = timeToMinutes(time)
            val diff = if (minutes >= maghribMinutes) {
                minutes - maghribMinutes
            } else {
                totalMinutes + minutes - maghribMinutes
            }
            (diff.toFloat() / totalMinutes) * 360f - 90f // -90 to start from top
        }
    }
    
    private fun calculateCurrentTimeAngle(maghribTime: String): Float {
        val now = Calendar.getInstance()
        val currentMinutes = now.get(Calendar.HOUR_OF_DAY) * 60 + now.get(Calendar.MINUTE)
        val maghribMinutes = timeToMinutes(maghribTime)
        val totalMinutes = 24 * 60
        
        val diff = if (currentMinutes >= maghribMinutes) {
            currentMinutes - maghribMinutes
        } else {
            totalMinutes + currentMinutes - maghribMinutes
        }
        
        return (diff.toFloat() / totalMinutes) * 360f - 90f
    }
    
    private fun timeToMinutes(time: String): Int {
        val parts = time.split(":")
        return parts[0].toInt() * 60 + parts[1].toInt()
    }
    
    private fun calculateAngleWithOffset(time: String, maghribTime: String, offsetMinutes: Int): Float {
        val timeMinutes = timeToMinutes(time) + offsetMinutes
        val maghribMinutes = timeToMinutes(maghribTime)
        val totalMinutes = 24 * 60
        
        val diff = if (timeMinutes >= maghribMinutes) {
            timeMinutes - maghribMinutes
        } else {
            totalMinutes + timeMinutes - maghribMinutes
        }
        
        return (diff.toFloat() / totalMinutes) * 360f - 90f
    }
    
    private fun calculateSweep(start: Float, end: Float): Float {
        var sweep = end - start
        if (sweep < 0) sweep += 360f
        return sweep
    }
    
    private fun drawGradientSegment(
        canvas: Canvas,
        centerX: Float,
        centerY: Float,
        radius: Float,
        startAngle: Float,
        sweepAngle: Float,
        colors: List<Int>
    ) {
        val rectF = RectF(
            centerX - radius,
            centerY - radius,
            centerX + radius,
            centerY + radius
        )
        
        val shader = RadialGradient(
            centerX, centerY, radius,
            colors.toIntArray(),
            null,
            Shader.TileMode.CLAMP
        )
        
        val paint = Paint().apply {
            this.shader = shader
            isAntiAlias = true
            style = Paint.Style.FILL
        }
        
        canvas.drawArc(rectF, startAngle, sweepAngle, true, paint)
    }
    
    private fun drawCenterText(
        canvas: Canvas,
        centerX: Float,
        centerY: Float,
        nextPrayerLabel: String,
        nextPrayer: String,
        timeRemaining: String,
        remainingLabel: String
    ) {
        val labelPaint = Paint().apply {
            color = Color.BLACK
            textSize = 28f
            textAlign = Paint.Align.CENTER
            isAntiAlias = true
        }
        
        val prayerPaint = Paint().apply {
            color = Color.BLACK
            textSize = 48f
            textAlign = Paint.Align.CENTER
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            isAntiAlias = true
        }
        
        val timePaint = Paint().apply {
            color = Color.BLACK
            textSize = 72f
            textAlign = Paint.Align.CENTER
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            isAntiAlias = true
        }
        
        val remainingPaint = Paint().apply {
            color = Color.BLACK
            textSize = 32f
            textAlign = Paint.Align.CENTER
            isAntiAlias = true
        }
        
        // Metinleri çiz
        canvas.drawText(nextPrayerLabel, centerX, centerY - 80, labelPaint)
        canvas.drawText(nextPrayer, centerX, centerY - 20, prayerPaint)
        canvas.drawText(timeRemaining, centerX, centerY + 60, timePaint)
        canvas.drawText(remainingLabel, centerX, centerY + 100, remainingPaint)
    }
}
