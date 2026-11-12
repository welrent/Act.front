import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import 'api_client.dart';

/// Auth state. Sign-in calls the Act API and stores a bearer token.
class AuthService extends ChangeNotifier {
  final ApiClient api;
  AppUser _user = AppUser();
  bool _loading = true;
  bool _demoMode = false;
  String? _error;
  String? _idToken;

  static const _tokenKey = 'act_token';
  static const _userKey = 'act_user';

  AppUser get user => _user;
  bool get loading => _loading;
  bool get isAuthenticated => _user.isAuthenticated;
  bool get demoMode => _demoMode;
  String? get error => _error;
  String? get idToken => _idToken;

  bool get isAdmin => _user.isAdmin;
  bool get isWorker => _user.isWorker;
  bool get canAccessAdmin => _user.canAccessAdmin;

  AuthService(this.api) {
    _init();
  }

  Future<void> _init() async {
    _loading = true;
    notifyListeners();
    await _restoreSession();
    _loading = false;
    notifyListeners();
  }

  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString(_tokenKey);
      final rawUser = prefs.getString(_userKey);
      if (savedToken == null || savedToken.isEmpty || rawUser == null) {
        return;
      }
      api.token = savedToken;
      final response = await api.get('/api/auth/me');
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final userMap = Map<String, dynamic>.from(decoded['user'] as Map);
      if (decoded['role'] != null) userMap['role'] = decoded['role'];
      _user = AppUser.fromMap(userMap);
      _idToken = savedToken;
      _demoMode = false;
    } catch (_) {
      api.token = null;
      _user = AppUser();
      _idToken = null;
    }
  }

  Future<void> setUser(AppUser user, {String? idToken}) async {
    _user = user;
    _idToken = idToken;
    api.token = idToken;
    _error = null;
    _demoMode = false;
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_idToken == null || !_user.isAuthenticated) {
        await prefs.remove(_tokenKey);
        await prefs.remove(_userKey);
        return;
      }
      await prefs.setString(_tokenKey, _idToken!);
      await prefs.setString(_userKey, jsonEncode(_user.toMap()));
    } catch (_) {}
  }

  /// Sign in with email + password against POST /api/auth/login.
  Future<bool> signInWithEmailPassword(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await api.login(email.trim(), password);
      await setUser(result.user, idToken: result.token);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Could not reach the Act API';
      notifyListeners();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _loading = true;
    notifyListeners();
    try {
      if (api.token != null) {
        await api.deleteSession();
      }
    } catch (_) {
    } finally {
      api.token = null;
      _user = AppUser();
      _idToken = null;
      _error = null;
      await _persist();
      _loading = false;
      notifyListeners();
    }
  }

  void setError(String? message) {
    _error = message;
    notifyListeners();
  }
}
