import 'package:flutter/material.dart';

class SelectionChipWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? selectedColor;
  final Color? selectedTextColor;
  final Color? unselectedColor;
  final Color? unselectedTextColor;

  const SelectionChipWidget({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.selectedColor,
    this.selectedTextColor,
    this.unselectedColor,
    this.unselectedTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (selectedColor ?? const Color(0xFF7B5BF2))
              : (unselectedColor ?? const Color(0xFFF6F7F8)),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected
                ? (selectedColor ?? const Color(0xFF7B5BF2))
                : const Color(0xFFE4E7EC),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? (selectedTextColor ?? Colors.white)
                : (unselectedTextColor ?? const Color(0xFF6E7681)),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}