import 'package:auren/core/api_client.dart';
import 'package:auren/core/token_storage.dart';

class AuthRepository {
  final ApiClient api;
  AuthRepository({required this.api});

  /// POST /api/v1/auth/login
  /// body: { email, password }
  /// response esperado: { accessToken, refreshToken, userId }
  Future<void> login({required String email, required String password}) async {
    final res = await api.post('/auth/login', {
      'email': email,
      'password': password,
    }, auth: false);

    final access = res['accessToken'] as String?;
    final refresh = res['refreshToken'] as String?;
    final userId = res['userId'] is int
        ? res['userId'] as int
        : (res['userId'] == null ? null : int.tryParse(res['userId'].toString()));

    if (access == null || refresh == null || userId == null) {
      throw Exception('Login falhou: resposta inválida do servidor.');
    }

    await TokenStorage.write(
      accessToken: access,
      refreshToken: refresh,
      userId: userId,
    );
  }

  /// POST /api/v1/auth/signup
  /// body: { firstName, lastName, birthDate(ISO), email }
  /// envia e-mail com PIN
  Future<void> signupStart({
    required String firstName,
    required String lastName,
    required DateTime birthDate,
    required String email,
  }) async {
    await api.post('/auth/signup', {
      'firstName': firstName,
      'lastName': lastName,
      'birthDate': birthDate.toIso8601String(),
      'email': email,
    }, auth: false);
  }

  /// POST /api/v1/auth/verify-pin
  /// body: { email, pin }
  Future<void> verifyPin({
    required String email,
    required String pin,
  }) async {
    await api.post('/auth/verify-pin', {
      'email': email,
      'pin': pin,
    }, auth: false);
  }

  /// POST /api/v1/auth/create-password
  /// body: { email, password }
  Future<void> createPassword({
    required String email,
    required String password,
  }) async {
    await api.post('/auth/create-password', {
      'email': email.trim(),
      'password': password
    }, auth: false);
  }

  /// Opcional: logout local
  Future<void> logout() async {
    await TokenStorage.clear();
  }
}