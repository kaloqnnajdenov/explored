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

### Visited grid overlay (H3)
- Every `LatLngSample` is processed immediately in
  `DefaultVisitedGridRepository` (no deferred jobs). The per-sample pipeline:
  1) Accuracy gate: if a sample carries `accuracyMeters` and it's > 50m, skip.
     Samples without accuracy are accepted by default.
  2) Compute base H3 cell (res 12 by default) and skip the write if the base
     cell AND hour-of-day match the last persisted sample.
  3) Convert to E5 ints and `epochSeconds` (`ts.millisecondsSinceEpoch ~/ 1000`)
     to preserve second-level precision.
  4) Upsert into `visits_daily` and `visits_lifetime` for the base resolution
     and all parent resolutions (`[11, 10, 9, 8, 7, 6]`) in a single
     transaction; increment `days_visited` via the dedupe table
     `visits_lifetime_days`.
  5) Cleanup `visits_daily` older than 180 days only when the last cleanup is
     older than the configured interval (default 6 hours).
- Incremental aggregation is handled per sample: each resolution row is
  updated immediately, so there are no deferred rollups.
- Zoom -> H3 resolution mapping lives in `VisitedGridConfig.resolutionForZoom`.
- Rendering path only:
  - Viewport bounds -> H3 `polygonToCells` (polyfill).
  - Query `visits_daily` for "today/last 7 days" or `visits_lifetime` for
    "all time" (chunked `IN (...)` lists).
  - Draw visited cell boundaries using `PolygonLayer` (no heatmap).
  - If the polyfill exceeds 2500 cells, the resolution is reduced until it fits.
- Battery efficiency techniques:
  - Sample writes are skipped when the base cell + hour haven't changed.
  - Writes are coalesced while a DB transaction is in flight.
  - All per-sample updates happen in one transaction with upserts.
  - Cleanup is rate-limited by a persisted `last_cleanup_ts`.
- Overlay refresh triggers on camera idle or a short debounce, with request-id
  guards to ignore stale work during fast pans.
- Timestamps: all stored timestamps (`first_ts`, `last_ts`, `last_cleanup_ts`)
  are Unix epoch **seconds**, preserving second-level precision end-to-end.

### Visited overlay integration
- Wire camera changes to `MapViewModel.onCameraChanged` and idle events to
  `MapViewModel.onCameraIdle`; the overlay work runs off the UI thread and
  applies diffs with boundary caching.

```dart
FlutterMap(
  options: MapOptions(
    onPositionChanged: (camera, hasGesture) {
      viewModel.onCameraChanged(
        bounds: VisitedGridBounds(
          north: camera.visibleBounds.north,
          south: camera.visibleBounds.south,
          east: camera.visibleBounds.east,
          west: camera.visibleBounds.west,
        ),
        zoom: camera.zoom,
      );
      if (!hasGesture) {
        viewModel.onCameraIdle(
          bounds: VisitedGridBounds(
            north: camera.visibleBounds.north,
            south: camera.visibleBounds.south,
            east: camera.visibleBounds.east,
            west: camera.visibleBounds.west,
          ),
          zoom: camera.zoom,
        );
      }
    },
    onMapEvent: (event) {
      if (event is MapEventMoveEnd ||
          event is MapEventFlingAnimationEnd ||
          event is MapEventDoubleTapZoomEnd ||
          event is MapEventRotateEnd) {
        viewModel.onCameraIdle(
          bounds: VisitedGridBounds(
            north: event.camera.visibleBounds.north,
            south: event.camera.visibleBounds.south,
            east: event.camera.visibleBounds.east,
            west: event.camera.visibleBounds.west,
          ),
          zoom: event.camera.zoom,
        );
      }
    },
  ),
);
```

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
- `drift`, `drift_flutter`: SQLite persistence for visited H3 cells.
- `h3_flutter`: H3 indexing + polygon boundaries.
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
