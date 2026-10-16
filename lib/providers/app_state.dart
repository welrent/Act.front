import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';
import '../models/contract.dart';
import '../models/page.dart';
import '../models/seed_data.dart';

/// Combined app state provider.
/// Holds AuthService + ApiClient and exposes cached data + convenience methods.
class AppState extends ChangeNotifier {
  final AuthService auth = AuthService();
  final ApiClient api = ApiClient();

  // Data caches pre-populated with SeedData from Next.js
  List<Contract> _contracts = List.from(SeedData.contracts);
  List<PageItem> _pages = List.from(SeedData.pages);
  List<SiteSetting> _settings = List.from(SeedData.settings);

  bool _contractsLoading = false;
  bool _pagesLoading = false;
  bool _settingsLoading = false;
  String? _error;

  List<Contract> get contracts => _contracts;
  List<PageItem> get pages => _pages;
  List<SiteSetting> get settings => _settings;

  bool get contractsLoading => _contractsLoading;
  bool get pagesLoading => _pagesLoading;
  bool get settingsLoading => _settingsLoading;
  String? get error => _error;

  AppState() {
    auth.addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    notifyListeners();
    if (auth.isAuthenticated) {
      loadContracts();
      loadPages();
      loadSettings();
    }
  }

  void setError(String? message) {
    _error = message;
    notifyListeners();
  }

  // ── Contracts ──────────────────────────────────────────────────────

  Future<void> loadContracts({String? uid}) async {
    _contractsLoading = true;
    _error = null;
    notifyListeners();
    try {
      final targetUid =
          uid ?? ((auth.user.uid ?? '').isNotEmpty ? auth.user.uid : null);
      if (targetUid != null) {
        final fetched = await api.listContracts(uid: targetUid);
        if (fetched.isNotEmpty) {
          _contracts = fetched;
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _contractsLoading = false;
      notifyListeners();
    }
  }

  Future<Contract?> loadContract(String ref) async {
    try {
      final fetched = await api.getContract(ref);
      if (fetched != null) {
        final idx = _contracts.indexWhere((c) => c.contractRef == ref);
        if (idx >= 0) {
          _contracts[idx] = fetched;
        } else {
          _contracts.insert(0, fetched);
        }
        notifyListeners();
        return fetched;
      }
    } catch (_) {}

    // Fallback to local cache or seed data
    try {
      return _contracts.firstWhere(
        (c) => c.contractRef == ref || c.bookingRef == ref,
      );
    } catch (_) {
      try {
        return SeedData.contracts.firstWhere(
          (c) => c.contractRef == ref || c.bookingRef == ref,
        );
      } catch (_) {
        return SeedData.contracts.isNotEmpty ? SeedData.contracts.first : null;
      }
    }
  }

  Future<bool> createContract({
    required String userUid,
    required String vehicleName,
    String? bookingRef,
    String vehicleType = 'car',
    String? vehicleImage,
    String? startDate,
    String? endDate,
    int? days,
    double? price,
    String? location,
    String? status,
    String? source,
  }) async {
    _contractsLoading = true;
    notifyListeners();
    try {
      if (startDate == null || endDate == null) {
        _error = 'start_date and end_date are required';
        return false;
      }
      final input = CreateContractInput(
        userUid: userUid,
        bookingRef: bookingRef,
        vehicleType: vehicleType,
        vehicleName: vehicleName,
        vehicleImage: vehicleImage,
        startDate: startDate,
        endDate: endDate,
        days: days,
        price: price,
        location: location,
        status: status,
        source: source,
      );
      final created = await api.createContract(input);
      _contracts.insert(0, created);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _contractsLoading = false;
      notifyListeners();
    }
  }

  // ── Pages ──────────────────────────────────────────────────────────

  Future<void> loadPages() async {
    _pagesLoading = true;
    _error = null;
    notifyListeners();
    try {
      final fetched = await api.getPages();
      if (fetched.isNotEmpty) {
        _pages = fetched;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _pagesLoading = false;
      notifyListeners();
    }
  }

  PageItem? findPageBySlug(String slug) {
    try {
      return _pages.firstWhere((p) => p.slug == slug);
    } catch (_) {
      try {
        return SeedData.pages.firstWhere((p) => p.slug == slug);
      } catch (_) {
        return null;
      }
    }
  }

  Future<bool> updatePageContent(int id, String content) async {
    try {
      final ok = await api.updatePage(id, content);
      if (ok) await loadPages();
      return ok;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // ── Settings ───────────────────────────────────────────────────────

  Future<void> loadSettings() async {
    _settingsLoading = true;
    _error = null;
    notifyListeners();
    try {
      final fetched = await api.getSettings();
      if (fetched.isNotEmpty) {
        _settings = fetched;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _settingsLoading = false;
      notifyListeners();
    }
  }

  String? settingValue(String key) {
    try {
      return _settings.firstWhere((s) => s.key == key).value;
    } catch (_) {
      return null;
    }
  }

  Future<bool> updateSettings(List<SiteSetting> updated) async {
    _settingsLoading = true;
    notifyListeners();
    try {
      final ok = await api.updateSettings(updated);
      if (ok) await loadSettings();
      return ok;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _settingsLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    auth.removeListener(_onAuthChanged);
    api.dispose();
    super.dispose();
  }
}
