import 'dart:io';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../models/pet_report.dart';
import '../providers/pet_reports_provider.dart';
import '../services/location_service.dart';
import 'report_detail_screen.dart';

class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key, this.myLocation});

  final LatLng? myLocation;

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  final _locationService = LocationService();
  PetSpecies? _speciesFilter;

  @override
  Widget build(BuildContext context) {
    final reports = context.watch<PetReportsProvider>().reports.where((r) {
      if (_speciesFilter != null && r.species != _speciesFilter) return false;
      return true;
    }).toList();

    if (widget.myLocation != null) {
      reports.sort((a, b) {
        final da = _locationService.distanceInMeters(
          widget.myLocation!,
          LatLng(a.latitude, a.longitude),
        );
        final db = _locationService.distanceInMeters(
          widget.myLocation!,
          LatLng(b.latitude, b.longitude),
        );
        return da.compareTo(db);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Todos'),
                  selected: _speciesFilter == null,
                  onSelected: (_) => setState(() => _speciesFilter = null),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Perros'),
                  selected: _speciesFilter == PetSpecies.dog,
                  onSelected: (_) => setState(() => _speciesFilter = PetSpecies.dog),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Gatos'),
                  selected: _speciesFilter == PetSpecies.cat,
                  onSelected: (_) => setState(() => _speciesFilter = PetSpecies.cat),
                ),
              ],
            ),
          ),
        ),
      ),
      body: reports.isEmpty
          ? const Center(child: Text('No hay reportes todavía.'))
          : ListView.separated(
              itemCount: reports.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final report = reports[index];
                final distanceLabel = widget.myLocation != null
                    ? _locationService.formatDistance(
                        _locationService.distanceInMeters(
                          widget.myLocation!,
                          LatLng(report.latitude, report.longitude),
                        ),
                      )
                    : null;
                return ListTile(
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage:
                        report.photoPath != null ? FileImage(File(report.photoPath!)) : null,
                    child: report.photoPath == null
                        ? Icon(
                            report.species == PetSpecies.dog ? Icons.pets : Icons.cruelty_free,
                            color: Colors.grey.shade500,
                          )
                        : null,
                  ),
                  title: Text(report.name),
                  subtitle: Text(
                    '${report.species.label}${report.breed.isNotEmpty ? ' · ${report.breed}' : ''}',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Chip(
                        label: Text(
                          report.status.label,
                          style: const TextStyle(fontSize: 11),
                        ),
                        backgroundColor: report.status == PetStatus.lost
                            ? Colors.deepOrange.shade50
                            : Colors.green.shade50,
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      if (distanceLabel != null) ...[
                        const SizedBox(height: 4),
                        Text(distanceLabel, style: const TextStyle(fontSize: 11)),
                      ],
                    ],
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ReportDetailScreen(reportId: report.id),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
