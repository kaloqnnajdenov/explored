import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart' as path_provider;

import '../models/fog_of_war_tile_key.dart';

abstract class TileCachePathProvider {
  Future<Directory> getTemporaryDirectory();
}

class PathProviderTileCachePathProvider implements TileCachePathProvider {
  @override
  Future<Directory> getTemporaryDirectory() {
    return path_provider.getTemporaryDirectory();
  }
}

class FogOfWarTileCacheService {
  FogOfWarTileCacheService({
    required TileCachePathProvider pathProvider,
    this.maxEntries = 200,
  }) : _pathProvider = pathProvider;

  final TileCachePathProvider _pathProvider;
  final int maxEntries;
  final LinkedHashMap<FogOfWarTileKey, Uint8List> _memoryCache =
      LinkedHashMap();
  Directory? _cacheDir;

  Uint8List? readFromMemory(FogOfWarTileKey key) {
    final value = _memoryCache.remove(key);
    if (value == null) {
      return null;
    }
    _memoryCache[key] = value;
    return value;
  }

  void writeToMemory(FogOfWarTileKey key, Uint8List bytes) {
    if (maxEntries <= 0) {
      return;
    }
    _memoryCache.remove(key);
    _memoryCache[key] = bytes;
    _evictIfNeeded();
  }

  void evictFromMemory(FogOfWarTileKey key) {
    _memoryCache.remove(key);
  }

  Future<Uint8List?> readFromDisk(FogOfWarTileKey key) async {
    final file = await _fileForKey(key);
    if (!await file.exists()) {
      return null;
    }
    return file.readAsBytes();
  }

  Future<void> writeToDisk(FogOfWarTileKey key, Uint8List bytes) async {
    final file = await _fileForKey(key);
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }
    final tempPath = '${file.path}.tmp';
    final tempFile = File(tempPath);
    await tempFile.writeAsBytes(bytes, flush: true);
    await tempFile.rename(file.path);
  }

  Future<void> evictFromDisk(FogOfWarTileKey key) async {
    final file = await _fileForKey(key);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> clear() async {
    _memoryCache.clear();
    final dir = await _ensureCacheDir();
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  Future<File> _fileForKey(FogOfWarTileKey key) async {
    final dir = await _ensureCacheDir();
    final name = key.cacheKey.replaceAll('/', '_');
    return File('${dir.path}/$name.png');
  }

  Future<Directory> _ensureCacheDir() async {
    if (_cacheDir != null) {
      return _cacheDir!;
    }
    final base = await _pathProvider.getTemporaryDirectory();
    _cacheDir = Directory('${base.path}/fog_of_war_tiles');
    return _cacheDir!;
  }

  void _evictIfNeeded() {
    while (_memoryCache.length > maxEntries) {
      _memoryCache.remove(_memoryCache.keys.first);
    }
  }
}
