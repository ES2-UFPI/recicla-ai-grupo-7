import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:recicla_ai_grupo_7_frontend/services/api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _role = 'PRODUTOR';
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  List<String> _errorMessages = [];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.primary),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/logo.png',
                    width: 140,
                    height: 140,
                  ),

                  const SizedBox(height: 32),

                  // Título
                  Text(
                    "Crie sua conta",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Preencha os campos para se registrar",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                  ),

                  const SizedBox(height: 40),

                  // Campo de Nome
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Nome completo",
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Por favor, insira seu nome";
                      }
                      if (value.trim().split(' ').length < 2) {
                        return "Insira nome e sobrenome";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Campo de E-mail
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "E-mail",
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Por favor, insira seu e-mail";
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return "E-mail inválido";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Campo de Senha
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: "Senha",
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Por favor, insira sua senha";
                      }
                      if (value.length < 6) {
                        return "A senha deve ter pelo menos 6 caracteres";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Campo de Confirmar Senha
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      labelText: "Confirmar senha",
                      prefixIcon: const Icon(Icons.lock_reset_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Por favor, confirme sua senha";
                      }
                      if (value != _passwordController.text) {
                        return "As senhas não coincidem";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 30),

                  // Dropdown de Papel
                  DropdownButtonFormField<String>(
                    initialValue: _role,
                    decoration: InputDecoration(
                      labelText: "Selecione seu papel",
                      prefixIcon: const Icon(Icons.person_search_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'PRODUTOR', child: Text('Produtor')),
                      DropdownMenuItem(value: 'COLETOR', child: Text('Coletor')),
                      DropdownMenuItem(value: 'COOPERATIVA', child: Text('Cooperativa')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _role = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null) return "Selecione seu papel";
                      return null;
                    },
                  ),

                  const SizedBox(height: 30),

                  // Exibição de Erros
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

                  // Botão de Registrar
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      setState(() {
                        _errorMessages = [];
                      });

                      try {
                        final response = await ApiService.authSignup(
                          _nameController.text.trim(),
                          _emailController.text.trim(),
                          _passwordController.text,
                          _role,
                        );

                        final body = jsonDecode(response.body);

                        if (response.statusCode == 201 || response.statusCode == 200) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Cadastro realizado com sucesso! Faça login."),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pushReplacementNamed(context, '/login');
                          }
                        } else if (response.statusCode == 400 || response.statusCode == 422) {
                          final errors = (body["errors"] as List<dynamic>?)?.cast<String>() ??
                              ["Erro ao processar cadastro."];

                          if (mounted) {
                            setState(() {
                              _errorMessages = List<String>.from(errors);
                            });
                          }
                        } else {
                          if (mounted) {
                            setState(() {
                              _errorMessages = ["Erro no servidor: ${response.statusCode}"];
                            });
                          }
                        }
                      } catch (e) {
                        if (mounted) {
                          setState(() {
                            _errorMessages = [
                              "Erro de conexão. Verifique sua internet e tente novamente.",
                            ];
                          });
                        }
                      }
                    },
                    icon: const Icon(Icons.app_registration_rounded),
                    label: const Text(
                      "Registrar-se",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Link para Login
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: Text(
                      "Já tem uma conta? Entrar",
                      style: TextStyle(color: colorScheme.primary),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Versão
                  Text(
                    "Versão 0.1.0",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}