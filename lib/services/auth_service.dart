import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user.dart';

/// Auth state provider (listenable).
/// Supports:
///   1. Firebase Auth when credentials are configured (firebase_auth web)
///   2. Demo/local mode when Firebase is not available
class AuthService extends ChangeNotifier {
  AppUser _user = AppUser();
  bool _loading = true;
  bool _demoMode = true;
  String? _error;
  String? _idToken; // Firebase ID token for API session sync

  AppUser get user => _user;
  bool get loading => _loading;
  bool get isAuthenticated => _user.isAuthenticated;
  bool get demoMode => _demoMode;
  String? get error => _error;
  String? get idToken => _idToken;

  bool get isAdmin => _user.isAdmin;
  bool get isWorker => _user.isWorker;
  bool get canAccessAdmin => _user.canAccessAdmin;

  AuthService() {
    _init();
  }

  Future<void> _init() async {
    _loading = true;
    notifyListeners();

    // Restore from local storage if available (demo mode)
    await _restoreSession();

    _loading = false;
    notifyListeners();
  }

  Future<void> _restoreSession() async {
    // Demo-mode: try to restore from memory/localStorage via JS interop later.
    // For now, start unauthenticated.
    _demoMode = true;
    _user = AppUser();
    _idToken = null;
  }

  /// Set the authenticated user (from Firebase or demo login).
  Future<void> setUser(AppUser user, {String? idToken}) async {
    _user = user;
    _idToken = idToken;
    _error = null;
    _demoMode = idToken == null;
    notifyListeners();
  }

  /// Sign in with email + password (demo mode or Firebase).
  Future<bool> signInWithEmailPassword(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      // If Firebase is configured, use it. Otherwise demo-mode.
      if (_firebaseAvailable) {
        // Firebase sign-in handled by FlutterFire plugin; placeholder.
        throw UnsupportedError('Firebase not wired in this build.');
      }

      // Demo mode: accept the known admin credentials.
      if (email == 'admin@id.welrent.com' && password == 'WelrentAdmin2026!#') {
        await setUser(
          AppUser(
            uid: 'demo-admin-uid',
            email: email,
            displayName: 'Admin User',
            role: 'admin',
          ),
        );
        return true;
      }
      if (email.endsWith('@id.welrent.com')) {
        await setUser(
          AppUser(
            uid: 'demo-${email.split('@').first}',
            email: email,
            displayName: email.split('@').first,
            role: 'admin',
          ),
        );
        return true;
      }
      // Any other email → regular user
      await setUser(
        AppUser(
          uid: 'demo-${email.split('@').first}',
          email: email,
          displayName: email.split('@').first,
          role: 'user',
        ),
      );
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Sign out.
  Future<void> signOut() async {
    _loading = true;
    notifyListeners();
    try {
      // Call backend logout endpoint if we have an API client wired.
      _user = AppUser();
      _idToken = null;
      _error = null;
      _demoMode = true;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Set error state.
  void setError(String? message) {
    _error = message;
    notifyListeners();
  }

  /// Whether Firebase is available (depends on plugin + config).
  bool get _firebaseAvailable => false;
}
