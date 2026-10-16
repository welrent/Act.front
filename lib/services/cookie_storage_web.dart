// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

bool hasConsent(String key) {
  try {
    final local = html.window.localStorage[key];
    if (local == 'true') return true;
  } catch (_) {}
  try {
    return (html.document.cookie ?? '').contains('$key=true') ||
        (html.document.cookie ?? '').contains('cookieConsentAct=true');
  } catch (_) {
    return false;
  }
}

void setConsent(String key) {
  try {
    html.window.localStorage[key] = 'true';
    html.document.cookie =
        '$key=true; max-age=31536000; path=/; SameSite=Lax';
    html.document.cookie =
        'cookieConsentAct=true; max-age=31536000; path=/; SameSite=Lax';
  } catch (_) {}
}
