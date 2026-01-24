import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:explored/features/visited_grid/data/models/fog_of_war_tile_key.dart';
import 'package:explored/features/visited_grid/data/services/fog_of_war_tile_cache_service.dart';

class FakeTileCachePathProvider implements TileCachePathProvider {
  FakeTileCachePathProvider(this.directory);

  final Directory directory;

  @override
  Future<Directory> getTemporaryDirectory() async => directory;
}

void main() {
  test('Writes and reads tiles from disk cache', () async {
    final directory = Directory.systemTemp.createTempSync(
      'fog_of_war_cache_test',
    );
    addTearDown(() async {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });

    final cacheService = FogOfWarTileCacheService(
      pathProvider: FakeTileCachePathProvider(directory),
      maxEntries: 10,
    );
    const key = FogOfWarTileKey(
      x: 1,
      y: 2,
      z: 3,
      tileSize: 256,
      styleId: 'style',
    );
    final bytes = Uint8List.fromList([1, 2, 3, 4]);

    await cacheService.writeToDisk(key, bytes);
    final loaded = await cacheService.readFromDisk(key);

    expect(loaded, bytes);
  });

  test('Evicts least recently used memory entries', () {
    final directory = Directory.systemTemp.createTempSync(
      'fog_of_war_cache_memory_test',
    );
    addTearDown(() async {
      if (directory.existsSync()) {
        await directory.delete(recursive: true);
      }
    });

    final cacheService = FogOfWarTileCacheService(
      pathProvider: FakeTileCachePathProvider(directory),
      maxEntries: 1,
    );
    const keyA = FogOfWarTileKey(
      x: 0,
      y: 0,
      z: 1,
      tileSize: 256,
      styleId: 'style',
    );
    const keyB = FogOfWarTileKey(
      x: 1,
      y: 0,
      z: 1,
      tileSize: 256,
      styleId: 'style',
    );

    cacheService.writeToMemory(keyA, Uint8List.fromList([1]));
    cacheService.writeToMemory(keyB, Uint8List.fromList([2]));

    expect(cacheService.readFromMemory(keyA), isNull);
    expect(cacheService.readFromMemory(keyB), isNotNull);
  });
}
