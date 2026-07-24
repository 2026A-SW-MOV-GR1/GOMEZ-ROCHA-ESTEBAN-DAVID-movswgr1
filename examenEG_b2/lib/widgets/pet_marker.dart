import 'package:flutter/material.dart';

import '../models/pet_report.dart';

/// Pin personalizado para un reporte de mascota: color e ícono cambian
/// según especie (perro/gato) y estado (perdido/encontrado).
class PetMarker extends StatelessWidget {
  const PetMarker({
    super.key,
    required this.species,
    required this.status,
    this.size = 44,
    this.onTap,
  });

  final PetSpecies species;
  final PetStatus status;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = status == PetStatus.found
        ? Colors.green.shade600
        : Colors.deepOrange.shade600;
    final icon = species == PetSpecies.dog ? Icons.pets : Icons.cruelty_free;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: const [
                BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: size * 0.55),
          ),
          CustomPaint(
            size: const Size(10, 6),
            painter: _TrianglePainter(color: color),
          ),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  _TrianglePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Punto pequeño usado para marcar avistamientos en el mapa.
class SightingDot extends StatelessWidget {
  const SightingDot({super.key, this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: Colors.blue.shade700,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 1)),
          ],
        ),
      ),
    );
  }
}
