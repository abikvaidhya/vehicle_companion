package com.abik.vaidhya.vehicle_companion.channels

import android.content.Context
import androidx.work.Data
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import com.abik.vaidhya.vehicle_companion.worker.MaintenanceReminderWorker
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.concurrent.TimeUnit

class NotificationChannelHandler(
    private val context: Context,
    messenger: BinaryMessenger,
) : MethodCallHandler {

    companion object {
        const val METHOD_CHANNEL = "com.abik.vaidhya.vehiclecompanion/notification"
        private const val WORK_PREFIX = "maintenance_reminder_"
    }

    private val methodChannel = MethodChannel(messenger, METHOD_CHANNEL)

    fun register() {
        methodChannel.setMethodCallHandler(this)
    }

    fun unregister() {
        methodChannel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "scheduleReminder" -> {
                val id = call.argument<String>("id")
                val title = call.argument<String>("title") ?: "Maintenance due"
                val delaySeconds = call.argument<Number>("delaySeconds")?.toLong() ?: 0L

                if (id.isNullOrBlank()) {
                    result.error("INVALID_ARGS", "id is required", null)
                    return
                }
                schedule(id, title, delaySeconds)
                result.success(null)
            }
            "cancelReminder" -> {
                val id = call.argument<String>("id")
                if (id.isNullOrBlank()) {
                    result.error("INVALID_ARGS", "id is required", null)
                    return
                }
                WorkManager.getInstance(context)
                    .cancelUniqueWork(WORK_PREFIX + id)
                result.success(null)
            }
            "cancelAll" -> {
                WorkManager.getInstance(context)
                    .cancelAllWorkByTag("maintenance_reminder")
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun schedule(id: String, title: String, delaySeconds: Long) {
        val data = Data.Builder()
            .putString(MaintenanceReminderWorker.KEY_TITLE, title)
            .putString(MaintenanceReminderWorker.KEY_ID, id)
            .build()

        val request = OneTimeWorkRequestBuilder<MaintenanceReminderWorker>()
            .setInitialDelay(delaySeconds.coerceAtLeast(0), TimeUnit.SECONDS)
            .setInputData(data)
            .addTag("maintenance_reminder")
            .build()

        WorkManager.getInstance(context).enqueueUniqueWork(
            WORK_PREFIX + id,
            ExistingWorkPolicy.REPLACE,
            request,
        )
    }
}