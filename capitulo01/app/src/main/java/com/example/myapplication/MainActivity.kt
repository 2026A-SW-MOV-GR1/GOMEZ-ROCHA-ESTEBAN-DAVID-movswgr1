package com.example.myapplication

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.example.resources/native"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getResources" -> {
                    val ctx = this@MainActivity
                    val text          = ctx.getString(R.string.greeting)
                    val textColorInt  = ctx.getColor(R.color.text_color)
                    val bgColorInt    = ctx.getColor(R.color.background_color)
                    val textColorHex  = "#%06X".format(textColorInt and 0xFFFFFF)
                    val bgColorHex    = "#%06X".format(bgColorInt and 0xFFFFFF)
                    result.success(mapOf(
                        "text"            to text,
                        "textColor"       to textColorHex,
                        "backgroundColor" to bgColorHex
                    ))
                }
                "showToast" -> {
                    val message = call.argument<String>("message") ?: ""
                    android.widget.Toast.makeText(
                        this@MainActivity,
                        message,
                        android.widget.Toast.LENGTH_SHORT
                    ).show()
                    result.success(null)
                }
                "saveCount" -> {
                    val count = call.argument<Int>("count") ?: 0
                    getSharedPreferences("lifecycle", MODE_PRIVATE)
                        .edit()
                        .putInt("count", count)
                        .apply()
                    result.success(null)
                }
                "getCount" -> {
                    val count = getSharedPreferences("lifecycle", MODE_PRIVATE)
                        .getInt("count", 0)
                    result.success(count)
                }
                else -> result.notImplemented()
            }
        }
    }
}