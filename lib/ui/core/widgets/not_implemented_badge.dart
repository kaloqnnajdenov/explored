import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../translations/locale_keys.g.dart';
import '../app_colors.dart';

class NotImplementedBadge extends StatelessWidget {
  const NotImplementedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.slate100,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Text(
        LocaleKeys.common_not_implemented.tr(),
        style: const TextStyle(
          color: AppColors.slate500,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
