import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LifecycleScreen extends StatefulWidget {
  const LifecycleScreen({super.key});

  @override
  State<LifecycleScreen> createState() => _LifecycleScreenState();
}

class _LifecycleScreenState extends State<LifecycleScreen>
    with WidgetsBindingObserver {
  static const _channel = MethodChannel('com.example.resources/native');
  int _count = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cargarContador();
    debugPrint('🟢 [LIFECYCLE] onCreate → initState() ejecutado');
    debugPrint('🟢 [LIFECYCLE] onStart  → Widget montado en el árbol');
  }

  Future<void> _cargarContador() async {
    final count = await _channel.invokeMethod<int>('getCount') ?? 0;
    setState(() => _count = count);
  }

  Future<void> _incrementar() async {
    setState(() => _count++);
    await _channel.invokeMethod('saveCount', {'count': _count});
    debugPrint('🔢 [COUNTER] Contador incrementado a: $_count');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint('🟢 [LIFECYCLE] onRestart + onResume → resumed');
        break;
      case AppLifecycleState.inactive:
        debugPrint('🟡 [LIFECYCLE] onPause → inactive');
        break;
      case AppLifecycleState.hidden:
        debugPrint('🔴 [LIFECYCLE] onStop → hidden');
        break;
      case AppLifecycleState.detached:
        debugPrint('💀 [LIFECYCLE] onDestroy → detached');
        break;
      case AppLifecycleState.paused:
        debugPrint('🔴 [LIFECYCLE] onPause completo → paused');
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    debugPrint('💀 [LIFECYCLE] onDestroy → dispose() ejecutado');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ciclo de Vida'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(height: 8),
                  Text(
                    'Sube el contador a 10 y luego:\n'
                        '1. Rota la pantalla\n'
                        '2. Ve al Home y vuelve\n'
                        '3. Observa los logs en consola',
                    style: TextStyle(
                        color: Colors.blue.shade800, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            Text(
              '$_count',
              style: const TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('presiones',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _incrementar,
              icon: const Icon(Icons.add),
              label: const Text('Sumar +1'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(200, 56),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                setState(() => _count = 0);
                PageStorage.of(context).writeState(context, 0, identifier: 'count');
                debugPrint('🔄 [COUNTER] Contador reseteado a 0');
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Resetear'),
            ),
          ],
        ),
      ),
    );
  }
}