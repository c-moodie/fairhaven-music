import 'package:finamp/components/finamp_app_bar_back_button.dart';
import 'package:finamp/l10n/app_localizations.dart';
import 'package:finamp/screens/accessibility_settings_screen.dart';
import 'package:finamp/screens/logs_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class AdvancedLoginOptionsScreen extends ConsumerWidget {
  const AdvancedLoginOptionsScreen({super.key});

  static const routeName = "/login/advanced";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.advanced), leading: FinampAppBarBackButton()),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 200.0),
        children: [
          ListTile(
            leading: const Icon(TablerIcons.accessible),
            title: Text(AppLocalizations.of(context)!.accessibility),
            onTap: () => Navigator.of(context).pushNamed(AccessibilitySettingsScreen.routeName),
          ),
          ListTile(
            leading: const Icon(TablerIcons.file_text),
            title: Text(AppLocalizations.of(context)!.viewLogs),
            onTap: () => Navigator.of(context).pushNamed(LogsScreen.routeName),
          ),
        ],
      ),
    );
  }
}
