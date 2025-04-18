package com.example.jugadwake

import android.animation.ValueAnimator
import android.app.Activity
import android.app.KeyguardManager
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.view.View
import android.view.WindowManager
import android.view.WindowManager.LayoutParams
import android.view.animation.AccelerateDecelerateInterpolator
import android.widget.Toast

class JarvisLockActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Special handling for Android 15 (API 35) and above
        if (Build.VERSION.SDK_INT >= 35) { // Android 15+
            // For Android 15, we need to use a different approach
            // Make sure the window is shown over the lock screen
            window.addFlags(
                LayoutParams.FLAG_KEEP_SCREEN_ON or
                LayoutParams.FLAG_DISMISS_KEYGUARD or
                LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                LayoutParams.FLAG_TURN_SCREEN_ON or
                LayoutParams.FLAG_ALLOW_LOCK_WHILE_SCREEN_ON
            )

            // Set window attributes to make it show on top
            window.attributes = window.attributes.apply {
                screenBrightness = 1.0f // Full brightness
                // Set the window type to be shown over the lock screen
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    type = LayoutParams.TYPE_APPLICATION_OVERLAY
                } else {
                    type = LayoutParams.TYPE_SYSTEM_ALERT
                }
            }
        }
        // For Android 14 (API 34), check for full-screen intent permission
        else if (Build.VERSION.SDK_INT == Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            if (!notificationManager.canUseFullScreenIntent()) {
                // We don't have permission to show full-screen intent
                Toast.makeText(this, "Please enable full-screen notifications for this app in Settings", Toast.LENGTH_LONG).show()

                // Prompt the user to enable the permission
                try {
                    val intent = Intent(Settings.ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT)
                    intent.putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                    startActivity(intent)
                } catch (e: Exception) {
                    // Fallback if the settings page can't be opened
                }

                // Close this activity since we can't show it properly
                finish()
                return
            }

            // Set flags to show over lock screen and turn screen on
            setShowWhenLocked(true)
            setTurnScreenOn(true)

            // Dismiss keyguard
            val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
            keyguardManager.requestDismissKeyguard(this, null)
        }
        // For Android 13 (API 33) and below
        else {
            // Set flags to show over lock screen and turn screen on
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
                setShowWhenLocked(true)
                setTurnScreenOn(true)

                // Dismiss keyguard
                val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
                keyguardManager.requestDismissKeyguard(this, null)
            } else {
                // For older versions
                window.addFlags(
                    LayoutParams.FLAG_DISMISS_KEYGUARD or
                    LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    LayoutParams.FLAG_TURN_SCREEN_ON
                )
            }
        }

        // Set a custom view with animation instead of using Lottie
        setContentView(JarvisAnimationView(this))

        // Auto-dismiss after animation (e.g., 5 seconds)
        Handler(Looper.getMainLooper()).postDelayed({
            if (!isFinishing) {
                finish()
            }
        }, 5000) // 5 seconds
    }

    // Custom view for Jarvis-like animation
    inner class JarvisAnimationView(context: Context) : View(context) {
        private val paint = Paint().apply {
            color = Color.CYAN
            style = Paint.Style.STROKE
            strokeWidth = 10f
            isAntiAlias = true
        }

        private var radius = 100f
        private var alpha = 255
        private var rotation = 0f

        init {
            // Set transparent background
            setBackgroundColor(Color.TRANSPARENT)

            // Animate radius
            ValueAnimator.ofFloat(100f, 300f).apply {
                duration = 2000
                repeatCount = ValueAnimator.INFINITE
                repeatMode = ValueAnimator.REVERSE
                interpolator = AccelerateDecelerateInterpolator()
                addUpdateListener { animation ->
                    radius = animation.animatedValue as Float
                    invalidate()
                }
                start()
            }

            // Animate rotation
            ValueAnimator.ofFloat(0f, 360f).apply {
                duration = 3000
                repeatCount = ValueAnimator.INFINITE
                interpolator = AccelerateDecelerateInterpolator()
                addUpdateListener { animation ->
                    rotation = animation.animatedValue as Float
                    invalidate()
                }
                start()
            }
        }

        override fun onDraw(canvas: Canvas) {
            super.onDraw(canvas)

            val centerX = width / 2f
            val centerY = height / 2f

            // Save the canvas state
            canvas.save()

            // Rotate the canvas
            canvas.rotate(rotation, centerX, centerY)

            // Draw outer circle
            paint.alpha = 200
            canvas.drawCircle(centerX, centerY, radius, paint)

            // Draw inner circle
            paint.alpha = 150
            canvas.drawCircle(centerX, centerY, radius * 0.7f, paint)

            // Draw inner-most circle
            paint.alpha = 100
            canvas.drawCircle(centerX, centerY, radius * 0.4f, paint)

            // Restore the canvas state
            canvas.restore()
        }
    }
}
