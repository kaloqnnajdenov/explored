import 'dart:ui';

class FogOfWarStyle {
  const FogOfWarStyle({
    required this.highlightColor,
    this.highlightOpacity = 0.35,
    this.blurSigma = 4.0,
  });

  final Color highlightColor;
  final double highlightOpacity;
  final double blurSigma;

  String get id =>
      '${highlightColor.toARGB32()}_${highlightOpacity}_$blurSigma';
}
