import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Animated hero carousel banner for the home screen.
class HeroBanner extends StatefulWidget {
  const HeroBanner({super.key});

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  final List<_BannerItem> _banners = const [
    _BannerItem(
      title: 'Play Fantasy Cricket',
      subtitle: 'Create your dream team and win big!',
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFE11D48), Color(0xFF9F1239)],
      ),
      icon: Icons.sports_cricket,
    ),
    _BannerItem(
      title: 'Live Matches',
      subtitle: 'Follow ball-by-ball action in real-time',
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
      ),
      icon: Icons.live_tv,
    ),
    _BannerItem(
      title: 'Win Prizes',
      subtitle: 'Join contests and compete for rewards',
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF22C55E), Color(0xFF15803D)],
      ),
      icon: Icons.emoji_events,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _banners.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _banners.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: banner.gradient,
                  borderRadius: AppSpacing.borderRadiusLg,
                  boxShadow: [
                    BoxShadow(
                      color: banner.gradient.colors.first.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Icon(
                        banner.icon,
                        size: 150,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            banner.icon,
                            size: 36,
                            color: Colors.white,
                          ),
                          AppSpacing.gapH12,
                          Text(
                            banner.title,
                            style: AppTypography.headlineMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          AppSpacing.gapH4,
                          Text(
                            banner.subtitle,
                            style: AppTypography.bodyMedium.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        AppSpacing.gapH12,
        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? AppColors.primary
                    : AppColors.border,
                borderRadius: AppSpacing.borderRadiusFull,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BannerItem {
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final IconData icon;

  const _BannerItem({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.icon,
  });
}
