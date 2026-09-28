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

/// Fairhaven Music logo burgundy (#771116), used as the main accent in light mode and for containers.
const Color burgundyColor = Color(0xFF771116);

/// A slightly brighter burgundy so accents stay readable on dark backgrounds.
const Color burgundyBrightColor = Color(0xFFC8373E);

/// Very dark burgundy used for dark backgrounds / icon backgrounds.
const Color burgundyDeepColor = Color(0xFF2A0709);

/// Complementary gold accent (tertiary color).
const Color goldAccentColor = Color(0xFFE9C16C);

/// Link shown under the Log In button on the sign-in screen.
const String accountHelpUrl = "https://it.fairhavenbaptist.org/music-app/";

/// Public repository with the Fairhaven Music source code.
/// Finamp is licensed under the MPL-2.0, which requires the source code of this
/// modified version to be available to everyone who gets the app.
const String sourceCodeUrl = "https://github.com/c-moodie/fairhaven-music";

/// The original project this app is based on (credited in the About screen).
const String originalProjectUrl = "https://github.com/finamp-app/finamp";
