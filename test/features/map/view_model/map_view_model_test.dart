import 'package:flutter_test/flutter_test.dart';

import 'package:explored/features/map/data/models/map_tile_source.dart';
import 'package:explored/features/map/data/repositories/map_repository.dart';
import 'package:explored/features/map/data/services/map_attribution_service.dart';
import 'package:explored/features/map/data/services/map_tile_service.dart';
import 'package:explored/features/map/view_model/map_view_model.dart';

void main() {
  test('initialize loads map config', () async {
    final attributionService = _FakeMapAttributionService();
    final mapRepository = MapRepository(
      tileService: _FakeMapTileService(),
      attributionService: attributionService,
    );
    final viewModel = MapViewModel(mapRepository: mapRepository);

    expect(viewModel.state.isLoading, isTrue);

    await viewModel.initialize();

    final state = viewModel.state;
    expect(state.isLoading, isFalse);
    expect(state.tileSource.urlTemplate, 'https://example.com/{z}/{x}/{y}.png');
    expect(state.tileSource.subdomains, ['a']);
    expect(state.center.latitude, 0);
    expect(state.center.longitude, 0);
  });

  test('openAttribution delegates to repository', () async {
    final attributionService = _FakeMapAttributionService();
    final mapRepository = MapRepository(
      tileService: _FakeMapTileService(),
      attributionService: attributionService,
    );

    final viewModel = MapViewModel(mapRepository: mapRepository);

    await viewModel.openAttribution();

    expect(attributionService.wasOpened, isTrue);
  });
}

/// Simple fake that returns a deterministic tile source.
class _FakeMapTileService implements MapTileService {
  @override
  MapTileSource getTileSource() {
    return const MapTileSource(
      urlTemplate: 'https://example.com/{z}/{x}/{y}.png',
      subdomains: ['a'],
      userAgentPackageName: 'com.example.test',
    );
  }
}

class _FakeMapAttributionService implements MapAttributionService {
  bool wasOpened = false;

  @override
  Future<void> openAttribution() async {
    wasOpened = true;
  }
}
