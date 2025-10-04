import 'package:auren/features/auth/data/repositories/auth_repository.dart';

class SignupUseCase {
  final AuthRepository repository;
  SignupUseCase(this.repository);

  /// Etapa 1: dispara envio do PIN
  Future<void> start({
    required String firstName,
    required String lastName,
    required DateTime birthDate,
    required String email,
  }) {
    return repository.signupStart(
      firstName: firstName,
      lastName: lastName,
      birthDate: birthDate,
      email: email,
    );
  }

  /// Etapa 2: verifica o PIN
  Future<void> verifyPin({
    required String email,
    required String pin,
  }) {
    return repository.verifyPin(email: email, pin: pin);
  }

  /// Etapa 3: cria a senha
  Future<void> createPassword({
    required String email,
    required String password,
  }) {
    return repository.createPassword(email: email, password: password);
  }
}