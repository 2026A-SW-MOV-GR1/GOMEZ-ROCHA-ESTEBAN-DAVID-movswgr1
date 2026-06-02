import 'package:flutter/material.dart';
import '../services/secrets_service.dart';

class SecretsScreen extends StatefulWidget {
  const SecretsScreen({super.key});

  @override
  State<SecretsScreen> createState() => _SecretsScreenState();
}

class _SecretsScreenState extends State<SecretsScreen> {
  final _llaveCtrl = TextEditingController();
  final _valorCtrl = TextEditingController();

  MecanismoStorage _mecanismo = MecanismoStorage.sharedPreferences;
  String? _resultadoRecuperar;
  bool    _guardado   = false;
  bool    _noEncontrado = false;
  bool    _cargando   = false;

  // Configuración visual de cada mecanismo
  Map<MecanismoStorage, Map<String, dynamic>> get _config => {
    MecanismoStorage.sharedPreferences: {
      'label': 'SharedPreferences',
      'descripcion': 'Clave-Valor simple · No cifrado',
      'color': Colors.blue,
      'icono': Icons.storage,
      'nativo': 'SharedPreferences (Android)',
    },
    MecanismoStorage.dataStore: {
      'label': 'DataStore',
      'descripcion': 'Clave-Valor asíncrono · No cifrado',
      'color': Colors.teal,
      'icono': Icons.data_object,
      'nativo': 'DataStore (Android)',
    },
    MecanismoStorage.encryptedSharedPreferences: {
      'label': 'EncryptedSharedPreferences',
      'descripcion': 'Clave-Valor cifrado · AES-256',
      'color': Colors.purple,
      'icono': Icons.lock,
      'nativo': 'EncryptedSharedPreferences (Android)',
    },
  };

  Future<void> _guardar() async {
    if (_llaveCtrl.text.isEmpty || _valorCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa llave y valor')),
      );
      return;
    }
    setState(() { _cargando = true; _guardado = false; _noEncontrado = false; _resultadoRecuperar = null; });
    await SecretsService.guardar(_llaveCtrl.text, _valorCtrl.text, _mecanismo);
    setState(() { _cargando = false; _guardado = true; });
  }

  Future<void> _recuperar() async {
    if (_llaveCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa una llave para recuperar')),
      );
      return;
    }
    setState(() { _cargando = true; _guardado = false; _noEncontrado = false; _resultadoRecuperar = null; });
    final valor = await SecretsService.recuperar(_llaveCtrl.text, _mecanismo);
    setState(() {
      _cargando = false;
      if (valor != null) {
        _resultadoRecuperar = valor;
      } else {
        _noEncontrado = true;
      }
    });
  }

  @override
  void dispose() {
    _llaveCtrl.dispose();
    _valorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cfg = _config[_mecanismo]!;
    final color = cfg['color'] as MaterialColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Secretos'),
        centerTitle: true,
        backgroundColor: color.shade100,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── Selector de mecanismo ──────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Compartimento de almacenamiento',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  ...MecanismoStorage.values.map((m) {
                    final c = _config[m]!;
                    final col = c['color'] as MaterialColor;
                    return RadioListTile<MecanismoStorage>(
                      value: m,
                      groupValue: _mecanismo,
                      onChanged: (v) => setState(() {
                        _mecanismo = v!;
                        _guardado = false;
                        _noEncontrado = false;
                        _resultadoRecuperar = null;
                      }),
                      title: Row(
                        children: [
                          Icon(c['icono'] as IconData,
                              size: 18, color: col.shade700),
                          const SizedBox(width: 8),
                          Text(c['label'] as String,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13)),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c['descripcion'] as String,
                              style: const TextStyle(fontSize: 12)),
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: col.shade50,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: col.shade200),
                            ),
                            child: Text(
                              'Nativo: ${c['nativo']}',
                              style: TextStyle(
                                  fontSize: 10, color: col.shade800),
                            ),
                          ),
                        ],
                      ),
                      activeColor: col,
                    );
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Inputs ────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _llaveCtrl,
                    decoration: InputDecoration(
                      labelText: 'Llave (Key)',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.key),
                      filled: true,
                      fillColor: color.shade50,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _valorCtrl,
                    decoration: InputDecoration(
                      labelText: 'Valor (Value)',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.edit_note),
                      filled: true,
                      fillColor: color.shade50,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _cargando ? null : _guardar,
                          icon: const Icon(Icons.save),
                          label: const Text('Guardar'),
                          style: FilledButton.styleFrom(
                            backgroundColor: color,
                            minimumSize: const Size.fromHeight(48),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _cargando ? null : _recuperar,
                          icon: const Icon(Icons.search),
                          label: const Text('Recuperar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: color,
                            side: BorderSide(color: color),
                            minimumSize: const Size.fromHeight(48),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Resultados ────────────────────────────
          if (_cargando)
            const Center(child: CircularProgressIndicator()),

          if (_guardado)
            Card(
              color: Colors.green.shade50,
              child: ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('¡Guardado correctamente!',
                    style: TextStyle(
                        color: Colors.green, fontWeight: FontWeight.w600)),
                subtitle: Text(
                    'Llave "${_llaveCtrl.text}" almacenada en ${cfg['label']}'),
              ),
            ),

          if (_resultadoRecuperar != null)
            Card(
              color: color.shade50,
              child: ListTile(
                leading: Icon(cfg['icono'] as IconData, color: color),
                title: Text('Valor recuperado de ${cfg['label']}',
                    style: TextStyle(
                        color: color.shade800, fontWeight: FontWeight.w600)),
                subtitle: Text(_resultadoRecuperar!,
                    style: const TextStyle(fontSize: 16)),
              ),
            ),

          if (_noEncontrado)
            Card(
              color: Colors.red.shade50,
              child: ListTile(
                leading: const Icon(Icons.search_off, color: Colors.red),
                title: const Text('Secreto no encontrado',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w600)),
                subtitle: Text(
                    'La llave "${_llaveCtrl.text}" no existe en ${cfg['label']}'),
              ),
            ),
        ],
      ),
    );
  }
}