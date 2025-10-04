import 'dart:convert';

enum TransactionType { income, expense }

TransactionType _typeFromString(String? s) {
  if (s == null) return TransactionType.expense;
  final up = s.toUpperCase();
  return up == 'INCOME' ? TransactionType.income : TransactionType.expense;
}

String _typeToString(TransactionType t) =>
    t == TransactionType.income ? 'INCOME' : 'EXPENSE';

DateTime _parseDate(dynamic v) {
  if (v is String) {
    // aceita "2025-08-30" ou "2025-08-30T00:00:00" etc.
    final d = DateTime.tryParse(v);
    if (d != null) return d;
  }
  return DateTime.now();
}

double _parseAmount(dynamic v) {
  if (v is num) return v.toDouble();
  if (v is String) {
    // trata BigDecimal serializado como string e vírgula decimal
    final s = v.replaceAll(',', '.').trim();
    final d = double.tryParse(s);
    if (d != null) return d;
  }
  return 0.0;
}

class Transaction {
  final int? id;
  final double amount;      // positivo
  final String description;
  final String category;
  final DateTime date;
  final TransactionType type;

  const Transaction({
    this.id,
    required this.amount,
    required this.description,
    required this.category,
    required this.date,
    required this.type,
  });

  bool get isExpense => type == TransactionType.expense;

  factory Transaction.fromJson(Map<String, dynamic> json) {
    double _amt(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v'.replaceAll(',', '.')) ?? 0.0;
    DateTime _dt(dynamic v) => DateTime.tryParse('$v') ?? DateTime.now();

    return Transaction(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      amount: _amt(json['amount']),
      description: (json['description'] as String?) ?? '',
      category: (json['category'] as String?) ?? 'Outros',
      date: _dt(json['date']),
      type: _typeFromString(json['type'] as String?),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'description': description,
      'amount': amount, // sempre positivo
      'category': category,
      'date': date.toIso8601String(),
      'type': _typeToString(type),
    };
  }
}
