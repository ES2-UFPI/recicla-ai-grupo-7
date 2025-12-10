import 'dart:convert';
import 'package:http/http.dart' as http;

import '../app_config.dart';
import '../models/pickup_point.dart';

class PickupApiService {
  final String token;
  final String baseUrl;

  PickupApiService({
    required this.token,
  }) : baseUrl = "http://${AppConfig.apiHost}:${AppConfig.apiPort}";

  Future<List<PickupPoint>> fetchPickupPoints() async {
    final url = Uri.parse("$baseUrl/residue/map_points");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Erro ao buscar pontos: ${response.body}");
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body["data"] as List<dynamic>;

    return data
        .map((e) => PickupPoint.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
