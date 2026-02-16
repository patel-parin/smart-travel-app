import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _currentUser;
  String? _currentUserName;
  SharedPreferences? _prefs;

  static const String _usersKey = 'registered_users';
  static const String _loggedInUserKey = 'logged_in_user';

  bool get isLoggedIn => _isLoggedIn;
  String? get currentUser => _currentUser;
  String? get currentUserName => _currentUserName;

  Future<void> _ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get all registered users from local storage
  Future<List<Map<String, dynamic>>> _getUsers() async {
    await _ensureInitialized();
    final usersJson = _prefs!.getString(_usersKey);
    if (usersJson == null) return [];
    final List<dynamic> decoded = jsonDecode(usersJson);
    return decoded.cast<Map<String, dynamic>>();
  }

  /// Save users to local storage
  Future<void> _saveUsers(List<Map<String, dynamic>> users) async {
    await _ensureInitialized();
    await _prefs!.setString(_usersKey, jsonEncode(users));
  }

  /// Check and restore login state on app start
  Future<void> checkLoginState() async {
    await _ensureInitialized();
    final loggedInUser = _prefs!.getString(_loggedInUserKey);
    if (loggedInUser != null) {
      final userData = jsonDecode(loggedInUser);
      _isLoggedIn = true;
      _currentUser = userData['email'];
      _currentUserName = userData['name'];
      notifyListeners();
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    try {
      await _ensureInitialized();
      
      // Get existing users
      final users = await _getUsers();
      
      // Check if user already exists
      final existingUser = users.any((user) => user['email'] == email);
      if (existingUser) return false;

      // Add new user
      users.add({
        'name': name,
        'email': email,
        'password': password,
        'createdAt': DateTime.now().toIso8601String(),
      });
      
      await _saveUsers(users);
      return true;
    } catch (e) {
      debugPrint('Signup Error: $e');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      await _ensureInitialized();
      
      final users = await _getUsers();
      
      // Find user with matching email and password
      final user = users.firstWhere(
        (u) => u['email'] == email && u['password'] == password,
        orElse: () => {},
      );

      if (user.isNotEmpty) {
        _isLoggedIn = true;
        _currentUser = email;
        _currentUserName = user['name'];
        
        // Persist login state
        await _prefs!.setString(_loggedInUserKey, jsonEncode({
          'email': email,
          'name': user['name'],
        }));
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login Error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await _ensureInitialized();
    _isLoggedIn = false;
    _currentUser = null;
    _currentUserName = null;
    await _prefs!.remove(_loggedInUserKey);
    notifyListeners();
  }
}
