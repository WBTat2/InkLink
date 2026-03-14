import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

class TattooMachineProgress extends StatelessWidget {
  /// progress should be 0.0 -> 1.0
  final double progress;

  /// Height of the SVG widget
  final double height;

  const TattooMachineProgress({
    super.key,
    required this.progress,
    this.height = 90,
  });

  @override
  Widget build(BuildContext context) {
    final p = progress.clamp(0.0, 1.0);

    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // RED FILL (clipped, so it "fills" not "shrinks")
          ClipRect(
            clipper: _WidthClipper(fraction: p),
            child: SvgPicture.asset(
              'assets/icons/tattoo_machine_solid.svg',
              height: height,
              fit: BoxFit.contain,
              colorFilter: const ColorFilter.mode(
                AppTheme.inkRed,
                BlendMode.srcIn,
              ),
            ),
          ),

          // OUTLINE ON TOP
          SvgPicture.asset(
            'assets/icons/tattoo_machine_outline.svg',
            height: height,
            fit: BoxFit.contain,
            colorFilter: const ColorFilter.mode(
              Colors.white70,
              BlendMode.srcIn,
            ),
          ),
        ],
      ),
    );
  }
}

class _WidthClipper extends CustomClipper<Rect> {
  final double fraction;
  _WidthClipper({required this.fraction});

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * fraction, size.height);
  }

  @override
  bool shouldReclip(_WidthClipper oldClipper) {
    return oldClipper.fraction != fraction;
  }
}