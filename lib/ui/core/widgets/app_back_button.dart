import 'package:flutter/material.dart';

import '../app_colors.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const SizedBox(
          width: 48,
          height: 48,
          child: Icon(Icons.arrow_back, color: AppColors.slate900),
        ),
      ),
    );
  }
}
