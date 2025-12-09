import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:recicla_ai_grupo_7_frontend/blocs/auth_bloc.dart';
import 'package:recicla_ai_grupo_7_frontend/models/pickup_point.dart';
import 'package:recicla_ai_grupo_7_frontend/services/pickup_api_service.dart';
import 'package:recicla_ai_grupo_7_frontend/widgets/app_app_bar.dart';
import 'package:recicla_ai_grupo_7_frontend/widgets/app_drawer.dart';

class PickupMapScreen extends StatefulWidget {
  const PickupMapScreen({super.key});

  @override
  State<PickupMapScreen> createState() => _PickupMapScreenState();
}

class _PickupMapScreenState extends State<PickupMapScreen> {
  late Future<List<PickupPoint>> _futurePoints;

  @override
  void initState() {
    super.initState();
    _futurePoints = _loadPoints();
  }

  Future<List<PickupPoint>> _loadPoints() async {
    final authState = context.read<AuthCubit>().state;
    final token = authState?.accessToken ?? '';

    if (token.isEmpty) {
      throw Exception('Faça login para ver o mapa.');
    }
    print(">>> CHAMANDO API DO MAPA...");
    final api = PickupApiService(token: token);
    final points = await api.fetchPickupPoints();
    print(">>> API RETORNOU ${points.length} PONTOS");
    return points;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(title: "Pontos de Coleta"),
      endDrawer: AppDrawer(),
      body: FutureBuilder<List<PickupPoint>>(
        future: _futurePoints,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Erro ao carregar pontos:\n${snapshot.error}",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final points = snapshot.data ?? [];

          if (points.isEmpty) {
            return const Center(
              child: Text(
                "Nenhuma coleta com localização encontrada.",
                textAlign: TextAlign.center,
              ),
            );
          }

          // centraliza no primeiro ponto
          final LatLng center = points.first.latLng;

          final markers = points
            .map(
              (p) => Marker(
                point: p.latLng,
                width: 40,
                height: 40,
                child: Tooltip(
                  message: p.address,
                  child: const Icon(
                    Icons.location_on,
                    size: 36,
                    color: Colors.red,
                  ),
                ),
              ),
            )
            .toList();

          return FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(markers: markers),
            ],
          );
        },
      ),
    );
  }
}

