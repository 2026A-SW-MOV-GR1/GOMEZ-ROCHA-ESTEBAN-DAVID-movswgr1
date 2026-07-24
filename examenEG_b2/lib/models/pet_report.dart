enum PetSpecies { dog, cat }

enum PetStatus { lost, found }

extension PetSpeciesLabel on PetSpecies {
  String get label => this == PetSpecies.dog ? 'Perro' : 'Gato';
}

extension PetStatusLabel on PetStatus {
  String get label => this == PetStatus.lost ? 'Perdido' : 'Encontrado';
}

/// Un avistamiento reportado por la comunidad en una ubicación y momento
/// distintos al del reporte original. Permite reconstruir el recorrido
/// probable de la mascota sobre el mapa.
class Sighting {
  final String id;
  final double latitude;
  final double longitude;
  final String note;
  final DateTime reportedAt;

  Sighting({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.note,
    required this.reportedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'latitude': latitude,
        'longitude': longitude,
        'note': note,
        'reportedAt': reportedAt.toIso8601String(),
      };

  factory Sighting.fromJson(Map<String, dynamic> json) => Sighting(
        id: json['id'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        note: json['note'] as String,
        reportedAt: DateTime.parse(json['reportedAt'] as String),
      );
}

class PetReport {
  final String id;
  final String name;
  final PetSpecies species;
  final String breed;
  final String color;
  final String description;
  final String contactName;
  final String contactPhone;
  final String? photoPath;
  final double latitude;
  final double longitude;
  final String? address;
  final PetStatus status;
  final DateTime createdAt;
  final List<Sighting> sightings;

  PetReport({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.color,
    required this.description,
    required this.contactName,
    required this.contactPhone,
    this.photoPath,
    required this.latitude,
    required this.longitude,
    this.address,
    this.status = PetStatus.lost,
    required this.createdAt,
    this.sightings = const [],
  });

  PetReport copyWith({
    String? name,
    PetSpecies? species,
    String? breed,
    String? color,
    String? description,
    String? contactName,
    String? contactPhone,
    String? photoPath,
    double? latitude,
    double? longitude,
    String? address,
    PetStatus? status,
    List<Sighting>? sightings,
  }) {
    return PetReport(
      id: id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      color: color ?? this.color,
      description: description ?? this.description,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      photoPath: photoPath ?? this.photoPath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      status: status ?? this.status,
      createdAt: createdAt,
      sightings: sightings ?? this.sightings,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'species': species.name,
        'breed': breed,
        'color': color,
        'description': description,
        'contactName': contactName,
        'contactPhone': contactPhone,
        'photoPath': photoPath,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'sightings': sightings.map((s) => s.toJson()).toList(),
      };

  factory PetReport.fromJson(Map<String, dynamic> json) => PetReport(
        id: json['id'] as String,
        name: json['name'] as String,
        species: PetSpecies.values.byName(json['species'] as String),
        breed: json['breed'] as String,
        color: json['color'] as String,
        description: json['description'] as String,
        contactName: json['contactName'] as String,
        contactPhone: json['contactPhone'] as String,
        photoPath: json['photoPath'] as String?,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        address: json['address'] as String?,
        status: PetStatus.values.byName(json['status'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        sightings: (json['sightings'] as List<dynamic>? ?? [])
            .map((e) => Sighting.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
