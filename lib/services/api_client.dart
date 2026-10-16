import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/contract.dart';
import '../models/page.dart';
import '../models/user.dart';

/// Configuration for the API base URL.
/// Set via --dart-define=API_BASE_URL=... or fallback to localhost.
class ApiConfig {
  static String get baseUrl {
    // Allow override from environment / dart-define
    const fromDefine = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (fromDefine.isNotEmpty) return fromDefine;
    // In production on act.welrent.com, same-origin. Default to localhost for dev.
    return 'http://127.0.0.1:3000';
  }
}

/// Standard API error thrown by the client.
class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  @override
  String toString() => 'ApiException($statusCode: $message)';
}

/// HTTP API client for Welrent Act PHP backend.
/// All database access stays server-side; this client only calls JSON endpoints.
class ApiClient {
  final http.Client _client;
  final String baseUrl;
  final Map<String, String> _defaultHeaders;

  ApiClient({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        baseUrl = baseUrl ?? ApiConfig.baseUrl,
        _defaultHeaders = const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        };

  /// GET helper
  Future<http.Response> get(String path, {Map<String, String>? headers}) async {
    final uri = Uri.parse('$baseUrl$path');
    final allHeaders = {..._defaultHeaders, ...?headers};
    final response = await _client.get(uri, headers: allHeaders);
    return _handle(response);
  }

  /// POST helper
  Future<http.Response> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final allHeaders = {..._defaultHeaders, ...?headers};
    final response = await _client.post(
      uri,
      headers: allHeaders,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handle(response);
  }

  /// DELETE helper
  Future<http.Response> delete(String path,
      {Map<String, String>? headers}) async {
    final uri = Uri.parse('$baseUrl$path');
    final allHeaders = {..._defaultHeaders, ...?headers};
    final response = await _client.delete(uri, headers: allHeaders);
    return _handle(response);
  }

  http.Response _handle(http.Response response) {
    if (response.statusCode >= 400) {
      String message = 'Request failed (${response.statusCode})';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['error'] != null) {
          message = decoded['error'].toString();
        }
      } catch (_) {}
      throw ApiException(response.statusCode, message);
    }
    return response;
  }

  // ── Contracts ──────────────────────────────────────────────────────

  /// GET /api/contracts?uid=<uid>
  Future<List<Contract>> listContracts({String? uid}) async {
    final query = uid != null ? '?uid=$uid' : '';
    final response = await get('/api/contracts$query');
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final list = (decoded['contracts'] as List? ?? [])
        .map((e) => Contract.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    return list;
  }

  /// GET /api/contracts/{ref}
  Future<Contract?> getContract(String ref) async {
    final response = await get('/api/contracts/${Uri.encodeComponent(ref)}');
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final contract = decoded['contract'];
    if (contract == null) return null;
    return Contract.fromMap(Map<String, dynamic>.from(contract));
  }

  /// POST /api/contracts
  Future<Contract> createContract(CreateContractInput input) async {
    final response = await post('/api/contracts', body: input.toJson());
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final contract = decoded['contract'] ?? decoded;
    return Contract.fromMap(Map<String, dynamic>.from(contract));
  }

  // ── Search ─────────────────────────────────────────────────────────

  /// GET /api/search?q=<query>
  Future<List<Map<String, dynamic>>> search(String query) async {
    if (query.trim().length < 2) return [];
    final response = await get('/api/search?q=${Uri.encodeComponent(query)}');
    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return List<Map<String, dynamic>>.from(decoded.cast<Map>());
    }
    if (decoded is Map && decoded['results'] is List) {
      return List<Map<String, dynamic>>.from(decoded['results'].cast<Map>());
    }
    return [];
  }

  // ── Pages ──────────────────────────────────────────────────────────

  /// GET /api/admin/pages
  Future<List<PageItem>> getPages() async {
    final response = await get('/api/admin/pages');
    final decoded = jsonDecode(response.body);
    final list = (decoded as List? ?? [])
        .map((e) => PageItem.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    return list;
  }

  /// POST /api/admin/pages — update page content
  Future<bool> updatePage(int id, String content) async {
    final response = await post(
      '/api/admin/pages',
      body: {'id': id, 'content': content},
    );
    return response.statusCode == 200;
  }

  // ── Settings ───────────────────────────────────────────────────────

  /// GET /api/admin/settings
  Future<List<SiteSetting>> getSettings() async {
    final response = await get('/api/admin/settings');
    final decoded = jsonDecode(response.body);
    final list = (decoded as List? ?? [])
        .map((e) => SiteSetting.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    return list;
  }

  /// POST /api/admin/settings — update settings
  Future<bool> updateSettings(List<SiteSetting> settings) async {
    final response = await post(
      '/api/admin/settings',
      body: {'settings': settings.map((s) => s.toMap()).toList()},
    );
    return response.statusCode == 200;
  }

  // ── Auth session ───────────────────────────────────────────────────

  /// POST /api/auth/session — create session from Firebase ID token
  Future<AppUser> createSession({
    required String idToken,
    required String email,
    required String uid,
  }) async {
    final response = await post(
      '/api/auth/session',
      body: {
        'idToken': idToken,
        'email': email,
        'uid': uid,
      },
    );
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final role = decoded['role'] ?? 'user';
    return AppUser(uid: uid, email: email, role: role);
  }

  /// DELETE /api/auth/session — logout
  Future<bool> deleteSession() async {
    final response = await delete('/api/auth/session');
    return response.statusCode == 200;
  }

  void dispose() {
    _client.close();
  }
}
