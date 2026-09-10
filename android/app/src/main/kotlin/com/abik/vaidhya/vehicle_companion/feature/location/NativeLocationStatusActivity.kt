//package com.abik.vaidhya.vehicle_companion.feature.location
//
//import android.Manifest
//import android.annotation.SuppressLint
//import android.content.pm.PackageManager
//import android.os.Bundle
//import androidx.activity.ComponentActivity
//import androidx.activity.compose.setContent
//import androidx.activity.result.contract.ActivityResultContracts
//import androidx.compose.foundation.layout.Arrangement
//import androidx.compose.foundation.layout.Column
//import androidx.compose.foundation.layout.Spacer
//import androidx.compose.foundation.layout.fillMaxSize
//import androidx.compose.foundation.layout.height
//import androidx.compose.foundation.layout.padding
//import androidx.compose.material3.Button
//import androidx.compose.material3.MaterialTheme
//import androidx.compose.material3.Surface
//import androidx.compose.material3.Text
//import androidx.compose.runtime.Composable
//import androidx.compose.runtime.getValue
//import androidx.compose.runtime.mutableStateOf
//import androidx.compose.runtime.remember
//import androidx.compose.runtime.setValue
//import androidx.compose.ui.Alignment
//import androidx.compose.ui.Modifier
//import androidx.compose.ui.unit.dp
//import androidx.core.content.ContextCompat
//import com.google.android.gms.location.LocationServices
//import com.google.android.gms.location.Priority
//import com.google.android.gms.tasks.CancellationTokenSource
//
//class NativeLocationStatusActivity : ComponentActivity() {
//
//    private val permissionLauncher = registerForActivityResult(
//        ActivityResultContracts.RequestMultiplePermissions(),
//    ) { /* Compose re-reads permission on next interaction */ }
//
//    override fun onCreate(savedInstanceState: Bundle?) {
//        super.onCreate(savedInstanceState)
//        setContent {
//            MaterialTheme {
//                Surface(modifier = Modifier.fillMaxSize()) {
//                    LocationStatusScreen(
//                        hasPermission = hasLocationPermission(),
//                        onRequestPermission = {
//                            permissionLauncher.launch(
//                                arrayOf(
//                                    Manifest.permission.ACCESS_FINE_LOCATION,
//                                    Manifest.permission.ACCESS_COARSE_LOCATION,
//                                ),
//                            )
//                        },
//                        onFetchLocation = { onResult ->
//                            fetchLastLocation(onResult)
//                        },
//                        onClose = { finish() },
//                    )
//                }
//            }
//        }
//    }
//
//    private fun hasLocationPermission(): Boolean {
//        return ContextCompat.checkSelfPermission(
//            this,
//            Manifest.permission.ACCESS_FINE_LOCATION,
//        ) == PackageManager.PERMISSION_GRANTED
//    }
//
//    @SuppressLint("MissingPermission")
//    private fun fetchLastLocation(onResult: (String) -> Unit) {
//        if (!hasLocationPermission()) {
//            onResult("Permission not granted")
//            return
//        }
//        val client = LocationServices.getFusedLocationProviderClient(this)
//        val token = CancellationTokenSource()
//        client.getCurrentLocation(Priority.PRIORITY_HIGH_ACCURACY, token.token)
//            .addOnSuccessListener { loc ->
//                if (loc != null) {
//                    onResult(
//                        "lat=${"%.5f".format(loc.latitude)}, " +
//                                "lng=${"%.5f".format(loc.longitude)}\n" +
//                                "accuracy=${loc.accuracy.toInt()} m",
//                    )
//                } else {
//                    onResult("No location available")
//                }
//            }
//            .addOnFailureListener { e ->
//                onResult("Error: ${e.message}")
//            }
//    }
//}
//
//@Composable
//private fun LocationStatusScreen(
//    hasPermission: Boolean,
//    onRequestPermission: () -> Unit,
//    onFetchLocation: ((String) -> Unit) -> Unit,
//    onClose: () -> Unit,
//) {
//    var status by remember {
//        mutableStateOf(if (hasPermission) "Permission granted" else "Permission needed")
//    }
//
//    Column(
//        modifier = Modifier
//            .fillMaxSize()
//            .padding(24.dp),
//        verticalArrangement = Arrangement.Center,
//        horizontalAlignment = Alignment.CenterHorizontally,
//    ) {
//        Text(
//            text = "Native Location Status",
//            style = MaterialTheme.typography.headlineSmall,
//        )
//        Spacer(modifier = Modifier.height(8.dp))
//        Text(
//            text = "Jetpack Compose screen opened from Flutter",
//            style = MaterialTheme.typography.bodyMedium,
//            color = MaterialTheme.colorScheme.onSurfaceVariant,
//        )
//        Spacer(modifier = Modifier.height(24.dp))
//        Text(text = status, style = MaterialTheme.typography.bodyLarge)
//        Spacer(modifier = Modifier.height(24.dp))
//
//        if (!hasPermission) {
//            Button(onClick = onRequestPermission) {
//                Text("Request location permission")
//            }
//        } else {
//            Button(onClick = { onFetchLocation { status = it } }) {
//                Text("Get current location")
//            }
//        }
//
//        Spacer(modifier = Modifier.height(12.dp))
//        Button(onClick = onClose) {
//            Text("Close")
//        }
//    }
//}