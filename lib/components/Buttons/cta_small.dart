import 'package:finamp/fairhaven_theme.dart';
import 'package:finamp/services/feedback_helper.dart';
import 'package:flutter/material.dart';

class CTASmall extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool vertical;
  final bool disabled;
  final void Function() onPressed;

  const CTASmall({
    super.key,
    required this.text,
    required this.icon,
    this.vertical = false,
    this.disabled = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = disabled
        ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
        : Theme.of(context).colorScheme.primary;
    return FilledButton(
      onPressed: disabled
          ? null
          : () {
              FeedbackHelper.feedback(FeedbackType.selection);
              onPressed();
            },
      style: ButtonStyle(
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(FairhavenRadius.sm)),
        ),
        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
        backgroundColor: WidgetStateProperty.all<Color>(fairhavenTonalFill(context, disabled: disabled)),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        direction: vertical ? Axis.vertical : Axis.horizontal,
        alignment: vertical ? WrapAlignment.center : WrapAlignment.start,
        children: [
          Icon(icon, size: 20, color: accentColor, weight: 1.0),
          const SizedBox(width: 8, height: 4),
          Text(
            text,
            style: TextStyle(
              color:
                  fairhavenOnTonal(context, disabled: disabled),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
