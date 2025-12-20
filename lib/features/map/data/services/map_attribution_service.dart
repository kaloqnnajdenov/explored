import 'package:url_launcher/url_launcher.dart';

/// Opens attribution links required by the current map provider.
abstract class MapAttributionService {
  Future<void> openAttribution();
}

/// Url-launcher-backed implementation for the map attribution link.
class UrlLauncherMapAttributionService implements MapAttributionService {
  UrlLauncherMapAttributionService({
    Uri? attributionUri,
  }) : _attributionUri =
           attributionUri ?? Uri.parse('https://www.openstreetmap.org/copyright');

  final Uri _attributionUri;

  @override
  Future<void> openAttribution() async {
    final launched = await launchUrl(
      _attributionUri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      throw Exception('map_attribution_launch_failed');
    }
  }
}
