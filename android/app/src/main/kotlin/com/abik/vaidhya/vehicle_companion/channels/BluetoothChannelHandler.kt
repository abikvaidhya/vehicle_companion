package com.abik.vaidhya.vehicle_companion.channels

import android.Manifest
import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * Bluetooth LE channel — includes a mock OBD device for emulator / demo.
 *
 * Channels:
 *   Method: com.abik.vaidhya.vehiclecompanion/bluetooth
 *   Event:  com.abik.vaidhya.vehiclecompanion/bluetooth_stream
 */
class BluetoothChannelHandler(
    private val context: Context,
    messenger: BinaryMessenger,
) : MethodCallHandler, EventChannel.StreamHandler {

    companion object {
        const val METHOD_CHANNEL = "com.abik.vaidhya.vehiclecompanion/bluetooth"
        const val EVENT_CHANNEL = "com.abik.vaidhya.vehiclecompanion/bluetooth_stream"

        private val MOCK_DEVICE = mapOf(
            "type" to "device",
            "deviceId" to "mock-obd-001",
            "name" to "Mock OBD-II Adapter",
            "rssi" to -55,
            "isMock" to true,
        )
    }

    private val methodChannel = MethodChannel(messenger, METHOD_CHANNEL)
    private val eventChannel = EventChannel(messenger, EVENT_CHANNEL)
    private val mainHandler = Handler(Looper.getMainLooper())

    private var eventSink: EventChannel.EventSink? = null
    private var isScanning = false
    private var connectedDeviceId: String? = null

    private val bluetoothAdapter: BluetoothAdapter? by lazy {
        val manager =
            context.getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager
        manager?.adapter
    }

    fun register() {
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
    }

    fun unregister() {
        stopScanInternal()
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        eventSink = null
    }

    // ── MethodCallHandler ───────────────────────────────────────────────────

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "startScan" -> {
                startScanInternal()
                result.success(null)
            }
            "stopScan" -> {
                stopScanInternal()
                result.success(null)
            }
            "connect" -> {
                val deviceId = call.argument<String>("deviceId")
                if (deviceId.isNullOrBlank()) {
                    result.error("INVALID_ARGS", "deviceId is required", null)
                    return
                }
                connectInternal(deviceId, result)
            }
            "disconnect" -> {
                disconnectInternal()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    // ── EventChannel.StreamHandler ──────────────────────────────────────────

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
        stopScanInternal()
    }

    // ── Scan ────────────────────────────────────────────────────────────────

    @SuppressLint("MissingPermission")
    private fun startScanInternal() {
        if (isScanning) return
        isScanning = true
        emitState("scanning")

        // Always emit mock device so demos work on emulator
        mainHandler.postDelayed({
            if (isScanning) {
                eventSink?.success(MOCK_DEVICE)
            }
        }, 600)

        if (hasBluetoothPermission() && bluetoothAdapter?.isEnabled == true) {
            try {
                @Suppress("DEPRECATION")
                bluetoothAdapter?.startDiscovery()
            } catch (_: SecurityException) {
                // mock already scheduled
            }
        }
    }

    @SuppressLint("MissingPermission")
    private fun stopScanInternal() {
        if (!isScanning) return
        isScanning = false
        try {
            @Suppress("DEPRECATION")
            bluetoothAdapter?.cancelDiscovery()
        } catch (_: SecurityException) {
        }
        emitState("idle")
    }

    // ── Connect ─────────────────────────────────────────────────────────────

    private fun connectInternal(deviceId: String, result: Result) {
        mainHandler.postDelayed({
            connectedDeviceId = deviceId
            emitState("connected", deviceId)
            result.success(mapOf("deviceId" to deviceId, "status" to "connected"))
        }, 400)
    }

    private fun disconnectInternal() {
        val previous = connectedDeviceId
        connectedDeviceId = null
        emitState("disconnected", previous)
    }

    // ── Helpers ─────────────────────────────────────────────────────────────

    private fun emitState(state: String, deviceId: String? = null) {
        val payload = mutableMapOf<String, Any>(
            "type" to "state",
            "state" to state,
        )
        deviceId?.let { payload["deviceId"] = it }
        eventSink?.success(payload)
    }

    private fun hasBluetoothPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.BLUETOOTH_SCAN,
            ) == PackageManager.PERMISSION_GRANTED &&
                    ContextCompat.checkSelfPermission(
                        context,
                        Manifest.permission.BLUETOOTH_CONNECT,
                    ) == PackageManager.PERMISSION_GRANTED
        } else {
            ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.BLUETOOTH,
            ) == PackageManager.PERMISSION_GRANTED
        }
    }
}