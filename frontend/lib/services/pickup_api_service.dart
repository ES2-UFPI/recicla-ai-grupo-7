import 'dart:convert';
import 'package:http/http.dart' as http;

import '../app_config.dart';
import '../models/pickup_point.dart';

class PickupApiService {
  final String token;

  PickupApiService({required this.token});

  Uri _buildUri(String path) {
    return Uri.parse("http://${AppConfig.apiHost}:${AppConfig.apiPort}$path");
  }

  Future<List<PickupPoint>> fetchPickupPoints() async {
    print(">>> FetchPickupPoints() chamado!");

    final url = _buildUri("/residue/map_points");
    
    print(">>> URL chamada: $url");

    final resp = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    print(">>> STATUS CODE: ${resp.statusCode}");
    print(">>> BODY: ${resp.body}");

    if (resp.statusCode != 200) {
      throw Exception("Erro ao buscar pontos: ${resp.statusCode}");
    }

    final body = jsonDecode(resp.body);

    final List<dynamic> data = body["data"] ?? [];

    return data.map((e) => PickupPoint.fromJson(e)).toList();
  }
}
