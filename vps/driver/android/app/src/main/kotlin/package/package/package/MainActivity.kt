package com.hayyaride.driver

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.content.BroadcastReceiver
import android.content.Context
import android.util.Log
import android.os.Bundle
import android.content.IntentFilter

class MainActivity: FlutterFragmentActivity() {
    private val channel = "flutter.app/fcm"
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
      if(call.method == "logToken"){
          val token = call.argument<String>("token")
          Log.d("FCM_TOKEN", token ?: "")
          result.success(null)
      } else {
          result.notImplemented()
      }
    }
    }
      private fun awakeapp(){ }
}
