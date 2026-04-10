import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Православний хрест ПЦУ — замінює зірки (Icons.auto_awesome) скрізь в додатку.
/// Використовує орнамент, натхненний логотипом ПЦУ.
class OrthodoxCrossWidget extends StatelessWidget {
  final double size;
  final Color color;
  final bool withGlow;

  const OrthodoxCrossWidget({
    super.key,
    this.size = 40,
    this.color = AppTheme.goldAccent,
    this.withGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/OCU_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      // Тільки якщо колір не золото (основний колір лого), 
      // ми можемо захотіти його тонувати (наприклад, для бордових акцентів)
      color: color == AppTheme.goldAccent ? null : color,
      colorBlendMode: color == AppTheme.goldAccent ? null : BlendMode.srcIn,
    );
  }
}

/// Розподільник між молитвами — хрест з орнаментальними лініями.
/// Замінює assets/images/b.png
class PrayerDividerCross extends StatelessWidget {
  const PrayerDividerCross({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ornamentLine(),
          const SizedBox(width: 12),
          OrthodoxCrossWidget(
            size: 28,
            color: AppTheme.ocuBurgundy.withOpacity(0.6),
          ),
          const SizedBox(width: 12),
          _ornamentLine(),
        ],
      ),
    );
  }

  Widget _ornamentLine() {
    return Row(
      children: List.generate(3, (i) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        width: i == 1 ? 20 : 10,
        height: 0.8,
        color: AppTheme.ocuBurgundy.withOpacity(0.35),
      )),
    );
  }
}

/// Хрест у кружечку — для аватара капелана в чаті
class ChaplainAvatarCross extends StatelessWidget {
  final double radius;

  const ChaplainAvatarCross({super.key, this.radius = 18});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.surfaceLight,
        border: Border.all(
          color: AppTheme.goldAccent.withOpacity(0.5),
          width: 0.5,
        ),
      ),
      child: Center(
        child: OrthodoxCrossWidget(
          size: radius * 1.1,
          color: AppTheme.ocuBurgundy,
        ),
      ),
    );
  }
}

class _OrthodoxCrossPainter extends CustomPainter {
  final Color color;
  final bool withGlow;

  _OrthodoxCrossPainter({required this.color, required this.withGlow});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    // Пропорції православного хреста
    final armW = w * 0.18;  // Товщина вертикалі
    final cx = w / 2;
    final cy = h / 2;

    // Вертикальна балка
    final vertRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: armW, height: h),
      Radius.circular(armW * 0.3),
    );
    canvas.drawRRect(vertRect, paint);

    // Горизонтальна балка (на 1/3 від верху)
    final horizRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, h * 0.35),
        width: w,
        height: armW,
      ),
      Radius.circular(armW * 0.3),
    );
    canvas.drawRRect(horizRect, paint);

    // Косопоперечина (праволіворуч, нижня третина) — 8-кінцевий хрест
    final diagPaint = Paint()
      ..color = color
      ..strokeWidth = armW * 0.7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final diagY = cy + h * 0.18;
    final diagSpan = w * 0.38;
    canvas.drawLine(
      Offset(cx - diagSpan, diagY - diagSpan * 0.25),
      Offset(cx + diagSpan, diagY + diagSpan * 0.25),
      diagPaint,
    );
  }

  @override
  bool shouldRepaint(_OrthodoxCrossPainter old) =>
      old.color != color || old.withGlow != withGlow;
}
