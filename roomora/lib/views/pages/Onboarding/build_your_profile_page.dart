import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../theme/colors.dart';
import '/../../viewmodels/Onboarding/onboarding_viewmodel.dart';
import 'dart:io';
class BuildYourProfileView extends StatelessWidget {
  final BuildYourProfileViewModel vm;
  final String role;

  const BuildYourProfileView({super.key, required this.vm, required this.role});

  bool get isStudent => role == 'student';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text('Build your', style: _h1Black),
              const Text('profile', style: _h1Purple),
              const SizedBox(height: 4),
              Text(
                isStudent
                    ? 'A good profile gets you three times as many matches.'
                    : 'Help tenants get to know you.',
                style: const TextStyle(
                    fontSize: 14, color: AppColors.neutral700, fontFamily: 'Sora'),
              ),
              const SizedBox(height: 24),

              // Profile photo
              _PhotoPicker(vm: vm, isStudent: isStudent),
              const SizedBox(height: 20),

              if (isStudent) ...[
                _OnboardingField(
                  label: 'UNIVERSITY',
                  hint: 'e.g., Tec de Monterrey',
                  icon: Icons.school_outlined,
                  onChanged: (v) => vm.university = v,
                ),
                const SizedBox(height: 16),

                _DropdownField(
                  label: 'MAJOR',
                  hint: 'Select your major',
                  value: vm.major,
                  options: BuildYourProfileViewModel.majors,
                  onChanged: (v) { vm.major = v; vm.notifyListeners(); },
                ),
                const SizedBox(height: 16),
              ],

              Row(
                children: [
                  Expanded(
                    child: _YearDropdown(
                      label: 'BIRTH YEAR',
                      icon: Icons.calendar_today_outlined,
                      years: BuildYourProfileViewModel.birthYears,
                      value: vm.birthYear,
                      onChanged: (v) { vm.birthYear = v; vm.notifyListeners(); },
                    ),
                  ),
                  if (isStudent) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: _YearDropdown(
                        label: 'GRADUATION YEAR',
                        icon: Icons.school_outlined,
                        years: BuildYourProfileViewModel.gradYears,
                        value: vm.graduationYear,
                        onChanged: (v) { vm.graduationYear = v; vm.notifyListeners(); },
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),

              _OnboardingField(
                label: 'BIO',
                hint: 'tell us about yourself, what you study...',
                maxLines: 4,
                onChanged: (v) { vm.bio = v; vm.notifyListeners(); },
              ),
              if (vm.bio.isNotEmpty && vm.bio.length < 5) ...[
                const SizedBox(height: 6),
                const Text('Add at least 5 characters.',
                    style: TextStyle(
                        color: AppColors.purple500,
                        fontSize: 12,
                        fontFamily: 'Sora')),
              ],
              const SizedBox(height: 20),

              Row(
                children: [
                  const Text('HOBBIES',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral700,
                          letterSpacing: 0.8,
                          fontFamily: 'Sora')),
                  const Spacer(),
                  Text(
                    '${vm.selectedHobbies.length} / ${BuildYourProfileViewModel.maxHobbies}',
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.neutral600,
                        fontFamily: 'Sora'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: BuildYourProfileViewModel.hobbies.map((hobby) {
                  final selected = vm.selectedHobbies.contains(hobby);
                  return _SelectableChip(
                    label: hobby,
                    selected: selected,
                    onTap: () => vm.toggleHobby(hobby),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  final BuildYourProfileViewModel vm;
  final bool isStudent;

  const _PhotoPicker({super.key, required this.vm, required this.isStudent});

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    
    if (image != null) {
      vm.profilePhotoPath = image.path;
      vm.notifyListeners();
    }
  }

  void _showImageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.neutral300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined, color: AppColors.neutral700),
                  title: const Text('Take a photo', 
                      style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w600, color: AppColors.neutral900)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, color: AppColors.neutral700),
                  title: const Text('Select from the gallery', 
                      style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w600, color: AppColors.neutral900)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImageOptions(context),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.neutral300,
                backgroundImage: vm.profilePhotoPath != null
                    ? FileImage(File(vm.profilePhotoPath!)) as ImageProvider
                    : null,
                child: vm.profilePhotoPath == null
                    ? const Icon(Icons.person, size: 36, color: AppColors.neutral500)
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.purple500,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Profile picture',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral900,
                        fontFamily: 'Sora')),
                const SizedBox(height: 4),
                Text(
                  isStudent
                      ? 'A clear photo generates more trust with landlords and roommates.'
                      : 'A clear photo generates more trust with tenants.',
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.neutral700,
                      fontFamily: 'Sora'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const _h1Black = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.neutral900,
    fontFamily: 'Sora',
    letterSpacing: -0.5);

const _h1Purple = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.purple500,
    fontFamily: 'Sora',
    letterSpacing: -0.5);

class _OnboardingField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData? icon;
  final int maxLines;
  final void Function(String) onChanged;

  const _OnboardingField({
    required this.label,
    required this.hint,
    required this.onChanged,
    this.icon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral700,
                letterSpacing: 0.8,
                fontFamily: 'Sora')),
        const SizedBox(height: 6),
        TextField(
          maxLines: maxLines,
          onChanged: onChanged,
          style: const TextStyle(
              fontSize: 14, color: AppColors.neutral900, fontFamily: 'Sora'),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
                color: AppColors.neutral600, fontSize: 14, fontFamily: 'Sora'),
            prefixIcon: icon != null
                ? Icon(icon, color: AppColors.neutral600, size: 18)
                : null,
            filled: true,
            fillColor: AppColors.neutral200,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.purple500, width: 1.5)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final List<String> options;
  final void Function(String?) onChanged;

  const _DropdownField({
    required this.label,
    required this.hint,
    required this.options,
    required this.onChanged,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral700,
                letterSpacing: 0.8,
                fontFamily: 'Sora')),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.neutral200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(hint,
                  style: const TextStyle(
                      color: AppColors.neutral600,
                      fontSize: 14,
                      fontFamily: 'Sora')),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: AppColors.neutral600),
              style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.neutral900,
                  fontFamily: 'Sora'),
              onChanged: onChanged,
              items: options
                  .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _YearDropdown extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<int> years;
  final int? value;
  final void Function(int?) onChanged;

  const _YearDropdown({
    required this.label,
    required this.icon,
    required this.years,
    required this.onChanged,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral700,
                letterSpacing: 0.8,
                fontFamily: 'Sora')),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.neutral200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: value,
              hint: Row(
                children: [
                  Icon(icon, size: 16, color: AppColors.neutral600),
                  const SizedBox(width: 8),
                  const Text('Select',
                      style: TextStyle(
                          color: AppColors.neutral600,
                          fontSize: 14,
                          fontFamily: 'Sora')),
                ],
              ),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: AppColors.neutral600),
              style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.neutral900,
                  fontFamily: 'Sora'),
              onChanged: onChanged,
              items: years.reversed
                  .map((y) =>
                      DropdownMenuItem(value: y, child: Text(y.toString())))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectableChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SelectableChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.purple100 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.purple500 : AppColors.neutral500,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected ? AppColors.purple700 : AppColors.neutral700,
            fontFamily: 'Sora',
          ),
        ),
      ),
    );
  }
}