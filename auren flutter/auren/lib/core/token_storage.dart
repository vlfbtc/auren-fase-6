import 'package:shared_preferences/shared_preferences.dart';

class StoredTokens {
  final String? accessToken;
  final String? refreshToken;
  final int? userId;
  StoredTokens({this.accessToken, this.refreshToken, this.userId});
}

class TokenStorage {
  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';
  static const _kUserId = 'user_id';

  static Future<void> write({String? accessToken, String? refreshToken, int? userId}) async {
    final sp = await SharedPreferences.getInstance();
    if (accessToken != null) await sp.setString(_kAccess, accessToken);
    if (refreshToken != null) await sp.setString(_kRefresh, refreshToken);
    if (userId != null) await sp.setInt(_kUserId, userId);
  }

  static Future<StoredTokens?> read() async {
    final sp = await SharedPreferences.getInstance();
    final a = sp.getString(_kAccess);
    final r = sp.getString(_kRefresh);
    final u = sp.getInt(_kUserId);
    if (a == null && r == null && u == null) return null;
    return StoredTokens(accessToken: a, refreshToken: r, userId: u);
  }

  static Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kAccess);
    await sp.remove(_kRefresh);
    await sp.remove(_kUserId);
  }
}
