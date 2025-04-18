package com.example.jugadwake

import android.app.KeyguardManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.IBinder
import android.util.Log
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.view.animation.Animation
import android.view.animation.ScaleAnimation
import android.widget.FrameLayout
import androidx.core.app.NotificationCompat
import androidx.core.app.ServiceCompat

class LockScreenOverlayService : Service() {
    companion object {
        private const val TAG = "LockScreenOverlayService"
        private const val NOTIFICATION_ID = 1002
        private const val CHANNEL_ID = "lock_screen_overlay_channel"

        // Flag to track if service is running
        var isRunning = false
    }

    private lateinit var windowManager: WindowManager
    private var overlayView: View? = null
    private var isOverlayShowing = false

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Lock Screen Overlay Service created")

        // Initialize window manager
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "Lock Screen Overlay Service started")

        // Create notification channel for Android O and above
        createNotificationChannel()

        // Start as a foreground service with notification
        val notification = createNotification()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_MANIFEST)
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }

        // Handle intent actions
        when (intent?.action) {
            "SHOW_OVERLAY" -> showOverlay()
            "HIDE_OVERLAY" -> hideOverlay()
            "TOGGLE_OVERLAY" -> {
                if (isOverlayShowing) hideOverlay() else showOverlay()
            }
        }

        isRunning = true

        // If service is killed, restart it
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "Lock Screen Overlay Service destroyed")

        // Remove overlay view if it exists
        hideOverlay()
        isRunning = false
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "Lock Screen Overlay"
            val descriptionText = "Shows animation on lock screen"
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
            .setContentTitle("Lock Screen Animation Active")
            .setContentText("Tap to open app")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setContentIntent(pendingIntent)
            .build()
    }

    private fun showOverlay() {
        if (overlayView != null) {
            // Already showing
            return
        }

        try {
            // Create overlay parameters
            val params = WindowManager.LayoutParams(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.MATCH_PARENT,
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
                } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    WindowManager.LayoutParams.TYPE_SYSTEM_ALERT
                } else {
                    WindowManager.LayoutParams.TYPE_SYSTEM_ERROR // This has highest priority, will show over lock screen
                },
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
                PixelFormat.TRANSLUCENT
            )

            params.gravity = Gravity.CENTER

            // Set window brightness to ensure visibility on lock screen
            params.screenBrightness = 1.0f

            // Inflate the overlay layout
            val inflater = getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater
            val view = inflater.inflate(R.layout.overlay_layout, null)
            overlayView = view

            // Create a simple animation to mimic the Flutter sphere animation
            val container = view.findViewById<FrameLayout>(R.id.overlay_container)
            val sphere = View(this)
            sphere.layoutParams = FrameLayout.LayoutParams(300, 300).apply {
                gravity = Gravity.CENTER
            }
            sphere.background = createCircleDrawable()
            container.addView(sphere)

            // Add a simple animation
            val scaleAnimation = ScaleAnimation(
                0.8f, 1.2f, 0.8f, 1.2f,
                Animation.RELATIVE_TO_SELF, 0.5f,
                Animation.RELATIVE_TO_SELF, 0.5f
            )
            scaleAnimation.duration = 1000
            scaleAnimation.repeatMode = Animation.REVERSE
            scaleAnimation.repeatCount = Animation.INFINITE
            sphere.startAnimation(scaleAnimation)

            // Add the view to the window manager
            windowManager.addView(overlayView, params)
            isOverlayShowing = true

            Log.d(TAG, "Overlay shown on lock screen")
        } catch (e: Exception) {
            Log.e(TAG, "Error showing overlay: ${e.message}")
        }
    }

    private fun hideOverlay() {
        try {
            if (overlayView != null) {
                windowManager.removeView(overlayView)
                overlayView = null
                isOverlayShowing = false
                Log.d(TAG, "Overlay hidden")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error hiding overlay: ${e.message}")
        }
    }

    // Method to be called from Flutter to update the overlay with animation data
    fun updateOverlayAnimation(isActive: Boolean) {
        if (isActive && !isOverlayShowing) {
            showOverlay()
        } else if (!isActive && isOverlayShowing) {
            hideOverlay()
        }
    }

    // Create a circle drawable for the sphere animation
    private fun createCircleDrawable(): GradientDrawable {
        return GradientDrawable().apply {
            shape = GradientDrawable.OVAL
            gradientType = GradientDrawable.RADIAL_GRADIENT
            colors = intArrayOf(
                Color.parseColor("#00BFA5"), // Cyan-teal
                Color.parseColor("#1A237E")  // Deep midnight blue
            )
            gradientRadius = 150f
            setGradientCenter(0.3f, 0.3f)
        }
    }
}
