import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auren/features/auth/domain/models/transaction.dart';

// Base da API: ler de --dart-define ou usar padrão do emulador Android
const String _kDefaultBase = 'http://10.0.2.2:8080/api/v1';
String _apiBase = const String.fromEnvironment('API_BASE', defaultValue: _kDefaultBase);

class TransactionApiService {
  TransactionApiService({String? baseUrl}) {
    if (baseUrl != null && baseUrl.isNotEmpty) {
      _apiBase = baseUrl;
    }
  }

  Future<String> _getToken() async {
    final sp = await SharedPreferences.getInstance();
    final token = sp.getString('access_token') ?? '';
    if (token.isEmpty) {
      throw Exception('Usuário não autenticado');
    }
    return token;
  }

  Future<int> _getUserId() async {
    final sp = await SharedPreferences.getInstance();
    final uid = sp.getInt('user_id');
    if (uid == null) {
      throw Exception('userId ausente nas preferências');
    }
    return uid;
  }

  /// GET /api/v1/users/{userId}/transactions?from=YYYY-MM-DD&to=YYYY-MM-DD&limit=N
  Future<List<Transaction>> getUserTransactions({int limit = 10}) async {
    final token = await _getToken();
    final userId = await _getUserId();

    final now = DateTime.now();
    final from = DateTime(now.year, now.month - 5, 1);
    final to = now;

    String fmt(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    final uri = Uri.parse(
      '$_apiBase/users/$userId/transactions?from=${fmt(from)}&to=${fmt(to)}&limit=$limit',
    );

    final res = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Falha ao carregar transações (${res.statusCode})');
    }

    final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
    return data.map<Transaction>((e) {
      // Esperado do backend:
      // { id, description, amount, date (yyyy-MM-dd), category, type: "EXPENSE"/"INCOME" }
      final typeStr = (e['type'] ?? 'EXPENSE') as String;
      final tType = typeStr.toUpperCase() == 'INCOME'
          ? TransactionType.income
          : TransactionType.expense;

      final String dateStr = (e['date'] ?? '') as String;
      final parts = dateStr.split('-');
      DateTime date = DateTime.now();
      if (parts.length == 3) {
        date = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }

      return Transaction(
        id: (e['id'] ?? 0) as int,
        amount: (e['amount'] as num).toDouble(),
        description: (e['description'] ?? '') as String,
        category: (e['category'] ?? 'Outros') as String,
        date: date,
        type: tType,
      );
    }).toList();
  }

  /// POST /api/v1/users/{userId}/transactions
  Future<bool> submitTransaction(Transaction tx) async {
    final token = await _getToken();
    final userId = await _getUserId();

    String fmt(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    final body = {
      'description': tx.description,
      'amount': tx.amount,
      'date': fmt(tx.date),
      'category': tx.category,
      'type': tx.type == TransactionType.income ? 'INCOME' : 'EXPENSE',
    };

    final uri = Uri.parse('$_apiBase/users/$userId/transactions');

    final res = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    // 201 ou 200 — conforme seu controller
    if (res.statusCode == 201 || res.statusCode == 200) {
      return true;
    }

    // Log útil para debug rápido
    // ignore: avoid_print
    print('POST transactions falhou: ${res.statusCode} ${res.body}');
    return false;
  }
}
