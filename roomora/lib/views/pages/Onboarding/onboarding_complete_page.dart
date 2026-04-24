import 'package:flutter/material.dart';
import '../../../theme/colors.dart';
import '../../widgets/onboarding_shared_widgets.dart';

class OnboardingCompleteView extends StatefulWidget {
  final String firstName;
  final String role;
  final VoidCallback onContinue;

  const OnboardingCompleteView({
    super.key,
    required this.firstName,
    required this.role,
    required this.onContinue,
  });

  @override
  State<OnboardingCompleteView> createState() => _OnboardingCompleteViewState();
}

class _OnboardingCompleteViewState extends State<OnboardingCompleteView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  bool get isStudent => widget.role == 'student';

  List<Map<String, dynamic>> get perks => isStudent
      ? [
          {'icon': Icons.verified_user, 'color': AppColors.purple500, 'bg': AppColors.purple100,
           'title': 'Badge verificado en tu perfil', 'sub': 'Los demás saben que sos un estudiante real'},
          {'icon': Icons.home, 'color': ExtraAppColors.yellow500, 'bg': ExtraAppColors.yellow100,
           'title': 'Acceso a listings exclusivos', 'sub': 'Landlords que solo alquilan a estudiantes'},
          {'icon': Icons.people, 'color': AppColors.purple500, 'bg': AppColors.purple100,
           'title': 'Matching de roommates', 'sub': 'Encontrá personas que se adapten a tu estilo'},
        ]
      : [
          {'icon': Icons.verified_user, 'color': AppColors.purple500, 'bg': AppColors.purple100,
           'title': 'Badge de landlord verificado', 'sub': 'Los estudiantes confían en tus listings'},
          {'icon': Icons.list_alt, 'color': ExtraAppColors.yellow500, 'bg': ExtraAppColors.yellow100,
           'title': 'Publicá listings ilimitados', 'sub': 'Llegá a estudiantes verificados'},
          {'icon': Icons.people, 'color': AppColors.purple500, 'bg': AppColors.purple100,
           'title': 'Herramientas de screening', 'sub': 'Encontrá inquilinos confiables'},
        ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    Future.delayed(const Duration(milliseconds: 200), () => _controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(width: 160, height: 160,
                          decoration: BoxDecoration(shape: BoxShape.circle,
                              color: ExtraAppColors.green100.withOpacity(0.3))),
                      Container(width: 120, height: 120,
                          decoration: BoxDecoration(shape: BoxShape.circle,
                              color: ExtraAppColors.green100.withOpacity(0.5))),
                      Container(width: 88, height: 88,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: ExtraAppColors.green200),
                          child: const Icon(Icons.check,
                              color: Colors.white, size: 36)),
                      Positioned(
                        right: 36, bottom: 36,
                        child: Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                              color: AppColors.purple500,
                              borderRadius: BorderRadius.circular(8)),
                          child: Icon(
                            isStudent ? Icons.school : Icons.home,
                            color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Estás verificado,',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700,
                          color: AppColors.neutral900, fontFamily: 'Sora')),
                  Text('${widget.firstName} 🎉',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700,
                          color: AppColors.purple500, fontFamily: 'Sora')),
                  const SizedBox(height: 6),
                  Text('Tu estado de ${isStudent ? "estudiante" : "propietario"} fue confirmado.',
                      style: const TextStyle(fontSize: 14, color: AppColors.neutral600,
                          fontFamily: 'Sora')),
                  const Text('Bienvenido a Roomora.',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                          color: AppColors.neutral900, fontFamily: 'Sora')),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.neutral300),
                      boxShadow: [BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('DESBLOQUEADO PARA VOS',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                                color: AppColors.neutral500, letterSpacing: 0.8,
                                fontFamily: 'Sora')),
                        const SizedBox(height: 12),
                        ...perks.map((p) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(children: [
                            Container(width: 40, height: 40,
                              decoration: BoxDecoration(
                                  color: p['bg'] as Color,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Icon(p['icon'] as IconData,
                                  color: p['color'] as Color, size: 18)),
                            const SizedBox(width: 12),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p['title'] as String,
                                    style: const TextStyle(fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.neutral900,
                                        fontFamily: 'Sora')),
                                Text(p['sub'] as String,
                                    style: const TextStyle(fontSize: 11,
                                        color: AppColors.neutral600,
                                        fontFamily: 'Sora')),
                              ],
                            )),
                            const Icon(Icons.check_circle,
                                color: ExtraAppColors.green400, size: 20),
                          ]),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.purple500,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        isStudent ? 'Buscar roommate  →' : 'Publicar listing  →',
                        style: const TextStyle(color: Colors.white,
                            fontSize: 16, fontWeight: FontWeight.w600,
                            fontFamily: 'Sora'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}