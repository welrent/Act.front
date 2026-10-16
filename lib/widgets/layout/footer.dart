import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/colors.dart';
import '../../services/cookie_storage.dart';

/// In-page Footer — matches Next.js Footer.tsx .design-footer
class Footer extends StatefulWidget {
  const Footer({super.key});

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  String _currentLang = 'en';

  final List<Map<String, String>> _languages = const [
    {'code': 'fr', 'flag': '🇫🇷'},
    {'code': 'nl', 'flag': '🇳🇱'},
    {'code': 'en', 'flag': '🇬🇧'},
    {'code': 'es', 'flag': '🇪🇸'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 24),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 8,
            children: [
              InkWell(
                onTap: () => launchUrl(
                  Uri.parse('https://welrent.com'),
                  mode: LaunchMode.externalApplication,
                ),
                child: const Text(
                  'Welrent Europa B.V.',
                  style: TextStyle(
                    color: Color(0xFFCBCBCF),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: _languages.map((lang) {
                  final code = lang['code']!;
                  final flag = lang['flag']!;
                  final isActive = _currentLang == code;
                  return _langButton(code, flag, isActive);
                }).toList(),
              ),
            ],
          ),
          const Text(
            '© 2026',
            style: TextStyle(
              color: Color(0xFFCBCBCF),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _langButton(String code, String flag, bool active) {
    return InkWell(
      onTap: () => setState(() => _currentLang = code),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(left: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFEEE9F8) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? const Color(0xFFDDD5F3) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(flag, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 5),
            Text(
              code.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                color: active ? AppColors.designText : const Color(0xFFB0AABF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Strict GDPR Fixed Cookie Banner — 1:1 match to Screenshot 1, 2, 3 and Footer.php
class FixedCookieBanner extends StatefulWidget {
  const FixedCookieBanner({super.key});

  @override
  State<FixedCookieBanner> createState() => _FixedCookieBannerState();
}

class _FixedCookieBannerState extends State<FixedCookieBanner> {
  bool _visible = false;
  static const _consentKey = 'welrent_act_cookie_consent';

  @override
  void initState() {
    super.initState();
    _checkConsent();
  }

  void _checkConsent() {
    if (!CookieStorage.hasConsent(_consentKey)) {
      setState(() => _visible = true);
    }
  }

  void _accept() {
    CookieStorage.setConsent(_consentKey);
    setState(() => _visible = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.cookieBannerBg,
        border: Border(
          top: BorderSide(color: AppColors.cookieBannerBorder, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 30,
            offset: Offset(0, -10),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1050),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 650;
              if (isMobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextContent(),
                    const SizedBox(height: 16),
                    _buildAcceptButton(),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: _buildTextContent()),
                  const SizedBox(width: 24),
                  _buildAcceptButton(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: const [
        Text(
          'We value your privacy.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Our infrastructure uses tracking cookies to structurally enhance your browsing layout patterns and optimize backend tracking parameters. Clicking "Yes, Accept" confirms your alignment.',
          style: TextStyle(
            color: AppColors.cookieBannerText,
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildAcceptButton() {
    return ElevatedButton(
      onPressed: _accept,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.cookieBannerBorder,
        foregroundColor: AppColors.designText,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        elevation: 0,
      ),
      child: const Text(
        'Yes, Accept',
        style: TextStyle(
          color: AppColors.designText,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
