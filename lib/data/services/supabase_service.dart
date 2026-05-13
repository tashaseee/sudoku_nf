import '../../core/api/api_client.dart';

/// Backward-compatible service wrapper around ApiClient.
/// Keeps the same interface for any code referencing SupabaseService.
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final ApiClient _api = ApiClient();

  Future<void> initialize() async {
    await _api.init();
  }

  ApiClient get api => _api;

  bool get isLoggedIn => _api.isLoggedIn;

  Map<String, dynamic>? get currentUser => _api.currentUser;

  Future<Map<String, dynamic>> signUp(String email, String username, String password) async {
    return await _api.register(email, username, password);
  }

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    return await _api.login(email, password);
  }

  Future<void> signOut() async {
    await _api.logout();
  }

  Future<void> saveGameStats({
    required int mistakes,
    required int timeElapsed,
    required String difficulty,
    required String result,
    int hintsUsed = 0,
    bool isAiCoach = false,
  }) async {
    if (!_api.isLoggedIn) return;

    await _api.saveGame(
      difficulty: difficulty,
      result: result,
      timeElapsed: timeElapsed,
      mistakes: mistakes,
      hintsUsed: hintsUsed,
      isAiCoach: isAiCoach,
    );
  }
}
