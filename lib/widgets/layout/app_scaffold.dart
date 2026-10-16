import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import 'sidebar.dart';
import 'header.dart';
import 'footer.dart';

/// Main app scaffold: mirrors Next.js .site-layout and .design-wrapper structure.
class AppScaffold extends StatelessWidget {
  final Widget body;
  final bool showSidebar;
  final bool showFooter;

  const AppScaffold({
    super.key,
    required this.body,
    this.showSidebar = true,
    this.showFooter = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Stack(
        children: [
          // Main scrollable content
          Positioned.fill(
            child: SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1050),
                  child: isMobile
                      ? _buildMobileLayout(context)
                      : _buildDesktopLayout(context),
                ),
              ),
            ),
          ),

          // Strict GDPR Fixed Cookie Banner
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: FixedCookieBanner(),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showSidebar) const Sidebar(),
        Expanded(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Header(),
                body,
                const SizedBox(height: 32),
                if (showFooter) const Footer(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showSidebar) const Sidebar(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Header(),
              const SizedBox(height: 12),
              body,
              const SizedBox(height: 24),
              if (showFooter) const Footer(),
            ],
          ),
        ),
      ],
    );
  }
}
