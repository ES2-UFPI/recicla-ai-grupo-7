import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../blocs/auth_bloc.dart';
import '../services/api_service.dart';
import '../services/geocoding_service.dart';

class RegisterAddressPage extends StatefulWidget {
  const RegisterAddressPage({super.key});

  @override
  State<RegisterAddressPage> createState() => _RegisterAddressPageState();
}

class _RegisterAddressPageState extends State<RegisterAddressPage> {
  final _formKey = GlobalKey<FormState>();

  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _cepController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _streetController.dispose();
    _numberController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _cepController.dispose();
    super.dispose();
  }

  // === pegar latitude/longitude via Geolocator (localização atual) ===
  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Serviço de localização desativado.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permissão de localização negada.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Permissão de localização negada permanentemente. '
        'Ative nas configurações.',
      );
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Cadastra usando **localização atual (GPS)**
  Future<void> _submitWithCurrentLocation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final pos = await _getCurrentPosition();
      final token = context.read<AuthCubit>().state?.accessToken ?? '';

      if (token.isEmpty) {
        throw Exception('Usuário não autenticado.');
      }

      final body = {
        "street": _streetController.text.trim(),
        "number": _numberController.text.trim(),
        "city": _cityController.text.trim(),
        "state": _stateController.text.trim(),
        "zipcode": _cepController.text.trim(),
        "latitude": pos.latitude,
        "longitude": pos.longitude,
      };

      final resp = await ApiService.registerAddress(
        bearerToken: token,
        addressData: body,
      );

      if (resp.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Endereço cadastrado com sucesso!")),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao cadastrar endereço: ${resp.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: $e")),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Cadastra usando **endereço digitado (geocoding)** → para aparecer no mapa
  Future<void> _submitWithGeocoding() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final token = context.read<AuthCubit>().state?.accessToken ?? '';
      if (token.isEmpty) {
        throw Exception('Usuário não autenticado.');
      }

      // Monta string de endereço para geocodificação
      final addressQuery =
          "${_streetController.text} ${_numberController.text}, "
          "${_cityController.text}, ${_stateController.text}, "
          "${_cepController.text}";

      final coords = await GeocodingService.searchAddress(addressQuery);

      if (coords == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Endereço não encontrado no mapa (geocoding falhou)."),
          ),
        );
        return;
      }

      final body = {
        "street": _streetController.text.trim(),
        "number": _numberController.text.trim(),
        "city": _cityController.text.trim(),
        "state": _stateController.text.trim(),
        "zipcode": _cepController.text.trim(),
        "latitude": coords["lat"],
        "longitude": coords["lng"],
      };

      final resp = await ApiService.registerAddress(
        bearerToken: token,
        addressData: body,
      );

      if (resp.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Endereço cadastrado com sucesso (com mapa)!"),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao cadastrar endereço: ${resp.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: $e")),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadastrar Endereço"),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _streetController,
                decoration: const InputDecoration(labelText: "Rua"),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? "Informe a rua" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(labelText: "Número"),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: "Cidade"),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? "Informe a cidade" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(labelText: "Estado (UF)"),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? "Informe o estado" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cepController,
                decoration: const InputDecoration(labelText: "CEP"),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _submitWithCurrentLocation,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Icon(Icons.my_location),
                  label: Text(
                    _isSaving
                        ? "Salvando..."
                        : "Usar minha localização e cadastrar",
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isSaving ? null : _submitWithGeocoding,
                  icon: const Icon(Icons.location_on_outlined),
                  label: const Text("Cadastrar endereço digitado (aparecer no mapa)"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

