import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Settings {
  final ThemeMode themeMode;
  Settings({required this.themeMode});
}

class SettingsCubit extends Cubit<Settings> {
  SettingsCubit() : super(Settings(themeMode: ThemeMode.light));

  void setTheme(ThemeMode theme) {
    emit(Settings(themeMode: theme));
  }
}