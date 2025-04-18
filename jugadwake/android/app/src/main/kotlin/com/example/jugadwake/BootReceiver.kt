package com.example.jugadwake

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import android.util.Log

class BootReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "BootReceiver"
        private const val PREFS_NAME = "JugadWakePrefs"
        private const val KEY_SERVICE_ENABLED = "service_enabled"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            Log.d(TAG, "Boot completed received")

            // Check if service was enabled before reboot
            val prefs: SharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val serviceEnabled = prefs.getBoolean(KEY_SERVICE_ENABLED, false)

            if (serviceEnabled) {
                Log.d(TAG, "Starting WakeWordService after boot")

                // For Android 15+, we need to use a different approach
                if (Build.VERSION.SDK_INT >= 35) {
                    try {
                        // Start the main activity first, which will then start the service
                        val mainActivityIntent = Intent(context, MainActivity::class.java).apply {
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            putExtra("START_SERVICE_ON_BOOT", true)
                        }
                        context.startActivity(mainActivityIntent)
                        Log.d(TAG, "Started MainActivity to handle service start on Android 15+")
                    } catch (e: Exception) {
                        Log.e(TAG, "Failed to start activity on boot: ${e.message}")
                        // Fallback to direct service start
                        startServiceDirectly(context)
                    }
                } else {
                    // For Android 14 and below, start the service directly
                    startServiceDirectly(context)
                }
            }
        }
    }

    private fun startServiceDirectly(context: Context) {
        try {
            val serviceIntent = Intent(context, WakeWordService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(serviceIntent)
            } else {
                context.startService(serviceIntent)
            }
            Log.d(TAG, "Service started directly")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start service directly: ${e.message}")
        }
    }
}
