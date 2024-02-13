package com.alamintijarahresources.mukminapps
import android.media.RingtoneManager
import android.content.Context
import android.content.IntentFilter
import android.net.wifi.WifiManager
import android.os.Bundle
import android.os.PersistableBundle
import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.lang.reflect.Method

class MainActivity: FlutterActivity() {
    private val CHANNEL = "flutter.native/helper"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        super.configureFlutterEngine(flutterEngine)
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler(VideoPlayer360Plugin(this))
         MethodChannel(flutterEngine.dartExecutor.binaryMessenger,"dexterx.dev/flutter_local_notifications_example").setMethodCallHandler { call, result ->
           
            if ("getAlarmUri" == call.method) {
                result.success(RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM).toString())
            }
        }

    }

}
