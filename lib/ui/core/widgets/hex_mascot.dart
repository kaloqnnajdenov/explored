import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app_colors.dart';

enum HexMascotPose { idle, walking, pointing, mapUnroll, checklist, celebrate }

class HexMascot extends StatefulWidget {
  const HexMascot({required this.pose, required this.size, super.key});

  final HexMascotPose pose;
  final double size;

  @override
  State<HexMascot> createState() => _HexMascotState();
}

class _HexMascotState extends State<HexMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value * math.pi * 2;
        final transform = _transformForPose(widget.pose, t);

        return Transform.translate(
          offset: transform.offset,
          child: Transform.rotate(
            angle: transform.rotation,
            child: Transform.scale(
              scale: transform.scale,
              child: _MascotImage(size: widget.size),
            ),
          ),
        );
      },
    );
  }

  _PoseTransform _transformForPose(HexMascotPose pose, double t) {
    switch (pose) {
      case HexMascotPose.idle:
        return _PoseTransform(
          offset: Offset(0, math.sin(t) * 4),
          rotation: math.sin(t) * 0.02,
          scale: 1,
        );
      case HexMascotPose.walking:
        return _PoseTransform(
          offset: Offset(math.sin(t) * 8, math.sin(t * 2) * 2),
          rotation: math.sin(t) * 0.05,
          scale: 1,
        );
      case HexMascotPose.pointing:
        return _PoseTransform(
          offset: Offset(0, math.sin(t * 1.5) * 3),
          rotation: math.sin(t) * 0.12,
          scale: 1,
        );
      case HexMascotPose.mapUnroll:
        return _PoseTransform(
          offset: Offset(0, -math.sin(t).abs() * 6),
          rotation: math.sin(t) * 0.04,
          scale: 1 + math.sin(t).abs() * 0.05,
        );
      case HexMascotPose.checklist:
        return _PoseTransform(
          offset: Offset(0, -math.sin(t * 1.4).abs() * 5),
          rotation: math.sin(t * 1.4) * 0.03,
          scale: 1 + math.sin(t * 1.4).abs() * 0.04,
        );
      case HexMascotPose.celebrate:
        return _PoseTransform(
          offset: Offset(math.sin(t) * 5, -math.sin(t * 2).abs() * 10),
          rotation: math.sin(t * 2) * 0.14,
          scale: 1 + math.sin(t * 2).abs() * 0.1,
        );
    }
  }
}

class _PoseTransform {
  const _PoseTransform({
    required this.offset,
    required this.rotation,
    required this.scale,
  });

  final Offset offset;
  final double rotation;
  final double scale;
}

class _MascotImage extends StatelessWidget {
  const _MascotImage({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/images/hex.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return DecoratedBox(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.emerald100,
            ),
            child: Center(
              child: Icon(
                Icons.pets,
                size: size * 0.5,
                color: AppColors.emerald700,
              ),
            ),
          );
        },
      ),
    );
  }
}
