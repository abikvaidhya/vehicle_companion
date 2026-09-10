package com.abik.vaidhya.vehicle_companion.worker

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.work.Worker
import androidx.work.WorkerParameters
import com.abik.vaidhya.vehicle_companion.MainActivity

/**
 * Shows a local notification when a maintenance reminder fires.
 * Open the app (MainActivity) on tap.
 */
class MaintenanceReminderWorker(
    context: Context,
    params: WorkerParameters,
) : Worker(context, params) {

    companion object {
        const val KEY_TITLE = "title"
        const val KEY_ID = "id"
        private const val CHANNEL_ID = "maintenance_reminders"
        private const val CHANNEL_NAME = "Maintenance reminders"
    }

    override fun doWork(): Result {
        val title = inputData.getString(KEY_TITLE) ?: "Maintenance due"
        val id = inputData.getString(KEY_ID) ?: "default"

        createChannelIfNeeded()
        showNotification(title, id)
        return Result.success()
    }

    private fun createChannelIfNeeded() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager =
            applicationContext.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channel = NotificationChannel(
            CHANNEL_ID,
            CHANNEL_NAME,
            NotificationManager.IMPORTANCE_DEFAULT,
        ).apply {
            description = "Reminders for vehicle service and inspections"
        }
        manager.createNotificationChannel(channel)
    }

    private fun showNotification(title: String, id: String) {
        val intent = Intent(applicationContext, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pending = PendingIntent.getActivity(
            applicationContext,
            id.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val notification = NotificationCompat.Builder(applicationContext, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_menu_compass)
            .setContentTitle("Vehicle Companion")
            .setContentText(title)
            .setContentIntent(pending)
            .setAutoCancel(true)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .build()

        val manager =
            applicationContext.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.notify(id.hashCode(), notification)
    }
}
