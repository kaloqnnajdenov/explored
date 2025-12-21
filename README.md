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
- The ViewModel exposes commands for all user actions (request permissions,
  open settings, start/stop tracking) and owns the `LocationTrackingState`.
- `handleAppLifecycleState` keeps tracking in sync: foreground when the app is
  active, background when it is paused, and none when permissions or services
  are missing.
- `LocationRepository` switches between two Services:
  - `GeolocatorForegroundLocationService` for foreground location streams.
  - `BackgroundLocationService` for background tracking via a foreground
    service and notification on Android.
- The View layer constructs localized notification text and passes it to the
  ViewModel, keeping translations out of lower layers per MVVC rules.
- Each location update is cached via `LocationStorageService` so the last known
  location can be restored on startup and displayed in the panel.
- A watchdog timer re-checks permissions every 5 seconds to catch revokes or
  Settings changes while the app is running.

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
- `geolocator`: foreground location stream with high accuracy.
- `permission_handler`: location + notification permission prompts and
  Settings deep-link.
- `shared_preferences`: store last known location for quick restore on launch.
- `flutter_map`: map rendering with OpenStreetMap tiles.
- `latlong2`: LatLng model used by `flutter_map`.
- `url_launcher`: open OpenStreetMap attribution links.
- `flutter_test`, `flutter_lints`: testing and linting during development.

## Challenges faced
- Coordinating Android background tracking requirements (foreground service,
  persistent notification, and POST_NOTIFICATIONS on Android 13+).
- Handling the permission matrix across iOS and Android (when-in-use vs always,
  notification permissions, and "denied forever" flows).
- Swapping foreground/background tracking on lifecycle changes without leaking
  streams or leaving services running.
- Keeping tracking resilient to Settings changes, which required periodic
  permission checks and careful state transitions.
- Working around deprecated embedding references in the upstream background
  location plugin by maintaining a small local fork.
- Communicating battery optimization constraints to users because background
  updates can be throttled by the OS.
