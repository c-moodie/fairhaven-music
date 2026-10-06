import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ---------------------------------------------------------------------------
/// Fairhaven Music UI theme
///
/// One place for the shapes, type and spacing used across the app. Colors are
/// NOT defined here: they still come from `color_schemes.g.dart` / `branding.dart`
/// (burgundy + gold). Component themes below deliberately avoid hard-coding
/// colors, so per-album themes on the player screen and in menus keep working.
/// ---------------------------------------------------------------------------

/// Serif used for screen titles, album/track titles on the player and headings.
/// Bundled in assets/fonts (SIL Open Font License).
const String fairhavenDisplayFont = "Literata";

/// Corner radii, from small controls to sheets.
abstract final class FairhavenRadius {
  static const double xs = 6.0;
  static const double sm = 10.0;
  static const double md = 16.0;
  static const double lg = 22.0;
  static const double sheet = 28.0;
}

/// Display text style helper for places that build their own TextStyle.
TextStyle fairhavenDisplayStyle({double? fontSize, FontWeight fontWeight = FontWeight.w600, Color? color, double? height}) =>
    TextStyle(
      fontFamily: fairhavenDisplayFont,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: -0.2,
    );

/// Soft accent fill used behind secondary buttons and quick actions.
/// Reads the color scheme at build time so it follows per-item themes.
Color fairhavenTonalFill(BuildContext context, {bool disabled = false}) {
  final scheme = ColorScheme.of(context);
  final accent = scheme.primary;
  if (Theme.brightnessOf(context) == Brightness.dark) {
    return accent.withValues(alpha: disabled ? 0.06 : 0.16);
  }
  return Color.alphaBlend(accent.withValues(alpha: 0.10), scheme.surface).withValues(alpha: disabled ? 0.5 : 1.0);
}

/// Text color that sits on [fairhavenTonalFill].
Color fairhavenOnTonal(BuildContext context, {bool disabled = false}) {
  final accent = ColorScheme.of(context).primary;
  final base = Theme.brightnessOf(context) == Brightness.light
      ? Color.alphaBlend(accent.withValues(alpha: 0.45), Colors.black)
      : Colors.white;
  return base.withValues(alpha: disabled ? 0.5 : 1.0);
}

const TextTheme _fairhavenTextTheme = TextTheme(
  displayLarge: TextStyle(fontFamily: fairhavenDisplayFont, fontWeight: FontWeight.w400, letterSpacing: -0.6),
  displayMedium: TextStyle(fontFamily: fairhavenDisplayFont, fontWeight: FontWeight.w400, letterSpacing: -0.4),
  displaySmall: TextStyle(fontFamily: fairhavenDisplayFont, fontWeight: FontWeight.w400, letterSpacing: -0.2),
  headlineLarge: TextStyle(fontFamily: fairhavenDisplayFont, fontWeight: FontWeight.w600, letterSpacing: -0.4),
  headlineMedium: TextStyle(fontFamily: fairhavenDisplayFont, fontWeight: FontWeight.w600, letterSpacing: -0.3),
  headlineSmall: TextStyle(fontFamily: fairhavenDisplayFont, fontWeight: FontWeight.w600, letterSpacing: -0.2),
  titleLarge: TextStyle(fontFamily: fairhavenDisplayFont, fontWeight: FontWeight.w600, letterSpacing: -0.2),
  titleMedium: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.05),
  labelLarge: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.15),
);

/// Builds the full app theme for a color scheme. Used for the main app theme,
/// the error app, and themed bottom sheets so every surface shares the same
/// shapes and type.
ThemeData buildFairhavenTheme({required ColorScheme colorScheme, PageTransitionsTheme? pageTransitionsTheme}) {
  final brightness = colorScheme.brightness;
  const stadium = StadiumBorder();

  return ThemeData(
    brightness: brightness,
    colorScheme: colorScheme,
    textTheme: _fairhavenTextTheme,
    appBarTheme: AppBarThemeData(
      centerTitle: false,
      titleSpacing: 4.0,
      systemOverlayStyle: brightness == Brightness.light
          ? const SystemUiOverlayStyle(
              statusBarBrightness: Brightness.light,
              statusBarIconBrightness: Brightness.dark,
              systemNavigationBarIconBrightness: Brightness.dark,
            )
          : null,
    ),
    snackBarTheme: const SnackBarThemeData(
      //TODO get rid of floating action buttons and re-enable the floating behavior and insetPadding
      // behavior: SnackBarBehavior.floating,
      elevation: 10.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(FairhavenRadius.md))),
      dismissDirection: DismissDirection.horizontal,
    ),
    tooltipTheme: const TooltipThemeData(waitDuration: Duration(milliseconds: 800), preferBelow: false),
    cardTheme: const CardThemeData(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(FairhavenRadius.md))),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(shape: stadium, padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(shape: stadium)),
    outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(shape: stadium)),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(shape: stadium)),
    chipTheme: const ChipThemeData(shape: StadiumBorder()),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(FairhavenRadius.lg))),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(FairhavenRadius.sheet))),
    ),
    popupMenuTheme: const PopupMenuThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(FairhavenRadius.md))),
    ),
    drawerTheme: const DrawerThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(FairhavenRadius.sheet))),
      endShape: RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(left: Radius.circular(FairhavenRadius.sheet))),
    ),
    dividerTheme: const DividerThemeData(thickness: 0.6, space: 20),
    sliderTheme: const SliderThemeData(trackHeight: 4.0),
    pageTransitionsTheme: pageTransitionsTheme,
  );
}
