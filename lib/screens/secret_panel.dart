import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../theme/colors.dart';
import '../widgets/layout/app_scaffold.dart';
import '../providers/app_state.dart';

/// Control panel — matches /secret-panel.
class SecretPanelScreen extends StatelessWidget {
  const SecretPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final canAccess = state.auth.canAccessAdmin;

    if (!state.auth.user.isAuthenticated) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => GoRouter.of(context).push('/'));
      return const Center(child: CircularProgressIndicator());
    }

    if (!canAccess) {
      return AppScaffold(
        body: const Center(
          child: Text('Access restricted to admins and workers.',
              style: TextStyle(color: AppColors.designMuted)),
        ),
      );
    }

    return AppScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
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
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Color(0xFF22C55E), blurRadius: 8)
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Admin Area · Restricted',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white70,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Control Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Manage your site content and configuration from one central location.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _stat('8', 'Pages'),
                    _stat('4', 'Languages'),
                    _stat('3', 'Agreements'),
                    _stat('Live', 'Status'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              childAspectRatio: 0.85,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              children: [
                _toolCard(
                  context,
                  icon: Icons.business_outlined,
                  title: 'Company Settings',
                  desc: 'Set your company address, email, VAT number and more.',
                  route: '/secret-panel/settings',
                  badge: 'Active',
                  badgeColor: const Color(0xFF22C55E),
                  disabled: false,
                ),
                _toolCard(
                  context,
                  icon: Icons.edit_outlined,
                  title: 'Site Text Editor',
                  desc:
                      'Modify the content of static pages like Terms of Service.',
                  route: '/secret-panel/editor',
                  badge: 'Active',
                  badgeColor: const Color(0xFF22C55E),
                  disabled: false,
                ),
                _toolCard(
                  context,
                  icon: Icons.settings_outlined,
                  title: 'Global Settings',
                  desc: 'Update site name, contact email, and other configs.',
                  badge: 'Coming Soon',
                  badgeColor: AppColors.designMuted,
                  disabled: true,
                ),
                _toolCard(
                  context,
                  icon: Icons.people_outlined,
                  title: 'User Management',
                  desc:
                      'View registered users, manage roles, and review login activity.',
                  badge: 'Coming Soon',
                  badgeColor: AppColors.designMuted,
                  disabled: true,
                ),
                _toolCard(
                  context,
                  icon: Icons.analytics_outlined,
                  title: 'Analytics',
                  desc:
                      'Track page views, user interactions, and agreement downloads.',
                  badge: 'Coming Soon',
                  badgeColor: AppColors.designMuted,
                  disabled: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.only(left: 12),
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: Colors.white24, width: 2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 3),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String desc,
    String? route,
    required String badge,
    required Color badgeColor,
    required bool disabled,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.panelCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.panelCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEEE9F8), Color(0xFFDDD5F3)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: AppColors.designText),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: badge == 'Active'
                      ? const Color(0xFF22C55E).withOpacity(0.08)
                      : const Color(0xFFF4F5F6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: badge == 'Active'
                        ? const Color(0xFF22C55E).withOpacity(0.2)
                        : const Color(0xFFEBEBEB),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      badge,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: badgeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.designText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: const TextStyle(
                fontSize: 13, color: Color(0xFF9C9CA0), height: 1.6),
          ),
          const Spacer(),
          Opacity(
            opacity: disabled ? 0.6 : 1.0,
            child: InkWell(
              onTap: disabled ? null : () => context.push(route!),
              borderRadius: BorderRadius.circular(14),
              child: Container(height: 1),
            ),
          ),
        ],
      ),
    );
  }
}
