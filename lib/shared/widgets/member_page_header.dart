import 'package:fitpulse/core/routing/app_routes.dart';
import 'package:fitpulse/features/theme_preview/presentation/widgets/theme_selector.dart';
import 'package:fitpulse/shared/widgets/brand_mark.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Route header that removes redundant back/theme controls in the phone shell.
class MemberPageHeader extends StatelessWidget {
  const MemberPageHeader({
    this.actionIcon,
    this.actionTooltip,
    this.onAction,
    super.key,
  });

  final IconData? actionIcon;
  final String? actionTooltip;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 600;
        return Row(
          children: [
            if (!compact) ...[
              IconButton.filledTonal(
                tooltip: 'Back to dashboard',
                onPressed: () => context.go(AppRoutes.dashboard),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: 12),
            ],
            const BrandMark(),
            const Spacer(),
            if (onAction != null)
              IconButton.filledTonal(
                tooltip: actionTooltip,
                onPressed: onAction,
                icon: Icon(actionIcon),
              ),
            if (onAction != null && !compact) const SizedBox(width: 10),
            if (!compact) const ThemeSelector(),
          ],
        );
      },
    );
  }
}
