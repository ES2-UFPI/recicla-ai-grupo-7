import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  Timer? _autoRefreshTimer;
  bool _isRefreshing = false;

  // intervalinho de atualização automática
  static const Duration _refreshInterval = Duration(seconds: 20);

  /// Tipos de material selecionados no filtro.
  /// Conjunto vazio = mostrar todos.
  final Set<String> _selectedTypes = {};

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
    _autoRefreshTimer?.cancel();

    _autoRefreshTimer = Timer.periodic(_refreshInterval, (_) async {
      if (!mounted || _isRefreshing) return;

      _isRefreshing = true;
      try {
        final future = _loadPoints();
        setState(() {
          _futurePoints = future;
        });
        await future;
      } catch (_) {
        // aqui a gente ignora erros pontuais do refresh
      } finally {
        _isRefreshing = false;
      }
    });
  }

  Future<void> _refreshNow() async {
    final future = _loadPoints();
    setState(() {
      _futurePoints = future;
    });
    await future;
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

  void _toggleTypeFilter(String type) {
    setState(() {
      if (_selectedTypes.contains(type)) {
        _selectedTypes.remove(type);
      } else {
        _selectedTypes.add(type);
      }
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedTypes.clear();
    });
  }

  Widget _buildFilterBar(List<String> materialTypes) {
    if (materialTypes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              label: const Text("Todos"),
              selected: _selectedTypes.isEmpty,
              onSelected: (_) => _clearFilters(),
            ),
            const SizedBox(width: 8),
            ...materialTypes.map(
              (type) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  label: Text(type),
                  selected: _selectedTypes.contains(type),
                  onSelected: (_) => _toggleTypeFilter(type),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

          // Descobre todos os tipos de material presentes
          final materialTypesSet = <String>{};
          for (final p in points) {
            for (final item in p.items) {
              final t = item.materialType.trim();
              if (t.isNotEmpty) {
                materialTypesSet.add(t);
              }
            }
          }
          final materialTypes = materialTypesSet.toList()..sort();

          // Aplica filtro: se não há tipos selecionados, mostra todos
          List<PickupPoint> visiblePoints;
          if (_selectedTypes.isEmpty) {
            visiblePoints = points;
          } else {
            visiblePoints = points.where((p) {
              final pointTypes =
                  p.items.map((i) => i.materialType.trim()).toSet();
              return pointTypes.any(_selectedTypes.contains);
            }).toList();
          }

          // Se não há nenhum ponto compatível com o filtro, mostra mensagem
          if (visiblePoints.isEmpty) {
            return Column(
              children: [
                _buildFilterBar(materialTypes),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshNow,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 150),
                        Center(
                          child: Text(
                            "Nenhum ponto encontrado para os filtros selecionados.",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          final LatLng center = visiblePoints.first.latLng;

          final markers = visiblePoints
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

          return Column(
            children: [
              _buildFilterBar(materialTypes),
              Expanded(
                child: RefreshIndicator(
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}


