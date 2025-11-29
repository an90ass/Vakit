package com.example.namaz

import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.vakit.widget/service"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startWidgetService" -> {
                    startWidgetUpdateService()
                    result.success(true)
                }
                "stopWidgetService" -> {
                    stopWidgetUpdateService()
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun startWidgetUpdateService() {
        // Start WorkManager for periodic updates
        WidgetUpdateWorker.schedule(this)
        
        // Also start foreground service for real-time updates
        val serviceIntent = Intent(this, WidgetUpdateService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(serviceIntent)
        } else {
            startService(serviceIntent)
        }
    }

    private fun stopWidgetUpdateService() {
        // Cancel WorkManager
        WidgetUpdateWorker.cancel(this)
        
        // Stop foreground service
        val serviceIntent = Intent(this, WidgetUpdateService::class.java)
        stopService(serviceIntent)
    }
}
