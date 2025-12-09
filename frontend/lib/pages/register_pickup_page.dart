import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:recicla_ai_grupo_7_frontend/blocs/auth_bloc.dart';
import 'package:recicla_ai_grupo_7_frontend/models/address.dart';
import 'package:recicla_ai_grupo_7_frontend/services/api_service.dart';
import 'package:recicla_ai_grupo_7_frontend/widgets/app_app_bar.dart';

class RegisterPickupPage extends StatefulWidget {
  const RegisterPickupPage({super.key});

  @override
  State<RegisterPickupPage> createState() => _RegisterPickupPageState();
}

class _RegisterPickupPageState extends State<RegisterPickupPage> {
  final _formKey = GlobalKey<FormState>();

  DateTime? _scheduledTime;

  // materiais
  List<dynamic> _materials = [];
  bool _loadingMaterials = true;

  // endereços
  List<Address> _addresses = [];
  bool _loadingAddresses = true;
  String? _selectedAddressId;

  bool _isSubmitting = false;
  List<String> _errors = [];
  String? _successMessage;

  // Lista dinâmica de itens
  final List<Map<String, dynamic>> _items = [
    {"material_id": null, "quantity": 1, "weight_kg": 0.0},
  ];

  @override
  void initState() {
    super.initState();
    _loadMaterials();
    _loadAddresses();
  }

  Future<void> _loadMaterials() async {
    final token = context.read<AuthCubit>().state?.accessToken ?? '';

    try {
      final response = await ApiService.listMaterials(token);
      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body["success"] == true) {
        setState(() {
          _materials = body["data"] ?? [];
          _loadingMaterials = false;
        });
      } else {
        setState(() {
          _loadingMaterials = false;
          _errors = ["Falha ao carregar materiais."];
        });
      }
    } catch (e) {
      setState(() {
        _loadingMaterials = false;
        _errors = ["Erro de conexão ao carregar materiais."];
      });
    }
  }

  Future<void> _loadAddresses() async {
    final token = context.read<AuthCubit>().state?.accessToken ?? '';

    try {
      final response = await ApiService.getMyAddresses(token);
      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        final List<dynamic> data = body['data'] ?? [];
        setState(() {
          _addresses = data
              .map((a) => Address.fromJson(a as Map<String, dynamic>))
              .toList();
          _loadingAddresses = false;
        });
      } else {
        setState(() {
          _loadingAddresses = false;
          _errors = ["Falha ao carregar endereços."];
        });
      }
    } catch (e) {
      setState(() {
        _loadingAddresses = false;
        _errors = ["Erro de conexão ao carregar endereços."];
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_scheduledTime == null) {
      setState(() => _errors = ["Selecione uma data e horário da coleta."]);
      return;
    }

    if (_selectedAddressId == null) {
      setState(() => _errors = ["Selecione um endereço."]);
      return;
    }

    if (_items.any((i) => i["material_id"] == null)) {
      setState(() => _errors = ["Existe um item sem material selecionado."]);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errors = [];
      _successMessage = null;
    });

    final token = context.read<AuthCubit>().state?.accessToken ?? '';

    final payload = {
      "address_id": _selectedAddressId,
      "scheduled_time": _scheduledTime!.toIso8601String(),
      "items": _items,
    };

    try {
      final response = await ApiService.registerPickup(
        bearerToken: token,
        pickupData: payload,
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body["success"] == true) {
        // feedback e ir pro mapa
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coleta registrada com sucesso!')),
        );
        if (mounted) {
          Navigator.pushNamed(context, '/points');
        }
      } else {
        final errs =
            (body["errors"] as List<dynamic>?)?.cast<String>() ??
                ["Erro ao registrar coleta."];

        setState(() => _errors = errs);
      }
    } catch (e) {
      setState(() => _errors = ["Erro de conexão."]);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 2)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      _scheduledTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _openRegisterAddress() async {
    final result = await Navigator.pushNamed(context, '/register-address');
    // se cadastrou endereço, recarrega a lista
    if (result == true) {
      _loadAddresses();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppAppBar(title: "Registrar Coleta"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Nova Coleta",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                "Solicite a coleta de materiais recicláveis em seu endereço.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              if (_loadingMaterials || _loadingAddresses)
                const Center(child: CircularProgressIndicator()),

              if (!_loadingMaterials && !_loadingAddresses)
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // ======================= ENDEREÇO =======================
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedAddressId,
                              items: _addresses
                                  .map(
                                    (a) => DropdownMenuItem<String>(
                                      value: a.id,
                                      child: Text(a.fullText),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedAddressId = value;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: "Endereço",
                                prefixIcon:
                                    const Icon(Icons.home_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return "Selecione um endereço";
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _openRegisterAddress,
                            icon: const Icon(Icons.add_location_alt),
                            tooltip: "Cadastrar novo endereço",
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ======================= DATA E HORA ======================
                      InkWell(
                        onTap: _pickDateTime,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: "Data e Hora da Coleta",
                            prefixIcon:
                                const Icon(Icons.calendar_month_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _scheduledTime == null
                                ? "Selecione"
                                : "${_scheduledTime!.day}/${_scheduledTime!.month}/${_scheduledTime!.year} "
                                    "às ${_scheduledTime!.hour.toString().padLeft(2, '0')}:"
                                    "${_scheduledTime!.minute.toString().padLeft(2, '0')}",
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ======================= ITENS ============================
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Itens da Coleta",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(height: 12),

                      for (int i = 0; i < _items.length; i++)
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                // Material
                                DropdownButtonFormField(
                                  value: _items[i]["material_id"],
                                  items: _materials
                                      .map<DropdownMenuItem<String>>(
                                        (m) => DropdownMenuItem(
                                          value: m["id"],
                                          child: Text(m["type"]),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _items[i]["material_id"] = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText: "Material",
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                  ),
                                  validator: (v) =>
                                      v == null ? "Selecione um material" : null,
                                ),
                                const SizedBox(height: 16),

                                // Quantidade
                                TextFormField(
                                  initialValue:
                                      _items[i]["quantity"].toString(),
                                  decoration: InputDecoration(
                                    labelText: "Quantidade",
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) {
                                    _items[i]["quantity"] =
                                        int.tryParse(v) ?? 1;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Peso
                                TextFormField(
                                  initialValue:
                                      _items[i]["weight_kg"].toString(),
                                  decoration: InputDecoration(
                                    labelText: "Peso (kg)",
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) {
                                    _items[i]["weight_kg"] =
                                        double.tryParse(v) ?? 0.0;
                                  },
                                ),
                                const SizedBox(height: 12),

                                if (_items.length > 1)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.delete_forever,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        setState(() => _items.removeAt(i));
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _items.add({
                              "material_id": null,
                              "quantity": 1,
                              "weight_kg": 0.0
                            });
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("Adicionar Item"),
                      ),

                      const SizedBox(height: 24),

                      // ======================= ERROS ============================
                      if (_errors.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: Colors.red.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _errors.map((e) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Text(
                                  "• $e",
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                      if (_successMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.green.shade300,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.green),
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

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation(
                                            Colors.white),
                                  ),
                                )
                              : const Icon(Icons.add_task),
                          label: Text(
                            _isSubmitting
                                ? "Enviando..."
                                : "Registrar Coleta",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: _isSubmitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
