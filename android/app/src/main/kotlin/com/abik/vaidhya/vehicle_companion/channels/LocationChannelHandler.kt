package com.abik.vaidhya.vehicle_companion.channels

import android.Manifest
import android.annotation.SuppressLint
import android.content.Context
import android.content.pm.PackageManager
import android.location.Location
import android.os.Looper
import androidx.core.content.ContextCompat
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationCallback
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationResult
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Priority
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class LocationChannelHandler(
    private val context: Context,
    messenger: BinaryMessenger,
) : MethodCallHandler, EventChannel.StreamHandler {

    companion object {
        const val METHOD_CHANNEL = "com.abik.vaidhya.vehicle_companion/location"
        const val EVENT_CHANNEL = "com.abik.vaidhya.vehicle_companion/location_stream"
    }

    private val methodChannel = MethodChannel(messenger, METHOD_CHANNEL)
    private val eventChannel = EventChannel(messenger, EVENT_CHANNEL)

    private val fusedClient: FusedLocationProviderClient =
        LocationServices.getFusedLocationProviderClient(context)

    private var eventSink: EventChannel.EventSink? = null
    private var locationCallback: LocationCallback? = null

    fun register() {
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
    }

    fun unregister() {
        stopTrackingInternal()
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        eventSink = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getCurrentPosition" -> getCurrentPosition(result)
            "stopTracking" -> {
                stopTrackingInternal()
                result.success(null)
            }
            "checkPermission" -> result.success(checkPermissionStatus())
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        startTrackingInternal()
    }

    override fun onCancel(arguments: Any?) {
        stopTrackingInternal()
        eventSink = null
    }

    private fun checkPermissionStatus(): String {
        val fine = ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.ACCESS_FINE_LOCATION,
        ) == PackageManager.PERMISSION_GRANTED
        val coarse = ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.ACCESS_COARSE_LOCATION,
        ) == PackageManager.PERMISSION_GRANTED
        return when {
            fine -> "granted_fine"
            coarse -> "granted_coarse"
            else -> "denied"
        }
    }

    private fun hasLocationPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.ACCESS_FINE_LOCATION,
        ) == PackageManager.PERMISSION_GRANTED ||
                ContextCompat.checkSelfPermission(
                    context,
                    Manifest.permission.ACCESS_COARSE_LOCATION,
                ) == PackageManager.PERMISSION_GRANTED
    }

    @SuppressLint("MissingPermission")
    private fun getCurrentPosition(result: Result) {
        if (!hasLocationPermission()) {
            result.error("PERMISSION_DENIED", "Location permission not granted", null)
            return
        }
        fusedClient.lastLocation
            .addOnSuccessListener { location: Location? ->
                if (location != null) {
                    result.success(locationToMap(location))
                } else {
                    requestSingleUpdate(result)
                }
            }
            .addOnFailureListener { e ->
                result.error("ERROR", e.message, null)
            }
    }

    @SuppressLint("MissingPermission")
    private fun requestSingleUpdate(result: Result) {
        val request = LocationRequest.Builder(Priority.PRIORITY_HIGH_ACCURACY, 1000L)
            .setMaxUpdates(1)
            .build()

        val callback = object : LocationCallback() {
            override fun onLocationResult(locationResult: LocationResult) {
                fusedClient.removeLocationUpdates(this)
                val loc = locationResult.lastLocation
                if (loc != null) {
                    result.success(locationToMap(loc))
                } else {
                    result.error("UNAVAILABLE", "Could not obtain location", null)
                }
            }
        }
        fusedClient.requestLocationUpdates(request, callback, Looper.getMainLooper())
    }

    @SuppressLint("MissingPermission")
    private fun startTrackingInternal() {
        if (!hasLocationPermission()) {
            eventSink?.error("PERMISSION_DENIED", "Location permission not granted", null)
            return
        }
        if (locationCallback != null) return

        val request = LocationRequest.Builder(
            Priority.PRIORITY_HIGH_ACCURACY,
            2000L,
        )
            .setMinUpdateIntervalMillis(1000L)
            .setMinUpdateDistanceMeters(5f)
            .build()

        locationCallback = object : LocationCallback() {
            override fun onLocationResult(locationResult: LocationResult) {
                locationResult.lastLocation?.let { loc ->
                    eventSink?.success(locationToMap(loc))
                }
            }
        }

        fusedClient.requestLocationUpdates(
            request,
            locationCallback!!,
            Looper.getMainLooper(),
        )
    }

    private fun stopTrackingInternal() {
        locationCallback?.let { fusedClient.removeLocationUpdates(it) }
        locationCallback = null
    }

    private fun locationToMap(location: Location): Map<String, Any> {
        return mapOf(
            "latitude" to location.latitude,
            "longitude" to location.longitude,
            "accuracy" to location.accuracy.toDouble(),
            "timestamp" to location.time,
            "speed" to location.speed.toDouble(),
        )
    }
}