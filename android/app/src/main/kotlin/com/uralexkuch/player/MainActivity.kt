package com.uralexkuch.player

import android.view.KeyEvent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {

    private var volumeEventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // EventChannel для передачі натискань Volume у Flutter
        // Використовується для Panic Wipe (Volume Down x3)
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.molitovnik/volume"
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                volumeEventSink = events
            }
            override fun onCancel(arguments: Any?) {
                volumeEventSink = null
            }
        })
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        return when (keyCode) {
            KeyEvent.KEYCODE_VOLUME_DOWN -> {
                volumeEventSink?.success("volumeDown")
                true // перехоплюємо кнопку (без зміни гучності)
            }
            else -> super.onKeyDown(keyCode, event)
        }
    }
}
