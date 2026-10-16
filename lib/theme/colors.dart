import 'package:flutter/material.dart';

/// Design tokens matching original Next.js / layout.php
abstract class AppColors {
  // Brand
  static const Color primary = Color(0xFF2D3ED2);
  static const Color primaryHover = Color(0xFF1F2CA8);

  // Surface / background
  static const Color secondary = Color(0xFFF4F5F7);
  static const Color bgLight = Color(0xFFFFFFFF);
  static const Color designBg = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFF9FAFB);
  static const Color cardHover = Color(0xFFF4F5F6);

  // Text
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF666666);
  static const Color designText = Color(0xFF2F214B);
  static const Color designMuted = Color(0xFF8C8C91);
  static const Color designMutedLight = Color(0xFFB0AABF);

  // Borders
  static const Color borderColor = Color(0xFFEAECF0);
  static const Color designBorder = Color(0xFFF4F5F6);

  // Accents
  static const Color heroAccent = Color(0xFF8EB9FF);
  static const Color danger = Color(0xFFEF4135);
  static const Color dangerBg = Color(0xFFFFF5F5);
  static const Color dangerBorder = Color(0xFFFDDCDA);
  static const Color success = Color(0xFF22C55E);
  static const Color successBg = Color(0xFFE7F7EC);

  // Pill / interactive states
  static const Color pillBg = Color(0xFFF1F2F4);
  static const Color pillText = Color(0xFFC4C4C8);
  static const Color pillHoverBg = Color(0xFFEEE9F8);
  static const Color pillHoverText = Color(0xFF2F214B);
  static const Color pillActiveBorder = Color(0xFFDDD5F3);

  // Header
  static const Color pipeColor = Color(0xFFD6D6DD);
  static const Color actColor = Color(0xFFC0BDC8);
  static const Color searchBg = Color(0xFFF4F5F6);
  static const Color searchShortcutBg = Color(0xFFE2E2E6);
  static const Color searchShortcutText = Color(0xFF8C8C91);

  // Avatar
  static const Color avatarBg = Color(0xFFF4F5F6);
  static const Color avatarActive = Color(0xFF2F214B);
  static const Color avatarIcon = Color(0xFFC0BDC8);

  // Cookie banner
  static const Color cookieBannerBg = Color(0xFF2A303C);
  static const Color cookieBannerText = Color(0xFFC0BDC8);
  static const Color cookieBannerBorder = Color(0xFF8EB9FF);

  // Control panel
  static const Color panelGradientStart = Color(0xFF2F214B);
  static const Color panelGradientEnd = Color(0xFF4A3270);
  static const Color panelCardBg = Color(0xFFFAFAFA);
  static const Color panelCardBorder = Color(0xFFF0EEF6);

  // Sidebar
  static const Color sidebarBg = Color(0xFFFFFFFF);
  static const Color sidebarMobileBg = Color(0xFFF9FAFB);
  static const Color sidebarBorder = Color(0xFFF4F5F6);
  static const Color sidebarSectionTitle = Color(0xFFC0BDC8);
  static const Color sidebarLink = Color(0xFF8C8C91);
  static const Color sidebarLinkActive = Color(0xFF2F214B);
}
