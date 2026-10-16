import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../providers/app_state.dart';

/// Sidebar navigation — 1:1 match to Next.js Sidebar.tsx and globals.css
class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final state = context.watch<AppState>();

    return SizedBox(
      width: isMobile ? null : 220,
      child: isMobile
          ? _buildMobileSidebar(context, state)
          : _buildDesktopSidebar(context, state),
    );
  }

  Widget _buildDesktopSidebar(BuildContext context, AppState state) {
    return Container(
      width: 220,
      padding: const EdgeInsets.fromLTRB(24, 35, 24, 24),
      decoration: const BoxDecoration(
        color: AppColors.sidebarBg,
        border: Border(
          right: BorderSide(color: AppColors.sidebarBorder, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Navigation'),
          _sidebarLink(context, 'Dashboard', '/'),
          _sidebarLink(context, 'My Profile', '/profile'),
          _sidebarLink(
              context, 'Car Agreements', '/pages/car-rental-agreement'),
          _sidebarLink(context, 'Motorcycle Agreements',
              '/pages/motorcycle-rental-agreement'),
          _sidebarLink(
              context, 'Boat Agreements', '/pages/boat-rental-agreement'),
          _sidebarLink(context, 'Equipment Agreements',
              '/pages/equipment-rental-agreement'),
          const SizedBox(height: 24),
          _sectionTitle('Legal Hub'),
          _sidebarLink(context, 'Terms of Service', '/pages/terms'),
          _sidebarLink(context, 'Privacy Policy', '/pages/privacy'),
          _sidebarLink(context, 'Cookie Rules', '/pages/cookie'),
          if (state.auth.canAccessAdmin) ...[
            const SizedBox(height: 24),
            _sectionTitle('Admin Core'),
            _sidebarLink(context, 'Control Panel', '/secret-panel'),
            _sidebarLink(context, 'Company Settings', '/secret-panel/settings'),
            _sidebarLink(context, 'Site Text Editor', '/secret-panel/editor'),
          ],
        ],
      ),
    );
  }

  Widget _buildMobileSidebar(BuildContext context, AppState state) {
    return Container(
      height: 52,
      decoration: const BoxDecoration(
        color: AppColors.sidebarMobileBg,
        border: Border(
          bottom: BorderSide(color: AppColors.borderColor, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            _mobilePill(context, 'Dashboard', '/'),
            const SizedBox(width: 8),
            _mobilePill(context, 'My Profile', '/profile'),
            const SizedBox(width: 8),
            _mobilePill(
                context, 'Car Agreements', '/pages/car-rental-agreement'),
            const SizedBox(width: 8),
            _mobilePill(context, 'Motorcycle Agreements',
                '/pages/motorcycle-rental-agreement'),
            const SizedBox(width: 8),
            _mobilePill(
                context, 'Boat Agreements', '/pages/boat-rental-agreement'),
            const SizedBox(width: 8),
            _mobilePill(context, 'Equipment Agreements',
                '/pages/equipment-rental-agreement'),
            const SizedBox(width: 8),
            _mobilePill(context, 'Terms of Service', '/pages/terms'),
            const SizedBox(width: 8),
            _mobilePill(context, 'Privacy Policy', '/pages/privacy'),
            const SizedBox(width: 8),
            _mobilePill(context, 'Cookie Rules', '/pages/cookie'),
            if (state.auth.canAccessAdmin) ...[
              const SizedBox(width: 8),
              _mobilePill(context, 'Control Panel', '/secret-panel'),
              const SizedBox(width: 8),
              _mobilePill(context, 'Settings', '/secret-panel/settings'),
              const SizedBox(width: 8),
              _mobilePill(context, 'Editor', '/secret-panel/editor'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.sidebarSectionTitle,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _sidebarLink(BuildContext context, String name, String route) {
    return _HoverableSidebarLink(name: name, route: route);
  }

  Widget _mobilePill(BuildContext context, String name, String route) {
    final location = GoRouterState.of(context).matchedLocation;
    final isActive = location == route;
    return InkWell(
      onTap: () => context.go(route),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFEEE9F8) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isActive
              ? Border.all(color: const Color(0xFFDDD5F3), width: 1)
              : null,
        ),
        child: Text(
          name,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? AppColors.designText : AppColors.designMuted,
          ),
        ),
      ),
    );
  }
}

class _HoverableSidebarLink extends StatefulWidget {
  final String name;
  final String route;

  const _HoverableSidebarLink({required this.name, required this.route});

  @override
  State<_HoverableSidebarLink> createState() => _HoverableSidebarLinkState();
}

class _HoverableSidebarLinkState extends State<_HoverableSidebarLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final isActive = location == widget.route;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: () => context.go(widget.route),
          child: Text(
            widget.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: (isActive || _isHovered)
                  ? AppColors.designText
                  : AppColors.designMuted,
            ),
          ),
        ),
      ),
    );
  }
}
