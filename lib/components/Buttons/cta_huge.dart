import 'package:finamp/services/feedback_helper.dart';
import 'package:flutter/material.dart';

class CTAHuge extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool vertical;
  final void Function() onPressed;
  final bool disabled;

  const CTAHuge({
    super.key,
    required this.text,
    required this.icon,
    this.vertical = false,
    required this.onPressed,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = disabled
        ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
        : Theme.of(context).colorScheme.primary;
    final onAccentColor = Theme.of(context).colorScheme.onPrimary.withOpacity(disabled ? 0.6 : 1.0);
    return FilledButton(
      onPressed: disabled
          ? null
          : () {
              FeedbackHelper.feedback(FeedbackType.selection);
              onPressed();
            },
      style: ButtonStyle(
        shape: WidgetStateProperty.all<OutlinedBorder>(const StadiumBorder()),
        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.symmetric(horizontal: 32, vertical: 20)),
        backgroundColor: WidgetStateProperty.all<Color>(accentColor),
        elevation: WidgetStateProperty.all<double>(disabled ? 0 : 2),
        shadowColor: WidgetStateProperty.all<Color>(accentColor.withOpacity(0.5)),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        direction: vertical ? Axis.vertical : Axis.horizontal,
        alignment: vertical ? WrapAlignment.center : WrapAlignment.start,
        children: [
          Icon(icon, size: 26, color: onAccentColor, weight: 1.5),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(color: onAccentColor, fontSize: 19, fontWeight: FontWeight.w600, letterSpacing: 0.2),
          ),
        ],
      ),
    );
  }
}
