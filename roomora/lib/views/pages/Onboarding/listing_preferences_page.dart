import 'package:flutter/material.dart';
import '../../../theme/colors.dart';
import '../../../viewmodels/Onboarding/onboarding_viewmodel.dart';
import '../../widgets/onboarding_shared_widgets.dart';

class ListingPreferencesView extends StatelessWidget {
  final ListingPreferencesViewModel vm;
  const ListingPreferencesView({super.key, required this.vm});

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
              const Text('Find your', style: h1Black),
              const Text('next home', style: h1Purple),
              const SizedBox(height: 20),
              PrefSection(icon: Icons.attach_money, title: 'MONTHLY BUDGET', child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('\$${vm.maxBudget ?? 0}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                          color: AppColors.neutral900, fontFamily: 'Sora')),
                  const SizedBox(height: 8),
                  Row(children: ListingPreferencesViewModel.budgetOptions.map((amount) {
                    final label = amount >= 1200 ? '\$${(amount ~/ 100) * 100}+' : '\$$amount';
                    return Expanded(child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: CustomChip(label: label,
                          selected: vm.maxBudget == amount,
                          onTap: () => vm.setMaxBudget(amount)),
                    ));
                  }).toList()),
                ])),
              PrefSection(icon: Icons.home_outlined, title: 'PROPERTY TYPE', child:
                GridView.count(
                  crossAxisCount: 2, shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8, crossAxisSpacing: 8,
                  childAspectRatio: 1.6,
                  children: ListingPreferencesViewModel.propertyTypes.map((opt) {
                    final sel = vm.propertyType == opt['label'];
                    return GestureDetector(
                      onTap: () => vm.setPropertyType(opt['label']),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          color: sel ? AppColors.purple100 : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: sel ? AppColors.purple500 : AppColors.neutral400,
                              width: sel ? 2 : 1)),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(opt['emoji']!, style: const TextStyle(fontSize: 22)),
                          Text(opt['label']!, style: const TextStyle(fontSize: 13,
                              fontWeight: FontWeight.w600, fontFamily: 'Sora')),
                          Text(opt['sub']!, style: const TextStyle(fontSize: 10,
                              color: AppColors.neutral600, fontFamily: 'Sora'),
                              textAlign: TextAlign.center),
                        ]),
                      ),
                    );
                  }).toList())),
              PrefSection(icon: Icons.event_outlined, title: 'CONTRACT TERM', child:
                Row(children: ListingPreferencesViewModel.leaseOptions.map((months) =>
                  Expanded(child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: CustomChip(label: '$months months',
                        selected: vm.leaseLength == months,
                        onTap: () => vm.setLeaseLength(months))))).toList())),
              PrefSection(icon: Icons.star_outline, title: 'ESSENTIAL AMENITIES', child:
                GridView.count(
                  crossAxisCount: 3, shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8, crossAxisSpacing: 8,
                  childAspectRatio: 1.4,
                  children: ListingPreferencesViewModel.amenities.map((opt) {
                    final sel = vm.selectedAmenities.contains(opt['label']);
                    return GestureDetector(
                      onTap: () => vm.toggleAmenity(opt['label']!),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          color: sel ? AppColors.purple100 : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: sel ? AppColors.purple500 : AppColors.neutral400,
                              width: sel ? 2 : 1)),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(opt['emoji']!, style: const TextStyle(fontSize: 20)),
                          const SizedBox(height: 4),
                          Text(opt['label']!, style: const TextStyle(fontSize: 11,
                              fontFamily: 'Sora'), textAlign: TextAlign.center),
                        ]),
                      ),
                    );
                  }).toList())),
            ],
          ),
        );
      },
    );
  }
}