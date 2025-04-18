package com.example.jugadwake

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.Bundle
import android.os.IBinder
import android.os.PowerManager
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import android.util.Log
import androidx.core.app.NotificationCompat
import java.util.Locale

class WakeWordService : Service() {
    companion object {
        private const val TAG = "WakeWordService"
        private const val NOTIFICATION_ID = 1001
        private const val CHANNEL_ID = "wake_word_channel"
        private const val WAKE_PHRASE = "hey boy"

        // Intent actions for broadcasting
        const val ACTION_WAKE_WORD_DETECTED = "com.example.jugadwake.WAKE_WORD_DETECTED"
        const val ACTION_TRANSCRIPTION_UPDATE = "com.example.jugadwake.TRANSCRIPTION_UPDATE"
        const val EXTRA_TRANSCRIPTION = "transcription"

        // Service state
        var isRunning = false
    }

    private lateinit var speechRecognizer: SpeechRecognizer
    private lateinit var recognizerIntent: Intent
    private lateinit var wakeLock: PowerManager.WakeLock
    private var isListening = false

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Service created")

        // Create wake lock
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "jugadwake:WakeWordWakeLock"
        )

        // Initialize speech recognizer
        initializeSpeechRecognizer()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "Service started")

        // Create notification channel for Android O and above
        createNotificationChannel()

        // Start as a foreground service with notification
        val notification = createNotification()

        // Handle different Android versions
        if (Build.VERSION.SDK_INT >= 35) { // Android 15+
            // For Android 15, we need to specify both microphone and data sync
            try {
                startForeground(NOTIFICATION_ID, notification,
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE or
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
                Log.d(TAG, "Started foreground service with microphone and special use types on Android 15+")
            } catch (e: Exception) {
                Log.e(TAG, "Error starting foreground service on Android 15+: ${e.message}")
                // Fallback to just microphone
                try {
                    startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE)
                } catch (e2: Exception) {
                    Log.e(TAG, "Fallback also failed: ${e2.message}")
                    // Last resort
                    startForeground(NOTIFICATION_ID, notification)
                }
            }
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE)
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }

        // Acquire wake lock to keep CPU running (with timeout for Android 15+)
        if (!wakeLock.isHeld) {
            if (Build.VERSION.SDK_INT >= 35) {
                // On Android 15+, we need to use a timeout to avoid battery restrictions
                wakeLock.acquire(10 * 60 * 1000L) // 10 minutes

                // Schedule a handler to renew the wake lock periodically
                scheduleWakeLockRenewal()
            } else {
                // For older versions, we can use the indefinite wake lock
                wakeLock.acquire()
            }
        }

        // Start listening
        startListening()

        isRunning = true

        // If service is killed, restart it
        return START_STICKY
    }

    override fun onDestroy() {
        Log.d(TAG, "Service destroyed")

        // Stop listening
        stopListening()

        // Release wake lock
        if (wakeLock.isHeld) {
            wakeLock.release()
        }

        isRunning = false

        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "Wake Word Detection"
            val descriptionText = "Listens for wake word to activate the app"
            val importance = NotificationManager.IMPORTANCE_LOW
            val channel = NotificationChannel(CHANNEL_ID, name, importance).apply {
                description = descriptionText
            }

            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        // Create an intent to open the app when notification is tapped
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            packageManager.getLaunchIntentForPackage(packageName),
            PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Listening for 'Hey boy'")
            .setContentText("Tap to open app")
            .setSmallIcon(android.R.drawable.ic_btn_speak_now) // Use a default icon for now
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setContentIntent(pendingIntent)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC) // Show on lock screen
            .setOngoing(true) // Make it persistent
            .build()
    }

    private fun initializeSpeechRecognizer() {
        if (!SpeechRecognizer.isRecognitionAvailable(this)) {
            Log.e(TAG, "Speech recognition is not available on this device")
            return
        }

        speechRecognizer = SpeechRecognizer.createSpeechRecognizer(this)
        speechRecognizer.setRecognitionListener(createRecognitionListener())

        recognizerIntent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            putExtra(RecognizerIntent.EXTRA_LANGUAGE, Locale.getDefault())
            putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
            putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 3)
            putExtra(RecognizerIntent.EXTRA_CALLING_PACKAGE, packageName)
        }
    }

    private fun createRecognitionListener(): RecognitionListener {
        return object : RecognitionListener {
            override fun onReadyForSpeech(params: Bundle?) {
                Log.d(TAG, "Ready for speech")
                isListening = true
            }

            override fun onBeginningOfSpeech() {
                Log.d(TAG, "Beginning of speech")
            }

            override fun onRmsChanged(rmsdB: Float) {
                // Not used, but required to implement
            }

            override fun onBufferReceived(buffer: ByteArray?) {
                // Not used, but required to implement
            }

            override fun onEndOfSpeech() {
                Log.d(TAG, "End of speech")
                isListening = false
                // Restart listening after a short delay
                restartListeningWithDelay()
            }

            override fun onError(error: Int) {
                val errorMessage = when (error) {
                    SpeechRecognizer.ERROR_AUDIO -> "Audio recording error"
                    SpeechRecognizer.ERROR_CLIENT -> "Client side error"
                    SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS -> "Insufficient permissions"
                    SpeechRecognizer.ERROR_NETWORK -> "Network error"
                    SpeechRecognizer.ERROR_NETWORK_TIMEOUT -> "Network timeout"
                    SpeechRecognizer.ERROR_NO_MATCH -> "No match found"
                    SpeechRecognizer.ERROR_RECOGNIZER_BUSY -> "RecognitionService busy"
                    SpeechRecognizer.ERROR_SERVER -> "Server error"
                    SpeechRecognizer.ERROR_SPEECH_TIMEOUT -> "No speech input"
                    else -> "Unknown error"
                }
                Log.e(TAG, "Error: $errorMessage ($error)")

                isListening = false

                // Restart listening after errors (except permission errors)
                if (error != SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS) {
                    restartListeningWithDelay()
                }
            }

            override fun onResults(results: Bundle?) {
                processResults(results, false)
            }

            override fun onPartialResults(partialResults: Bundle?) {
                processResults(partialResults, true)
            }

            override fun onEvent(eventType: Int, params: Bundle?) {
                // Not used, but required to implement
            }

            private fun processResults(results: Bundle?, isPartial: Boolean) {
                results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)?.let { matches ->
                    if (matches.isNotEmpty()) {
                        val text = matches[0].lowercase()
                        Log.d(TAG, "Recognized${if (isPartial) " (partial)" else ""}: $text")

                        // Broadcast transcription for debugging
                        sendTranscriptionBroadcast(text)

                        // Check for wake phrase
                        if (text.contains(WAKE_PHRASE)) {
                            Log.d(TAG, "Wake phrase detected!")
                            wakeUpScreen()
                            sendWakeWordBroadcast()
                        }
                    }
                }
            }
        }
    }

    private fun startListening() {
        if (!isListening) {
            try {
                speechRecognizer.startListening(recognizerIntent)
                Log.d(TAG, "Started listening")
            } catch (e: Exception) {
                Log.e(TAG, "Error starting speech recognition: ${e.message}")
                restartListeningWithDelay()
            }
        }
    }

    private fun stopListening() {
        if (isListening) {
            try {
                speechRecognizer.stopListening()
                Log.d(TAG, "Stopped listening")
            } catch (e: Exception) {
                Log.e(TAG, "Error stopping speech recognition: ${e.message}")
            }
            isListening = false
        }
    }

    private fun restartListeningWithDelay() {
        android.os.Handler().postDelayed({
            if (isRunning) {
                startListening()
            }
        }, 300) // Short delay to avoid overwhelming the recognizer
    }

    private fun wakeUpScreen() {
        try {
            val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
            val wakeLock = powerManager.newWakeLock(
                PowerManager.FULL_WAKE_LOCK or
                PowerManager.ACQUIRE_CAUSES_WAKEUP or
                PowerManager.ON_AFTER_RELEASE,
                "jugadwake:WakeUpScreenLock"
            )

            // Acquire and release to turn screen on
            wakeLock.acquire(10000) // 10 seconds

            Log.d(TAG, "Screen wake lock acquired")
        } catch (e: Exception) {
            Log.e(TAG, "Error waking up screen: ${e.message}")
        }
    }

    private fun sendWakeWordBroadcast() {
        val intent = Intent(ACTION_WAKE_WORD_DETECTED)
        sendBroadcast(intent)
    }

    private fun sendTranscriptionBroadcast(text: String) {
        val intent = Intent(ACTION_TRANSCRIPTION_UPDATE).apply {
            putExtra(EXTRA_TRANSCRIPTION, text)
        }
        sendBroadcast(intent)
    }

    // Schedule periodic wake lock renewal to keep the service running on Android 15+
    private fun scheduleWakeLockRenewal() {
        val handler = android.os.Handler(android.os.Looper.getMainLooper())
        val renewalRunnable = object : Runnable {
            override fun run() {
                if (isRunning) {
                    try {
                        // Release the old wake lock if it's held
                        if (wakeLock.isHeld) {
                            wakeLock.release()
                        }

                        // Acquire a new wake lock
                        wakeLock.acquire(10 * 60 * 1000L) // 10 minutes
                        Log.d(TAG, "Wake lock renewed")

                        // Schedule the next renewal
                        handler.postDelayed(this, 9 * 60 * 1000L) // 9 minutes (before expiration)
                    } catch (e: Exception) {
                        Log.e(TAG, "Error renewing wake lock: ${e.message}")
                    }
                }
            }
        }

        // Start the periodic renewal
        handler.postDelayed(renewalRunnable, 9 * 60 * 1000L) // 9 minutes
    }
}
