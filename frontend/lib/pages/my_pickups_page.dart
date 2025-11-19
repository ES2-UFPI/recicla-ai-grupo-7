import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:recicla_ai_grupo_7_frontend/blocs/auth_bloc.dart';
import 'package:recicla_ai_grupo_7_frontend/services/api_service.dart';
import 'package:recicla_ai_grupo_7_frontend/widgets/app_app_bar.dart';

class MyPickupsPage extends StatefulWidget {
  const MyPickupsPage({super.key});

  @override
  State<MyPickupsPage> createState() => _MyPickupsPageState();
}

class _MyPickupsPageState extends State<MyPickupsPage> {
  bool _isLoading = true;
  List<dynamic> _pickups = [];
  List<String> _errors = [];

  @override
  void initState() {
    super.initState();
    _loadPickups();
  }

  Future<void> _loadPickups() async {
    setState(() {
      _isLoading = true;
      _errors = [];
    });

    final token = context.read<AuthCubit>().state?.accessToken ?? '';

    try {
      final response = await ApiService.getMyPickups(token);
      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body["success"] == true) {
        setState(() {
          _pickups = body["data"] ?? [];
        });
      } else {
        setState(() {
          _errors = (body["errors"] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              ["Erro ao carregar suas coletas."];
        });
      }
    } catch (e) {
      setState(() {
        _errors = ["Erro de conexão. Tente novamente mais tarde."];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(String isoString) {
    final date = DateTime.tryParse(isoString);
    if (date == null) return "Data inválida";

    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year} às "
        "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppAppBar(title: "Minhas Coletas"),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadPickups,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ====================== TÍTULO ======================
                Text(
                  "Minhas Solicitações de Coleta",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Acompanhe todas as coletas que você já registrou.",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                // ====================== LOADING ======================
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: CircularProgressIndicator(),
                    ),
                  ),

                // ====================== ERROS ======================
                if (!_isLoading && _errors.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _errors.map((msg) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            "• $msg",
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                // ====================== LISTA DE COLETAS ======================
                if (!_isLoading && _pickups.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _pickups.length,
                    itemBuilder: (context, index) {
                      final pickup = _pickups[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ID
                              Row(
                                children: [
                                  const Icon(Icons.assignment_outlined, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Coleta #${pickup['id']}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Endereço
                              Row(
                                children: [
                                  const Icon(Icons.home_outlined, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Endereço: ${pickup['address_id']}",
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Data
                              Row(
                                children: [
                                  const Icon(Icons.calendar_month_outlined, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatDate(pickup["scheduled_time"]),
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Itens
                              Text(
                                "Itens",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),

                              ...pickup["items"].map<Widget>((item) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Material ID: ${item['material_id']}"),
                                      Text("Quantidade: ${item['quantity']}"),
                                      Text("Peso (kg): ${item['weight_kg']}"),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                // ====================== LISTA VAZIA ======================
                if (!_isLoading && _pickups.isEmpty && _errors.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Text(
                        "Você ainda não registrou nenhuma coleta.",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
