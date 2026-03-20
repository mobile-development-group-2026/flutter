import 'package:flutter/material.dart';
import '/../theme/colors.dart';

class LoginBackground extends StatelessWidget {
  final Widget child;

  const LoginBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Capa base - color sólido oscuro
        Container(
          color: AppColors.purple900,
        ),

        // Gradiente radial principal - desde arriba
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, -0.6),
              radius: 1.1,
              colors: [
                AppColors.purple700.withValues(alpha: 0.9),
                AppColors.purple900.withValues(alpha: 0.0),
              ],
              stops: [0.0, 1.0],
            ),
          ),
        ),

        // Gradiente radial secundario - sutil en el centro
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, 0.1),
              radius: 0.7,
              colors: [
                AppColors.purple800.withValues(alpha: 0.5),
                Colors.transparent,
              ],
              stops: [0.0, 1.0],
            ),
          ),
        ),

        // Tu contenido va aquí encima
        child,
      ],
    );
  }
}