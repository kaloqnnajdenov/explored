import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../translations/locale_keys.g.dart';
import '../../../ui/core/app_colors.dart';
import '../../../ui/core/widgets/hex_mascot.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;

  static const List<_OnboardingSlideData> _slides = [
    _OnboardingSlideData(
      titleKey: LocaleKeys.onboarding_slide1_title,
      descriptionKey: LocaleKeys.onboarding_slide1_description,
      pose: HexMascotPose.walking,
      showGlow: true,
    ),
    _OnboardingSlideData(
      titleKey: LocaleKeys.onboarding_slide2_title,
      descriptionKey: LocaleKeys.onboarding_slide2_description,
      pose: HexMascotPose.checklist,
    ),
    _OnboardingSlideData(
      titleKey: LocaleKeys.onboarding_slide3_title,
      descriptionKey: LocaleKeys.onboarding_slide3_description,
      pose: HexMascotPose.mapUnroll,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _pageIndex == _slides.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final topPadding = constraints.maxHeight < 700 ? 24.0 : 80.0;
            final bottomPadding = constraints.maxHeight < 700 ? 24.0 : 48.0;

            return Padding(
              padding: EdgeInsets.fromLTRB(32, topPadding, 32, bottomPadding),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: _goToPermissions,
                      child: Text(
                        LocaleKeys.onboarding_action_skip.tr(),
                        style: const TextStyle(color: AppColors.slate400),
                      ),
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _slides.length,
                      onPageChanged: (index) {
                        setState(() {
                          _pageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final slide = _slides[index];
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _OnboardingSlide(
                            key: ValueKey(index),
                            data: slide,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (index) {
                      final isActive = index == _pageIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.emerald600
                              : AppColors.slate200,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.emerald900,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                        shadowColor: Colors.black.withValues(alpha: 0.2),
                      ),
                      onPressed: () => _handlePrimaryAction(isLastPage),
                      icon: const Icon(Icons.chevron_right),
                      label: Text(
                        isLastPage
                            ? LocaleKeys.onboarding_action_get_started.tr()
                            : LocaleKeys.onboarding_action_next.tr(),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _handlePrimaryAction(bool isLastPage) {
    if (isLastPage) {
      _goToPermissions();
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _goToPermissions() {
    context.go('/permissions');
  }
}

class _OnboardingSlideData {
  const _OnboardingSlideData({
    required this.titleKey,
    required this.descriptionKey,
    required this.pose,
    this.showGlow = false,
  });

  final String titleKey;
  final String descriptionKey;
  final HexMascotPose pose;
  final bool showGlow;
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({required this.data, super.key});

  final _OnboardingSlideData data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mascotSize = (constraints.maxHeight * 0.56).clamp(150.0, 360.0);
        final glowSize = mascotSize * 0.62;

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: mascotSize,
                  height: mascotSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (data.showGlow)
                        Container(
                          width: glowSize,
                          height: glowSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.emerald100.withValues(alpha: 0.8),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.emerald100.withValues(
                                  alpha: 0.9,
                                ),
                                blurRadius: 45,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      HexMascot(pose: data.pose, size: mascotSize),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data.titleKey.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate900,
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: Text(
                    data.descriptionKey.tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.slate500,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
