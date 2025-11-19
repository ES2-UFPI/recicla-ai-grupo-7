import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recicla_ai_grupo_7_frontend/blocs/auth_bloc.dart';
import 'package:recicla_ai_grupo_7_frontend/services/api_service.dart';
import 'package:recicla_ai_grupo_7_frontend/widgets/app_app_bar.dart';

class ListMaterialsPage extends StatefulWidget {
  const ListMaterialsPage({super.key});

  @override
  State<ListMaterialsPage> createState() => _ListMaterialsPageState();
}

class _ListMaterialsPageState extends State<ListMaterialsPage> {
  bool _isLoading = true;
  List<dynamic> _materials = [];
  List<String> _errors = [];

  @override
  void initState() {
    super.initState();
    _fetchMaterials();
  }

  Future<void> _fetchMaterials() async {
    setState(() {
      _isLoading = true;
      _errors = [];
    });

    final bearerToken = context.read<AuthCubit>().state?.accessToken ?? '';

    try {
      final response = await ApiService.listMaterials(bearerToken);
      final body = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200 && body["success"] == true) {
        setState(() {
          _materials = body["data"] ?? [];
        });
      } else {
        final errors = (body["errors"] as List<dynamic>?)?.cast<String>() ??
            ["Erro ao carregar materiais."];

        setState(() {
          _errors = errors;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errors = ["Erro de conexão. Tente novamente."];
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppAppBar(title: "Materiais Recicláveis"),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchMaterials,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== Título =====
                Text(
                  "Lista de Materiais",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 8),

                Text(
                  "Visualize todos os materiais recicláveis cadastrados no sistema.",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                // ===== CARREGANDO =====
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: CircularProgressIndicator(),
                    ),
                  ),

                // ===== ERROS =====
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
                      children: _errors
                          .map(
                            (msg) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                "• $msg",
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),

                // ===== LISTA =====
                if (!_isLoading && _materials.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _materials.length,
                    itemBuilder: (context, index) {
                      final material = _materials[index];

                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Tipo
                              Row(
                                children: [
                                  const Icon(Icons.category_outlined, size: 22),
                                  const SizedBox(width: 8),
                                  Text(
                                    material["type"] ?? "Sem tipo",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Descrição
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.description_outlined, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      material["description"] ?? "Sem descrição",
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // ID
                              Text(
                                "ID: ${material['id']}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                // ===== VAZIO =====
                if (!_isLoading && _materials.isEmpty && _errors.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Text(
                        "Nenhum material cadastrado.",
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
