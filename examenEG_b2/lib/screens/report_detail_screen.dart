import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/pet_report.dart';
import '../providers/pet_reports_provider.dart';
import '../services/location_service.dart';

class ReportDetailScreen extends StatefulWidget {
  const ReportDetailScreen({super.key, required this.reportId});

  final String reportId;

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  final _locationService = LocationService();
  bool _isAddingSighting = false;

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    await launchUrl(uri);
  }

  Future<void> _whatsapp(String phone) async {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/$digits');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openDirections(double lat, double lng) async {
    final uri = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      final webUri = Uri.parse(
        'https://www.openstreetmap.org/?mlat=$lat&mlon=$lng#map=17/$lat/$lng',
      );
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _reportSighting(PetReport report) async {
    setState(() => _isAddingSighting = true);
    try {
      final position = await _locationService.getCurrentPosition();
      if (!mounted) return;
      final note = await showDialog<String>(
        context: context,
        builder: (context) => _SightingNoteDialog(),
      );
      if (note == null) return;
      if (!mounted) return;
      await context.read<PetReportsProvider>().addSighting(
            reportId: report.id,
            latitude: position.latitude,
            longitude: position.longitude,
            note: note,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avistamiento registrado en el mapa')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isAddingSighting = false);
    }
  }

  Future<void> _confirmDelete(PetReport report) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar reporte'),
        content: Text('¿Eliminar el reporte de ${report.name}? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<PetReportsProvider>().deleteReport(report.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PetReportsProvider>();
    final report = provider.byId(widget.reportId);

    if (report == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Este reporte ya no existe.')),
      );
    }

    final sortedSightings = List.of(report.sightings)
      ..sort((a, b) => a.reportedAt.compareTo(b.reportedAt));
    final points = [
      LatLng(report.latitude, report.longitude),
      ...sortedSightings.map((s) => LatLng(s.latitude, s.longitude)),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(report.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(report),
          ),
        ],
      ),
      body: ListView(
        children: [
          if (report.photoPath != null)
            Image.file(
              File(report.photoPath!),
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            )
          else
            Container(
              height: 160,
              color: Colors.grey.shade200,
              child: Icon(
                report.species == PetSpecies.dog ? Icons.pets : Icons.cruelty_free,
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        report.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    Chip(
                      label: Text(report.status.label),
                      backgroundColor: report.status == PetStatus.lost
                          ? Colors.deepOrange.shade50
                          : Colors.green.shade50,
                      labelStyle: TextStyle(
                        color: report.status == PetStatus.lost
                            ? Colors.deepOrange.shade700
                            : Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${report.species.label}'
                  '${report.breed.isNotEmpty ? ' · ${report.breed}' : ''}'
                  ' · ${report.color}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Text(report.description),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.place, size: 18, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        report.address ??
                            '${report.latitude.toStringAsFixed(5)}, ${report.longitude.toStringAsFixed(5)}',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Visto por última vez: ${DateFormat('d MMM y, HH:mm', 'es').format(report.createdAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 220,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(report.latitude, report.longitude),
                        initialZoom: 15,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.examen.petfinder.pet_finder',
                        ),
                        if (points.length > 1)
                          PolylineLayer(polylines: [
                            Polyline(
                              points: points,
                              color: Colors.blue.shade400,
                              strokeWidth: 3,
                              pattern: const StrokePattern.dotted(),
                            ),
                          ]),
                        MarkerLayer(markers: [
                          Marker(
                            point: LatLng(report.latitude, report.longitude),
                            width: 40,
                            height: 40,
                            alignment: Alignment.bottomCenter,
                            child: Icon(
                              Icons.location_on,
                              color: report.status == PetStatus.lost
                                  ? Colors.deepOrange
                                  : Colors.green,
                              size: 40,
                            ),
                          ),
                          for (final s in sortedSightings)
                            Marker(
                              point: LatLng(s.latitude, s.longitude),
                              width: 18,
                              height: 18,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade700,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                        ]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _openDirections(report.latitude, report.longitude),
                      icon: const Icon(Icons.directions),
                      label: const Text('Cómo llegar'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _isAddingSighting ? null : () => _reportSighting(report),
                      icon: const Icon(Icons.visibility),
                      label: const Text('Reportar avistamiento'),
                    ),
                  ],
                ),
                if (sortedSightings.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Avistamientos', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  for (final s in sortedSightings)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.visibility, color: Colors.blue),
                      title: Text(s.note),
                      subtitle: Text(DateFormat('d MMM y, HH:mm', 'es').format(s.reportedAt)),
                    ),
                ],
                const Divider(height: 32),
                Text('Contacto', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(report.contactName),
                Text(report.contactPhone),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _call(report.contactPhone),
                        icon: const Icon(Icons.call),
                        label: const Text('Llamar'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(backgroundColor: Colors.green.shade600),
                        onPressed: () => _whatsapp(report.contactPhone),
                        icon: const Icon(Icons.chat),
                        label: const Text('WhatsApp'),
                      ),
                    ),
                  ],
                ),
                if (report.status == PetStatus.lost) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context.read<PetReportsProvider>().markAsFound(report.id),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Marcar como encontrado'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SightingNoteDialog extends StatefulWidget {
  @override
  State<_SightingNoteDialog> createState() => _SightingNoteDialogState();
}

class _SightingNoteDialogState extends State<_SightingNoteDialog> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('¿Dónde la viste?'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: 2,
        decoration: const InputDecoration(
          hintText: 'Ej. Cerca del parque, cruzando la calle...',
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            _controller.text.trim().isEmpty ? 'Avistamiento sin nota' : _controller.text.trim(),
          ),
          child: const Text('Registrar'),
        ),
      ],
    );
  }
}
