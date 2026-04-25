import 'package:flutter/material.dart';
import '../../../theme/colors.dart';
import '../../../viewmodels/Onboarding/onboarding_viewmodel.dart';
import '../../widgets/onboarding_shared_widgets.dart';

class NewListingView extends StatelessWidget {
  final NewListingViewModel vm;
  const NewListingView({super.key, required this.vm});

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
              const Text('New', style: h1Black),
              const Text('listing', style: h1Purple),
              const SizedBox(height: 4),
              const Text(
                  'Complete the details. You can edit before publishing.',
                  style: TextStyle(fontSize: 14, color: AppColors.neutral700, fontFamily: 'Sora')),
              const SizedBox(height: 20),
              OnboardingField(label: 'TITLE', hint: 'Comfortable studio near the cathedral',
                  icon: Icons.title, onChanged: (v) { vm.title = v; vm.notifyListeners(); }),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: OnboardingField(label: 'MONTHLY RENT', hint: '700',
                    icon: Icons.attach_money,
                    onChanged: (v) { vm.monthlyRent = v; vm.notifyListeners(); })),
                const SizedBox(width: 12),
                Expanded(child: OnboardingField(label: 'SECURITY DEPOSIT', hint: '700',
                    icon: Icons.attach_money,
                    onChanged: (v) { vm.securityDeposit = v; vm.notifyListeners(); })),
              ]),
              const SizedBox(height: 16),
              const Text('PROPERTY TYPE', style: sectionLabel),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8,
                children: NewListingViewModel.propertyTypes.map((type) {
                  final sel = vm.propertyType == type;
                  return CustomChip(label: type, selected: sel,
                      onTap: () { vm.propertyType = sel ? null : type; vm.notifyListeners(); });
                }).toList()),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('CONTRACT', style: sectionLabel),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: AppColors.neutral200,
                        borderRadius: BorderRadius.circular(12)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: vm.leaseLength,
                        isExpanded: true,
                        style: const TextStyle(fontSize: 14, color: AppColors.neutral900, fontFamily: 'Sora'),
                        onChanged: (v) { if (v != null) { vm.leaseLength = v; vm.notifyListeners(); } },
                        items: NewListingViewModel.leaseOptions
                            .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                            .toList(),
                      ),
                    ),
                  ),
                ])),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('AVAILABLE FROM', style: sectionLabel),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () async {
                      final d = await showDatePicker(context: context,
                          initialDate: vm.availableFrom,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)));
                      if (d != null) { vm.availableFrom = d; vm.notifyListeners(); }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.neutral200,
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 16, color: AppColors.neutral600),
                        const SizedBox(width: 8),
                        Text(
                          '${vm.availableFrom.day}/${vm.availableFrom.month}/${vm.availableFrom.year}',
                          style: const TextStyle(fontSize: 13, fontFamily: 'Sora'),
                        ),
                      ]),
                    ),
                  ),
                ])),
              ]),
              const SizedBox(height: 16),
              const Text('AMENITIES', style: sectionLabel),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8,
                  children: NewListingViewModel.amenities.map((a) => CustomChip(
                        label: a, selected: vm.selectedAmenities.contains(a),
                        onTap: () => vm.toggleAmenity(a))).toList()),
              const SizedBox(height: 16),
              const Text('RULES', style: sectionLabel),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8,
                  children: NewListingViewModel.rules.map((r) => CustomChip(
                        label: r, selected: vm.selectedRules.contains(r),
                        onTap: () => vm.toggleRule(r))).toList()),
              const SizedBox(height: 16),
              Row(children: [
                const Text('DESCRIPTION', style: sectionLabel),
                const Spacer(),
                Text('${vm.description.length} / ${NewListingViewModel.descriptionMinChars} min',
                    style: TextStyle(fontSize: 11, fontFamily: 'Sora',
                        color: vm.description.length >= NewListingViewModel.descriptionMinChars
                            ? ExtraAppColors.green400 : AppColors.neutral600)),
              ]),
              const SizedBox(height: 6),
              OnboardingField(
                label: '', maxLines: 4,
                hint: 'Describe your property — the neighborhood, what makes it great...',
                onChanged: (v) { vm.description = v; vm.notifyListeners(); }),
            ],
          ),
        );
      },
    );
  }
}