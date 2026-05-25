import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {

  // ⚠️ CHANGE PAR TON IP
  static const String baseUrl =
      "http://127.0.0.1:8000/api";

  Future<bool> login({
    required String username,
    required String password,
  }) async {

    try {

      final response = await http.post(

        Uri.parse('$baseUrl/token/'),

        body: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);

        final prefs =
            await SharedPreferences.getInstance();

        // SAVE TOKENS
        await prefs.setString(
          'access',
          data['access'],
        );

        await prefs.setString(
          'refresh',
          data['refresh'],
        );

        return true;

      } else {

        return false;
      }

    } catch (e) {

      print(e);

      return false;
    }
  }

  // GET ACCESS TOKEN
  Future<String?> getAccessToken() async {

    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getString('access');
  }

  // LOGOUT
  Future<void> logout() async {

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.clear();
  }
}