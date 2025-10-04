class FinancialTip {
  final String id;
  final String title;
  final String description;
  final String category;
  final String priority;
  final String? contentType; // "tip", "recommendation", etc.
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
    // backend pode NÃO mandar id; geramos um estável
    final generatedId = '${json['title'] ?? ''}|${json['category'] ?? ''}|${json['description'] ?? ''}';
    return FinancialTip(
      id: (json['id'] ?? generatedId).toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      priority: (json['priority'] ?? 'low').toString().toLowerCase(),
      contentType: json['contentType']?.toString(),
      articleId: json['articleId']?.toString(),
    );
  }
}
