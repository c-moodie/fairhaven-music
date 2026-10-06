import 'dart:math';

import 'package:finamp/services/feedback_helper.dart';
import 'package:flutter/material.dart';

class CTAMedium extends StatelessWidget {
  final String text;
  final IconData icon;
  final void Function() onPressed;
  final double? minWidth;
  final bool disabled;

  const CTAMedium({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.minWidth,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final minWidth = this.minWidth ?? screenSize.width * 0.25;
    final paddingHorizontal = screenSize.width * 0.015;
    final paddingVertical = screenSize.height * 0.015;
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
        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
          EdgeInsets.only(left: 8 + paddingHorizontal, right: 8, top: paddingVertical, bottom: paddingVertical),
        ),
        backgroundColor: WidgetStateProperty.all<Color>(accentColor),
      ),
      child: Container(
        constraints: BoxConstraints(minWidth: minWidth + paddingHorizontal),
        padding: EdgeInsets.only(right: paddingHorizontal), // this is to center the content when a minWidth is set
        alignment: Alignment.center,
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(icon, size: 22, color: onAccentColor, weight: 1.0),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(color: onAccentColor, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.2),
            ),
          ],
        ),
      ),
    );
  }

  static double predictedHeight(BuildContext context) {
    final densityAdj = VisualDensity.adaptivePlatformDensity.baseSizeAdjustment.dy;
    return max(
      MediaQuery.heightOf(context) * 0.03 + 24 + densityAdj + densityAdj,
      kMinInteractiveDimension + densityAdj,
    );
  }
}
