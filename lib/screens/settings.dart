import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../theme/colors.dart';
import '../widgets/layout/app_scaffold.dart';
import '../widgets/design_message.dart';
import '../providers/app_state.dart';
import '../models/page.dart';

/// Company settings — matches /secret-panel/settings.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Map<String, TextEditingController> _controllers = {};
  List<SiteSetting> _settings = [];
  bool _loading = true;
  bool _saving = false;
  String? _statusType;
  String? _statusMessage;

  static const _icons = {
    'COMPANY_ADDRESS': '🏢',
    'EMAIL': '📧',
    'CHAMBER_OF_COMMERCE_NUMBER': '🏛️',
    'VAT_NUMBER': '🧾',
    'PHONE_NUMBER': '📞',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final state = context.read<AppState>();
    await state.loadSettings();
    if (!mounted) return;
    setState(() {
      _settings = state.settings;
      _loading = false;
      for (final s in _settings) {
        _controllers[s.key] = TextEditingController(text: s.value);
      }
    });
  }

  @override
  void dispose() {
    for (final c in _controllers.values) c.dispose();
    super.dispose();
  }

  void _onChanged(String key, String value) {
    setState(() {
      _settings = _settings
          .map((s) => s.key == key
              ? SiteSetting(key: s.key, value: value, label: s.label)
              : s)
          .toList();
    });
  }

  Future<void> _handleSave() async {
    setState(() {
      _saving = true;
      _statusType = 'loading';
      _statusMessage = 'Saving settings...';
    });
    try {
      final ok = await context.read<AppState>().updateSettings(_settings);
      if (!mounted) return;
      setState(() {
        _saving = false;
        _statusType = ok ? 'success' : 'error';
        _statusMessage = ok
            ? '✅ Settings saved! All pages will now use the updated values.'
            : '❌ Failed to save. Please try again.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _statusType = 'error';
        _statusMessage = '❌ Failed to save. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [
                  AppColors.panelGradientStart,
                  AppColors.panelGradientEnd
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Admin Panel · Global Settings',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white70,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Company Settings',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'These values replace placeholders like [COMPANY_ADDRESS] across all legal pages automatically.',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (_loading)
            const DesignMessage(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 700),
              decoration: BoxDecoration(
                color: AppColors.panelCardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.panelCardBorder),
              ),
              child: Column(
                children: [
                  ..._settings.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final setting = entry.value;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${_icons[setting.key] ?? '⚙️'} ${setting.label}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.designText,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF4F5F6),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '[${setting.key}]',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.designMuted,
                                        fontFamily: 'monospace',
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _controllers[setting.key],
                                onChanged: (v) => _onChanged(setting.key, v),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.designText,
                                ),
                                decoration: InputDecoration(
                                  hintText:
                                      'Enter ${setting.label?.toLowerCase() ?? ''}...',
                                  hintStyle: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.designMuted),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFE8E4F2)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF9B7FD4)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (idx < _settings.length - 1)
                          const Divider(height: 1, color: Color(0xFFF0EEF6)),
                      ],
                    );
                  }),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 700),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEEE9F8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDDD5F3)),
            ),
            child: const Text(
              '💡 How it works: When a visitor opens a legal page (e.g. Car Rental Agreement), the system automatically replaces all placeholders with the values you set here. No manual editing of each page required.',
              style: TextStyle(
                  fontSize: 13, color: AppColors.designText, height: 1.6),
            ),
          ),
          const SizedBox(height: 16),
          if (_statusMessage != null)
            StatusBanner(type: _statusType ?? 'info', message: _statusMessage!),
          const SizedBox(height: 16),
          GradientButton(
            label: _saving ? 'Saving...' : '💾 Save Settings',
            onPressed: _handleSave,
            loading: _saving,
          ),
          const SizedBox(height: 16),
          Align(
            child: TextButton(
              onPressed: () => GoRouter.of(context).push('/secret-panel'),
              child: const Text('← Back to Control Panel',
                  style: TextStyle(fontSize: 13, color: AppColors.designMuted)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
