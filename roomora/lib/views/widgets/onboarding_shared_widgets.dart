import 'package:flutter/material.dart';
import '../../../theme/colors.dart';

const h1Black = TextStyle(fontSize: 32, fontWeight: FontWeight.w700,
    color: AppColors.neutral900, fontFamily: 'Sora', letterSpacing: -0.5);
const h1Purple = TextStyle(fontSize: 32, fontWeight: FontWeight.w700,
    color: AppColors.purple500, fontFamily: 'Sora', letterSpacing: -0.5);
const sectionLabel = TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
    color: AppColors.neutral700, letterSpacing: 0.8, fontFamily: 'Sora');

class PrefSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const PrefSection({super.key, required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 16, color: AppColors.purple500),
          const SizedBox(width: 6),
          Text(title, style: sectionLabel),
        ]),
        const SizedBox(height: 10),
        child,
      ]),
    );
  }
}

class CustomChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const CustomChip({super.key, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.purple100 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? AppColors.purple500 : AppColors.neutral400)),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
            color: selected ? AppColors.purple700 : AppColors.neutral700,
            fontFamily: 'Sora')),
      ),
    );
  }
}

class CircleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const CircleChip({super.key, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 40, height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? AppColors.purple100 : Colors.transparent,
          border: Border.all(
              color: selected ? AppColors.purple500 : AppColors.neutral400)),
        child: Center(child: Text(label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                color: selected ? AppColors.purple700 : AppColors.neutral700,
                fontFamily: 'Sora'))),
      ),
    );
  }
}

class LifestyleCard extends StatelessWidget {
  final String emoji, title, subtitle;
  final bool selected;
  final VoidCallback onTap;
  const LifestyleCard({super.key, required this.emoji, required this.title,
      required this.subtitle, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.purple100 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? AppColors.purple500 : AppColors.neutral400,
              width: selected ? 2 : 1)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
              fontFamily: 'Sora'), textAlign: TextAlign.center),
          Text(subtitle, style: const TextStyle(fontSize: 10,
              color: AppColors.neutral600, fontFamily: 'Sora'),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

class OnboardingField extends StatelessWidget {
  final String label, hint;
  final IconData? icon;
  final int maxLines;
  final void Function(String) onChanged;
  const OnboardingField({super.key, required this.label, required this.hint,
      required this.onChanged, this.icon, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (label.isNotEmpty) ...[
        Text(label, style: sectionLabel),
        const SizedBox(height: 6),
      ],
      TextField(
        maxLines: maxLines, onChanged: onChanged,
        style: const TextStyle(fontSize: 14, color: AppColors.neutral900, fontFamily: 'Sora'),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.neutral600, fontSize: 14, fontFamily: 'Sora'),
          prefixIcon: icon != null ? Icon(icon, color: AppColors.neutral600, size: 18) : null,
          filled: true, fillColor: AppColors.neutral200,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.purple500, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    ]);
  }
}

extension ExtraAppColors on AppColors {
  static const Color yellow100 = Color(0xFFFFF9EB);
  static const Color yellow500 = Color(0xFFEBA400);
  static const Color green200 = Color(0xFFDDFFCC);
  static const Color green400 = Color(0xFF69E052);
  static const Color green100 = Color(0xFFF2FFE5); 
}