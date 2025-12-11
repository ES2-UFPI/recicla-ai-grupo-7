import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';

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

  /// Timer para atualizar o mapa automaticamente
  Timer? _autoRefreshTimer;

  /// Flag para evitar múltiplas atualizações concorrentes
  bool _isRefreshing = false;

  /// Intervalo de atualização automática (ajuste se quiser)
  static const Duration _refreshInterval = Duration(seconds: 20);

  @override
  void initState() {
    super.initState();
    _futurePoints = _loadPoints();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  Future<List<PickupPoint>> _loadPoints() async {
    final authState = context.read<AuthCubit>().state;
    final token = authState?.accessToken ?? '';

    if (token.isEmpty) {
      throw Exception('Faça login para ver o mapa.');
    }

    final api = PickupApiService(token: token);
    final points = await api.fetchPickupPoints();
    return points;
  }

  void _startAutoRefresh() {
    // Garante que não fiquem múltiplos timers
    _autoRefreshTimer?.cancel();

    _autoRefreshTimer = Timer.periodic(_refreshInterval, (_) async {
      if (!mounted || _isRefreshing) return;

      _isRefreshing = true;
      try {
        // Cria um novo Future para o FutureBuilder reagir
        final future = _loadPoints();
        setState(() {
          _futurePoints = future;
        });
        // Aguarda finalizar para não disparar outra atualização em paralelo
        await future;
      } catch (e) {
        // Aqui podemos só logar/ignorar para não quebrar o timer
        // debugPrint('Erro ao atualizar pontos do mapa: $e');
      } finally {
        _isRefreshing = false;
      }
    });
  }

  void _showPointDetails(PickupPoint point) {
    final theme = Theme.of(context);
    final df = DateFormat('dd/MM/yyyy HH:mm');

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Detalhes da Coleta",
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                point.address,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              if (point.scheduledTime != null)
                Text(
                  "Disponível em: ${df.format(point.scheduledTime!)}",
                  style: theme.textTheme.bodyMedium,
                ),
              const SizedBox(height: 8),
              Text(
                "Materiais: ${point.materialsSummary}",
                style: theme.textTheme.bodyMedium,
              ),
              if (point.totalWeightKg > 0)
                Text(
                  "Volume estimado: ${point.totalWeightKg.toStringAsFixed(1)} kg",
                  style: theme.textTheme.bodyMedium,
                ),
              const SizedBox(height: 8),
              Text(
                "Status: ${point.status}",
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Fechar"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Permite também atualizar manualmente (pull-to-refresh se você quiser usar)
  Future<void> _refreshNow() async {
    final future = _loadPoints();
    setState(() {
      _futurePoints = future;
    });
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(title: "Pontos de Coleta"),
      endDrawer: AppDrawer(),
      body: FutureBuilder<List<PickupPoint>>(
        future: _futurePoints,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
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
            return RefreshIndicator(
              onRefresh: _refreshNow,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 150),
                  Center(
                    child: Text(
                      "Nenhuma coleta com localização encontrada.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          final LatLng center = points.first.latLng;

          final markers = points
              .map(
                (p) => Marker(
                  point: p.latLng,
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () => _showPointDetails(p),
                    child: const Icon(
                      Icons.location_on,
                      size: 36,
                      color: Colors.red,
                    ),
                  ),
                ),
              )
              .toList();

          // Envolve o mapa em RefreshIndicator para permitir "puxar pra atualizar"
          return RefreshIndicator(
            onRefresh: _refreshNow,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: constraints.maxHeight,
                    child: FlutterMap(
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
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

