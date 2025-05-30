package com.example.new_raksha

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.calls"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "makeCall") {
                val number = call.argument<String>("number")
                if (number != null && number.isNotEmpty()) {
                    try {
                        val intent = Intent(Intent.ACTION_CALL)
                        intent.data = Uri.parse("tel:$number")
                        startActivity(intent)
                        result.success("Calling $number")
                    } catch (e: Exception) {
                        result.error("CALL_ERROR", "Failed to make a call", e.message)
                    }
                } else {
                    result.error("INVALID_NUMBER", "Phone number is null or empty", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
