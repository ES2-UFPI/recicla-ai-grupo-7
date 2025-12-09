import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  /// Faz geocoding de um endereço textual e retorna {lat, lng}
  static Future<Map<String, double>?> searchAddress(String query) async {
    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/search"
      "?q=$query&format=json&limit=1",
    );

    final response = await http.get(
      url,
      headers: {
        // Nominatim exige um User-Agent identificável
        "User-Agent": "ReciclaAI-App/1.0 (flutter)",
      },
    );

    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body);

    if (data is List && data.isNotEmpty) {
      final item = data[0];
      final lat = double.tryParse(item["lat"] as String? ?? "");
      final lng = double.tryParse(item["lon"] as String? ?? "");

      if (lat != null && lng != null) {
        return {"lat": lat, "lng": lng};
      }
    }

    return null;
  }
}
