import 'package:flutter/material.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const ProgressIndicatorWidget({
    Key? key,
    required this.currentStep,
    this.totalSteps = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps * 2 - 1, (index) {
        if (index.isOdd) {
          return _buildLine(index ~/ 2);
        } else {
          final step = index ~/ 2 + 1;
          return _buildDot(step);
        }
      }),
    );
  }

  Widget _buildDot(int step) {
    final isCompleted = step <= currentStep;
    final isCurrent = step == currentStep;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted ? const Color(0xFF7B5BF2) : const Color(0xFFF1F2F4),
        border: Border.all(
          color: isCompleted ? const Color(0xFF7B5BF2) : const Color(0xFFE4E7EC),
          width: 1,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: const Color(0xFF7B5BF2).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          step.toString(),
          style: TextStyle(
            color: isCompleted ? Colors.white : const Color(0xFFB0B6BF),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildLine(int index) {
    final isCompleted = index + 1 < currentStep;

    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFF7B5BF2) : const Color(0xFFF0ECFE),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}