class InsightItem {
  final int id;
  final String title;
  final String content;
  InsightItem({required this.id, required this.title, required this.content});

  factory InsightItem.fromJson(Map<String, dynamic> j) => InsightItem(
    id: j['id'] as int,
    title: j['title'] as String,
    content: j['content'] as String,
  );
}

class InsightsResponse {
  final List<String> recommendations;
  InsightsResponse({required this.recommendations});
  factory InsightsResponse.fromJson(Map<String, dynamic> j) =>
      InsightsResponse(recommendations: (j['recommendations'] as List).map((e) => '$e').toList());
}
