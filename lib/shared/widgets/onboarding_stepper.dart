import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Dream11-style onboarding stepper: Select Match → Create Team → Join Contest
///
/// Ported from Fantasy- stepper.js
class OnboardingStepper extends StatelessWidget {
  /// 0-based index of the active step.
  final int activeStep;

  const OnboardingStepper({super.key, this.activeStep = 0});

  static const _steps = ['Select Match', 'Create Team', 'Join Contest'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.secondary,
      child: Row(
        children: List.generate(_steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            // Connector line
            final stepIndex = i ~/ 2;
            final isCompleted = stepIndex < activeStep;
            return Expanded(
              child: Container(
                height: 2,
                color: isCompleted
                    ? AppColors.primary
                    : Colors.white.withOpacity(0.2),
              ),
            );
          }
          // Step circle
          final stepIndex = i ~/ 2;
          final isActive    = stepIndex == activeStep;
          final isCompleted = stepIndex < activeStep;

          return _StepCircle(
            label: _steps[stepIndex],
            stepNumber: stepIndex + 1,
            isActive: isActive,
            isCompleted: isCompleted,
          );
        }),
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  final String label;
  final int stepNumber;
  final bool isActive;
  final bool isCompleted;

  const _StepCircle({
    required this.label,
    required this.stepNumber,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    Color circleColor;
    Color textColor;
    Widget circleChild;

    if (isCompleted) {
      circleColor = AppColors.primary;
      textColor   = AppColors.primary;
      circleChild = const Icon(Icons.check, color: Colors.white, size: 14);
    } else if (isActive) {
      circleColor = AppColors.primary;
      textColor   = Colors.white;
      circleChild = Text('$stepNumber',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13));
    } else {
      circleColor = Colors.white.withOpacity(0.15);
      textColor   = Colors.white.withOpacity(0.5);
      circleChild = Text('$stepNumber',
          style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontWeight: FontWeight.w600,
              fontSize: 13));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
            border: isActive
                ? Border.all(color: Colors.white, width: 2)
                : null,
          ),
          child: Center(child: circleChild),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 9,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
