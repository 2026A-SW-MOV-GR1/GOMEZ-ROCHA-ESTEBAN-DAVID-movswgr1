import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ResourcesApp());
}

class ResourcesApp extends StatefulWidget {
  const ResourcesApp({super.key});

  @override
  State<ResourcesApp> createState() => _ResourcesAppState();
}

class _ResourcesAppState extends State<ResourcesApp> with WidgetsBindingObserver {
  static const _channel = MethodChannel('android_resources');

  String _saludo = '';
  Color _textColor = const Color(0xFF000000);
  Color _backgroundColor = const Color(0xFFFFFFFF);
  String _debug = '';

  Future<void> _reloadFromAndroid() async {
    try {
      final bundle = await _channel.invokeMethod<Map>('getBundle', {
        'strings': ['saludo'],
        'colors': ['text_color', 'background_color'],
      });

      final strings = (bundle?['strings'] as Map?)?.cast<String, Object?>();
      final colors = (bundle?['colors'] as Map?)?.cast<String, Object?>();
      final debug = (bundle?['debug'] as Map?)?.cast<String, Object?>();

      final saludo = (strings?['saludo'] as String?) ?? '(sin saludo)';
      final textColorInt = colors?['text_color'] as int?;
      final bgColorInt = colors?['background_color'] as int?;

      setState(() {
        _saludo = saludo;
        if (textColorInt != null) _textColor = Color(textColorInt);
        if (bgColorInt != null) _backgroundColor = Color(bgColorInt);
        _debug = debug == null
            ? ''
            : 'locales=${debug['locales']} orientation=${debug['orientation']}';
      });
    } on PlatformException catch (e) {
      setState(() {
        _saludo = 'Error: ${e.code} ${e.message}';
        _debug = '';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_reloadFromAndroid());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    // Cambio de idioma del sistema → recargar recursos Android.
    unawaited(_reloadFromAndroid());
  }

  @override
  void didChangeMetrics() {
    // Rotación / cambio de tamaño → recargar recursos Android (values-land, etc).
    unawaited(_reloadFromAndroid());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: _backgroundColor,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _saludo,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_debug.isNotEmpty)
                    Text(
                      _debug,
                      style: TextStyle(color: _textColor.withOpacity(0.7)),
                    ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _reloadFromAndroid,
                    child: const Text('Recargar desde Android'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

