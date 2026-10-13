import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BrandMark extends StatelessWidget {
  final double size;
  final bool dark;

  const BrandMark({super.key, this.size = 64, this.dark = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BrandMarkPainter(dark: dark),
      ),
    );
  }
}

class _BrandMarkPainter extends CustomPainter {
  final bool dark;

  const _BrandMarkPainter({required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width * .23;
    final paper = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * .16, size.height * .08, size.width * .58, size.height * .72),
      Radius.circular(radius),
    );

    final shadowPaint = Paint()..color = Colors.black.withOpacity(.10);
    canvas.drawRRect(paper.shift(Offset(0, size.height * .035)), shadowPaint);

    final paperPaint = Paint()..color = dark ? const Color(0xFFF3F7F5) : Colors.white;
    canvas.drawRRect(paper, paperPaint);

    final foldPath = Path()
      ..moveTo(size.width * .58, size.height * .08)
      ..lineTo(size.width * .74, size.height * .24)
      ..lineTo(size.width * .58, size.height * .24)
      ..close();
    canvas.drawPath(foldPath, Paint()..color = AppColors.mint);

    final linePaint = Paint()
      ..color = AppColors.primary.withOpacity(.52)
      ..strokeWidth = size.width * .055
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(size.width * .28, size.height * .35), Offset(size.width * .58, size.height * .35), linePaint);
    canvas.drawLine(Offset(size.width * .28, size.height * .48), Offset(size.width * .52, size.height * .48), linePaint);

    final badgeCenter = Offset(size.width * .67, size.height * .64);
    canvas.drawCircle(badgeCenter, size.width * .23, Paint()..color = AppColors.primaryDark);
    canvas.drawCircle(badgeCenter, size.width * .195, Paint()..color = AppColors.primary);

    final checkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = size.width * .075;
    final checkPath = Path()
      ..moveTo(size.width * .56, size.height * .64)
      ..lineTo(size.width * .64, size.height * .72)
      ..lineTo(size.width * .79, size.height * .55);
    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant _BrandMarkPainter oldDelegate) => oldDelegate.dark != dark;
}

class DocumentIllustration extends StatelessWidget {
  final double height;

  const DocumentIllustration({super.key, this.height = 150});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 6,
            top: 24,
            child: Transform.rotate(
              angle: -.10,
              child: _MiniPaper(
                width: 90,
                height: 112,
                tint: AppColors.blueSoft,
                icon: Icons.travel_explore_outlined,
                accent: AppColors.blue,
              ),
            ),
          ),
          Positioned(
            right: 8,
            top: 30,
            child: Transform.rotate(
              angle: .10,
              child: _MiniPaper(
                width: 88,
                height: 108,
                tint: AppColors.amberSoft,
                icon: Icons.directions_car_outlined,
                accent: AppColors.amber,
              ),
            ),
          ),
          Positioned(
            top: 8,
            child: _MiniPaper(
              width: 102,
              height: 126,
              tint: Colors.white,
              icon: Icons.badge_outlined,
              accent: AppColors.primary,
              strong: true,
            ),
          ),
          Positioned(
            right: 22,
            bottom: 4,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: const [BoxShadow(color: Color(0x221B3D35), blurRadius: 14, offset: Offset(0, 6))],
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 26),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniPaper extends StatelessWidget {
  final double width;
  final double height;
  final Color tint;
  final Color accent;
  final IconData icon;
  final bool strong;

  const _MiniPaper({
    required this.width,
    required this.height,
    required this.tint,
    required this.accent,
    required this.icon,
    this.strong = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withOpacity(strong ? .16 : .10)),
        boxShadow: strong
            ? const [BoxShadow(color: Color(0x171B3D35), blurRadius: 18, offset: Offset(0, 8))]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: accent.withOpacity(.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: accent, size: 18),
          ),
          const Spacer(),
          Container(height: 6, width: width * .54, decoration: BoxDecoration(color: accent.withOpacity(.35), borderRadius: BorderRadius.circular(99))),
          const SizedBox(height: 7),
          Container(height: 5, width: width * .36, decoration: BoxDecoration(color: accent.withOpacity(.20), borderRadius: BorderRadius.circular(99))),
        ],
      ),
    );
  }
}
