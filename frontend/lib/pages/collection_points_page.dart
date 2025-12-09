import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:recicla_ai_grupo_7_frontend/widgets/app_app_bar.dart';
import 'package:recicla_ai_grupo_7_frontend/widgets/app_drawer.dart';

class CollectionPointsPage extends StatefulWidget {
  const CollectionPointsPage({super.key});

  @override
  State<CollectionPointsPage> createState() => _CollectionPointsState();
}

class _CollectionPointsState extends State<CollectionPointsPage> {
  final MapController _mapController = MapController();

  /// Por enquanto, 1 ponto fixo de exemplo.
  /// Depois vamos trocar isso por dados vindos da API.
  final List<LatLng> _collectionPoints = [
    // Ex.: Teresina – PI (altere para o local que você quiser)
    LatLng(-5.08921, -42.80160),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const AppAppBar(title: "Pontos de Coleta"),
      endDrawer: const AppDrawer(),
      body: _buildMap(theme),
    );
  }

  Widget _buildMap(ThemeData theme) {
    // Se não tiver nenhum ponto, podemos cair num centro padrão
    final LatLng initialCenter = _collectionPoints.isNotEmpty
        ? _collectionPoints.first
        : const LatLng(-14.2350, -51.9253); // Brasil

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: 13,
      ),
      children: [
        // Camada de tiles (OpenStreetMap)
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.example.recicla_ai_grupo_7',
        ),

        // Camada de marcadores
        MarkerLayer(
          markers: _collectionPoints
              .map(
                (point) => Marker(
                  point: point,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

