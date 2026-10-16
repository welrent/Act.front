import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/colors.dart';
import '../../widgets/layout/app_scaffold.dart';

/// Home page — 1:1 match to Screenshot 1 and Next.js page.tsx
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Car Image Graphic Banner
          Container(
            width: double.infinity,
            height: 180,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: const DecorationImage(
                image: AssetImage('assets/img/hero_car.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.35),
                    Colors.black.withOpacity(0.55),
                  ],
                ),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Welcome',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Smart rental contracts for cars and motorcycles — synced with the main Welrent site.',
                    style: TextStyle(
                      color: AppColors.heroAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Rental Agreements Pills
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: const [
                  _RentalPill(
                    label: 'Car rental contract',
                    route: '/pages/car-rental-agreement',
                  ),
                  SizedBox(width: 8),
                  _RentalPill(
                    label: 'Motorcycle rental contract',
                    route: '/pages/motorcycle-rental-agreement',
                  ),
                  SizedBox(width: 8),
                  _RentalPill(
                    label: 'Boat rental contract',
                    route: '/pages/boat-rental-agreement',
                  ),
                  SizedBox(width: 8),
                  _RentalPill(
                    label: 'Equipment rental contract',
                    route: '/pages/equipment-rental-agreement',
                  ),
                ],
              ),
            ),
          ),

          // Legal Pages Content 2-column grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isTwoColumn = constraints.maxWidth >= 600;
              if (isTwoColumn) {
                return Column(
                  children: const [
                    Row(
                      children: [
                        Expanded(
                          child: _LegalCard(
                            title: 'Terms of Service',
                            desc:
                                'Review the rules and guidelines for using the platform.',
                            route: '/pages/terms',
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _LegalCard(
                            title: 'Accessibility Statement',
                            desc:
                                'Our ongoing commitment to digital accessibility for all users.',
                            route: '/pages/accessibility',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _LegalCard(
                            title: 'Privacy Statement',
                            desc:
                                'Information on how we collect, use, and protect your data.',
                            route: '/pages/privacy',
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _LegalCard(
                            title: 'Cookie Statement',
                            desc:
                                'Details regarding our use of cookies and tracking tech.',
                            route: '/pages/cookie',
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }

              return Column(
                children: const [
                  _LegalCard(
                    title: 'Terms of Service',
                    desc:
                        'Review the rules and guidelines for using the platform.',
                    route: '/pages/terms',
                  ),
                  SizedBox(height: 16),
                  _LegalCard(
                    title: 'Accessibility Statement',
                    desc:
                        'Our ongoing commitment to digital accessibility for all users.',
                    route: '/pages/accessibility',
                  ),
                  SizedBox(height: 16),
                  _LegalCard(
                    title: 'Privacy Statement',
                    desc:
                        'Information on how we collect, use, and protect your data.',
                    route: '/pages/privacy',
                  ),
                  SizedBox(height: 16),
                  _LegalCard(
                    title: 'Cookie Statement',
                    desc:
                        'Details regarding our use of cookies and tracking tech.',
                    route: '/pages/cookie',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RentalPill extends StatefulWidget {
  final String label;
  final String route;

  const _RentalPill({required this.label, required this.route});

  @override
  State<_RentalPill> createState() => _RentalPillState();
}

class _RentalPillState extends State<_RentalPill> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => context.go(widget.route),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.pillHoverBg : AppColors.pillBg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _isHovered ? AppColors.pillHoverText : AppColors.pillText,
            ),
          ),
        ),
      ),
    );
  }
}

class _LegalCard extends StatefulWidget {
  final String title;
  final String desc;
  final String route;

  const _LegalCard({
    required this.title,
    required this.desc,
    required this.route,
  });

  @override
  State<_LegalCard> createState() => _LegalCardState();
}

class _LegalCardState extends State<_LegalCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => context.go(widget.route),
        child: Container(
          constraints: const BoxConstraints(minHeight: 100),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.cardHover : AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  color:
                      _isHovered ? AppColors.designText : AppColors.designMuted,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.desc,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFBDBDBD),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
