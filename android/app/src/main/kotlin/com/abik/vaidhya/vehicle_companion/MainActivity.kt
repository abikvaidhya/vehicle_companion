package com.abik.vaidhya.vehicle_companion

import com.abik.vaidhya.vehicle_companion.channels.BluetoothChannelHandler
import com.abik.vaidhya.vehicle_companion.channels.LocationChannelHandler
import com.abik.vaidhya.vehicle_companion.channels.NotificationChannelHandler
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    private var locationHandler: LocationChannelHandler? = null
    private var bluetoothHandler: BluetoothChannelHandler? = null
    private var notificationHandler: NotificationChannelHandler? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val messenger = flutterEngine.dartExecutor.binaryMessenger

        locationHandler = LocationChannelHandler(this, messenger).also { it.register() }
        bluetoothHandler = BluetoothChannelHandler(this, messenger).also { it.register() }
        notificationHandler = NotificationChannelHandler(this, messenger).also { it.register() }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        locationHandler?.unregister()
        bluetoothHandler?.unregister()
        notificationHandler?.unregister()
        locationHandler = null
        bluetoothHandler = null
        notificationHandler = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}