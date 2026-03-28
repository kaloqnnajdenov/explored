import 'country_pack_descriptor.dart';

class CountryPackState {
  const CountryPackState({
    required this.descriptor,
    required this.imported,
    this.importedAt,
  });

  final CountryPackDescriptor descriptor;
  final bool imported;
  final int? importedAt;
}
