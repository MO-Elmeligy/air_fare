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

class BluetoothSerialPluginWorking : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var bluetoothAdapter: BluetoothAdapter? = null
    private var bluetoothSocket: BluetoothSocket? = null
    private var inputStream: InputStream? = null
    private var outputStream: OutputStream? = null
    private var isConnected = false
    private var connectedDevice: BluetoothDevice? = null

    // UUID for Serial Port Profile (SPP)
    private val SPP_UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")

    // Broadcast receiver for device discovery
    private val discoveryReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when (intent.action) {
                BluetoothDevice.ACTION_FOUND -> {
                    val device: BluetoothDevice? = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                    device?.let {
                        val hasConnectPermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                            ActivityCompat.checkSelfPermission(context, android.Manifest.permission.BLUETOOTH_CONNECT) == PackageManager.PERMISSION_GRANTED
                        } else {
                            true
                        }
                        
                        if (hasConnectPermission) {
                            val deviceName = it.name ?: "Unknown Device"
                            val deviceAddress = it.address
                            
                            android.util.Log.d("BluetoothSerialWorking", "Found device: $deviceName ($deviceAddress)")
                            
                            channel.invokeMethod("onDeviceFound", mapOf(
                                "name" to deviceName,
                                "address" to deviceAddress,
                                "class" to (it.bluetoothClass?.majorDeviceClass ?: 0),
                                "bonded" to (it.bondState == BluetoothDevice.BOND_BONDED)
                            ))
                        }
                    }
                }
                BluetoothAdapter.ACTION_DISCOVERY_FINISHED -> {
                    android.util.Log.d("BluetoothSerialWorking", "Discovery finished")
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
        
        android.util.Log.d("BluetoothSerialWorking", "Plugin attached to engine")
        
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
        android.util.Log.d("BluetoothSerialWorking", "Method called: ${call.method}")
        when (call.method) {
            "isBluetoothAvailable" -> {
                result.success(bluetoothAdapter != null)
            }
            "isBluetoothEnabled" -> {
                result.success(bluetoothAdapter?.isEnabled == true)
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
            "isConnected" -> {
                val actuallyConnected = isConnected && 
                                       bluetoothSocket?.isConnected == true && 
                                       inputStream != null && 
                                       outputStream != null
                result.success(actuallyConnected)
            }
            else -> {
                result.notImplemented()
            }
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
        val hasScanPermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            ActivityCompat.checkSelfPermission(context, android.Manifest.permission.BLUETOOTH_SCAN) == PackageManager.PERMISSION_GRANTED
        } else {
            ActivityCompat.checkSelfPermission(context, android.Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
        }
        
        android.util.Log.d("BluetoothSerialWorking", "Starting discovery - hasScanPermission: $hasScanPermission")
        
        if (hasScanPermission) {
            if (bluetoothAdapter?.isDiscovering == true) {
                bluetoothAdapter?.cancelDiscovery()
            }
            val discoveryStarted = bluetoothAdapter?.startDiscovery() ?: false
            android.util.Log.d("BluetoothSerialWorking", "Discovery started: $discoveryStarted")
            result.success(discoveryStarted)
        } else {
            android.util.Log.d("BluetoothSerialWorking", "No scan permission")
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
        android.util.Log.d("BluetoothSerialWorking", "=== CONNECT METHOD CALLED ===")
        android.util.Log.d("BluetoothSerialWorking", "Address: $address, Name: $name")
        
        val hasConnectPermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            ActivityCompat.checkSelfPermission(context, android.Manifest.permission.BLUETOOTH_CONNECT) == PackageManager.PERMISSION_GRANTED
        } else {
            true
        }

        if (!hasConnectPermission) {
            android.util.Log.d("BluetoothSerialWorking", "No connect permission")
            result.success(false)
            return
        }

        if (bluetoothAdapter == null) {
            android.util.Log.d("BluetoothSerialWorking", "Bluetooth adapter is null")
            result.success(false)
            return
        }

        if (bluetoothAdapter?.isEnabled != true) {
            android.util.Log.d("BluetoothSerialWorking", "Bluetooth is not enabled")
            result.success(false)
            return
        }

        try {
            android.util.Log.d("BluetoothSerialWorking", "Disconnecting from any existing connection...")
            disconnectSilently()

            val device = bluetoothAdapter?.getRemoteDevice(address)
            if (device == null) {
                android.util.Log.d("BluetoothSerialWorking", "Device not found: $address")
                result.success(false)
                return
            }

            android.util.Log.d("BluetoothSerialWorking", "Device found: ${device.name} (${device.address})")
            android.util.Log.d("BluetoothSerialWorking", "Device bond state: ${device.bondState}")

            // Cancel discovery
            if (bluetoothAdapter?.isDiscovering == true) {
                bluetoothAdapter?.cancelDiscovery()
            }

            // Create socket
            bluetoothSocket = try {
                android.util.Log.d("BluetoothSerialWorking", "Creating SPP socket...")
                device.createRfcommSocketToServiceRecord(SPP_UUID)
            } catch (e: Exception) {
                android.util.Log.d("BluetoothSerialWorking", "Failed to create SPP socket: ${e.message}")
                try {
                    val m = device.javaClass.getMethod("createRfcommSocket", Int::class.javaPrimitiveType)
                    m.invoke(device, 1) as BluetoothSocket
                } catch (e2: Exception) {
                    android.util.Log.d("BluetoothSerialWorking", "All methods failed: ${e2.message}")
                    result.success(false)
                    return
                }
            }
            
            android.util.Log.d("BluetoothSerialWorking", "Socket created successfully")
            
            // Connect in background thread
            Thread {
                try {
                    android.util.Log.d("BluetoothSerialWorking", "Connecting to device...")
                    bluetoothSocket?.connect()
                    
                    android.util.Log.d("BluetoothSerialWorking", "Socket connected: ${bluetoothSocket?.isConnected}")
                    
                    if (bluetoothSocket?.isConnected == true) {
                        inputStream = bluetoothSocket?.inputStream
                        outputStream = bluetoothSocket?.outputStream
                        
                        if (inputStream != null && outputStream != null) {
                            isConnected = true
                            connectedDevice = device
                            
                            android.util.Log.d("BluetoothSerialWorking", "✅ Connection successful!")
                            
                            // Start listening for data
                            startListeningForData()
                            
                            // Notify Flutter on main thread
                            (context as? android.app.Activity)?.runOnUiThread {
                                channel.invokeMethod("onConnectionStateChanged", mapOf("connected" to true))
                            }
                            result.success(true)
                        } else {
                            android.util.Log.d("BluetoothSerialWorking", "❌ Failed to get streams")
                            result.success(false)
                        }
                    } else {
                        android.util.Log.d("BluetoothSerialWorking", "❌ Socket not connected")
                        result.success(false)
                    }
                    
                } catch (e: Exception) {
                    android.util.Log.d("BluetoothSerialWorking", "❌ Connection failed: ${e.message}")
                    e.printStackTrace()
                    result.success(false)
                }
            }.start()

        } catch (e: Exception) {
            android.util.Log.d("BluetoothSerialWorking", "❌ Connection error: ${e.message}")
            e.printStackTrace()
            result.success(false)
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

            channel.invokeMethod("onConnectionStateChanged", mapOf("connected" to false))
            result.success(true)
        } catch (e: IOException) {
            e.printStackTrace()
            result.success(false)
        }
    }

    private fun sendData(data: String, result: Result) {
        if (!isConnected || outputStream == null) {
            result.success(false)
            return
        }

        try {
            outputStream?.write(data.toByteArray())
            outputStream?.flush()
            android.util.Log.d("BluetoothSerialWorking", "Sent: $data")
            result.success(true)
        } catch (e: IOException) {
            e.printStackTrace()
            result.success(false)
        }
    }

    private fun startListeningForData() {
        Thread {
            val buffer = ByteArray(1024)
            android.util.Log.d("BluetoothSerialWorking", "🎧 Starting data listening thread...")
            
            while (isConnected) {
                try {
                    val bytes = inputStream?.read(buffer)
                    if (bytes != null && bytes > 0) {
                        val data = String(buffer, 0, bytes)
                        android.util.Log.d("BluetoothSerialWorking", "📱 Received from Arduino: $data")
                        (context as? android.app.Activity)?.runOnUiThread {
                            channel.invokeMethod("onDataReceived", mapOf("data" to data))
                        }
                    } else if (bytes == -1) {
                        android.util.Log.d("BluetoothSerialWorking", "❌ Connection closed by Arduino")
                        break
                    }
                } catch (e: IOException) {
                    android.util.Log.d("BluetoothSerialWorking", "❌ Data listening error: ${e.message}")
                    e.printStackTrace()
                    break
                }
            }
            android.util.Log.d("BluetoothSerialWorking", "🔚 Data listening thread ended")
        }.start()
    }
}
