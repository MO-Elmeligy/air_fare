package com.example.air_fare_app

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothSocket
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.IOException
import java.io.InputStream
import java.io.OutputStream
import java.util.*

class BluetoothSerialPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var bluetoothAdapter: BluetoothAdapter? = null
    private var bluetoothSocket: BluetoothSocket? = null
    private var inputStream: InputStream? = null
    private var outputStream: OutputStream? = null
    private var isConnected = false
    private var connectedDevice: BluetoothDevice? = null

    // UUID for Serial Port Profile (SPP) - زي Serial Bluetooth Terminal
    private val SPP_UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")

    // Broadcast receiver for device discovery
    private val discoveryReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when (intent.action) {
                BluetoothDevice.ACTION_FOUND -> {
                    val device: BluetoothDevice? = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                    device?.let {
                        // Check permissions properly
                        val hasConnectPermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                            ActivityCompat.checkSelfPermission(context, android.Manifest.permission.BLUETOOTH_CONNECT) == PackageManager.PERMISSION_GRANTED
                        } else {
                            true
                        }
                        
                        if (hasConnectPermission) {
                            val deviceName = it.name ?: "Unknown Device"
                            val deviceAddress = it.address
                            val deviceClass = it.bluetoothClass?.majorDeviceClass ?: 0
                            
                            android.util.Log.d("BluetoothSerial", "Found device: $deviceName ($deviceAddress)")
                            
                            // Send device info to Flutter - زي Serial Bluetooth Terminal
                            channel.invokeMethod("onDeviceFound", mapOf(
                                "name" to deviceName,
                                "address" to deviceAddress,
                                "class" to deviceClass,
                                "bonded" to (it.bondState == BluetoothDevice.BOND_BONDED)
                            ))
                        } else {
                            android.util.Log.d("BluetoothSerial", "No connect permission for device: ${it.address}")
                        }
                    }
                }
                BluetoothAdapter.ACTION_DISCOVERY_FINISHED -> {
                    // Discovery finished
                }
            }
        }
    }

    // Broadcast receiver for Bluetooth state changes
    private val bluetoothStateReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when (intent.action) {
                BluetoothAdapter.ACTION_STATE_CHANGED -> {
                    val state = intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, BluetoothAdapter.ERROR)
                    val isEnabled = state == BluetoothAdapter.STATE_ON
                    channel.invokeMethod("onBluetoothStateChanged", mapOf("enabled" to isEnabled))
                }
            }
        }
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "bluetooth_serial")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
        
        android.util.Log.d("BluetoothSerial", "Plugin attached to engine")
        
        // Register broadcast receivers
        val discoveryFilter = IntentFilter().apply {
            addAction(BluetoothDevice.ACTION_FOUND)
            addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED)
        }
        context.registerReceiver(discoveryReceiver, discoveryFilter)
        
        val bluetoothFilter = IntentFilter().apply {
            addAction(BluetoothAdapter.ACTION_STATE_CHANGED)
        }
        context.registerReceiver(bluetoothStateReceiver, bluetoothFilter)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        try {
            context.unregisterReceiver(discoveryReceiver)
            context.unregisterReceiver(bluetoothStateReceiver)
        } catch (e: Exception) {
            // Receiver might not be registered
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        android.util.Log.d("BluetoothSerial", "Method called: ${call.method}")
        when (call.method) {
            "isBluetoothAvailable" -> {
                result.success(bluetoothAdapter != null)
            }
            "isBluetoothEnabled" -> {
                result.success(bluetoothAdapter?.isEnabled == true)
            }
            "requestPermissions" -> {
                requestPermissions(result)
            }
            "enableBluetooth" -> {
                enableBluetooth(result)
            }
            "disableBluetooth" -> {
                disableBluetooth(result)
            }
            "getPairedDevices" -> {
                getPairedDevices(result)
            }
            "startDiscovery" -> {
                startDiscovery(result)
            }
            "cancelDiscovery" -> {
                cancelDiscovery(result)
            }
            "connect" -> {
                val address = call.argument<String>("address") ?: ""
                val name = call.argument<String>("name") ?: ""
                connect(address, name, result)
            }
            "disconnect" -> {
                disconnect(result)
            }
            "sendData" -> {
                val data = call.argument<String>("data") ?: ""
                sendData(data, result)
            }
            "sendBytes" -> {
                val bytes = call.argument<List<Int>>("bytes") ?: emptyList()
                sendBytes(bytes, result)
            }
            "pairDevice" -> {
                val address = call.argument<String>("address") ?: ""
                pairDevice(address, result)
            }
            "unpairDevice" -> {
                val address = call.argument<String>("address") ?: ""
                unpairDevice(address, result)
            }
            "isConnected" -> {
                val actuallyConnected = isConnected && 
                                       bluetoothSocket?.isConnected == true && 
                                       inputStream != null && 
                                       outputStream != null
                android.util.Log.d("BluetoothSerial", "Connection status check: isConnected=$isConnected, socketConnected=${bluetoothSocket?.isConnected}, hasStreams=${inputStream != null && outputStream != null}")
                result.success(actuallyConnected)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun requestPermissions(result: Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val permissions = arrayOf(
                android.Manifest.permission.BLUETOOTH_SCAN,
                android.Manifest.permission.BLUETOOTH_CONNECT,
                android.Manifest.permission.ACCESS_FINE_LOCATION
            )
            
            // Check if permissions are already granted
            val allGranted = permissions.all { permission ->
                ActivityCompat.checkSelfPermission(context, permission) == PackageManager.PERMISSION_GRANTED
            }
            
            if (allGranted) {
                result.success(true)
            } else {
                // Request permissions
                val activity = (context as? android.app.Activity)
                if (activity != null) {
                    ActivityCompat.requestPermissions(activity, permissions, 1)
                    result.success(true)
                } else {
                    result.success(false)
                }
            }
        } else {
            result.success(true)
        }
    }

    private fun enableBluetooth(result: Result) {
        if (bluetoothAdapter?.isEnabled == true) {
            result.success(true)
            return
        }
        
        if (ActivityCompat.checkSelfPermission(context, android.Manifest.permission.BLUETOOTH_CONNECT) == PackageManager.PERMISSION_GRANTED) {
            val intent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
            result.success(true)
        } else {
            result.success(false)
        }
    }

    private fun disableBluetooth(result: Result) {
        if (ActivityCompat.checkSelfPermission(context, android.Manifest.permission.BLUETOOTH_CONNECT) == PackageManager.PERMISSION_GRANTED) {
            bluetoothAdapter?.disable()
            result.success(true)
        } else {
            result.success(false)
        }
    }

    private fun getPairedDevices(result: Result) {
        if (ActivityCompat.checkSelfPermission(context, android.Manifest.permission.BLUETOOTH_CONNECT) == PackageManager.PERMISSION_GRANTED) {
            val pairedDevices = bluetoothAdapter?.bondedDevices ?: emptySet()
            val deviceList = pairedDevices.map { device ->
                mapOf(
                    "name" to (device.name ?: "Unknown Device"),
                    "address" to device.address,
                    "class" to (device.bluetoothClass?.majorDeviceClass ?: 0),
                    "bonded" to true
                )
            }
            result.success(deviceList)
        } else {
            result.success(emptyList<Map<String, Any>>())
        }
    }

    private fun startDiscovery(result: Result) {
        // Check permissions properly for different Android versions
        val hasScanPermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            ActivityCompat.checkSelfPermission(context, android.Manifest.permission.BLUETOOTH_SCAN) == PackageManager.PERMISSION_GRANTED
        } else {
            ActivityCompat.checkSelfPermission(context, android.Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
        }
        
        android.util.Log.d("BluetoothSerial", "Starting discovery - hasScanPermission: $hasScanPermission")
        
        if (hasScanPermission) {
            if (bluetoothAdapter?.isDiscovering == true) {
                android.util.Log.d("BluetoothSerial", "Cancelling previous discovery")
                bluetoothAdapter?.cancelDiscovery()
            }
            val discoveryStarted = bluetoothAdapter?.startDiscovery() ?: false
            android.util.Log.d("BluetoothSerial", "Discovery started: $discoveryStarted")
            result.success(discoveryStarted)
        } else {
            android.util.Log.d("BluetoothSerial", "No scan permission")
            result.success(false)
        }
    }

    private fun cancelDiscovery(result: Result) {
        val hasScanPermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            ActivityCompat.checkSelfPermission(context, android.Manifest.permission.BLUETOOTH_SCAN) == PackageManager.PERMISSION_GRANTED
        } else {
            ActivityCompat.checkSelfPermission(context, android.Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
        }
        
        if (hasScanPermission) {
            bluetoothAdapter?.cancelDiscovery()
        }
        result.success(true)
    }

    private fun connect(address: String, name: String, result: Result) {
        android.util.Log.d("BluetoothSerial", "=== CONNECT METHOD CALLED ===")
        android.util.Log.d("BluetoothSerial", "Address: $address, Name: $name")
        
        val hasConnectPermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            ActivityCompat.checkSelfPermission(context, android.Manifest.permission.BLUETOOTH_CONNECT) == PackageManager.PERMISSION_GRANTED
        } else {
            true
        }

        android.util.Log.d("BluetoothSerial", "Has connect permission: $hasConnectPermission")

        if (!hasConnectPermission) {
            android.util.Log.d("BluetoothSerial", "No connect permission")
            (context as? android.app.Activity)?.runOnUiThread {
                result.success(false)
            }
            return
        }

        try {
            android.util.Log.d("BluetoothSerial", "Disconnecting from any existing connection...")
            // Disconnect from any existing connection (without calling result.success)
            disconnectSilently()

            val device = bluetoothAdapter?.getRemoteDevice(address)
            android.util.Log.d("BluetoothSerial", "Device object: $device")
            if (device == null) {
                android.util.Log.d("BluetoothSerial", "Device not found: $address")
                (context as? android.app.Activity)?.runOnUiThread {
                    result.success(false)
                }
                return
            }

            android.util.Log.d("BluetoothSerial", "Device found: ${device.name} (${device.address})")
            android.util.Log.d("BluetoothSerial", "Device bond state: ${device.bondState}")
            android.util.Log.d("BluetoothSerial", "Device type: ${device.type}")

            android.util.Log.d("BluetoothSerial", "Attempting to connect to $name ($address)")
            android.util.Log.d("BluetoothSerial", "Using SPP UUID: $SPP_UUID")

            // Create socket - زي Serial Bluetooth Terminal
            // Try different connection methods
            bluetoothSocket = try {
                android.util.Log.d("BluetoothSerial", "Creating SPP socket...")
                val socket = device.createRfcommSocketToServiceRecord(SPP_UUID)
                android.util.Log.d("BluetoothSerial", "SPP socket created successfully")
                socket
            } catch (e: Exception) {
                android.util.Log.d("BluetoothSerial", "Failed to create SPP socket: ${e.message}")
                android.util.Log.d("BluetoothSerial", "Trying alternative method...")
                try {
                    // Alternative method for older devices
                    val m = device.javaClass.getMethod("createRfcommSocket", Int::class.javaPrimitiveType)
                    val socket = m.invoke(device, 1) as BluetoothSocket
                    android.util.Log.d("BluetoothSerial", "Alternative socket created successfully")
                    socket
                } catch (e2: Exception) {
                    android.util.Log.d("BluetoothSerial", "Alternative method also failed: ${e2.message}")
                    throw e2
                }
            }
            
            // Connect in a separate thread to avoid blocking
            Thread {
                try {
                    android.util.Log.d("BluetoothSerial", "Starting connection thread...")
                    
                    // Cancel any ongoing discovery
                    if (bluetoothAdapter?.isDiscovering == true) {
                        bluetoothAdapter?.cancelDiscovery()
                        android.util.Log.d("BluetoothSerial", "Cancelled discovery")
                    }
                    
                    // Set connection timeout and connect
                    android.util.Log.d("BluetoothSerial", "Attempting socket connection...")
                    bluetoothSocket?.connect()
                    
                    android.util.Log.d("BluetoothSerial", "Socket connect() completed")
                    
                    // Verify connection is successful
                    val isSocketConnected = bluetoothSocket?.isConnected == true
                    android.util.Log.d("BluetoothSerial", "Socket connected status: $isSocketConnected")
                    
                    if (isSocketConnected) {
                        try {
                            inputStream = bluetoothSocket?.inputStream
                            outputStream = bluetoothSocket?.outputStream
                            android.util.Log.d("BluetoothSerial", "Got input/output streams")

                            // Test the streams
                            if (inputStream != null && outputStream != null) {
                                isConnected = true
                                connectedDevice = device
                                android.util.Log.d("BluetoothSerial", "Streams are valid, connection established")

                                // Start listening for data
                                startListeningForData()

                                android.util.Log.d("BluetoothSerial", "Successfully connected to $name")
                                
                                // Run on main thread
                                (context as? android.app.Activity)?.runOnUiThread {
                                    channel.invokeMethod("onConnectionStateChanged", mapOf("connected" to true))
                                    result.success(true)
                                }
                            } else {
                                android.util.Log.d("BluetoothSerial", "Failed to get valid streams")
                                (context as? android.app.Activity)?.runOnUiThread {
                                    result.success(false)
                                }
                            }
                        } catch (e: Exception) {
                            android.util.Log.d("BluetoothSerial", "Error getting streams: ${e.message}")
                            (context as? android.app.Activity)?.runOnUiThread {
                                result.success(false)
                            }
                        }
                    } else {
                        android.util.Log.d("BluetoothSerial", "Socket not connected after connect() call")
                        (context as? android.app.Activity)?.runOnUiThread {
                            result.success(false)
                        }
                    }

                } catch (e: IOException) {
                    android.util.Log.d("BluetoothSerial", "Connection failed: ${e.message}")
                    e.printStackTrace()
                    (context as? android.app.Activity)?.runOnUiThread {
                        result.success(false)
                    }
                }
            }.start()

        } catch (e: Exception) {
            android.util.Log.d("BluetoothSerial", "Connection error: ${e.message}")
            e.printStackTrace()
            (context as? android.app.Activity)?.runOnUiThread {
                result.success(false)
            }
        }
    }

    private fun disconnectSilently() {
        try {
            isConnected = false
            inputStream?.close()
            outputStream?.close()
            bluetoothSocket?.close()
            
            inputStream = null
            outputStream = null
            bluetoothSocket = null
            connectedDevice = null
        } catch (e: IOException) {
            e.printStackTrace()
        }
    }

    private fun disconnect(result: Result) {
        try {
            isConnected = false
            inputStream?.close()
            outputStream?.close()
            bluetoothSocket?.close()
            
            inputStream = null
            outputStream = null
            bluetoothSocket = null
            connectedDevice = null

            (context as? android.app.Activity)?.runOnUiThread {
                channel.invokeMethod("onConnectionStateChanged", mapOf("connected" to false))
                result.success(true)
            }
        } catch (e: IOException) {
            e.printStackTrace()
            (context as? android.app.Activity)?.runOnUiThread {
                result.success(false)
            }
        }
    }

    private fun sendData(data: String, result: Result) {
        if (!isConnected || outputStream == null) {
            (context as? android.app.Activity)?.runOnUiThread {
                result.success(false)
            }
            return
        }

        try {
            outputStream?.write(data.toByteArray())
            outputStream?.flush()
            (context as? android.app.Activity)?.runOnUiThread {
                result.success(true)
            }
        } catch (e: IOException) {
            e.printStackTrace()
            (context as? android.app.Activity)?.runOnUiThread {
                result.success(false)
            }
        }
    }

    private fun sendBytes(bytes: List<Int>, result: Result) {
        if (!isConnected || outputStream == null) {
            (context as? android.app.Activity)?.runOnUiThread {
                result.success(false)
            }
            return
        }

        try {
            val byteArray = bytes.map { it.toByte() }.toByteArray()
            outputStream?.write(byteArray)
            outputStream?.flush()
            (context as? android.app.Activity)?.runOnUiThread {
                result.success(true)
            }
        } catch (e: IOException) {
            e.printStackTrace()
            (context as? android.app.Activity)?.runOnUiThread {
                result.success(false)
            }
        }
    }

    private fun pairDevice(address: String, result: Result) {
        if (ActivityCompat.checkSelfPermission(context, android.Manifest.permission.BLUETOOTH_CONNECT) == PackageManager.PERMISSION_GRANTED) {
            val device = bluetoothAdapter?.getRemoteDevice(address)
            device?.createBond()
            (context as? android.app.Activity)?.runOnUiThread {
                result.success(true)
            }
        } else {
            (context as? android.app.Activity)?.runOnUiThread {
                result.success(false)
            }
        }
    }

    private fun unpairDevice(address: String, result: Result) {
        if (ActivityCompat.checkSelfPermission(context, android.Manifest.permission.BLUETOOTH_CONNECT) == PackageManager.PERMISSION_GRANTED) {
            val device = bluetoothAdapter?.getRemoteDevice(address)
            val method = device?.javaClass?.getMethod("removeBond")
            method?.invoke(device)
            (context as? android.app.Activity)?.runOnUiThread {
                result.success(true)
            }
        } else {
            (context as? android.app.Activity)?.runOnUiThread {
                result.success(false)
            }
        }
    }

    private fun startListeningForData() {
        Thread {
            val buffer = ByteArray(1024)
            while (isConnected) {
                try {
                    val bytes = inputStream?.read(buffer)
                    if (bytes != null && bytes > 0) {
                        val data = String(buffer, 0, bytes)
                        (context as? android.app.Activity)?.runOnUiThread {
                            channel.invokeMethod("onDataReceived", mapOf("data" to data))
                        }
                    }
                } catch (e: IOException) {
                    e.printStackTrace()
                    break
                }
            }
        }.start()
    }
}
