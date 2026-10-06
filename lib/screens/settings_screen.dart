import 'package:finamp/branding.dart';
import 'package:finamp/components/SettingsScreen/logout_list_tile.dart';
import 'package:finamp/components/finamp_app_bar_back_button.dart';
import 'package:finamp/components/finamp_icon.dart';
import 'package:finamp/fairhaven_theme.dart';
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
        padding: const EdgeInsets.only(top: 4.0, bottom: 200.0),
        children: [
          SettingsGroup(
            title: AppLocalizations.of(context)!.settingsGroupLibrary,
            children: [
              ListTile(
                leading: const SettingsTileIcon(TablerIcons.sparkles),
                title: Text(AppLocalizations.of(context)!.quickSettingsScreen),
                trailing: const _Chevron(),
                onTap: () => Navigator.of(
                  context,
                ).pushNamed(QuickSettingsScreen.routeName, arguments: QuickSettingsScreen.fromSettingsScreen),
              ),
              ListTile(
                leading: const SettingsTileIcon(TablerIcons.home),
                title: Text(AppLocalizations.of(context)!.homeScreenSettingsTitle),
                trailing: const _Chevron(),
                onTap: () => Navigator.of(context).pushNamed(HomeScreenSettingsScreen.routeName),
              ),
              ListTile(
                leading: const SettingsTileIcon(Icons.library_music),
                title: Text(AppLocalizations.of(context)!.selectMusicLibraries),
                subtitle: ref.watch(finampSettingsProvider.isOffline)
                    ? Text(AppLocalizations.of(context)!.notAvailableInOfflineMode)
                    : null,
                trailing: const _Chevron(),
                enabled: !ref.watch(finampSettingsProvider.isOffline),
                onTap: () => Navigator.of(context).pushNamed(ViewSelector.routeName),
              ),
            ],
          ),
          SettingsGroup(
            title: AppLocalizations.of(context)!.settingsGroupPlayback,
            children: [
              ListTile(
                leading: const SettingsTileIcon(Icons.music_note),
                title: Text(AppLocalizations.of(context)!.audioService),
                trailing: const _Chevron(),
                onTap: () => Navigator.of(context).pushNamed(AudioServiceSettingsScreen.routeName),
              ),
              ListTile(
                leading: const SettingsTileIcon(Icons.compress),
                title: Text(AppLocalizations.of(context)!.transcoding),
                trailing: const _Chevron(),
                onTap: () => Navigator.of(context).pushNamed(TranscodingSettingsScreen.routeName),
              ),
              ListTile(
                leading: const SettingsTileIcon(Icons.equalizer_rounded),
                title: Text(AppLocalizations.of(context)!.volumeNormalizationSettingsTitle),
                trailing: const _Chevron(),
                onTap: () => Navigator.of(context).pushNamed(VolumeNormalizationSettingsScreen.routeName),
              ),
              ListTile(
                leading: const SettingsTileIcon(TablerIcons.cast),
                title: Text(AppLocalizations.of(context)!.playbackReportingSettingsTitle),
                trailing: const _Chevron(),
                onTap: () => Navigator.of(context).pushNamed(PlaybackReportingSettingsScreen.routeName),
              ),
            ],
          ),
          SettingsGroup(
            title: AppLocalizations.of(context)!.settingsGroupDownloadsNetwork,
            children: [
              ListTile(
                leading: const SettingsTileIcon(Icons.download),
                title: Text(AppLocalizations.of(context)!.downloadSettings),
                trailing: const _Chevron(),
                onTap: () => Navigator.of(context).pushNamed(DownloadsSettingsScreen.routeName),
              ),
              ListTile(
                leading: const SettingsTileIcon(Icons.wifi),
                title: Text(AppLocalizations.of(context)!.networkSettingsTitle),
                trailing: const _Chevron(),
                onTap: () => Navigator.of(context).pushNamed(NetworkSettingsScreen.routeName),
              ),
            ],
          ),
          SettingsGroup(
            title: AppLocalizations.of(context)!.settingsGroupLookAndFeel,
            children: [
              ListTile(
                leading: const SettingsTileIcon(Icons.widgets),
                title: Text(AppLocalizations.of(context)!.layoutAndTheme),
                trailing: const _Chevron(),
                onTap: () => Navigator.of(context).pushNamed(LayoutSettingsScreen.routeName),
              ),
              ListTile(
                leading: const SettingsTileIcon(Icons.gesture),
                title: Text(AppLocalizations.of(context)!.interactions),
                trailing: const _Chevron(),
                onTap: () => Navigator.of(context).pushNamed(InteractionSettingsScreen.routeName),
              ),
              ListTile(
                leading: const SettingsTileIcon(TablerIcons.accessible),
                title: Text(AppLocalizations.of(context)!.accessibility),
                trailing: const _Chevron(),
                onTap: () => Navigator.of(context).pushNamed(AccessibilitySettingsScreen.routeName),
              ),
            ],
          ),
          SettingsGroup(
            title: AppLocalizations.of(context)!.settingsGroupAccount,
            children: [
              if (!lockServerUrl)
                ListTile(
                  leading: const SettingsTileIcon(TablerIcons.access_point),
                  title: Text(AppLocalizations.of(context)!.serverSharingMenuButtonTitle),
                  onTap: () => showServerSharingPanel(context: context),
                ),
              const LogoutListTile(),
            ],
          ),
        ],
      ),
    );
  }
}

/// A titled, rounded group of settings rows.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final groupColor = Theme.brightnessOf(context) == Brightness.dark
        ? Color.alphaBlend(scheme.onSurface.withValues(alpha: 0.05), scheme.surface)
        : Color.alphaBlend(scheme.primary.withValues(alpha: 0.04), Colors.white);
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        rows.add(Divider(height: 1, thickness: 0.5, indent: 68, color: scheme.outlineVariant.withValues(alpha: 0.6)));
      }
      rows.add(children[i]);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 8),
            child: Text(
              title,
              style: TextTheme.of(context).titleSmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w600),
            ),
          ),
          Material(
            color: groupColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(FairhavenRadius.md)),
            clipBehavior: Clip.antiAlias,
            child: Column(children: rows),
          ),
        ],
      ),
    );
  }
}

/// Leading icon for a settings row, set in a softly tinted rounded square.
class SettingsTileIcon extends StatelessWidget {
  const SettingsTileIcon(this.icon, {super.key});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: Theme.brightnessOf(context) == Brightness.dark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(FairhavenRadius.sm),
      ),
      child: Icon(icon, size: 20, color: scheme.primary),
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron();

  @override
  Widget build(BuildContext context) {
    return Icon(TablerIcons.chevron_right, size: 18, color: ColorScheme.of(context).onSurfaceVariant.withValues(alpha: 0.6));
  }
}
