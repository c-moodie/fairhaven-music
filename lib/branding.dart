import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// Fairhaven Music branding
///
/// Edit the values in this file to change the default server address and the
/// core brand colors. Everything else in the app reads from here.
/// ---------------------------------------------------------------------------

/// The Fairhaven Music server the app connects to.
const String defaultServerUrl = "https://listen.fairhavenmusic.net";

/// When true, the app only ever connects to [defaultServerUrl]:
/// the server address field, local network server list, and the
/// server address settings are all hidden.
/// Set to false to let users enter a different server again.
const bool lockServerUrl = true;

/// Classic burgundy, used as the main accent in light mode and for containers.
const Color burgundyColor = Color(0xFF800020);

/// A slightly brighter burgundy so accents stay readable on dark backgrounds.
const Color burgundyBrightColor = Color(0xFFC8374F);

/// Very dark burgundy used for dark backgrounds / icon backgrounds.
const Color burgundyDeepColor = Color(0xFF2A0712);

/// Complementary gold accent (tertiary color).
const Color goldAccentColor = Color(0xFFE9C16C);

/// Link shown under the Log In button on the sign-in screen.
const String accountHelpUrl = "https://it.fairhavenbaptist.org/music-app/";
