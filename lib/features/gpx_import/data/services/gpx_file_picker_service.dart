import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import '../../../location/data/services/platform_info.dart';

class GpxSelectedFile {
  const GpxSelectedFile({
    required this.name,
    required this.bytes,
  });

  final String name;
  final Uint8List bytes;
}

abstract class FilePickerClient {
  Future<GpxSelectedFile?> pickFile({
    required FileType type,
    List<String>? allowedExtensions,
  });
}

class FilePickerClientImpl implements FilePickerClient {
  @override
  Future<GpxSelectedFile?> pickFile({
    required FileType type,
    List<String>? allowedExtensions,
  }) async {
    final shouldFilter = type == FileType.custom;
    final result = await FilePicker.platform.pickFiles(
      type: type,
      allowedExtensions: shouldFilter ? allowedExtensions : null,
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null) {
      return null;
    }

    return GpxSelectedFile(name: file.name, bytes: bytes);
  }
}

class GpxFilePickerService {
  GpxFilePickerService({
    required FilePickerClient client,
    required PlatformInfo platformInfo,
  })  : _client = client,
        _platformInfo = platformInfo;

  final FilePickerClient _client;
  final PlatformInfo _platformInfo;

  Future<GpxSelectedFile?> pickGpxFile() {
    final useCustomFilter = !_platformInfo.isAndroid;
    return _client.pickFile(
      type: useCustomFilter ? FileType.custom : FileType.any,
      allowedExtensions: useCustomFilter ? const ['gpx'] : null,
    );
  }
}
