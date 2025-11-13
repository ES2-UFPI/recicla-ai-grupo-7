import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recicla_ai_grupo_7_frontend/blocs/auth_bloc.dart';
import 'package:recicla_ai_grupo_7_frontend/services/api_service.dart';
import 'package:recicla_ai_grupo_7_frontend/widgets/app_app_bar.dart';

class RegisterMaterialPage extends StatefulWidget {
  const RegisterMaterialPage({super.key});

  @override
  State<RegisterMaterialPage> createState() => _RegisterMaterialPageState();
}

class _RegisterMaterialPageState extends State<RegisterMaterialPage> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;
  List<String> _errorMessages = [];
  String? _successMessage;

  @override
  void dispose() {
    _typeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _registerMaterial() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessages = [];
      _successMessage = null;
    });

    final bearerToken = context.read<AuthCubit>().state?.accessToken ?? '';
    final type = _typeController.text.trim();
    final description = _descriptionController.text.trim();

    try {
      final response = await ApiService.registerMaterial(
        bearerToken: bearerToken,
        type: type,
        description: description,
      );

      final body = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _successMessage = "Material cadastrado com sucesso!";
          _typeController.clear();
          _descriptionController.clear();
        });

        // Opcional: voltar após 2 segundos
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
      } else {
        final errors = (body["errors"] as List<dynamic>?)?.cast<String>() ??
            ["Erro ao cadastrar material."];

        setState(() {
          _errorMessages = errors;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessages = ["Erro de conexão. Tente novamente."];
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
      appBar: AppAppBar(title: "Cadastrar Material"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Text(
                "Novo Material Reciclável",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                "Adicione um novo tipo de material ao sistema. Apenas administradores podem realizar esta ação.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),

              // Formulário
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Campo: Tipo
                        TextFormField(
                          controller: _typeController,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: "Tipo do Material",
                            hintText: "Ex: plástico, papel, vidro",
                            prefixIcon: const Icon(Icons.category_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "O tipo é obrigatório";
                            }
                            if (value.trim().length < 2) {
                              return "Digite pelo menos 2 caracteres";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Campo: Descrição
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 4,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            labelText: "Descrição",
                            hintText: "Descreva o material, exemplos de uso, etc.",
                            prefixIcon: const Icon(Icons.description_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignLabelWithHint: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "A descrição é obrigatória";
                            }
                            if (value.trim().length < 10) {
                              return "A descrição deve ter pelo menos 10 caracteres";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // Mensagens de erro
                        if (_errorMessages.isNotEmpty)
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
                              children: _errorMessages
                                  .map((msg) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Text(
                                          "• $msg",
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),

                        // Mensagem de sucesso
                        if (_successMessage != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              border: Border.all(color: Colors.green.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _successMessage!,
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Botão de cadastro
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _registerMaterial,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.add_box),
                            label: Text(
                              _isLoading ? "Cadastrando..." : "Cadastrar Material",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Dica
              Center(
                child: Text(
                  "Exemplos: plástico PET, papelão, alumínio, vidro verde...",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}