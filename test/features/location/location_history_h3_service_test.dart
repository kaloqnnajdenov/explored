import 'package:flutter_test/flutter_test.dart';
import 'package:explored/features/location/data/services/location_history_h3_service.dart';

void main() {
  test('cellIdForLatLng uses injected resolver when provided', () {
    final service = LocationHistoryH3Service(
      cellIdResolver: (lat, lon) => 'cell_${lat}_$lon',
    );

    final actual = service.cellIdForLatLng(
      latitude: 12.34,
      longitude: 56.78,
    );

    expect(actual, 'cell_12.34_56.78');
  });
}
