import 'package:flutter/material.dart';
import '../../../theme/colors.dart';
import '../../../viewmodels/Onboarding/onboarding_viewmodel.dart';
import '../../widgets/onboarding_shared_widgets.dart';

class RoommatePreferencesView extends StatelessWidget {
  final RoommatePreferencesViewModel vm;
  final String role;
  const RoommatePreferencesView(
      {super.key, required this.vm, required this.role});

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
              const Text('Your roommate', style: h1Black),
              const Text('ideal', style: h1Purple),
              const SizedBox(height: 4),
              const Text(
                'Help us find someone you really want to live with.',
                style: TextStyle(
                    fontSize: 14,
                    color: AppColors.neutral700,
                    fontFamily: 'Sora'),
              ),
              const SizedBox(height: 24),
              PrefSection(icon: Icons.people_outline, title: 'SPOTS AVAILABLE', child:
                Row(children: List.generate(4, (i) {
                  final n = i + 1;
                  final sel = vm.spotsAvailable == n;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CircleChip(label: '$n', selected: sel,
                        onTap: () => vm.setSpotsAvailable(n)),
                  );
                }))),
              PrefSection(icon: Icons.calendar_today_outlined, title: 'MONTH OF MOVE-IN', child:
                Wrap(spacing: 8, runSpacing: 8,
                  children: ['Jan','Feb','Mar','Apr','May','Jun',
                              'Jul','Aug','Sep','Oct','Nov','Dec']
                      .map((m) => CustomChip(label: m,
                            selected: vm.moveInMonth == m,
                            onTap: () => vm.setMoveInMonth(vm.moveInMonth == m ? null : m)))
                      .toList())),
              PrefSection(icon: Icons.person_outline, title: 'GENDER PREFERENCE', child:
                Wrap(spacing: 8, runSpacing: 8,
                  children: [
                    {'label': 'No preference', 'value': 0},
                    {'label': 'Like me', 'value': 1},
                    {'label': 'Women only', 'value': 2},
                    {'label': 'Men only', 'value': 3},
                  ].map((o) => CustomChip(
                        label: o['label'] as String,
                        selected: vm.genderPreference == o['value'],
                        onTap: () => vm.setGenderPreference(
                            vm.genderPreference == o['value'] ? null : o['value'] as int)))
                      .toList())),
              PrefSection(icon: Icons.nightlight_round, title: 'SLEEP SCHEDULE', child:
                Row(children: [
                  {'emoji': '🌅', 'label': 'Early bird', 'sub': 'Before 7am', 'value': 0},
                  {'emoji': '🌙', 'label': 'Night owl', 'sub': 'After midnight', 'value': 1},
                  {'emoji': '🎲', 'label': 'No preference', 'sub': 'Anytime', 'value': 2},
                ].map((o) => Expanded(child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: LifestyleCard(
                    emoji: o['emoji'] as String,
                    title: o['label'] as String,
                    subtitle: o['sub'] as String,
                    selected: vm.sleepSchedule == o['value'],
                    onTap: () => vm.setSleepSchedule(
                        vm.sleepSchedule == o['value'] ? null : o['value'] as int),
                  )))).toList())),
              PrefSection(icon: Icons.auto_awesome, title: 'LIMPIEZA', child:
                Row(children: [
                  {'emoji': '✨', 'label': 'Very clean', 'sub': 'Always tidy', 'value': 0},
                  {'emoji': '🧹', 'label': 'Moderate', 'sub': 'Sufficiently clean', 'value': 1},
                  {'emoji': '😌', 'label': 'Relaxed', 'sub': 'Laid-back', 'value': 2},
                ].map((o) => Expanded(child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: LifestyleCard(
                    emoji: o['emoji'] as String,
                    title: o['label'] as String,
                    subtitle: o['sub'] as String,
                    selected: vm.cleanliness == o['value'],
                    onTap: () => vm.setCleanliness(
                        vm.cleanliness == o['value'] ? null : o['value'] as int),
                  )))).toList())),
              PrefSection(icon: Icons.favorite_outline, title: 'LIFESTYLE', child:
                Wrap(spacing: 8, runSpacing: 8,
                  children: [
                    {'emoji': '🚭', 'label': 'Non-smoker'},
                    {'emoji': '🐾', 'label': 'Pet-friendly'},
                    {'emoji': '💃', 'label': 'No parties'},
                    {'emoji': '📚', 'label': 'Study oriented'},
                    {'emoji': '🍳', 'label': 'Frequent cooking'},
                    {'emoji': '🫂', 'label': 'Few visitors'},
                  ].map((o) => CustomChip(
                        label: '${o['emoji']} ${o['label']}',
                        selected: vm.selectedLifestyle.contains(o['label']),
                        onTap: () => vm.toggle(vm.selectedLifestyle, o['label']!)))
                      .toList())),
            ],
          ),
        );
      },
    );
  }
}