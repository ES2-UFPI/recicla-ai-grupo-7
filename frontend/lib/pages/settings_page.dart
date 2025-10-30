import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recicla_ai_grupo_7_frontend/blocs/settings_bloc.dart';
import 'package:recicla_ai_grupo_7_frontend/widgets/app_app_bar.dart';
import 'package:recicla_ai_grupo_7_frontend/widgets/app_drawer.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(title: "Configurações"),
      endDrawer: AppDrawer(),
      body: BlocBuilder<SettingsCubit, Settings>(
        builder: (context, settings) => Center(
          child: ListView(
            children: [
              // settings of theme
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Theme"),
                  const SizedBox(width: 10),
                  const Icon(Icons.light_mode),
                  const SizedBox(width: 5),
                  Switch(
                    value: settings.themeMode == ThemeMode.dark, 
                    onChanged: (value) => setState(() {
                      context.read<SettingsCubit>().setTheme( value ? ThemeMode.dark : ThemeMode.light );
                    })
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
