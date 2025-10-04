class TransactionDto {
  final int? id;
  final double amount; // positivo
  final String description;
  final String category;
  final DateTime date;
  final String type; // 'INCOME' | 'EXPENSE'

  const TransactionDto({
    this.id,
    required this.amount,
    required this.description,
    required this.category,
    required this.date,
    required this.type,
  });

  bool get isExpense => type.toUpperCase() == 'EXPENSE';

  factory TransactionDto.fromJson(Map<String, dynamic> json) {
    return TransactionDto(
      id: json['id'] is int ? json['id'] as int : (json['id'] == null ? null : int.tryParse(json['id'].toString())),
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'Outros',
      date: DateTime.parse(json['date'] as String),
      type: (json['type'] as String?)?.toUpperCase() == 'INCOME' ? 'INCOME' : 'EXPENSE',
    );
  }

  Map<String, dynamic> toCreateJson() => {
    'description': description,
    'amount': amount,
    'category': category,
    'date': date.toIso8601String(),
    'type': type,
  };
}
