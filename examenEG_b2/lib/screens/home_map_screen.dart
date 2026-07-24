import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../models/pet_report.dart';
import '../providers/pet_reports_provider.dart';
import '../services/location_service.dart';
import '../widgets/pet_marker.dart';
import 'report_detail_screen.dart';
import 'report_form_screen.dart';
import 'report_list_screen.dart';

/// Ubicación de respaldo (Quito, Ecuador) si no se puede obtener el GPS.
const _fallbackCenter = LatLng(-0.1807, -78.4678);

class HomeMapScreen extends StatefulWidget {
  const HomeMapScreen({super.key});

  @override
  State<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends State<HomeMapScreen> {
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();

  PetSpecies? _speciesFilter;
  bool _onlyLost = false;
  LatLng? _myLocation;

  @override
  void initState() {
    super.initState();
    _centerOnMyLocation(showErrors: false);
  }

  Future<void> _centerOnMyLocation({bool showErrors = true}) async {
    try {
      final position = await _locationService.getCurrentPosition();
      final latLng = LatLng(position.latitude, position.longitude);
      setState(() => _myLocation = latLng);
      _mapController.move(latLng, 15);
    } catch (e) {
      if (showErrors && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  List<PetReport> _applyFilters(List<PetReport> reports) {
    return reports.where((r) {
      if (_speciesFilter != null && r.species != _speciesFilter) return false;
      if (_onlyLost && r.status != PetStatus.lost) return false;
      return true;
    }).toList();
  }

  Future<void> _openForm() async {
    final created = await Navigator.of(context).push<PetReport>(
      MaterialPageRoute(
        builder: (_) => ReportFormScreen(initialCenter: _myLocation ?? _fallbackCenter),
      ),
    );
    if (created != null) {
      _mapController.move(LatLng(created.latitude, created.longitude), 16);
    }
  }

  void _openDetail(PetReport report) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ReportDetailScreen(reportId: report.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PetReportsProvider>();
    final reports = _applyFilters(provider.reports);

    final markers = <Marker>[
      for (final report in reports)
        Marker(
          point: LatLng(report.latitude, report.longitude),
          width: 46,
          height: 54,
          alignment: Alignment.bottomCenter,
          child: PetMarker(
            species: report.species,
            status: report.status,
            onTap: () => _openDetail(report),
          ),
        ),
      for (final report in reports)
        for (final sighting in report.sightings)
          Marker(
            point: LatLng(sighting.latitude, sighting.longitude),
            width: 18,
            height: 18,
            child: SightingDot(onTap: () => _openDetail(report)),
          ),
      if (_myLocation != null)
        Marker(
          point: _myLocation!,
          width: 20,
          height: 20,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
          ),
        ),
    ];

    final polylines = <Polyline>[
      for (final report in reports)
        if (report.sightings.isNotEmpty)
          Polyline(
            points: [
              LatLng(report.latitude, report.longitude),
              ...(List.of(report.sightings)
                    ..sort((a, b) => a.reportedAt.compareTo(b.reportedAt)))
                  .map((s) => LatLng(s.latitude, s.longitude)),
            ],
            color: Colors.blue.shade400,
            strokeWidth: 3,
            pattern: const StrokePattern.dotted(),
          ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mascotas Perdidas'),
        actions: [
          IconButton(
            tooltip: 'Ver lista',
            icon: const Icon(Icons.list_alt),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ReportListScreen(myLocation: _myLocation),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterBar(
            speciesFilter: _speciesFilter,
            onlyLost: _onlyLost,
            onSpeciesChanged: (s) => setState(() => _speciesFilter = s),
            onOnlyLostChanged: (v) => setState(() => _onlyLost = v),
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _myLocation ?? _fallbackCenter,
                    initialZoom: 13,
                    minZoom: 3,
                    maxZoom: 18,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.examen.petfinder.pet_finder',
                    ),
                    PolylineLayer(polylines: polylines),
                    MarkerLayer(markers: markers),
                    const RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution('© OpenStreetMap contributors'),
                      ],
                    ),
                  ],
                ),
                if (provider.isLoading)
                  const Positioned.fill(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: FloatingActionButton(
                    heroTag: 'my-location',
                    mini: true,
                    onPressed: () => _centerOnMyLocation(showErrors: true),
                    child: const Icon(Icons.my_location),
                  ),
                ),
                const Positioned(left: 12, bottom: 12, child: _MapLegend()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Reportar mascota'),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.speciesFilter,
    required this.onlyLost,
    required this.onSpeciesChanged,
    required this.onOnlyLostChanged,
  });

  final PetSpecies? speciesFilter;
  final bool onlyLost;
  final ValueChanged<PetSpecies?> onSpeciesChanged;
  final ValueChanged<bool> onOnlyLostChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('Todos'),
                    selected: speciesFilter == null,
                    onSelected: (_) => onSpeciesChanged(null),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: const Icon(Icons.pets, size: 18),
                    label: const Text('Perros'),
                    selected: speciesFilter == PetSpecies.dog,
                    onSelected: (_) => onSpeciesChanged(PetSpecies.dog),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: const Icon(Icons.cruelty_free, size: 18),
                    label: const Text('Gatos'),
                    selected: speciesFilter == PetSpecies.cat,
                    onSelected: (_) => onSpeciesChanged(PetSpecies.cat),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Text('Solo perdidos', style: TextStyle(fontSize: 12)),
          Switch(value: onlyLost, onChanged: onOnlyLostChanged),
        ],
      ),
    );
  }
}

class _MapLegend extends StatelessWidget {
  const _MapLegend();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _LegendItem(color: Colors.deepOrange, label: 'Perdido'),
          _LegendItem(color: Colors.green, label: 'Encontrado'),
          _LegendItem(color: Colors.blue, label: 'Avistamiento'),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
