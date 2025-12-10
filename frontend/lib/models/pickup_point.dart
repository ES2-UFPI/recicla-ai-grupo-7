import 'package:latlong2/latlong.dart';

class PickupMaterialItem {
  final String materialType;
  final int? quantity;
  final double? weightKg;

  PickupMaterialItem({
    required this.materialType,
    this.quantity,
    this.weightKg,
  });

  factory PickupMaterialItem.fromJson(Map<String, dynamic> json) {
    return PickupMaterialItem(
      materialType: json['material_type'] as String? ?? 'Desconhecido',
      quantity: json['quantity'] as int?,
      weightKg: (json['weight_kg'] != null)
          ? (json['weight_kg'] as num).toDouble()
          : null,
    );
  }
}

class PickupPoint {
  final String id;
  final String status;
  final String address;
  final double latitude;
  final double longitude;
  final DateTime? scheduledTime;
  final List<PickupMaterialItem> items;

  PickupPoint({
    required this.id,
    required this.status,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.items,
    this.scheduledTime,
  });

  LatLng get latLng => LatLng(latitude, longitude);

  /// Tipos de material em formato resumido
  String get materialsSummary {
    final setTypes = items.map((e) => e.materialType).toSet();
    return setTypes.isEmpty ? 'Não informado' : setTypes.join(', ');
  }

  /// Volume estimado em kg (soma dos pesos)
  double get totalWeightKg {
    return items.fold<double>(
      0.0,
      (sum, item) => sum + (item.weightKg ?? 0.0),
    );
  }

  factory PickupPoint.fromJson(Map<String, dynamic> json) {
    final itemsJson = (json['items'] as List<dynamic>? ?? []);
    return PickupPoint(
      id: json['id'] as String,
      status: json['status'] as String? ?? 'PENDENTE',
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      scheduledTime: json['scheduled_time'] != null
          ? DateTime.parse(json['scheduled_time'] as String)
          : null,
      items: itemsJson
          .map((e) => PickupMaterialItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

