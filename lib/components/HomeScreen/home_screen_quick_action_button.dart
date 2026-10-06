import 'package:finamp/fairhaven_theme.dart';
import 'package:finamp/services/feedback_helper.dart';
import 'package:finamp/utils/platform_helper.dart';
import 'package:flutter/material.dart';

class HomeScreenQuickActionButton extends StatelessWidget {
  final String text;
  final String? label;
  final IconData icon;
  final double width;
  final bool vertical;
  final void Function() onPressed;
  final void Function()? onSecondaryPressed;
  final bool disabled;

  const HomeScreenQuickActionButton({
    super.key,
    required this.text,
    this.label,
    required this.icon,
    required this.width,
    this.vertical = false,
    required this.onPressed,
    this.onSecondaryPressed,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = disabled ? ColorScheme.of(context).primary.withOpacity(0.5) : ColorScheme.of(context).primary;

    final buttonChildren = [
      Icon(icon, size: 18, color: accentColor, weight: 1.0, applyTextScaling: true),
      Text(
        text,
        style: TextStyle(
          color: fairhavenOnTonal(context, disabled: disabled),
          fontSize: 13,
          height: 0.9,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    ];

    final buttonContent = vertical
        ? Column(mainAxisAlignment: MainAxisAlignment.center, spacing: isDesktop ? 4.0 : 6.0, children: buttonChildren)
        : Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            spacing: 6.0,
            children: buttonChildren,
          );

    return Semantics(
      label: text,
      tooltip: label,
      button: true,
      focusable: true,
      onLongPressHint: label,
      excludeSemantics: true, // replace child semantics with custom semantics
      container: true,
      child: SizedBox(
        width: width,
        child: GestureDetector(
          onLongPress: disabled || onSecondaryPressed == null
              ? null
              : () {
                  FeedbackHelper.feedback(FeedbackType.selection);
                  onSecondaryPressed!();
                },
          onSecondaryTap: disabled || onSecondaryPressed == null
              ? null
              : () {
                  FeedbackHelper.feedback(FeedbackType.selection);
                  onSecondaryPressed!();
                },
          child: FilledButton(
            onPressed: disabled
                ? null
                : () {
                    FeedbackHelper.feedback(FeedbackType.selection);
                    onPressed();
                  },

            style: ButtonStyle(
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(isDesktop ? FairhavenRadius.sm : FairhavenRadius.md)),
              ),
              padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                EdgeInsets.symmetric(horizontal: 8, vertical: isDesktop ? 16 : 8),
              ),
              backgroundColor: WidgetStateProperty.all<Color>(fairhavenTonalFill(context, disabled: disabled)),
            ),
            child: buttonContent,
          ),
        ),
      ),
    );
  }
}
