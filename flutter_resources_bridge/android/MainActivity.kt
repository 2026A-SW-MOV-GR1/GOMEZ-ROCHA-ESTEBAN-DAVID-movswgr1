package com.example.flutter_resources_bridge

import android.content.res.Resources
import androidx.annotation.ColorInt
import androidx.core.content.res.ResourcesCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "android_resources"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getString" -> handleGetString(call, result)
                    "getColor" -> handleGetColor(call, result)
                    "getBundle" -> handleGetBundle(call, result)
                    else -> result.notImplemented()
                }
            }
    }

    private fun handleGetString(call: MethodCall, result: MethodChannel.Result) {
        val name = call.argument<String>("name")
        if (name.isNullOrBlank()) {
            result.error("bad_args", "Missing 'name' for getString", null)
            return
        }

        val id = resources.getIdentifier(name, "string", packageName)
        if (id == 0) {
            result.error("not_found", "String resource '$name' not found", null)
            return
        }

        // Usa el Context/Resources actuales del Activity: respeta idioma/orientación vigentes.
        result.success(getString(id))
    }

    private fun handleGetColor(call: MethodCall, result: MethodChannel.Result) {
        val name = call.argument<String>("name")
        if (name.isNullOrBlank()) {
            result.error("bad_args", "Missing 'name' for getColor", null)
            return
        }

        val id = resources.getIdentifier(name, "color", packageName)
        if (id == 0) {
            result.error("not_found", "Color resource '$name' not found", null)
            return
        }

        @ColorInt val colorInt = ResourcesCompat.getColor(resources, id, theme)
        // Enviar como Int ARGB (Flutter lo puede convertir a Color).
        result.success(colorInt)
    }

    private fun handleGetBundle(call: MethodCall, result: MethodChannel.Result) {
        val strings = call.argument<List<String>>("strings") ?: emptyList()
        val colors = call.argument<List<String>>("colors") ?: emptyList()

        val out = mutableMapOf<String, Any?>()
        out["strings"] = resolveStrings(resources, strings)
        out["colors"] = resolveColors(resources, colors)

        // Extra: útil para depurar qué configuración está activa.
        val c = resources.configuration
        out["debug"] = mapOf(
            "locales" to c.locales.toLanguageTags(),
            "orientation" to c.orientation
        )

        result.success(out)
    }

    private fun resolveStrings(res: Resources, names: List<String>): Map<String, String?> {
        val map = LinkedHashMap<String, String?>()
        for (name in names) {
            val id = res.getIdentifier(name, "string", packageName)
            map[name] = if (id == 0) null else getString(id)
        }
        return map
    }

    private fun resolveColors(res: Resources, names: List<String>): Map<String, Int?> {
        val map = LinkedHashMap<String, Int?>()
        for (name in names) {
            val id = res.getIdentifier(name, "color", packageName)
            map[name] = if (id == 0) null else ResourcesCompat.getColor(res, id, theme)
        }
        return map
    }
}

