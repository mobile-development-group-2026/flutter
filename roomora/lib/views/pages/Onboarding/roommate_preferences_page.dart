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
              const Text('Tu roommate', style: h1Black),
              const Text('ideal', style: h1Purple),
              const SizedBox(height: 4),
              const Text(
                'Ayudanos a encontrar a alguien con quien realmente quieras vivir.',
                style: TextStyle(
                    fontSize: 14,
                    color: AppColors.neutral700,
                    fontFamily: 'Sora'),
              ),
              const SizedBox(height: 24),
              PrefSection(icon: Icons.people_outline, title: 'LUGARES DISPONIBLES', child:
                Row(children: List.generate(4, (i) {
                  final n = i + 1;
                  final sel = vm.spotsAvailable == n;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CircleChip(label: '$n', selected: sel,
                        onTap: () => vm.setSpotsAvailable(n)),
                  );
                }))),
              PrefSection(icon: Icons.calendar_today_outlined, title: 'MES DE MUDANZA', child:
                Wrap(spacing: 8, runSpacing: 8,
                  children: ['Ene','Feb','Mar','Abr','May','Jun',
                              'Jul','Ago','Sep','Oct','Nov','Dic']
                      .map((m) => CustomChip(label: m,
                            selected: vm.moveInMonth == m,
                            onTap: () => vm.setMoveInMonth(vm.moveInMonth == m ? null : m)))
                      .toList())),
              PrefSection(icon: Icons.person_outline, title: 'PREFERENCIA DE GÉNERO', child:
                Wrap(spacing: 8, runSpacing: 8,
                  children: [
                    {'label': 'Sin preferencia', 'value': 0},
                    {'label': 'Como yo', 'value': 1},
                    {'label': 'Solo mujeres', 'value': 2},
                    {'label': 'Solo hombres', 'value': 3},
                  ].map((o) => CustomChip(
                        label: o['label'] as String,
                        selected: vm.genderPreference == o['value'],
                        onTap: () => vm.setGenderPreference(
                            vm.genderPreference == o['value'] ? null : o['value'] as int)))
                      .toList())),
              PrefSection(icon: Icons.nightlight_round, title: 'HORARIO DE SUEÑO', child:
                Row(children: [
                  {'emoji': '🌅', 'label': 'Madrugador', 'sub': 'Antes de 7am', 'value': 0},
                  {'emoji': '🌙', 'label': 'Noctámbulo', 'sub': 'Después medianoche', 'value': 1},
                  {'emoji': '🎲', 'label': 'Sin pref.', 'sub': 'Cualquiera', 'value': 2},
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
                  {'emoji': '✨', 'label': 'Muy limpio', 'sub': 'Siempre ordenado', 'value': 0},
                  {'emoji': '🧹', 'label': 'Moderado', 'sub': 'Suficientemente limpio', 'value': 1},
                  {'emoji': '😌', 'label': 'Relajado', 'sub': 'Vivido', 'value': 2},
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
              PrefSection(icon: Icons.favorite_outline, title: 'ESTILO DE VIDA', child:
                Wrap(spacing: 8, runSpacing: 8,
                  children: [
                    {'emoji': '🚭', 'label': 'No fumador'},
                    {'emoji': '🐾', 'label': 'Pet-friendly'},
                    {'emoji': '💃', 'label': 'Sin fiestas'},
                    {'emoji': '📚', 'label': 'Estudio'},
                    {'emoji': '🍳', 'label': 'Cocina seguido'},
                    {'emoji': '🫂', 'label': 'Pocas visitas'},
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