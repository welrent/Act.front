import 'cookie_storage_stub.dart'
    if (dart.library.html) 'cookie_storage_web.dart' as impl;

abstract class CookieStorage {
  static bool hasConsent(String key) => impl.hasConsent(key);
  static void setConsent(String key) => impl.setConsent(key);
}
