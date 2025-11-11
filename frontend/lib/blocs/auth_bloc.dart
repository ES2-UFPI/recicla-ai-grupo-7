import 'package:flutter_bloc/flutter_bloc.dart';

class Auth {
  final String accessToken;
  final String refreshToken;
  Auth({required this.accessToken, required this.refreshToken});
}

class AuthCubit extends Cubit<Auth?> {
  AuthCubit() : super(null);

  void setAuth(String accessToken, String refreshToken) {
    emit(Auth(accessToken: accessToken, refreshToken: refreshToken));
  }

  void clearAuth() {
    emit(null);
  }
}