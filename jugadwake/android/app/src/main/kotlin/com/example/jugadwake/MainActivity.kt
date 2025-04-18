package com.example.jugadwake

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.SharedPreferences
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val TAG = "MainActivity"
        private const val METHOD_CHANNEL = "com.example.jugadwake/wake_word"
        private const val EVENT_CHANNEL = "com.example.jugadwake/transcription"
        private const val PREFS_NAME = "JugadWakePrefs"
        private const val KEY_SERVICE_ENABLED = "service_enabled"
    }

    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var transcriptionReceiver: BroadcastReceiver? = null
    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Set up method channel
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "startWakeWordService" -> {
                    startWakeWordService(result)
                }
                "stopWakeWordService" -> {
                    stopWakeWordService(result)
                }
                "isWakeWordServiceRunning" -> {
                    result.success(WakeWordService.isRunning)
                }
                "requestBatteryOptimizationDisable" -> {
                    requestBatteryOptimizationDisable(result)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // Set up event channel for transcription updates
        eventChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
                registerTranscriptionReceiver()
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
                unregisterTranscriptionReceiver()
            }
        })
    }

    private fun startWakeWordService(result: MethodChannel.Result) {
        try {
            if (!WakeWordService.isRunning) {
                val serviceIntent = Intent(this, WakeWordService::class.java)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    startForegroundService(serviceIntent)
                } else {
                    startService(serviceIntent)
                }

                // Save service state
                val prefs: SharedPreferences = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                prefs.edit().putBoolean(KEY_SERVICE_ENABLED, true).apply()

                result.success(true)
            } else {
                result.success(true) // Already running
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error starting service: ${e.message}")
            result.error("SERVICE_START_ERROR", e.message, null)
        }
    }

    private fun stopWakeWordService(result: MethodChannel.Result) {
        try {
            if (WakeWordService.isRunning) {
                val serviceIntent = Intent(this, WakeWordService::class.java)
                stopService(serviceIntent)

                // Save service state
                val prefs: SharedPreferences = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                prefs.edit().putBoolean(KEY_SERVICE_ENABLED, false).apply()
            }
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping service: ${e.message}")
            result.error("SERVICE_STOP_ERROR", e.message, null)
        }
    }

    private fun requestBatteryOptimizationDisable(result: MethodChannel.Result) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val intent = Intent()
                val packageName = packageName
                val pm = getSystemService(Context.POWER_SERVICE) as PowerManager

                if (!pm.isIgnoringBatteryOptimizations(packageName)) {
                    intent.action = Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
                    intent.data = Uri.parse("package:$packageName")
                    startActivity(intent)
                    result.success(true)
                } else {
                    // Already ignoring battery optimizations
                    result.success(true)
                }
            } else {
                // Not needed on older Android versions
                result.success(true)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error requesting battery optimization disable: ${e.message}")
            result.error("BATTERY_OPT_ERROR", e.message, null)
        }
    }

    private fun registerTranscriptionReceiver() {
        if (transcriptionReceiver == null) {
            val intentFilter = IntentFilter().apply {
                addAction(WakeWordService.ACTION_TRANSCRIPTION_UPDATE)
                addAction(WakeWordService.ACTION_WAKE_WORD_DETECTED)
            }

            transcriptionReceiver = object : BroadcastReceiver() {
                override fun onReceive(context: Context, intent: Intent) {
                    when (intent.action) {
                        WakeWordService.ACTION_TRANSCRIPTION_UPDATE -> {
                            val text = intent.getStringExtra(WakeWordService.EXTRA_TRANSCRIPTION) ?: ""
                            eventSink?.success(mapOf("type" to "transcription", "text" to text))
                        }
                        WakeWordService.ACTION_WAKE_WORD_DETECTED -> {
                            eventSink?.success(mapOf("type" to "wake_word_detected"))
                        }
                    }
                }
            }

            registerReceiver(transcriptionReceiver, intentFilter)
        }
    }

    private fun unregisterTranscriptionReceiver() {
        transcriptionReceiver?.let {
            try {
                unregisterReceiver(it)
            } catch (e: Exception) {
                Log.e(TAG, "Error unregistering receiver: ${e.message}")
            }
            transcriptionReceiver = null
        }
    }

    override fun onDestroy() {
        unregisterTranscriptionReceiver()
        super.onDestroy()
    }
}