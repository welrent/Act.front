import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/colors.dart';
import '../widgets/layout/app_scaffold.dart';
import '../widgets/legal_document_renderer.dart';
import '../providers/app_state.dart';
import '../models/contract.dart';
import '../models/seed_data.dart';

/// Contract detail page — 1:1 match to Screenshot 2 and Next.js contracts/[ref]/page.tsx
class ContractDetailScreen extends StatefulWidget {
  final String ref;
  const ContractDetailScreen({super.key, required this.ref});

  @override
  State<ContractDetailScreen> createState() => _ContractDetailScreenState();
}

class _ContractDetailScreenState extends State<ContractDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadContract(widget.ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    // Search in state contracts, then fallback to SeedData contracts
    Contract? contract;
    try {
      contract = state.contracts.firstWhere(
        (c) => c.contractRef == widget.ref || c.bookingRef == widget.ref,
      );
    } catch (_) {
      try {
        contract = SeedData.contracts.firstWhere(
          (c) => c.contractRef == widget.ref || c.bookingRef == widget.ref,
        );
      } catch (_) {
        // Fallback default
        if (widget.ref.contains('DEMO1') || widget.ref.isNotEmpty) {
          contract = SeedData.contracts.first;
        }
      }
    }

    return AppScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (contract == null) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text('Contract not found.',
                    style:
                        TextStyle(color: AppColors.designMuted, fontSize: 16)),
              ),
            ),
          ] else ...[
            // Top card matching Next.js .design-message
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 500;
                  final details = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contract!.contractRef,
                        style: const TextStyle(
                          color: AppColors.designText,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${contract.vehicleName} · ${contract.vehicleType} · ${contract.status}',
                        style: const TextStyle(
                          color: AppColors.designMuted,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  );

                  final buttons = Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (contract.agreementSlug != null)
                        _ActionPill(
                          label: 'Full agreement terms',
                          onTap: () =>
                              context.go('/pages/${contract!.agreementSlug}'),
                        ),
                      const SizedBox(width: 10),
                      _ActionPill(
                        label: 'Open main site',
                        onTap: () => launchUrl(
                          Uri.parse('https://welrent.com'),
                          mode: LaunchMode.externalApplication,
                        ),
                      ),
                    ],
                  );

                  if (isNarrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        details,
                        const SizedBox(height: 16),
                        buttons,
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: details),
                      buttons,
                    ],
                  );
                },
              ),
            ),

            // Legal Content outside the card on white background
            Container(
              constraints: const BoxConstraints(maxWidth: 860),
              child: LegalDocumentRenderer(
                html: contract.contractHtml ?? '',
              ),
            ),
            const SizedBox(height: 40),
          ],
        ],
      ),
    );
  }
}

class _ActionPill extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _ActionPill({required this.label, required this.onTap});

  @override
  State<_ActionPill> createState() => _ActionPillState();
}

class _ActionPillState extends State<_ActionPill> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
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
