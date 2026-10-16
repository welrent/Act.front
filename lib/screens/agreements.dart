import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../theme/colors.dart';
import '../widgets/layout/app_scaffold.dart';
import '../widgets/design_message.dart';
import '../providers/app_state.dart';

/// Agreements listing — matches /agreements.
class AgreementsScreen extends StatefulWidget {
  const AgreementsScreen({super.key});

  @override
  State<AgreementsScreen> createState() => _AgreementsScreenState();
}

class _AgreementsScreenState extends State<AgreementsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadPages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final pages = state.pages;

    return AppScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'All Agreements',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.designText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'A comprehensive directory of our standard forms and contracts.',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.designMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (state.pagesLoading)
            const DesignMessage(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (pages.isEmpty)
            const DesignMessage(
              child: Center(
                child: Text(
                  'No agreements found. Check back later or create some from the Admin Panel.',
                  style: TextStyle(color: AppColors.designMuted),
                ),
              ),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 16,
              children: pages.map((p) {
                return SizedBox(
                  width: (MediaQuery.of(context).size.width - 48) / 2 - 12,
                  child: DesignMessage(
                    interactive: true,
                    onTap: () => context.push('/pages/${p.slug}'),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                p.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.designText,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          (p.content != null &&
                                  p.content!
                                      .replaceAll(RegExp(r'<[^>]*>'), '')
                                      .trim()
                                      .isNotEmpty)
                              ? p.content!
                                  .replaceAll(RegExp(r'<[^>]*>'), '')
                                  .trim()
                              : 'A standard Welrent rental agreement.',
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.designMuted,
                            height: 1.6,
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(height: 8),
                        RentalCardPill(
                            label: 'Read Agreement', route: '/pages/${p.slug}'),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
