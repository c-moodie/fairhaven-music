import 'package:finamp/branding.dart';
import 'package:finamp/components/SettingsScreen/logout_list_tile.dart';
import 'package:finamp/components/finamp_app_bar_back_button.dart';
import 'package:finamp/components/finamp_icon.dart';
import 'package:finamp/l10n/app_localizations.dart';
import 'package:finamp/menus/server_sharing_menu.dart';
import 'package:finamp/screens/accessibility_settings_screen.dart';
import 'package:finamp/screens/audio_service_settings_screen.dart';
import 'package:finamp/screens/downloads_settings_screen.dart';
import 'package:finamp/screens/home_screen_settings_screen.dart';
import 'package:finamp/screens/interaction_settings_screen.dart';
import 'package:finamp/screens/layout_settings_screen.dart';
import 'package:finamp/screens/network_settings_screen.dart';
import 'package:finamp/screens/playback_reporting_settings_screen.dart';
import 'package:finamp/screens/quick_settings_screen.dart';
import 'package:finamp/screens/transcoding_settings_screen.dart';
import 'package:finamp/screens/view_selector.dart';
import 'package:finamp/screens/volume_normalization_settings_screen.dart';
import 'package:finamp/services/finamp_settings_helper.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  static const routeName = "/settings";

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
        leading: FinampAppBarBackButton(),
        actions: [
          FinampSettingsHelper.makeSettingsResetButtonWithDialog(
            context,
            FinampSettingsHelper.resetAllSettings,
            isGlobal: true,
          ),
          Semantics.fromProperties(
            properties: SemanticsProperties(label: AppLocalizations.of(context)!.about, button: true),
            excludeSemantics: true,
            container: true,
            child: IconButton(
              icon: const Icon(Icons.info),
              onPressed: () async {
                final localizations = AppLocalizations.of(context)!;
                final applicationLegalese = AppLocalizations.of(context)!.applicationLegalese(sourceCodeUrl);
                PackageInfo packageInfo = await PackageInfo.fromPlatform();
                if (!context.mounted) return;

                ThemeData theme = Theme.of(context);
                const linkStyle = TextStyle(color: Colors.blue, decoration: TextDecoration.underline);

                showAboutDialog(
                  context: context,
                  applicationName: packageInfo.appName,
                  applicationVersion: packageInfo.version,
                  applicationIcon: Padding(padding: const EdgeInsets.only(top: 8.0), child: FinampIcon(56, 56)),
                  applicationLegalese: applicationLegalese,
                  children: [
                    const SizedBox(height: 20),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(color: theme.textTheme.bodyMedium!.color),
                        children: [
                          TextSpan(
                            text: localizations.finampTagline,
                            style: const TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
                          ),
                          const TextSpan(text: '\n\n'),
                          TextSpan(text: localizations.aboutContributionPrompt),
                          const TextSpan(text: '\n\n'),
                          TextSpan(text: '${localizations.aboutContributionLink}\n'),
                          TextSpan(
                            text: sourceCodeUrl,
                            style: linkStyle,
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                await launchUrl(Uri.parse(sourceCodeUrl));
                              },
                          ),
                          const TextSpan(text: '\n\n'),
                          TextSpan(text: '${localizations.aboutOriginalProject}\n'),
                          TextSpan(
                            text: originalProjectUrl,
                            style: linkStyle,
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                await launchUrl(Uri.parse(originalProjectUrl));
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 200.0),
        children: [
          ListTile(
            leading: const Icon(TablerIcons.sparkles),
            title: Text(AppLocalizations.of(context)!.quickSettingsScreen),
            onTap: () => Navigator.of(
              context,
            ).pushNamed(QuickSettingsScreen.routeName, arguments: QuickSettingsScreen.fromSettingsScreen),
          ),
          ListTile(
            leading: const Icon(TablerIcons.home),
            title: Text(AppLocalizations.of(context)!.homeScreenSettingsTitle),
            onTap: () => Navigator.of(context).pushNamed(HomeScreenSettingsScreen.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.compress),
            title: Text(AppLocalizations.of(context)!.transcoding),
            onTap: () => Navigator.of(context).pushNamed(TranscodingSettingsScreen.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: Text(AppLocalizations.of(context)!.downloadSettings),
            onTap: () => Navigator.of(context).pushNamed(DownloadsSettingsScreen.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.wifi),
            title: Text(AppLocalizations.of(context)!.networkSettingsTitle),
            onTap: () => Navigator.of(context).pushNamed(NetworkSettingsScreen.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.music_note),
            title: Text(AppLocalizations.of(context)!.audioService),
            onTap: () => Navigator.of(context).pushNamed(AudioServiceSettingsScreen.routeName),
          ),
          ListTile(
            leading: const Icon(TablerIcons.cast),
            title: Text(AppLocalizations.of(context)!.playbackReportingSettingsTitle),
            onTap: () => Navigator.of(context).pushNamed(PlaybackReportingSettingsScreen.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.equalizer_rounded),
            title: Text(AppLocalizations.of(context)!.volumeNormalizationSettingsTitle),
            onTap: () => Navigator.of(context).pushNamed(VolumeNormalizationSettingsScreen.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.gesture),
            title: Text(AppLocalizations.of(context)!.interactions),
            onTap: () => Navigator.of(context).pushNamed(InteractionSettingsScreen.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.widgets),
            title: Text(AppLocalizations.of(context)!.layoutAndTheme),
            onTap: () => Navigator.of(context).pushNamed(LayoutSettingsScreen.routeName),
          ),
          ListTile(
            leading: const Icon(TablerIcons.accessible),
            title: Text(AppLocalizations.of(context)!.accessibility),
            onTap: () => Navigator.of(context).pushNamed(AccessibilitySettingsScreen.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.library_music),
            title: Text(AppLocalizations.of(context)!.selectMusicLibraries),
            subtitle: ref.watch(finampSettingsProvider.isOffline)
                ? Text(AppLocalizations.of(context)!.notAvailableInOfflineMode)
                : null,
            enabled: !ref.watch(finampSettingsProvider.isOffline),
            onTap: () => Navigator.of(context).pushNamed(ViewSelector.routeName),
          ),
          Divider(),
          if (!lockServerUrl)
            ListTile(
              leading: Icon(TablerIcons.access_point),
              title: Text(AppLocalizations.of(context)!.serverSharingMenuButtonTitle),
              onTap: () => showServerSharingPanel(context: context),
            ),
          const LogoutListTile(),
        ],
      ),
    );
  }
}
