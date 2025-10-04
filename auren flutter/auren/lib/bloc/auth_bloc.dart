import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:auren/core/token_storage.dart';
import 'package:auren/features/auth/data/repositories/auth_repository.dart';

/// ----------------------
/// EVENTS
/// ----------------------
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

/// App iniciou: queremos SEMPRE ir para a tela de login
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Login com email/senha
class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  const LoginRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

/// Início do cadastro: dispara envio de PIN por email
class SignupStartRequested extends AuthEvent {
  final String firstName;
  final String lastName;
  final DateTime birthDate;
  final String email;
  const SignupStartRequested({
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.email,
  });
  @override
  List<Object?> get props => [firstName, lastName, birthDate, email];
}

class AuthPasswordCreated extends AuthState {
  final String email;
  const AuthPasswordCreated(this.email);
  @override
  List<Object?> get props => [email];
}

/// Submissão do PIN (verificação)
class VerifyPinSubmitted extends AuthEvent {
  final String email;
  final String code;
  const VerifyPinSubmitted({required this.email, required this.code});
  @override
  List<Object?> get props => [email, code];
}

/// Criação de senha
class CreatePasswordSubmitted extends AuthEvent {
  final String email;
  final String password;
  const CreatePasswordSubmitted({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

/// Logout
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// ----------------------
/// STATES
/// ----------------------
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthAuthenticated extends AuthState {
  final int? userId;
  const AuthAuthenticated({this.userId});
  @override
  List<Object?> get props => [userId];
}

class AuthCodeSent extends AuthState {
  final String email;
  const AuthCodeSent(this.email);
  @override
  List<Object?> get props => [email];
}

class AuthPinVerified extends AuthState {
  final String email;
  const AuthPinVerified(this.email);
  @override
  List<Object?> get props => [email];
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

/// ----------------------
/// BLOC
/// ----------------------
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepo;

  AuthBloc({required this.authRepo}) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheck);
    on<LoginRequested>(_onLogin);
    on<SignupStartRequested>(_onSignupStart);
    on<VerifyPinSubmitted>(_onVerifyPin);
    on<CreatePasswordSubmitted>(_onCreatePassword);
    on<LogoutRequested>(_onLogout);
  }

  /// SEM login automático: sempre força ir para a tela de login.
  Future<void> _onCheck(
      AuthCheckRequested e,
      Emitter<AuthState> emit,
      ) async {
    // Opcional, mas recomendado se você quer "zerar" sessão antiga:
    await TokenStorage.clear();
    emit(const AuthUnauthenticated());
  }

  /// Login
  Future<void> _onLogin(
      LoginRequested e,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());
    try {
      await authRepo.login(email: e.email, password: e.password);
      final st = await TokenStorage.read();
      emit(AuthAuthenticated(userId: st?.userId));
    } catch (err) {
      emit(AuthError(err.toString().replaceFirst('Exception: ', '')));
    }
  }

  /// Início do cadastro: envia PIN
  Future<void> _onSignupStart(
      SignupStartRequested e,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());
    try {
      await authRepo.signupStart(
        firstName: e.firstName,
        lastName: e.lastName,
        birthDate: e.birthDate,
        email: e.email,
      );
      emit(AuthCodeSent(e.email));
    } catch (err) {
      emit(AuthError(err.toString().replaceFirst('Exception: ', '')));
    }
  }

  /// Verificação do PIN
  Future<void> _onVerifyPin(
      VerifyPinSubmitted e,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());
    try {
      await authRepo.verifyPin(email: e.email, pin: e.code);
      emit(AuthPinVerified(e.email));
    } catch (err) {
      emit(AuthError(err.toString().replaceFirst('Exception: ', '')));
    }
  }

  /// Criação de senha
  Future<void> _onCreatePassword(
      CreatePasswordSubmitted e,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());
    try {
      await authRepo.createPassword(email: e.email, password: e.password);
      emit(AuthPasswordCreated(e.email));
      emit(const AuthUnauthenticated());
    } catch (err) {
      emit(AuthError(err.toString().replaceFirst('Exception: ', '')));
    }
  }

  /// Logout
  Future<void> _onLogout(
      LogoutRequested e,
      Emitter<AuthState> emit,
      ) async {
    await TokenStorage.clear();
    emit(const AuthUnauthenticated());
  }
}
