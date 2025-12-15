import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recicla_ai_grupo_7_frontend/blocs/auth_bloc.dart';
import 'package:recicla_ai_grupo_7_frontend/services/api_service.dart';
import 'package:recicla_ai_grupo_7_frontend/widgets/app_app_bar.dart';
import 'package:recicla_ai_grupo_7_frontend/widgets/app_drawer.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool _isLoading = true;
  String? _error;
  List<dynamic> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final auth = context.read<AuthCubit>().state;
      if (auth == null) {
        setState(() {
          _error = "Você precisa estar autenticado.";
          _isLoading = false;
        });
        return;
      }

      final resp = await ApiService.getHistory(bearerToken: auth.accessToken);
      if (resp.statusCode != 200) {
        setState(() {
          _error = "Erro ao carregar histórico (${resp.statusCode})";
          _isLoading = false;
        });
        return;
      }

      final decoded = jsonDecode(utf8.decode(resp.bodyBytes));
      final data = decoded["data"] as List<dynamic>? ?? [];

      setState(() {
        _items = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Erro ao carregar histórico: $e";
        _isLoading = false;
      });
    }
  }

  Widget _buildStatusChip(String? status, ColorScheme colors) {
    final text = status ?? "-";
    final color = text.toLowerCase().contains("pend")
        ? colors.tertiary
        : colors.primary;
    return Chip(
      label: Text(text, style: TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }

  Widget _buildCard(dynamic item, ColorScheme colors) {
    final createdAt = item["scheduled_time"] ?? item["created_at"];
    final addressId = item["address_id"] ?? "";
    final status = item["status"] ?? "";
    final items = item["items"] as List<dynamic>? ?? [];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Coleta ${item["id"] ?? ""}",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                _buildStatusChip(status, colors),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Agendada: ${createdAt ?? "-"}",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (addressId.isNotEmpty)
              Text(
                "Endereço: $addressId",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: 8),
            if (items.isNotEmpty) ...[
              Text(
                "Materiais:",
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              ...items.map((it) {
                final qty = it["quantity"] ?? it["weight_kg"] ?? "";
                return Text("• ${it["material_id"] ?? it["name"] ?? "Material"} (${qty.toString()})");
              }),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppAppBar(title: "Histórico"),
      endDrawer: AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _error!,
                          style: TextStyle(color: colors.error, fontSize: 16),
                        ),
                      ),
                    ],
                  )
                : _items.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 120),
                          Center(child: Text("Nenhuma coleta encontrada.")),
                        ],
                      )
                    : ListView.builder(
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          return _buildCard(_items[index], colors);
                        },
                      ),
      ),
    );
  }
}