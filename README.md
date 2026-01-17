# explored

Flutter MVP for continuous location tracking (foreground + background) with a
map UI. The code is structured around MVVC (View -> ViewModel -> Repository ->
Service) so location logic stays testable and platform IO stays isolated.

## How the code works

### App bootstrap and MVVC wiring
- `lib/main.dart` builds Services, then Repositories, then `MapViewModel`, and
  injects it into `ExploredApp`.
- `lib/app/explored_app.dart` registers the ViewModel with Provider and renders
  `MapView`.
- Data flow is always: View -> ViewModel -> Repository -> Service -> Repository
  -> ViewModel -> View. No layer skipping.

### Map feature
- `MapRepository` exposes `MapConfig` and `MapTileSource`, currently backed by
  OpenStreetMap tiles.
- `MapViewModel` loads the config once and holds `MapViewState` for the UI.
- `MapView` renders `FlutterMap` + `TileLayer`, overlays the tracking panel, and
  shows an attribution banner; tapping the attribution uses `url_launcher`.

### Location tracking
- `MapViewModel` exposes commands for permission prompts and settings access,
  and owns the `LocationTrackingState` rendered by the map panel.
- Tracking starts in `lib/main.dart` via
  `DefaultLocationUpdatesRepository.startTracking()` after wiring services.
- `DefaultLocationUpdatesRepository` gates tracking on:
  - Location services being enabled.
  - Required permission level (background on iOS + Android SDK >= 29).
  - Notification permission when required (Android 13+).
- `LocationTrackingServiceFactory` creates the platform-specific
  `LocationTrackingService`, which wraps the `background_location` plugin.
- `LocationTrackingServiceBase` filters raw updates through the adaptive policy
  (distance/interval) and logs when updates stop for too long.
- `MapViewModel` subscribes to `locationUpdatesRepository.locationUpdates` and
  updates the last known map location in UI state.

### Localization
- All user-facing strings live in `assets/translations/en.json` and are accessed
  via `LocaleKeys.*` with `easy_localization`.

### Tests
- Widget/unit tests in `test/` simulate permission and lifecycle scenarios and
  assert required Info.plist/AndroidManifest entries.

## Packages and why
- `provider`: dependency injection and `ChangeNotifier` bindings.
- `easy_localization`: mandatory localization system and key generation.
- `background_location` (local fork in `packages/background_location`): background
  GPS updates with foreground service support; fork avoids deprecated v1
  embedding references.
- `geolocator`: iOS permission + service status checks.
- `permission_handler`: location + notification permission prompts and
  Settings deep-link.
- `flutter_map`: map rendering with OpenStreetMap tiles.
- `latlong2`: LatLng model used by `flutter_map`.
- `url_launcher`: open OpenStreetMap attribution links.
- `flutter_test`, `flutter_lints`: testing and linting during development.

## Challenges faced
- Coordinating Android background tracking requirements (foreground service,
  persistent notification, and POST_NOTIFICATIONS on Android 13+).
- Handling the permission matrix across iOS and Android (when-in-use vs always,
  notification permissions, and "denied forever" flows).
- Balancing accuracy and battery with adaptive update filtering + watchdog logs.
- Normalizing permission/service checks before starting background tracking.
- Working around deprecated embedding references in the upstream background
  location plugin by maintaining a small local fork.
- Communicating battery optimization constraints to users because background
  updates can be throttled by the OS.
