/// API configuration constants for the Flutter app backend connection.

class ApiConfig {
  /// Base URL for the backend API.
  /// Change to your deployed URL for production, например https://your-backend-url.onrender.com.
  static const String baseUrl = 'http://localhost:8080';

  /// API prefix
  static const String apiPrefix = '/api';

  /// Full API URL
  static String get apiUrl => '$baseUrl$apiPrefix';

  // ─── Auth endpoints ───
  static String get registerUrl => '$apiUrl/auth/register';
  static String get loginUrl => '$apiUrl/auth/login';
  static String get meUrl => '$apiUrl/auth/me';

  // ─── User endpoints ───
  static String get profileUrl => '$apiUrl/users/me';
  static String get statsUrl => '$apiUrl/users/me/stats';
  static String get upgradeProUrl => '$apiUrl/users/me/upgrade-pro';

  // ─── Game endpoints ───
  static String get gamesUrl => '$apiUrl/games';
  static String get historyUrl => '$apiUrl/games/history';
  static String get leaderboardUrl => '$apiUrl/games/leaderboard';

  // ─── Achievements ───
  static String get achievementsUrl => '$apiUrl/achievements';

  // ─── Articles ───
  static const String articlesUrl = '$baseUrl/api/articles';
  static const String notificationsUrl = '$baseUrl/api/notifications';

  // ─── Health ───
  static String get healthUrl => '$apiUrl/health';
}
