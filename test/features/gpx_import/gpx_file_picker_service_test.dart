import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:file_picker/file_picker.dart';
import 'package:explored/features/gpx_import/data/services/gpx_file_picker_service.dart';
import 'package:explored/features/location/data/services/platform_info.dart';

class FakePlatformInfo implements PlatformInfo {
  FakePlatformInfo({
    required this.isAndroid,
    required this.isIOS,
    required this.androidSdkInt,
  });

  @override
  final bool isAndroid;

  @override
  final bool isIOS;

  @override
  final int? androidSdkInt;
}

class FakeFilePickerClient implements FilePickerClient {
  FileType? type;
  List<String>? allowedExtensions;
  GpxSelectedFile? file;

  @override
  Future<GpxSelectedFile?> pickFile({
    required FileType type,
    List<String>? allowedExtensions,
  }) async {
    this.type = type;
    this.allowedExtensions = allowedExtensions;
    return file;
  }
}

void main() {
  test('pickGpxFile uses custom filter on non-Android platforms', () async {
    final client = FakeFilePickerClient()
      ..file = GpxSelectedFile(
        name: 'track.gpx',
        bytes: Uint8List.fromList([1, 2, 3]),
      );
    final service = GpxFilePickerService(
      client: client,
      platformInfo: FakePlatformInfo(
        isAndroid: false,
        isIOS: true,
        androidSdkInt: null,
      ),
    );

    final selection = await service.pickGpxFile();

    expect(client.type, FileType.custom);
    expect(client.allowedExtensions, ['gpx']);
    expect(selection, isNotNull);
    expect(selection!.name, 'track.gpx');
  });

  test('pickGpxFile uses any type on Android', () async {
    final client = FakeFilePickerClient()..file = null;
    final service = GpxFilePickerService(
      client: client,
      platformInfo: FakePlatformInfo(
        isAndroid: true,
        isIOS: false,
        androidSdkInt: 34,
      ),
    );

    final selection = await service.pickGpxFile();

    expect(client.type, FileType.any);
    expect(client.allowedExtensions, isNull);
    expect(selection, isNull);
  });
}
