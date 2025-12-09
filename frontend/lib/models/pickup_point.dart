import 'package:latlong2/latlong.dart';

class PickupPoint {
  final String id;
  final String status;
  final double latitude;
  final double longitude;
  final String address;

  PickupPoint({
    required this.id,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  factory PickupPoint.fromJson(Map<String, dynamic> json) {
    return PickupPoint(
      id: json['id'] as String,
      status: json['status'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String,
    );
  }

  LatLng get latLng => LatLng(latitude, longitude);
}

