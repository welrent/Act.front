import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../theme/colors.dart';
import '../widgets/layout/app_scaffold.dart';
import '../widgets/design_message.dart';
import '../providers/app_state.dart';

/// Portal page — matches /portal/:username.
class PortalScreen extends StatefulWidget {
  final String username;
  const PortalScreen({super.key, required this.username});

  @override
  State<PortalScreen> createState() => _PortalScreenState();
}

class _PortalScreenState extends State<PortalScreen> {
  bool _loading = true;
  Map<String, dynamic>? _user;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _hydrate();
  }

  Future<void> _hydrate() async {
    final state = context.read<AppState>();
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {
      _isAuthenticated = state.auth.user.isAuthenticated;
      if (_isAuthenticated) {
        _user = {
          'displayName': state.auth.user.displayName ?? state.auth.user.email,
          'email': state.auth.user.email,
          'uid': state.auth.user.uid,
          'photoUrl': state.auth.user.photoUrl,
        };
      }
      _loading = false;
    });
  }

  Map<String, String> _splitName(String? displayName) {
    final parts = (displayName ?? '').trim().split(RegExp(r'\s+'));
    return {
      'first': parts.isNotEmpty && parts[0].isNotEmpty ? parts[0] : '—',
      'last': parts.length > 1 ? parts.sublist(1).join(' ') : '—',
    };
  }

  Widget _portalCard(String label, String value, IconData icon,
      {bool isId = false}) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0F0F4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFEEE9F8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF7C5DC7)),
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFFC0BDC8),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isId ? 12 : 16,
              fontWeight: FontWeight.w600,
              color: isId ? const Color(0xFF8C8C91) : AppColors.designText,
              fontFamily: isId ? 'monospace' : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    if (_loading) {
      return AppScaffold(
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  width: 44, height: 44, child: CircularProgressIndicator()),
              SizedBox(height: 12),
              Text('Loading profile…',
                  style: TextStyle(color: AppColors.designMuted, fontSize: 14)),
            ],
          ),
        ),
      );
    }

    if (!_isAuthenticated) {
      return AppScaffold(
        body: Center(
          child: DesignMessage(
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline,
                    size: 44, color: Color(0xFFC0BDC8)),
                const SizedBox(height: 16),
                const Text(
                  'Sign in to view your profile',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.designText),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This page is only visible to authenticated Welrent members.',
                  style: TextStyle(fontSize: 14, color: AppColors.designMuted),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const __LoginModalPlaceholder(),
                    );
                  },
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final name = _splitName(_user?['displayName']);

    return AppScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFF2F214B), Color(0xFF1A1130)],
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFF3E2D63),
                    child: Text(
                      (_user?['displayName'] ?? _user?['email'] ?? '?')[0]
                          .toUpperCase(),
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF8EB9FF)),
                    ),
                  ),
                  const SizedBox(width: 28),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _user?['displayName'] ?? _user?['email'] ?? '—',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _user?['email'] ?? '—',
                          style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF8EB9FF),
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8EB9FF).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color:
                                    const Color(0xFF8EB9FF).withOpacity(0.2)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified,
                                  size: 12, color: Color(0xFF8EB9FF)),
                              SizedBox(width: 5),
                              Text(
                                'Verified Member',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF8EB9FF)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isMobile ? 1 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isMobile ? 2.2 : 3.4,
              children: [
                _portalCard('First Name', name['first']!, Icons.person_outline),
                _portalCard('Last Name', name['last']!, Icons.people_outline),
                _portalCard('Email Address', _user?['email'] ?? '—',
                    Icons.email_outlined),
                _portalCard('Account ID', _user?['uid'] ?? '—', Icons.grid_on,
                    isId: true),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () => GoRouter.of(context).push('/'),
                  style: OutlinedButton.styleFrom(
                    side:
                        const BorderSide(color: Color(0xFFEAECF0), width: 1.5),
                    foregroundColor: AppColors.designText,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back, size: 15),
                      SizedBox(width: 6),
                      Text('Back to Dashboard'),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    context.read<AppState>().auth.signOut();
                    GoRouter.of(context).push('/');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dangerBg,
                    foregroundColor: AppColors.danger,
                    side: BorderSide(color: AppColors.dangerBorder, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.logout, size: 15),
                      SizedBox(width: 6),
                      Text('Sign Out'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class __LoginModalPlaceholder extends StatelessWidget {
  const __LoginModalPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Sign In',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            const Text(
              'Email/password login requires Firebase configuration.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                const SizedBox(width: 12),
                ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
