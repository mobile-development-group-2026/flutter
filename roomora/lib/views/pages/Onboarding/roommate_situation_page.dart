import 'package:flutter/material.dart';
import '../../../theme/colors.dart';
import '../../../viewmodels/Onboarding/onboarding_viewmodel.dart';
import '../../widgets/onboarding_shared_widgets.dart';

class RoommateSituationView extends StatelessWidget {
  final RoommateSituationViewModel vm;
  const RoommateSituationView({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('¿Cuál es tu', style: h1Black),
              const Text('situación?', style: h1Purple),
              const SizedBox(height: 4),
              const Text(
                'Elegí la que mejor describe dónde estás ahora.',
                style: TextStyle(
                    fontSize: 14,
                    color: AppColors.neutral700,
                    fontFamily: 'Sora'),
              ),
              const SizedBox(height: 24),
              ...HousingSituation.values.map((option) {
                final selected = vm.situation == option;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => vm.setSituation(option),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? AppColors.purple400
                              : AppColors.neutral400,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: selected
                                  ? AppColors.purple500
                                  : Colors.transparent,
                              border: Border.all(
                                color: selected
                                    ? AppColors.purple500
                                    : AppColors.neutral400,
                                width: 2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: option == HousingSituation.havePlace
                                  ? AppColors.purple100
                                  : ExtraAppColors.yellow100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(option.icon,
                                  style: const TextStyle(fontSize: 18)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(option.title,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.neutral900,
                                        fontFamily: 'Sora')),
                                Text(option.subtitle,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.neutral600,
                                        fontFamily: 'Sora')),
                                const SizedBox(height: 6),
                                Text(option.description,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.neutral600,
                                        fontFamily: 'Sora')),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 14, color: AppColors.neutral600),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Podés cambiar esto en cualquier momento desde tu perfil.',
                      style: TextStyle(
                          fontSize: 13,
                          color: AppColors.neutral600,
                          fontFamily: 'Sora'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}