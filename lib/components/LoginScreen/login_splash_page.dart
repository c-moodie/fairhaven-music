import 'package:finamp/components/Buttons/cta_huge.dart';
import 'package:finamp/components/finamp_icon.dart';
import 'package:finamp/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class LoginSplashPage extends StatelessWidget {
  static const routeName = "login/splash";

  final VoidCallback onGetStartedPressed;

  const LoginSplashPage({super.key, required this.onGetStartedPressed});

  @override
  Widget build(BuildContext context) {
    final placeholder = "FINAMP_PLACEHOLDER";
    final welcomeString = AppLocalizations.of(context)!.loginFlowWelcomeHeading(placeholder).split(placeholder);
    final welcomePrefix = welcomeString[0].trim();
    // Avoid crashing on incorrect translations without placeholder
    final welcomeSuffix = welcomeString.length > 1 ? welcomeString[1].trim() : "";
    final scheme = ColorScheme.of(context);
    final mutedColor = TextTheme.of(context).bodyLarge?.color?.withOpacity(0.7);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 72.0, bottom: 36.0),
                child: Hero(tag: "finamp_logo", child: FinampIcon(132, 132)),
              ),
              if (welcomePrefix.isNotEmpty)
                Text(
                  welcomePrefix,
                  textAlign: TextAlign.center,
                  style: TextTheme.of(context).titleMedium?.copyWith(color: mutedColor, fontWeight: FontWeight.w500),
                ),
              const SizedBox(height: 6),
              Text(
                "Fairhaven Music",
                textAlign: TextAlign.center,
                style: TextTheme.of(context).displaySmall?.copyWith(fontWeight: FontWeight.w600, height: 1.1),
              ),
              if (welcomeSuffix.isNotEmpty)
                Text(welcomeSuffix, textAlign: TextAlign.center, style: TextTheme.of(context).titleMedium),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18.0),
                child: Container(
                  width: 44,
                  height: 2.5,
                  decoration: BoxDecoration(color: scheme.tertiary, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Text(
                AppLocalizations.of(context)!.finampTagline,
                textAlign: TextAlign.center,
                style: TextTheme.of(context).bodyLarge?.copyWith(color: mutedColor, height: 1.4),
              ),
              const SizedBox(height: 64),
              CTAHuge(
                text: AppLocalizations.of(context)!.loginFlowGetStarted,
                icon: TablerIcons.music,
                onPressed: onGetStartedPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
