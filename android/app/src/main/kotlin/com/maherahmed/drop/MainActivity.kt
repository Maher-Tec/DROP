package com.maherahmed.drop

import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var widgetChannel: MethodChannel? = null
    private var pendingWidgetAction: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            setRecentsScreenshotEnabled(false)
        } else {
            // Older Android has no preview-only API. Also prevents screen capture.
            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val action = intent.getStringExtra(QuickDropWidgetProvider.EXTRA_ACTION) ?: return
        if (widgetChannel == null) {
            pendingWidgetAction = action
        } else {
            widgetChannel?.invokeMethod("widgetAction", action)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        pendingWidgetAction =
            intent?.getStringExtra(QuickDropWidgetProvider.EXTRA_ACTION) ?: pendingWidgetAction
        widgetChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            WIDGET_CHANNEL,
        ).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInitialAction" -> {
                        result.success(pendingWidgetAction)
                        pendingWidgetAction = null
                        intent?.removeExtra(QuickDropWidgetProvider.EXTRA_ACTION)
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    companion object {
        private const val WIDGET_CHANNEL = "com.maherahmed.drop/widget_launch"
    }
}
