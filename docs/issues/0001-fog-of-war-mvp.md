# Issue 0001: Fog-of-War MVP (Raster Overlay + Explored Area)

## Summary
Implement MVP features derived from a single canonical visited set (base E3 resolution):
- Raster/bitmap overlay showing visited areas as a blue highlight.
- Explored area accumulator from unique visited cells (m² persisted, km² displayed).
- Terminal logging for explored area updates.
- “Explored Area” screen showing total km2.
- User-selectable overlay tile size (256/512) via hamburger menu.
- Migrate navigation to go_router.

## Acceptance Criteria
- Canonical visited set uses base E3 resolution and remains the single source of truth.
- New GPS samples only update canonical set; overlays and area derive from it.
- Raster overlay uses tile-based mask rendered via dart:ui with blurred edges.
- Overlay updates incrementally for new visited cells (invalidate affected tiles only).
- Overlay tile size is switchable (256/512) via hamburger menu.
- Explored area total is persisted in m² and displayed in km2 with localized formatting.
- Explored area logs are emitted to terminal on:
  - New canonical cell added
  - Startup reconciliation
  - Opening the Explored Area screen
- go_router is used for navigation; map remains the default route.
- Localization keys exist for all new user-facing strings.
- Unit tests added for new ViewModels/Repositories/Services and key behaviors.
- Widget tests confirm new strings fit without overflow.

## MVVC Structure
- View:
  - MapView (uses overlay tile layer and menu entry)
  - ExploredAreaView (new screen)
- ViewModel:
  - MapViewModel (overlay controls + tile size selection)
  - ExploredAreaViewModel (reads stats, logs view)
- Repository:
  - VisitedGridRepository (canonical set + stats + update stream)
  - FogOfWarTileRepository (tile generation/caching from canonical set)
  - MapRepository (overlay tile size persistence)
- Services:
  - VisitedGridDatabase (stats table migration)
  - VisitedGridH3Service (cell area)
  - FogOfWarTileRasterService (dart:ui rendering)
  - FogOfWarTileCacheService (disk/memory cache)
  - MapOverlaySettingsService (SharedPreferences persistence)
  - ExploredAreaLogger (terminal logging)

## Notes
- No cloud sync or social features.
- No polygon overlay display for visited cells in map view.
- Area computation must use H3 cellArea API.
