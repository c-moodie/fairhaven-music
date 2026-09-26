import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:finamp/services/finamp_settings_helper.dart';
import 'package:finamp/branding.dart';

// Kept under their original names so existing references keep working.
// Both now point at the Fairhaven Music burgundy/gold palette.
const jellyfinBlueColor = burgundyBrightColor;
const jellyfinPurpleColor = goldAccentColor;

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  // Primary
  primary: burgundyColor,
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFFFDADB),
  onPrimaryContainer: Color(0xFF40000A),
  // Secondary
  secondary: Color(0xFF90494D),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFFFDADA),
  onSecondaryContainer: Color(0xFF3B0710),
  // Tertiary
  tertiary: Color(0xFF7A5900),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFFFDEA3),
  onTertiaryContainer: Color(0xFF261900),
  // Error
  error: Color(0xFFBA1A1A),
  errorContainer: Color(0xFFFFDAD6),
  onError: Color(0xFFFFFFFF),
  onErrorContainer: Color(0xFF410002),
  // Background & Surface
  background: Color(0xFFFFF8F7),
  onBackground: Color(0xFF251819),
  surface: Color(0xFFFFF8F7),
  surfaceContainerHighest: Color(0xFFF5DDDD),
  onSurface: Color(0xFF251819),
  surfaceVariant: Color(0xFFF4DDDD),
  onSurfaceVariant: Color(0xFF584141),
  // Other colors
  outline: Color(0xFF8C7071),
  onInverseSurface: Color(0xFFFFEDEC),
  inverseSurface: Color(0xFF3B2D2D),
  inversePrimary: Color(0xFFFFB3B5),
  shadow: Color(0xFF000000),
  surfaceTint: burgundyColor,
  outlineVariant: Color(0xFFE0BFBF),
  scrim: Color(0xFF000000),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  // Primary
  primary: burgundyBrightColor,
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: burgundyColor,
  onPrimaryContainer: Color(0xFFFFDADB),
  // Secondary
  secondary: Color(0xFFFFB3B5),
  onSecondary: Color(0xFF571C22),
  secondaryContainer: Color(0xFF743237),
  onSecondaryContainer: Color(0xFFFFDADA),
  // Tertiary
  tertiary: goldAccentColor,
  onTertiary: Color(0xFF402D00),
  tertiaryContainer: Color(0xFF5C4200),
  onTertiaryContainer: Color(0xFFFFDEA3),
  // Error
  error: Color(0xFFFFB4AB),
  errorContainer: Color(0xFF93000A),
  onError: Color(0xFF690005),
  onErrorContainer: Color(0xFFFFDAD6),
  // Background & Surface
  background: Color(0xFF1A1011),
  onBackground: Color(0xFFF5DDDD),
  surface: Color(0xFF1A1011),
  surfaceContainerHighest: Color(0xFF221416),
  onSurface: Color(0xFFF5DDDD),
  surfaceVariant: Color(0xFF584141),
  onSurfaceVariant: Color(0xFFE0BFBF),
  // Other colors
  outline: Color(0xFFA78A8A),
  onInverseSurface: Color(0xFF3B2D2D),
  inverseSurface: Color(0xFFF5DDDD),
  inversePrimary: burgundyColor,
  shadow: Color(0xFF000000),
  surfaceTint: burgundyBrightColor,
  outlineVariant: Color(0xFF584141),
  scrim: Color(0xFF000000),
);

/// If [color] is provided -> returns a generated color scheme
/// otherwise falls back to default color schemes
/// [lightColorScheme] or [darkColorScheme]
ColorScheme getColorScheme(Color? color, Brightness brightness, bool amoledTheme) {
  ColorScheme scheme = brightness == Brightness.dark ? darkColorScheme : lightColorScheme;

  if (color != null) {
    scheme = ColorScheme.fromSeed(
      seedColor: color,
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    );
  }

  if (amoledTheme && brightness == Brightness.dark) {
    scheme = scheme.copyWith(background: Color(0xFF000000), surface: Color(0xFF000000));
  }

  return scheme;
}
