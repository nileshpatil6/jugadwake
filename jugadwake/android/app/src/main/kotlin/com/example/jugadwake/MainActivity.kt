package com.example.jugadwake

import android.app.KeyguardManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.provider.Settings
import android.util.Log
import android.widget.Toast
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
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
        private const val KEY_LOCK_SCREEN_OVERLAY_ENABLED = "lock_screen_overlay_enabled"
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
                "startLockScreenOverlay" -> {
                    startLockScreenOverlay(result)
                }
                "stopLockScreenOverlay" -> {
                    stopLockScreenOverlay(result)
                }
                "isLockScreenOverlayRunning" -> {
                    result.success(LockScreenOverlayService.isRunning)
                }
                "requestOverlayPermission" -> {
                    requestOverlayPermission(result)
                }
                "showLockScreenAnimation" -> {
                    showJarvisLockScreenAnimation(result)
                }
                "requestNotificationPermission" -> {
                    requestNotificationPermission(result)
                }
                "showPersistentNotification" -> {
                    showPersistentNotification(result)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // Check if we need to start the service from boot
        intent?.let { intent ->
            if (intent.getBooleanExtra("START_SERVICE_ON_BOOT", false)) {
                Log.d(TAG, "Starting service from boot intent")
                // Start the wake word service
                Handler(Looper.getMainLooper()).postDelayed({
                    try {
                        startWakeWordService(object : MethodChannel.Result {
                            override fun success(result: Any?) {
                                Log.d(TAG, "Service started successfully from boot")
                                // Also show the persistent notification
                                showPersistentNotification(object : MethodChannel.Result {
                                    override fun success(result: Any?) {
                                        Log.d(TAG, "Persistent notification shown from boot")
                                    }
                                    override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                                        Log.e(TAG, "Error showing notification: $errorMessage")
                                    }
                                    override fun notImplemented() {}
                                })
                            }
                            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                                Log.e(TAG, "Error starting service from boot: $errorMessage")
                            }
                            override fun notImplemented() {}
                        })
                    } catch (e: Exception) {
                        Log.e(TAG, "Exception starting service from boot: ${e.message}")
                    }
                }, 2000) // Delay to ensure the activity is fully initialized
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

    private fun startLockScreenOverlay(result: MethodChannel.Result) {
        try {
            if (!LockScreenOverlayService.isRunning) {
                // Check for overlay permission
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
                    // Request permission
                    val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                        Uri.parse("package:$packageName"))
                    startActivity(intent)
                    result.success(false) // Permission needed
                    return
                }

                // Acquire wake lock to ensure device stays awake during overlay display
                val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
                val wakeLock = powerManager.newWakeLock(
                    PowerManager.FULL_WAKE_LOCK or
                    PowerManager.ACQUIRE_CAUSES_WAKEUP or
                    PowerManager.ON_AFTER_RELEASE, "jugadwake:LockScreenWakeLock")
                wakeLock.acquire(10000) // 10 seconds

                // Disable keyguard if needed
                val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
                if (keyguardManager.isKeyguardLocked) {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        keyguardManager.requestDismissKeyguard(this, null)
                    }
                }

                val serviceIntent = Intent(this, LockScreenOverlayService::class.java)
                serviceIntent.action = "SHOW_OVERLAY"
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    startForegroundService(serviceIntent)
                } else {
                    startService(serviceIntent)
                }

                // Save service state
                val prefs: SharedPreferences = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                prefs.edit().putBoolean(KEY_LOCK_SCREEN_OVERLAY_ENABLED, true).apply()

                result.success(true)
            } else {
                // Service already running, just show the overlay
                val serviceIntent = Intent(this, LockScreenOverlayService::class.java)
                serviceIntent.action = "SHOW_OVERLAY"
                startService(serviceIntent)
                result.success(true)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error starting lock screen overlay: ${e.message}")
            result.error("OVERLAY_START_ERROR", e.message, null)
        }
    }

    private fun stopLockScreenOverlay(result: MethodChannel.Result) {
        try {
            if (LockScreenOverlayService.isRunning) {
                // First hide the overlay
                val hideIntent = Intent(this, LockScreenOverlayService::class.java)
                hideIntent.action = "HIDE_OVERLAY"
                startService(hideIntent)

                // Then stop the service
                val serviceIntent = Intent(this, LockScreenOverlayService::class.java)
                stopService(serviceIntent)

                // Save service state
                val prefs: SharedPreferences = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                prefs.edit().putBoolean(KEY_LOCK_SCREEN_OVERLAY_ENABLED, false).apply()
            }
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping lock screen overlay: ${e.message}")
            result.error("OVERLAY_STOP_ERROR", e.message, null)
        }
    }

    private fun requestOverlayPermission(result: MethodChannel.Result) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                if (!Settings.canDrawOverlays(this)) {
                    // Request permission
                    val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                        Uri.parse("package:$packageName"))
                    startActivity(intent)
                    result.success(false) // Permission needed
                } else {
                    // Already have permission
                    result.success(true)
                }
            } else {
                // Permission not needed on older Android versions
                result.success(true)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error requesting overlay permission: ${e.message}")
            result.error("OVERLAY_PERMISSION_ERROR", e.message, null)
        }
    }

    private fun requestNotificationPermission(result: MethodChannel.Result) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                // For Android 13+ we need to request the POST_NOTIFICATIONS permission
                if (ContextCompat.checkSelfPermission(this, android.Manifest.permission.POST_NOTIFICATIONS)
                    != PackageManager.PERMISSION_GRANTED) {

                    // Define a request code for the permission request
                    val REQUEST_NOTIFICATION_PERMISSION = 123

                    // Request the permission
                    ActivityCompat.requestPermissions(
                        this,
                        arrayOf(android.Manifest.permission.POST_NOTIFICATIONS),
                        REQUEST_NOTIFICATION_PERMISSION
                    )

                    // Return false to indicate permission is being requested
                    result.success(false)
                } else {
                    // Permission already granted
                    result.success(true)
                }
            } else {
                // For Android 12 and below, notification permission is granted by default
                result.success(true)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error requesting notification permission: ${e.message}")
            result.error("NOTIFICATION_PERMISSION_ERROR", e.message, null)
        }
    }

    private fun showLockScreenAnimation(result: MethodChannel.Result) {
        try {
            // Create a high-priority notification with full-screen intent
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            // Create notification channel for Android O and above
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel(
                    "lock_screen_animation_channel",
                    "Lock Screen Animation",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "Shows animation on lock screen"
                    lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                    setShowBadge(true)
                }
                notificationManager.createNotificationChannel(channel)
            }

            // Create an intent to launch the lock screen animation activity
            val fullScreenIntent = Intent(this, LockScreenAnimationActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }

            val fullScreenPendingIntent = PendingIntent.getActivity(
                this,
                0,
                fullScreenIntent,
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            )

            // Create the notification
            val notification = NotificationCompat.Builder(this, "lock_screen_animation_channel")
                .setSmallIcon(android.R.drawable.ic_dialog_info)
                .setContentTitle("Wake Word Detected")
                .setContentText("Hey boy")
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setCategory(NotificationCompat.CATEGORY_CALL)
                .setFullScreenIntent(fullScreenPendingIntent, true)
                .setAutoCancel(true)
                .build()

            // Show the notification
            notificationManager.notify(1001, notification)

            // Also directly start the activity to ensure it shows
            startActivity(fullScreenIntent)

            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Error showing lock screen animation: ${e.message}")
            result.error("ANIMATION_ERROR", e.message, null)
        }
    }

    private fun showJarvisLockScreenAnimation(result: MethodChannel.Result) {
        try {
            // Create a high-priority notification with full-screen intent
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            // Create notification channel for Android O and above
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel(
                    "jarvis_lock_screen_channel",
                    "Jarvis Lock Screen Animation",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "Shows Jarvis animation on lock screen"
                    lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                    setShowBadge(true)
                }
                notificationManager.createNotificationChannel(channel)
            }

            // Special handling for Android 15 (API 35)
            if (Build.VERSION.SDK_INT >= 35) { // Android 15+
                // For Android 15, we need to use a simpler approach
                // Just start the activity directly
                val intent = Intent(this, JarvisLockActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                           Intent.FLAG_ACTIVITY_CLEAR_TOP or
                           Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS
                    // Add extra to indicate this is from a notification
                    putExtra("FROM_NOTIFICATION", true)
                }

                try {
                    startActivity(intent)
                    result.success(true)
                } catch (e: Exception) {
                    Log.e(TAG, "Failed to start activity on Android 15: ${e.message}")
                    result.error("JARVIS_ANIMATION_ERROR", e.message, null)
                }
                return
            }

            // For Android 14 and below, use the notification approach
            // Create an intent to launch the Jarvis lock screen activity
            val fullScreenIntent = Intent(this, JarvisLockActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                // Add extra to indicate this is from a notification
                putExtra("FROM_NOTIFICATION", true)
            }

            val fullScreenPendingIntent = PendingIntent.getActivity(
                this,
                0,
                fullScreenIntent,
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            )

            // Create the notification
            val notificationBuilder = NotificationCompat.Builder(this, "jarvis_lock_screen_channel")
                .setSmallIcon(android.R.drawable.ic_dialog_info)
                .setContentTitle("Wake Word Detected")
                .setContentText("Hey boy")
                .setPriority(NotificationCompat.PRIORITY_MAX) // Use MAX priority
                .setCategory(NotificationCompat.CATEGORY_CALL) // Use CALL category for better compatibility
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .setAutoCancel(true)

            // Check if we can use full-screen intent on Android 14
            if (Build.VERSION.SDK_INT == Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                // Android 14
                if (notificationManager.canUseFullScreenIntent()) {
                    // We have permission to use full-screen intent
                    notificationBuilder.setFullScreenIntent(fullScreenPendingIntent, true)

                    // Show the notification
                    notificationManager.notify(1003, notificationBuilder.build())

                    // Also directly start the activity to ensure it shows
                    startActivity(fullScreenIntent)
                } else {
                    // We don't have permission, just set the content intent
                    notificationBuilder.setContentIntent(fullScreenPendingIntent)

                    // Show the notification
                    notificationManager.notify(1003, notificationBuilder.build())

                    // Optionally, show a toast to inform the user
                    Toast.makeText(this, "Please enable full-screen notifications for this app in Settings", Toast.LENGTH_LONG).show()

                    // Prompt the user to enable the permission
                    try {
                        val intent = Intent(Settings.ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT)
                        intent.putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                        startActivity(intent)
                    } catch (e: Exception) {
                        Log.e(TAG, "Failed to open settings: ${e.message}")
                    }
                }
            } else {
                // For Android 13 and below, use full-screen intent as before
                notificationBuilder.setFullScreenIntent(fullScreenPendingIntent, true)

                // Show the notification
                notificationManager.notify(1003, notificationBuilder.build())

                // Also directly start the activity to ensure it shows
                startActivity(fullScreenIntent)
            }

            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Error showing Jarvis lock screen animation: ${e.message}")
            result.error("JARVIS_ANIMATION_ERROR", e.message, null)
        }
    }

    private fun showPersistentNotification(result: MethodChannel.Result) {
        try {
            // Use the NotificationHelper to show a persistent notification
            NotificationHelper.showPersistentNotification(this)
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Error showing persistent notification: ${e.message}")
            result.error("NOTIFICATION_ERROR", e.message, null)
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

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                registerReceiver(transcriptionReceiver, intentFilter, Context.RECEIVER_NOT_EXPORTED)
            } else {
                registerReceiver(transcriptionReceiver, intentFilter)
            }
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