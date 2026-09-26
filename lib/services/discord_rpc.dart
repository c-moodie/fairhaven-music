// Fairhaven Music: Discord Rich Presence has been removed.
//
// It only ever worked on desktop (Windows/macOS/Linux), and its package
// (flutter_discord_rpc) needs the Rust toolchain to build, which broke
// mobile builds on services like Codemagic. This stub keeps the same API
// so the rest of the app doesn't need to change.

class DiscordRpc {
  static void initialize() {}

  static Future<void> start() async {}

  static Future<void> stop({bool force = false}) async {}

  static Future<void> updateRPC() async {}
}
