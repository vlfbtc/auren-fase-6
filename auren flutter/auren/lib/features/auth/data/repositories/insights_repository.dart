import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../../core/api_client.dart';
import '../../../../core/token_storage.dart';
import '../../data/datasources/financial_education_service.dart'
    show FinancialTip, EducationalContentItem;

class InsightsRepository {
  final ApiClient api;
  InsightsRepository({required this.api});

  Future<int> _userId() async {
    final s = await TokenStorage.read();
    final id = s?.userId;
    if (id == null) throw Exception('Sessão inválida: userId não encontrado');
    return id;
  }

  Map<String, dynamic> _toMap(dynamic res) {
    // Aceita:
    // - Map (com ou sem 'data')
    // - String JSON
    // - Qualquer outro -> {}
    try {
      if (res is Map) {
        final data = res['data'] ?? res;
        return Map<String, dynamic>.from(data as Map);
      }
      if (res is String) {
        final decoded = jsonDecode(res);
        if (decoded is Map) {
          final data = decoded['data'] ?? decoded;
          return Map<String, dynamic>.from(data as Map);
        }
      }
    } catch (_) {}
    return <String, dynamic>{};
  }

  ({List<FinancialTip> tips, List<EducationalContentItem> edu}) _mapBundle(dynamic res) {
    final data = _toMap(res);

    // Fallback de chaves (swagger pode variar):
    final rawTips = (data['tips'] ??
        data['recommendations'] ??
        const []) as Object;
    final rawContent = (data['content'] ??
        data['contents'] ??
        const []) as Object;

    final tipsJson = (rawTips is List) ? rawTips : const [];
    final contentJson = (rawContent is List) ? rawContent : const [];

    final tips = tipsJson
        .whereType<Map>()
        .map((e) => FinancialTip.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final edu = contentJson
        .whereType<Map>()
        .map((e) => EducationalContentItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    if (kDebugMode) {
      debugPrint('INSIGHTS: tips=${tips.length}, edu=${edu.length}');
    }
    return (tips: tips, edu: edu);
  }

  Future<({List<FinancialTip> tips, List<EducationalContentItem> edu})> recent() async {
    final uid = await _userId();
    final res = await api.get('/users/$uid/insights?months=6&topN=10&refresh=true', auth: true);
    return _mapBundle(res);
  }

  Future<({List<FinancialTip> tips, List<EducationalContentItem> edu})> generate() async {
    final uid = await _userId();
    // corpo opcional; backend já ignora se não precisar
    final res = await api.post('/users/$uid/insights/generate', {}, auth: true);
    return _mapBundle(res);
  }
}
