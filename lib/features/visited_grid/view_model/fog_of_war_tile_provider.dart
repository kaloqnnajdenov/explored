import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';

import '../data/models/fog_of_war_tile_key.dart';
import '../data/repositories/fog_of_war_tile_repository.dart';

class FogOfWarTileProvider extends TileProvider {
  FogOfWarTileProvider({required FogOfWarTileRepository repository})
      : _repository = repository;

  final FogOfWarTileRepository _repository;

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return FogOfWarTileImageProvider(
      repository: _repository,
      keyData: FogOfWarTileKey(
        x: coordinates.x,
        y: coordinates.y,
        z: coordinates.z,
        tileSize: options.tileSize.toInt(),
        styleId: _repository.cacheId,
      ),
    );
  }
}

class FogOfWarTileImageProvider
    extends ImageProvider<FogOfWarTileImageProvider> {
  FogOfWarTileImageProvider({
    required FogOfWarTileRepository repository,
    required FogOfWarTileKey keyData,
  })  : _repository = repository,
        _keyData = keyData;

  final FogOfWarTileRepository _repository;
  final FogOfWarTileKey _keyData;

  @override
  Future<FogOfWarTileImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<FogOfWarTileImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    FogOfWarTileImageProvider key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(decode),
      scale: 1,
    );
  }

  Future<ui.Codec> _loadAsync(ImageDecoderCallback decode) async {
    final bytes = await _repository.loadTile(
      x: _keyData.x,
      y: _keyData.y,
      z: _keyData.z,
    );
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    return decode(buffer);
  }

  @override
  bool operator ==(Object other) {
    return other is FogOfWarTileImageProvider &&
        other._keyData == _keyData;
  }

  @override
  int get hashCode => _keyData.hashCode;
}
