package com.example.jugadwake

import android.app.Activity
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.View
import android.view.WindowManager
import android.view.animation.Animation
import android.view.animation.ScaleAnimation
import android.view.animation.AlphaAnimation
import android.view.animation.AnimationSet
import android.widget.FrameLayout
import android.widget.TextView
import android.graphics.drawable.GradientDrawable
import android.graphics.Color
import android.graphics.Typeface
import android.view.Gravity
import android.view.WindowInsets
import android.view.WindowInsetsController
import android.view.WindowManager.LayoutParams
import android.util.TypedValue

class LockScreenAnimationActivity : Activity() {

    private val handler = Handler(Looper.getMainLooper())
    private val displayDuration = 5000L // 5 seconds

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Set up window flags to show over lock screen
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            )
        }

        // Make the activity fullscreen
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.setDecorFitsSystemWindows(false)
            window.insetsController?.let {
                it.hide(WindowInsets.Type.statusBars() or WindowInsets.Type.navigationBars())
                it.systemBarsBehavior = WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
            }
        } else {
            @Suppress("DEPRECATION")
            window.decorView.systemUiVisibility = (
                View.SYSTEM_UI_FLAG_FULLSCREEN or
                View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or
                View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY or
                View.SYSTEM_UI_FLAG_LAYOUT_STABLE or
                View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or
                View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
            )
        }

        // Set a transparent background with a semi-transparent black overlay
        window.setBackgroundDrawableResource(android.R.color.transparent)

        // Create the layout
        val rootLayout = FrameLayout(this)
        rootLayout.layoutParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT
        )
        rootLayout.setBackgroundColor(Color.parseColor("#80000000")) // Semi-transparent black background

        // Create the sphere view - ENLARGED for lock screen
        val sphereView = View(this)
        val sphereSize = 400 // Larger size for lock screen
        val sphereParams = FrameLayout.LayoutParams(sphereSize, sphereSize)
        sphereParams.gravity = Gravity.CENTER
        sphereView.layoutParams = sphereParams

        // Set the sphere background with more vibrant colors
        sphereView.background = createCircleDrawable()

        // Create a text view for "Hey Boy"
        val textView = TextView(this)
        textView.text = "Hey Boy"
        textView.setTextColor(Color.WHITE)
        textView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 24f)
        textView.typeface = Typeface.create("sans-serif-light", Typeface.NORMAL)

        val textParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.WRAP_CONTENT,
            FrameLayout.LayoutParams.WRAP_CONTENT
        )
        textParams.gravity = Gravity.CENTER
        textParams.topMargin = sphereSize / 2 + 50 // Position below the sphere
        textView.layoutParams = textParams

        // Add views to the layout
        rootLayout.addView(sphereView)
        rootLayout.addView(textView)

        // Set the content view
        setContentView(rootLayout)

        // Create animation set for the sphere
        val animSet = AnimationSet(true)

        // Scale animation
        val scaleAnimation = ScaleAnimation(
            0.8f, 1.3f, 0.8f, 1.3f,
            Animation.RELATIVE_TO_SELF, 0.5f,
            Animation.RELATIVE_TO_SELF, 0.5f
        )
        scaleAnimation.duration = 1500
        scaleAnimation.repeatMode = Animation.REVERSE
        scaleAnimation.repeatCount = Animation.INFINITE
        animSet.addAnimation(scaleAnimation)

        // Pulse animation (alpha)
        val alphaAnimation = AlphaAnimation(0.7f, 1.0f)
        alphaAnimation.duration = 1000
        alphaAnimation.repeatMode = Animation.REVERSE
        alphaAnimation.repeatCount = Animation.INFINITE
        animSet.addAnimation(alphaAnimation)

        // Start the animation
        sphereView.startAnimation(animSet)

        // Fade in text
        val textFadeIn = AlphaAnimation(0.0f, 1.0f)
        textFadeIn.duration = 1000
        textView.startAnimation(textFadeIn)

        // Auto-close after the display duration
        handler.postDelayed({ finish() }, displayDuration)
    }

    // Create a circle drawable for the sphere animation with more vibrant colors
    private fun createCircleDrawable(): GradientDrawable {
        return GradientDrawable().apply {
            shape = GradientDrawable.OVAL
            gradientType = GradientDrawable.RADIAL_GRADIENT
            colors = intArrayOf(
                Color.parseColor("#00E5FF"), // Bright cyan
                Color.parseColor("#2979FF"), // Bright blue
                Color.parseColor("#3D5AFE")  // Indigo accent
            )
            gradientRadius = 200f
            setGradientCenter(0.3f, 0.3f)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        handler.removeCallbacksAndMessages(null)
    }
}
