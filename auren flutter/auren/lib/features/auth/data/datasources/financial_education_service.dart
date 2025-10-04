import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// ---- MODELOS (iguais ao que você já usa na tela) ----
class FinancialTip {
  final String id;
  final String title;
  final String description;
  final String category;
  final String priority; // "low" | "medium" | "high"
  final String? contentType; // "tip","recommendation","article","video","podcast"
  final String? articleId;

  FinancialTip({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    this.contentType,
    this.articleId,
  });

  factory FinancialTip.fromJson(Map<String, dynamic> json) {
    return FinancialTip(
      id: (json['id'] ?? '').toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'Geral',
      priority: (json['priority'] ?? 'medium').toString().toLowerCase(),
      contentType: (json['contentType'] ?? 'tip').toString().toLowerCase(),
      articleId: json['articleId']?.toString(),
    );
  }
}

class FinancialArticle {
  final String id;
  final String title;
  final String author;
  final DateTime publishDate;
  final String content;
  final String category;
  final int readTimeMinutes;
  final List<String> tags;

  FinancialArticle({
    required this.id,
    required this.title,
    required this.author,
    required this.publishDate,
    required this.content,
    required this.category,
    required this.readTimeMinutes,
    required this.tags,
  });

  factory FinancialArticle.fromJson(Map<String, dynamic> json) {
    return FinancialArticle(
      id: (json['id'] ?? '').toString(),
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      publishDate: DateTime.parse(json['publishDate'] ?? DateTime.now().toIso8601String()),
      content: json['content'] ?? '',
      category: json['category'] ?? 'Educação Financeira',
      readTimeMinutes: (json['readTimeMinutes'] ?? 5) as int,
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }
}

class EducationalContentItem {
  final String id;
  final String title;
  final String description;
  final String type; // "article","video","podcast"
  final String category;
  final String url;
  final String? thumbnailUrl;
  final String? author;
  final int? readTimeMinutes;
  final List<String> tags;

  EducationalContentItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.url,
    this.thumbnailUrl,
    this.author,
    this.readTimeMinutes,
    this.tags = const [],
  });

  factory EducationalContentItem.fromJson(Map<String, dynamic> json) {
    return EducationalContentItem(
      id: (json['id'] ?? '').toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: (json['type'] ?? 'article').toString().toLowerCase(),
      category: json['category'] ?? 'Educação Financeira',
      url: json['url'] ?? '',
      thumbnailUrl: json['thumbnailUrl'],
      author: json['author'],
      readTimeMinutes: json['readTimeMinutes'] is int ? json['readTimeMinutes'] as int : null,
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }
}

/// ---- SERVICE INTEGRADA AO SPRING BOOT ----
class FinancialEducationService {
  // Base do backend
  static const String _fallbackBase = 'http://10.0.2.2:8080/api/v1';
  final String _base =
  const String.fromEnvironment('API_BASE', defaultValue: _fallbackBase);

  Future<String> _token() async {
    final p = await SharedPreferences.getInstance();
    return p.getString('accessToken') ?? '';
  }

  Future<int> _userId() async {
    final p = await SharedPreferences.getInstance();
    // userId foi salvo como int/string durante o login
    final v = p.get('userId');
    if (v is int) return v;
    if (v is String) return int.parse(v);
    throw Exception('userId não encontrado no device');
  }

  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    if (token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  Uri _u(String path, [Map<String, dynamic>? q]) =>
      Uri.parse('$_base$path').replace(
        queryParameters: q?.map((k, v) => MapEntry(k, v.toString())),
      );

  /// Gera (POST) e busca (GET) insights recentes no servidor.
  /// Retorna uma tupla com:
  ///  - tips/recommendations (FinancialTip)
  ///  - educational items (EducationalContentItem)
  Future<({List<FinancialTip> tips, List<EducationalContentItem> edu})>
  syncAndLoad({int lookbackDays = 90, int limit = 10}) async {
    final token = await _token();
    final uid = await _userId();

    // 1) Solicita geração de insights (idempotente/estateless para o cliente)
    try {
      final post = await http.post(
        _u('/users/$uid/insights'),
        headers: _headers(token),
        body: jsonEncode({'lookbackDays': lookbackDays}),
      );
      if (post.statusCode >= 400) {
        if (kDebugMode) {
          print('Insights POST falhou: ${post.statusCode} ${post.body}');
        }
        // segue adiante — o GET abaixo pode já ter itens salvos
      }
    } catch (_) {
      // rede intermitente: seguimos para o GET
    }

    // 2) Busca os mais recentes
    final get = await http.get(
      _u('/users/$uid/insights/recent', {'limit': limit}),
      headers: _headers(token),
    );
    if (get.statusCode >= 400) {
      throw Exception('Falha ao carregar insights: ${get.statusCode}');
    }
    final decoded = jsonDecode(get.body);
    if (decoded is! List) {
      return (tips: const <FinancialTip>[], edu: const <EducationalContentItem>[]);
    }

    final tips = <FinancialTip>[];
    final edu = <EducationalContentItem>[];

    for (final item in decoded) {
      final ct = (item['contentType'] ?? 'tip').toString().toLowerCase();

      if (ct == 'article' || ct == 'video' || ct == 'podcast') {
        // conteúdo educativo
        edu.add(EducationalContentItem.fromJson({
          'id': item['articleId'] ?? item['id'],
          'title': item['title'],
          'description': item['description'],
          'type': ct,
          'category': item['category'] ?? 'Educação Financeira',
          'url': item['url'] ?? '',
          'thumbnailUrl': item['thumbnailUrl'],
          'author': item['author'],
          'readTimeMinutes': item['readTimeMinutes'],
          'tags': item['tags'] ?? [],
        }));
      } else {
        // dica/recomendação
        tips.add(FinancialTip.fromJson({
          'id': item['id'],
          'title': item['title'],
          'description': item['description'],
          'category': item['category'] ?? 'Geral',
          'priority': (item['priority'] ?? 'medium').toString().toLowerCase(),
          'contentType': ct,
          'articleId': item['articleId'],
        }));
      }
    }
    return (tips: tips, edu: edu);
  }

  /// A tela usa esse método para abrir o bottom-sheet do artigo.
  /// Implementamos um endpoint dedicado no backend.
  Future<FinancialArticle> getArticle(String articleId) async {
    final token = await _token();
    final res = await http.get(
      _u('/education/articles/$articleId'),
      headers: _headers(token),
    );
    if (res.statusCode >= 400) {
      throw Exception('Falha ao carregar artigo: ${res.statusCode}');
    }
    final obj = jsonDecode(res.body);
    return FinancialArticle.fromJson(obj);
  }

  // Métodos compatíveis com a tela atual (mantendo assinatura):
  Future<List<FinancialTip>> getFinancialTips({
    Map<String, double>? expenseCategories,
    String? riskProfile,
    double? monthlyIncome,
    double? monthlySavings,
    String? contentType,
    int? limit,
  }) async {
    final data = await syncAndLoad(limit: limit ?? 10);
    var list = data.tips;
    if (contentType != null) {
      list = list.where((t) => t.contentType == contentType.toLowerCase()).toList();
    }
    return list;
  }

  Future<List<EducationalContentItem>> getEducationalContent({
    String? category,
    String? type,
    int? limit,
  }) async {
    final data = await syncAndLoad(limit: limit ?? 10);
    var list = data.edu;
    if (type != null) {
      list = list.where((e) => e.type == type.toLowerCase()).toList();
    }
    if (category != null) {
      list = list.where((e) => e.category.toLowerCase() == category.toLowerCase()).toList();
    }
    return list;
  }
}
