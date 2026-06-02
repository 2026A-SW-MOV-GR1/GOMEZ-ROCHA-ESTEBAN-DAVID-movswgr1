import 'package:flutter/services.dart';

class ToastChannel {
  static const _channel = MethodChannel('com.example.resources/native');

  static Future<void> mostrar(String mensaje) async {
    try {
      await _channel.invokeMethod('showToast', {'message': mensaje});
    } on PlatformException catch (e) {
      print('Error Toast: ${e.message}');
    }
  }
}