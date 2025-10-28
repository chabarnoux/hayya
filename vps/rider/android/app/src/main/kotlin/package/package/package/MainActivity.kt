package com.hayyaride.rider

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log
import android.widget.Toast

class MainActivity: FlutterActivity() {
    private val channel = "flutter.app/fcm"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            if (call.method == "logToken") {
                val token = call.argument<String>("token")
                Log.d("FCM_TOKEN", token ?: "")
                Toast.makeText(applicationContext, "FCM token ready", Toast.LENGTH_SHORT).show()
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }
}
