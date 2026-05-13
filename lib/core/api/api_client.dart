import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

/// Centralized HTTP client with JWT token management.
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  String? _token;
  Map<String, dynamic>? _currentUser;

  /// JWT access token.
  String? get token => _token;

  /// Current authenticated user data.
  Map<String, dynamic>? get currentUser => _currentUser;

  /// Whether a user is logged in.
  bool get isLoggedIn => _token != null;

  /// Load persisted token from SharedPreferences.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    final userJson = prefs.getString('current_user');
    if (userJson != null) {
      _currentUser = json.decode(userJson);
    }
  }

  /// Persist token and user locally.
  Future<void> _persist(String token, Map<String, dynamic> user) async {
    _token = token;
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('current_user', json.encode(user));
  }

  /// Clear auth data.
  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('current_user');
  }

  /// Build headers with optional auth.
  Map<String, String> _headers({bool auth = true}) {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (auth && _token != null) {
      h['Authorization'] = 'Bearer $_token';
    }
    return h;
  }

  // ─── Auth ──────────────────────────────────────────

  /// Register a new account.
  Future<Map<String, dynamic>> register(
    String email,
    String username,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse(ApiConfig.registerUrl),
      headers: _headers(auth: false),
      body: json.encode({
        'email': email,
        'username': username,
        'password': password,
      }),
    );
    final data = json.decode(res.body);
    if (res.statusCode == 201) {
      await _persist(data['access_token'], data['user']);
      return data;
    }
    throw ApiException(res.statusCode, data['detail'] ?? 'Ошибка регистрации');
  }

  /// Login with email + password.
  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse(ApiConfig.loginUrl),
      headers: _headers(auth: false),
      body: json.encode({'email': email, 'password': password}),
    );
    final data = json.decode(res.body);
    if (res.statusCode == 200) {
      await _persist(data['access_token'], data['user']);
      return data;
    }
    throw ApiException(res.statusCode, data['detail'] ?? 'Неверные данные');
  }

  /// Refresh current user info.
  Future<Map<String, dynamic>> getMe() async {
    final res = await http.get(Uri.parse(ApiConfig.meUrl), headers: _headers());
    final data = json.decode(res.body);
    if (res.statusCode == 200) {
      _currentUser = data;
      return data;
    }
    throw ApiException(res.statusCode, data['detail'] ?? 'Ошибка');
  }

  // ─── User & Stats ─────────────────────────────────

  /// Get user stats.
  Future<Map<String, dynamic>> getStats() async {
    final res = await http.get(
      Uri.parse(ApiConfig.statsUrl),
      headers: _headers(),
    );
    if (res.statusCode == 200) return json.decode(res.body);
    throw ApiException(res.statusCode, 'Ошибка загрузки статистики');
  }

  /// Update profile.
  Future<Map<String, dynamic>> updateProfile({
    String? username,
    String? avatarUrl,
  }) async {
    final body = <String, dynamic>{};
    if (username != null) body['username'] = username;
    if (avatarUrl != null) body['avatar_url'] = avatarUrl;

    final res = await http.patch(
      Uri.parse(ApiConfig.profileUrl),
      headers: _headers(),
      body: json.encode(body),
    );
    final data = json.decode(res.body);
    if (res.statusCode == 200) {
      _currentUser = data;
      return data;
    }
    throw ApiException(res.statusCode, data['detail'] ?? 'Ошибка обновления');
  }

  /// Upgrade to PRO.
  Future<Map<String, dynamic>> upgradePro() async {
    final res = await http.post(
      Uri.parse(ApiConfig.upgradeProUrl),
      headers: _headers(),
    );
    final data = json.decode(res.body);
    if (res.statusCode == 200) {
      _currentUser = data;
      return data;
    }
    throw ApiException(res.statusCode, 'Ошибка активации PRO');
  }

  // ─── Games ────────────────────────────────────────

  /// Save a completed game.
  Future<Map<String, dynamic>> saveGame({
    required String difficulty,
    required String result,
    required int timeElapsed,
    int mistakes = 0,
    int hintsUsed = 0,
    bool isAiCoach = false,
    List<List<int>>? puzzle,
    List<List<int>>? solution,
  }) async {
    final body = {
      'difficulty': difficulty,
      'result': result,
      'time_elapsed': timeElapsed,
      'mistakes': mistakes,
      'hints_used': hintsUsed,
      'is_ai_coach': isAiCoach,
      if (puzzle != null) 'puzzle': puzzle,
      if (solution != null) 'solution': solution,
    };

    final res = await http.post(
      Uri.parse(ApiConfig.gamesUrl),
      headers: _headers(),
      body: json.encode(body),
    );
    if (res.statusCode == 201) return json.decode(res.body);
    throw ApiException(res.statusCode, 'Ошибка сохранения игры');
  }

  /// Get game history.
  Future<List<dynamic>> getHistory({
    int limit = 50,
    int offset = 0,
    String? resultFilter,
  }) async {
    var url = '${ApiConfig.historyUrl}?limit=$limit&offset=$offset';
    if (resultFilter != null) url += '&result_filter=$resultFilter';

    final res = await http.get(Uri.parse(url), headers: _headers());
    if (res.statusCode == 200) return json.decode(res.body);
    throw ApiException(res.statusCode, 'Ошибка загрузки истории');
  }

  /// Get leaderboard (public).
  Future<List<dynamic>> getLeaderboard({int limit = 20}) async {
    final res = await http.get(
      Uri.parse('${ApiConfig.leaderboardUrl}?limit=$limit'),
      headers: _headers(auth: false),
    );
    if (res.statusCode == 200) return json.decode(res.body);
    throw ApiException(res.statusCode, 'Ошибка загрузки лидерборда');
  }

  // ─── Achievements ─────────────────────────────────

  /// Get all achievements with unlock status.
  Future<List<dynamic>> getAchievements() async {
    final res = await http.get(
      Uri.parse(ApiConfig.achievementsUrl),
      headers: _headers(),
    );
    if (res.statusCode == 200) return json.decode(res.body);
    throw ApiException(res.statusCode, 'Ошибка загрузки достижений');
  }

  // ─── Articles ─────────────────────────────────────

  /// Get published articles (public).
  Future<List<dynamic>> getArticles({int limit = 20, int offset = 0}) async {
    final res = await http.get(
      Uri.parse('${ApiConfig.articlesUrl}?limit=$limit&offset=$offset'),
      headers: _headers(auth: false),
    );
    if (res.statusCode == 200) return json.decode(res.body);
    throw ApiException(res.statusCode, 'Ошибка загрузки статей');
  }

  // ─── Health ───────────────────────────────────────

  /// Check backend connectivity.
  Future<bool> checkHealth() async {
    try {
      final res = await http
          .get(Uri.parse(ApiConfig.healthUrl))
          .timeout(const Duration(seconds: 5));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ─── Notifications ────────────────────────────────

  Future<List<dynamic>> getNotifications() async {
    final res = await http.get(
      Uri.parse(ApiConfig.notificationsUrl),
      headers: _headers(),
    );
    if (res.statusCode == 200) return json.decode(utf8.decode(res.bodyBytes));
    throw ApiException(res.statusCode, 'Ошибка загрузки уведомлений');
  }

  Future<void> markNotificationsRead() async {
    final res = await http.post(
      Uri.parse('${ApiConfig.notificationsUrl}/read-all'),
      headers: _headers(),
    );
    if (res.statusCode != 200) {
      throw ApiException(res.statusCode, 'Ошибка обновления уведомлений');
    }
  }
}

/// Custom exception for API errors.
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
