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
  // Centro inicial do mapa (pode ajustar para sua cidade)
  final LatLng _initialCenter = LatLng(-5.0892, -42.8019); // Ex.: Teresina

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(title: "Pontos de Coleta"),
      endDrawer: const AppDrawer(),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _initialCenter,
          initialZoom: 13,
        ),
        children: [
          // Camada de tiles (OpenStreetMap)
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.recicla_ai_grupo_7_frontend',
          ),

          // Por enquanto, sem marcadores – só o mapa.
          // Próximo passo será adicionar os pontos de coleta aqui.
        ],
      ),
    );
  }
}
