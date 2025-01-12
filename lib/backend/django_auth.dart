import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DjangoBackend {
    // Singleton instance
  static final DjangoBackend _instance = DjangoBackend._internal();

  // Factory constructor to return the same instance
  factory DjangoBackend() => _instance;

  // Private constructor
  DjangoBackend._internal();

  final String baseUrl = 'http://192.168.242.48:8000';
 
  String? _accessToken;
  String? _refreshToken;

  Future<void> _loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('accessToken');
    _refreshToken = prefs.getString('refreshToken');
  }

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    _accessToken = null;
    _refreshToken = null;
  }

  Future<bool> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/api/token/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveTokens(data['access'], data['refresh']);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('Error during login: $e');
    }
  }

  Future<void> refreshToken() async {
    if (_refreshToken == null) throw Exception('No refresh token available');

    final url = Uri.parse('$baseUrl/api/token/refresh/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': _refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveTokens(data['access'], _refreshToken!);
      } else {
        throw Exception('Failed to refresh token: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error during token refresh.');
    }
  }

  Future<bool> isLoggedIn() async {
    await _loadTokens();
    print('Access token: $_accessToken');
    print('Refresh token: $_refreshToken');
    if (_accessToken == null) return false;

    // Optional: Check if the access token is valid by making a small request
    final url = Uri.parse('$baseUrl/api/protected/');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        // Token expired, try refreshing
        await refreshToken();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(String username, String password, String email) async {
    final url = Uri.parse('$baseUrl/api/register/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'email': email,
        }),
      );
      final data = jsonDecode(response.body);
      await _saveTokens(data['access'], data['refresh']);
      return response.statusCode == 201;
    } catch (e) {
      throw Exception('Error during registration: $e');
    }
  }

  Future<void> logout() async {
    await _clearTokens();
  }
}
