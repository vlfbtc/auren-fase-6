import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/api_client.dart';
import 'core/token_storage.dart';

import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/data/repositories/transaction_repository.dart';
import 'features/auth/data/repositories/insights_repository.dart';

import 'bloc/auth_bloc.dart';
import 'bloc/transaction_bloc.dart';
import 'bloc/insights_bloc.dart';

import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/signup_screen.dart';
import 'features/auth/presentation/screens/verification_code_screen.dart';
import 'features/auth/presentation/screens/password_creation_screen.dart';
import 'features/auth/presentation/screens/home_screen.dart';

const String kDefaultBase = 'http://10.0.2.2:8080/api/v1';
String get apiBase =>
    const String.fromEnvironment('API_BASE', defaultValue: kDefaultBase);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AurenApp());
}

class AurenApp extends StatelessWidget {
  const AurenApp({super.key});

  @override
  Widget build(BuildContext context) {
    final api = ApiClient(baseUrl: apiBase);
    final authRepo = AuthRepository(api: api);
    final txRepo = TransactionRepository(api: api);
    final insRepo = InsightsRepository(api: api);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepo),
        RepositoryProvider.value(value: txRepo),
        RepositoryProvider.value(value: insRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthBloc(authRepo: authRepo)),
          BlocProvider(create: (_) => TransactionBloc(txRepo: txRepo)),
          BlocProvider(create: (_) => InsightsBloc(repo: insRepo)),
        ],
        child: MaterialApp(
          title: 'Auren',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
            useMaterial3: true,
          ),
          initialRoute: '/login',
          routes: {
            '/login': (_) => const LoginScreen(),
            '/signup': (_) => const SignupScreen(),
            '/main': (_) => const HomeScreen(), // ou MainPage
          },
        ),
      ),
    );
  }
}
