import 'package:flutter/material.dart';
import '../services/post_service.dart';

class RestScreen extends StatefulWidget {
  const RestScreen({super.key});

  @override
  State<RestScreen> createState() => _RestScreenState();
}

class _RestScreenState extends State<RestScreen> {
  final _idCtrl      = TextEditingController();
  final _titleCtrl   = TextEditingController();
  final _bodyCtrl    = TextEditingController();

  Post?   _post;
  bool    _loading       = false;
  bool    _actualizado   = false;
  String? _error;

  Future<void> _obtener() async {
    final id = int.tryParse(_idCtrl.text);
    if (id == null || id < 1 || id > 100) {
      setState(() => _error = 'Ingresa un ID entre 1 y 100');
      return;
    }
    setState(() { _loading = true; _error = null; _actualizado = false; });
    try {
      final post = await PostService.getPost(id);
      setState(() {
        _post = post;
        _titleCtrl.text = post.title;
        _bodyCtrl.text  = post.body;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _actualizar() async {
    if (_post == null) return;
    setState(() { _loading = true; _error = null; _actualizado = false; });
    try {
      _post!.title = _titleCtrl.text;
      _post!.body  = _bodyCtrl.text;
      final updated = await PostService.updatePost(_post!);
      setState(() {
        _post       = updated;
        _actualizado = true;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JSONPlaceholder API'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── Sección GET ──────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.cloud_download, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text('GET /posts/{id}',
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _idCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'ID del post (1-100)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.tag),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: _loading ? null : _obtener,
                        icon: const Icon(Icons.search),
                        label: const Text('Obtener'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Estado: cargando / error / éxito ────────
          if (_loading)
            const Center(child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            )),

          if (_error != null)
            Card(
              color: Colors.red.shade50,
              child: ListTile(
                leading: const Icon(Icons.error, color: Colors.red),
                title: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            ),

          if (_actualizado)
            Card(
              color: Colors.green.shade50,
              child: const ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: Text('¡Actualizado correctamente! (200 OK)',
                    style: TextStyle(color: Colors.green,
                        fontWeight: FontWeight.w600)),
                subtitle: Text('El servidor respondió con el JSON modificado'),
              ),
            ),

          // ── Formulario editable (PUT) ────────────────
          if (_post != null) ...[
            const SizedBox(height: 4),
            Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(     // ← Column sí tiene children
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.edit, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text('PUT /posts/${_post!.id}',
                          style: Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('ID: ${_post!.id}',
                            style: TextStyle(
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.w600,
                                fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _bodyCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Contenido',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.article),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _loading ? null : _actualizar,
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Actualizar'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ],
        ],
      ),
    );
  }
}