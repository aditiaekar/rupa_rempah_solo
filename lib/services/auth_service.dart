import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  AuthService._();

  static final SharedPreferencesAsync _prefs = SharedPreferencesAsync();
  static const String _nameKey = 'user_full_name';
  static const String _usernameKey = 'user_username';
  static const String _passwordKey = 'user_password';
  static const String _loginKey = 'is_logged_in';

  static Future<void> register({
    required String fullName,
    required String username,
    required String password,
  }) async {
    await _prefs.setString(_nameKey, fullName.trim());
    await _prefs.setString(_usernameKey, username.trim());
    await _prefs.setString(_passwordKey, password);
    await _prefs.setBool(_loginKey, false);
  }

  static Future<bool> login(String username, String password) async {
    final savedUsername = await _prefs.getString(_usernameKey);
    final savedPassword = await _prefs.getString(_passwordKey);
    final isValid = username.trim() == savedUsername &&
        password == savedPassword &&
        savedUsername != null;

    if (isValid) {
      await _prefs.setBool(_loginKey, true);
    }
    return isValid;
  }

  static Future<bool> isLoggedIn() async {
    final loggedIn = await _prefs.getBool(_loginKey) ?? false;
    final username = await _prefs.getString(_usernameKey);
    return loggedIn && username != null;
  }

  static Future<String> getFullName() async {
    return await _prefs.getString(_nameKey) ?? 'Pengguna';
  }

  static Future<String> getUsername() async {
    return await _prefs.getString(_usernameKey) ?? '';
  }

  static Future<void> updateCredentials({
    required String username,
    String? newPassword,
  }) async {
    await _prefs.setString(_usernameKey, username.trim());
    if (newPassword != null && newPassword.isNotEmpty) {
      await _prefs.setString(_passwordKey, newPassword);
    }
  }

  static Future<void> logout() async {
    await _prefs.setBool(_loginKey, false);
  }
}
