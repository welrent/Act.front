import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/colors.dart';
import '../widgets/layout/app_scaffold.dart';
import '../widgets/design_message.dart';
import '../providers/app_state.dart';

/// Profile page — matches /profile.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<AppState>();
      if (state.auth.user.isAuthenticated) {
        state.loadContracts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.auth.user;
    final contracts = state.contracts;

    if (!user.isAuthenticated) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => GoRouter.of(context).push('/'));
      return const Center(child: CircularProgressIndicator());
    }

    return AppScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero graphic
          Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1E1B24),
                  Color(0xFF2F214B),
                  Color(0xFF4A3270)
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 50,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.designText,
                  child: Text(
                    user.avatarLetter,
                    style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  user.displayNameOrEmail,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Info card
          DesignMessage(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Email Address',
                        style: TextStyle(
                            color: AppColors.designMuted,
                            fontSize: 17,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      user.email ?? '—',
                      style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.designText,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'User ID (UID)',
                        style: TextStyle(
                            color: AppColors.designMuted,
                            fontSize: 17,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    GestureDetector(
                      onTap: _copyUid,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.pillBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              user.uid ?? '—',
                              style: const TextStyle(
                                fontSize: 13,
                                fontFamily: 'monospace',
                                color: AppColors.designMuted,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _copied ? 'Copied!' : 'Copy',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _copied
                                    ? AppColors.success
                                    : const Color(0xFFBDBDBD),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(child: SizedBox()),
                    TextButton(
                      onPressed: () {
                        context.read<AppState>().auth.signOut();
                        GoRouter.of(context).push('/');
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text(
                        'Sign Out',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // My contracts section header
          Row(
            children: [
              const Text(
                'My Contracts',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.designText),
              ),
              const Spacer(),
              InkWell(
                onTap: () => launchUrl(
                  Uri.parse('https://welrent.com'),
                  mode: LaunchMode.externalApplication,
                ),
                child: const Text(
                  'Book on main site →',
                  style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (state.contractsLoading)
            const DesignMessage(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (contracts.isEmpty)
            DesignMessage(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  const Text(
                    'No Active Contracts',
                    style: TextStyle(
                      color: AppColors.designMuted,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Book a car or motorcycle on the main Welrent site and Act will create your rental contract automatically.',
                    style: TextStyle(fontSize: 15, color: Color(0xFFBDBDBD)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RentalCardPill(
                          label: 'Car agreement',
                          route: '/pages/car-rental-agreement'),
                      const SizedBox(width: 8),
                      RentalCardPill(
                        label: 'Motorcycle agreement',
                        route: '/pages/motorcycle-rental-agreement',
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            ...contracts.map((c) {
              return DesignMessage(
                key: ValueKey(c.contractRef),
                interactive: true,
                onTap: () => context.push('/contracts/${c.contractRef}'),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.vehicleName,
                                style: const TextStyle(
                                  color: AppColors.designText,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                c.contractRef +
                                    (c.bookingRef != null
                                        ? ' · Booking ${c.bookingRef}'
                                        : ''),
                                style: const TextStyle(
                                  color: AppColors.designMuted,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              c.priceFormatted,
                              style: const TextStyle(
                                color: AppColors.designText,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${c.vehicleType} · ${c.status}',
                              style: const TextStyle(
                                color: AppColors.designMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      c.periodLabel +
                          (c.location != null ? ' · ${c.location}' : ''),
                      style: const TextStyle(
                        color: Color(0xFFBDBDBD),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Future<void> _copyUid() async {
    final user = context.read<AppState>().auth.user;
    await Clipboard.setData(ClipboardData(text: user.uid ?? ''));
    if (!mounted) return;
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }
}
