import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import '../config.dart';

class AuthService extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _currentUser;
  String? _currentUserName;
  mongo.Db? _db;
  mongo.DbCollection? _usersCollection;

  bool get isLoggedIn => _isLoggedIn;
  String? get currentUser => _currentUser;
  String? get currentUserName => _currentUserName;

  Future<void> _ensureInitialized() async {
    if (_db != null && _db!.isConnected) return;
    
    try {
      _db = await mongo.Db.create(AppConfig.mongoUri);
      await _db!.open();
      _usersCollection = _db!.collection(AppConfig.collectionName);
    } catch (e) {
      debugPrint('MongoDB Connection Error: $e');
      rethrow;
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    try {
      await _ensureInitialized();
      
      // Check if user already exists
      final existingUser = await _usersCollection!.findOne(mongo.where.eq('email', email));
      if (existingUser != null) return false;

      await _usersCollection!.insert({
        'name': name,
        'email': email,
        'password': password, // Note: In a real app, hash this!
        'createdAt': DateTime.now().toIso8601String(),
      });
      
      return true;
    } catch (e) {
      debugPrint('Signup Error: $e');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      await _ensureInitialized();
      
      final user = await _usersCollection!.findOne(
        mongo.where.eq('email', email).eq('password', password)
      );

      if (user != null) {
        _isLoggedIn = true;
        _currentUser = email;
        _currentUserName = user['name'];
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login Error: $e');
      return false;
    }
  }

  void logout() {
    _isLoggedIn = false;
    _currentUser = null;
    _currentUserName = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _db?.close();
    super.dispose();
  }
}
