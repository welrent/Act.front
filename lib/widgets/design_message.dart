import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/colors.dart';

/// Reusable design message / card box — matches .design-message.
class DesignMessage extends StatefulWidget {
  final Widget child;
  final bool interactive;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final double borderRadius;

  const DesignMessage({
    super.key,
    required this.child,
    this.interactive = false,
    this.onTap,
    this.padding = const EdgeInsets.all(24),
    this.backgroundColor,
    this.borderRadius = 12,
  });

  @override
  State<DesignMessage> createState() => _DesignMessageState();
}

class _DesignMessageState extends State<DesignMessage> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Color bg = widget.backgroundColor ?? AppColors.cardBg;
    if (widget.interactive && _isHovered) {
      bg = AppColors.cardHover;
    }

    Widget content = Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: widget.child,
    );

    if (widget.interactive && widget.onTap != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: content,
        ),
      );
    }

    return content;
  }
}

/// Rental card pill — matches .rental-card-pill.
class RentalCardPill extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final String? route;
  final Color? backgroundColor;
  final Color? textColor;

  const RentalCardPill({
    super.key,
    required this.label,
    this.onTap,
    this.route,
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<RentalCardPill> createState() => _RentalCardPillState();
}

class _RentalCardPillState extends State<RentalCardPill> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bg = _isHovered
        ? AppColors.pillHoverBg
        : (widget.backgroundColor ?? AppColors.pillBg);
    final color = _isHovered
        ? AppColors.pillHoverText
        : (widget.textColor ?? AppColors.pillText);

    final onTapHandler = widget.onTap ??
        (widget.route != null ? () => context.go(widget.route!) : null);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: onTapHandler,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

/// Primary gradient button used in control panel.
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool loading;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              loading ? const Color(0xFFC4B8DE) : AppColors.panelGradientStart,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white)))
            : Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
      ),
    );
  }
}

/// Status toast / banner shown after save actions.
class StatusBanner extends StatelessWidget {
  final String type; // 'success', 'error', 'loading', 'info'
  final String message;

  const StatusBanner({super.key, required this.type, required this.message});

  @override
  Widget build(BuildContext context) {
    Color bgColor, textColor, borderColor;
    switch (type) {
      case 'success':
        bgColor = AppColors.successBg;
        textColor = AppColors.success;
        borderColor = AppColors.success.withOpacity(0.2);
        break;
      case 'error':
        bgColor = AppColors.dangerBg;
        textColor = AppColors.danger;
        borderColor = AppColors.danger.withOpacity(0.2);
        break;
      case 'loading':
        bgColor = const Color(0xFFF9FAFB);
        textColor = AppColors.designMuted;
        borderColor = AppColors.borderColor;
        break;
      default:
        bgColor = const Color(0xFFF9FAFB);
        textColor = AppColors.designMuted;
        borderColor = AppColors.borderColor;
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          if (type == 'loading')
            const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2))
          else
            Icon(
                type == 'success'
                    ? Icons.check_circle
                    : (type == 'error'
                        ? Icons.error_outline
                        : Icons.info_outline),
                color: textColor,
                size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                  color: textColor, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
