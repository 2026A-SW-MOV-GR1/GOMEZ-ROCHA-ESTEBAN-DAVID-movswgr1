import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  final Distance _distanceCalculator = const Distance();
  final Geocoding _geocoding = Geocoding();

  /// Solicita permisos y devuelve la posición actual del dispositivo.
  /// Lanza [Exception] con un mensaje entendible si no es posible obtenerla.
  Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('El GPS está desactivado. Actívalo e inténtalo de nuevo.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permiso de ubicación denegado.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Permiso de ubicación bloqueado permanentemente. Habilítalo desde ajustes.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  /// Convierte coordenadas en una dirección legible. Devuelve null si falla
  /// (por ejemplo sin conexión), sin interrumpir el flujo de la app.
  Future<String?> reverseGeocode(double latitude, double longitude) async {
    try {
      final placemarks = await _geocoding.placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) return null;
      final p = placemarks.first;
      final parts = [p.street, p.subLocality, p.locality, p.administrativeArea]
          .whereType<String>()
          .where((part) => part.trim().isNotEmpty)
          .toList();
      return parts.isEmpty ? null : parts.join(', ');
    } catch (_) {
      return null;
    }
  }

  /// Distancia en metros entre dos coordenadas.
  double distanceInMeters(LatLng a, LatLng b) {
    return _distanceCalculator.as(LengthUnit.Meter, a, b);
  }

  String formatDistance(double meters) {
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }
}