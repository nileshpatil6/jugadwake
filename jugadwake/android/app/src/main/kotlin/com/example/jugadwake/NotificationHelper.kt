package com.example.jugadwake

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat

object NotificationHelper {
    private const val CHANNEL_ID = "lock_screen_notification_channel"
    private const val NOTIFICATION_ID = 1002

    fun showPersistentNotification(context: Context) {
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        // Create notification channel for Android O and above
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // For Android 15+, use a higher importance to ensure visibility
            val importance = if (Build.VERSION.SDK_INT >= 35) {
                NotificationManager.IMPORTANCE_HIGH
            } else {
                NotificationManager.IMPORTANCE_DEFAULT
            }

            val channel = NotificationChannel(
                CHANNEL_ID,
                "Lock Screen Notification",
                importance
            ).apply {
                description = "Always visible notification"
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                setShowBadge(false)
                // For Android 15+, make sure the notification is not silenced
                if (Build.VERSION.SDK_INT >= 35) {
                    setSound(null, null) // No sound but not silent
                    enableVibration(false) // No vibration
                    enableLights(true) // Enable lights
                }
            }
            notificationManager.createNotificationChannel(channel)
        }

        // Create an intent to launch the main activity when notification is tapped
        val contentIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }

        val contentPendingIntent = PendingIntent.getActivity(
            context,
            0,
            contentIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        // Create the notification
        val notificationBuilder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle("JugadWake Active")
            .setContentText("Wake word detection is running")
            .setSubText("Tap to open the app")
            .setPriority(NotificationCompat.PRIORITY_MAX) // Use MAX priority for Android 15
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setContentIntent(contentPendingIntent)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setOngoing(true) // Makes it persistent
            .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)

        // For Android 15+, add additional flags to ensure persistence
        if (Build.VERSION.SDK_INT >= 35) {
            notificationBuilder
                .setOnlyAlertOnce(true) // Only alert the first time
                .setAutoCancel(false) // Cannot be dismissed by user
                .setTimeoutAfter(0) // Never timeout
        }

        // Show the notification
        notificationManager.notify(NOTIFICATION_ID, notificationBuilder.build())
    }
}
