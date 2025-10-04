import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../../core/api_client.dart';
import '../../../../core/token_storage.dart';
import '../../domain/models/transaction.dart';

class TransactionRepository {
  final ApiClient api;
  TransactionRepository({required this.api});

  Future<int> _userId() async {
    final s = await TokenStorage.read();
    final id = s?.userId;
    if (id == null) throw Exception('Sessão inválida: userId não encontrado');
    return id;
  }

  Future<List<Transaction>> fetchTransactions({int limit = 50}) async {
    final uid = await _userId();

    // range: últimos 6 meses até hoje
    final now = DateTime.now();
    final to = DateTime(now.year, now.month, now.day);
    final from = DateTime(to.year, to.month - 6, 1);

    String d(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';

    final res = await api.get(
      '/users/$uid/transactions',
      auth: true,
      query: {
        'from': d(from),
        'to': d(to),
        'limit': '$limit',
      },
    );

    // Aceita lista pura ou wrapper {data:[...]} ou string JSON
    List<dynamic> list;
    if (res is List) {
      list = res;
    } else if (res is Map && res['data'] is List) {
      list = res['data'] as List;
    } else if (res is String) {
      final decoded = jsonDecode(res);
      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map && decoded['data'] is List) {
        list = decoded['data'] as List;
      } else {
        list = const [];
      }
    } else {
      list = const [];
    }

    final txs = list
        .whereType<Map>() // garante apenas mapas
        .map((e) => Transaction.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    if (kDebugMode) {
      debugPrint('TX payload tipo: ${res.runtimeType}');
      debugPrint('TX qtd no payload: ${list.length}');
      debugPrint('TX mapeadas: ${txs.length}');
      if (txs.isNotEmpty) {
        debugPrint('TX[0]: ${txs.first.description} ${txs.first.amount} ${txs.first.type}');
      }
    }
    return txs;
  }

  Future<void> addTransaction(Transaction t) async {
    final uid = await _userId();
    await api.post('/users/$uid/transactions', t.toCreateJson(), auth: true);
  }
}
