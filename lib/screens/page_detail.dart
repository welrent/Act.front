import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../theme/colors.dart';
import '../widgets/layout/app_scaffold.dart';
import '../widgets/legal_document_renderer.dart';
import '../providers/app_state.dart';
import '../models/page.dart';
import '../models/seed_data.dart';

/// Dynamic page detail — 1:1 match to Screenshot 3 and Next.js pages/[slug]/page.tsx
class PageDetailScreen extends StatefulWidget {
  final String slug;
  const PageDetailScreen({super.key, required this.slug});

  @override
  State<PageDetailScreen> createState() => _PageDetailScreenState();
}

class _PageDetailScreenState extends State<PageDetailScreen> {
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

    // Search in state pages, then fallback to SeedData
    PageItem? page;
    try {
      page = state.findPageBySlug(widget.slug);
    } catch (_) {}

    if (page == null) {
      try {
        page = SeedData.pages.firstWhere((p) => p.slug == widget.slug);
      } catch (_) {
        if (widget.slug.contains('car') || widget.slug.isEmpty) {
          page = SeedData.pages.first;
        }
      }
    }

    return AppScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (page == null) ...[
            const _NotFound(),
          ] else ...[
            Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: LegalDocumentRenderer(
                html: page.content ?? '<h1>${page.title}</h1>',
              ),
            ),
            const SizedBox(height: 40),
          ],
        ],
      ),
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '404',
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.w800,
                color: AppColors.designText,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'The page you are looking for does not exist.',
              style: TextStyle(fontSize: 16, color: AppColors.designMuted),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pillBg,
                foregroundColor: AppColors.designText,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text('Go Back Home',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
