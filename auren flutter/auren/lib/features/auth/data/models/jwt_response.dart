class JwtResponse {
  final String accessToken;
  final String refreshToken;
  final int userId;
  JwtResponse({required this.accessToken, required this.refreshToken, required this.userId});

  factory JwtResponse.fromJson(Map<String, dynamic> json) => JwtResponse(
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String,
    userId: (json['userId'] is int) ? json['userId'] as int : int.parse('${json['userId']}'),
  );
}
