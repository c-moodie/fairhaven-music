import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:finamp/models/finamp_models.dart';
import 'package:finamp/models/jellyfin_models.dart';
import 'package:finamp/services/queue_service.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

/// ---------------------------------------------------------------------------
/// Fairhaven Music live radio
///
/// Internet radio stations shown in the "Radio" row on the home screen.
/// To add, remove or rename a station, edit [liveRadioStations] below.
/// The url can be a playlist file (.m3u, .m3u8, .pls, .xspf) or a direct
/// stream address; playlists are read when the station is tapped.
/// ---------------------------------------------------------------------------

const List<LiveRadioStation> liveRadioStations = [
  LiveRadioStation(
    id: "abiding-instrumental",
    name: "Abiding Radio Instrumental",
    url: "https://streams.abidingradio.com/listen/abiding_radio_-_instrumental/instrumental.m3u",
  ),
  LiveRadioStation(
    id: "abiding-sacred",
    name: "Abiding Radio Sacred",
    url: "https://streams.abidingradio.com:8243/listen/abiding_radio_-_sacred/sacred.m3u",
  ),
  LiveRadioStation(
    id: "abiding-kids",
    name: "Abiding Radio Kids",
    url: "https://streams.abidingradio.com:8243/listen/abiding_radio_-_kids/kids.m3u",
  ),
  LiveRadioStation(id: "waus", name: "WAUS - St. Andrews", url: "https://waus.streamguys1.com/live"),
];

/// Shown as the "artist" line for stations (lock screen, player, notifications).
const String liveRadioLabel = "Live radio";

/// Radio items use ids with this prefix so the app can recognise them and never
/// send them to the music server (they don't exist there).
const String _liveRadioIdPrefix = "fairhaven-radio-";

final _liveRadioLogger = Logger("LiveRadio");

class LiveRadioStation {
  const LiveRadioStation({required this.id, required this.name, required this.url});

  /// Short unique id, letters/numbers/dashes only. Changing it breaks resuming
  /// a station that was playing before an update, so keep it stable.
  final String id;
  final String name;
  final String url;

  BaseItemId get itemId => BaseItemId("$_liveRadioIdPrefix$id");

  /// A library-style item so the station can travel through the normal queue.
  BaseItemDto toItem() => BaseItemDto(id: itemId, name: name, type: "Audio", mediaType: "Audio");
}

bool isLiveRadioItemId(Object? id) => id != null && "$id".startsWith(_liveRadioIdPrefix);

bool isLiveRadioItem(BaseItemDto? item) => item != null && isLiveRadioItemId(item.id);

LiveRadioStation? liveRadioStationForItem(BaseItemDto? item) {
  if (!isLiveRadioItem(item)) return null;
  for (final station in liveRadioStations) {
    if (station.itemId == item!.id) return station;
  }
  return null;
}

bool isLiveRadioMediaItem(MediaItem? mediaItem) => mediaItem?.extras?["liveRadioUrl"] != null;

/// Starts playing [station], replacing the current queue.
Future<void> playLiveRadioStation(LiveRadioStation station) async {
  _liveRadioLogger.info("Starting live radio station '${station.name}'");
  await GetIt.instance<QueueService>().startPlayback(
    items: [station.toItem()],
    source: QueueItemSource(
      type: QueueItemSourceType.unknown,
      name: QueueItemSourceName(type: QueueItemSourceNameType.preTranslated, pretranslatedName: station.name),
      id: station.itemId,
    ),
    order: FinampPlaybackOrder.linear,
  );
}

/// Turns "StreamTitle" metadata into a display string, or null if empty.
String? cleanIcyTitle(String? raw, {String? stationName}) {
  final title = raw?.trim();
  if (title == null || title.isEmpty || title == "-" || title == stationName) return null;
  return title;
}

// ---------------------------------------------------------------------------
// Playlist resolving
// ---------------------------------------------------------------------------

const _playlistExtensions = [".m3u", ".m3u8", ".pls", ".xspf"];
const _playlistContentTypes = [
  "mpegurl", // audio/x-mpegurl, application/vnd.apple.mpegurl, audio/mpegurl
  "scpls", // audio/x-scpls
  "xspf", // application/xspf+xml
];

/// Returns the address the player should actually open for a station [url].
///
/// Playlist files (.m3u, .pls, .xspf) are downloaded and the first stream in
/// them is returned. HLS playlists (.m3u8 with #EXT-X- tags) and direct
/// streams are returned unchanged, since the player handles those itself.
Future<Uri> resolveLiveRadioStream(String url) async {
  final uri = Uri.parse(url);
  final path = uri.path.toLowerCase();
  final looksLikePlaylist = _playlistExtensions.any(path.endsWith);

  final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
  try {
    final request = await client.getUrl(uri).timeout(const Duration(seconds: 10));
    request.headers.set(HttpHeaders.userAgentHeader, "FairhavenMusicApp");
    final response = await request.close().timeout(const Duration(seconds: 10));
    final contentType = response.headers.contentType?.mimeType.toLowerCase() ?? "";
    final isPlaylist = looksLikePlaylist || _playlistContentTypes.any(contentType.contains);

    if (!isPlaylist) {
      // A direct audio stream: stop downloading, the player will open it itself.
      await response.listen((_) {}).cancel();
      return uri;
    }
    if (response.statusCode >= 400) {
      throw HttpException("Station playlist returned HTTP ${response.statusCode}", uri: uri);
    }

    // Playlists are tiny; cap the read just in case.
    final bytes = <int>[];
    await for (final chunk in response.timeout(const Duration(seconds: 10))) {
      bytes.addAll(chunk);
      if (bytes.length > 256 * 1024) break;
    }
    final text = utf8.decode(bytes, allowMalformed: true);

    // HLS: hand the playlist itself to the player.
    if (text.contains("#EXT-X-")) return uri;

    final stream = _firstStreamInPlaylist(text, uri);
    if (stream == null) {
      throw FormatException("No stream address found in station playlist", url);
    }
    _liveRadioLogger.info("Resolved station playlist $url to $stream");
    return stream;
  } catch (error) {
    if (looksLikePlaylist) {
      _liveRadioLogger.severe("Couldn't read station playlist $url: $error");
      rethrow;
    }
    // Not obviously a playlist: let the player try the address directly.
    _liveRadioLogger.warning("Couldn't inspect $url ($error), trying it as a direct stream");
    return uri;
  } finally {
    client.close(force: false);
  }
}

Uri? _firstStreamInPlaylist(String text, Uri base) {
  final candidates = <String>[];

  // XSPF: <location>https://…</location>
  for (final match in RegExp(r"<location>\s*([^<\s]+)\s*</location>", caseSensitive: false).allMatches(text)) {
    candidates.add(_unescapeXml(match.group(1)!));
  }
  // PLS: File1=https://…
  for (final match in RegExp(r"^\s*File\d+\s*=\s*(\S+)", caseSensitive: false, multiLine: true).allMatches(text)) {
    candidates.add(match.group(1)!);
  }
  // M3U: every non-comment line is an entry
  if (candidates.isEmpty) {
    for (final line in const LineSplitter().convert(text)) {
      final entry = line.trim();
      if (entry.isEmpty || entry.startsWith("#") || entry.startsWith("[")) continue;
      candidates.add(entry);
    }
  }

  for (final candidate in candidates) {
    final resolved = base.resolve(candidate);
    if (resolved.scheme == "http" || resolved.scheme == "https") return resolved;
  }
  return null;
}

String _unescapeXml(String value) => value
    .replaceAll("&amp;", "&")
    .replaceAll("&lt;", "<")
    .replaceAll("&gt;", ">")
    .replaceAll("&quot;", "\"")
    .replaceAll("&apos;", "'");
