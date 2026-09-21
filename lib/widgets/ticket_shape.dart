import 'package:flutter/material.dart';

class TicketShape extends CustomPainter {
  final Color color;

  TicketShape({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);

    // Borde superior dentado
    double currentX = 0;
    const double toothWidth = 10.0;
    const double toothHeight = 6.0;
    
    while (currentX < size.width) {
      currentX += toothWidth / 2;
      path.lineTo(currentX, toothHeight);
      currentX += toothWidth / 2;
      path.lineTo(currentX, 0);
    }

    path.lineTo(size.width, size.height);

    // Borde inferior dentado
    currentX = size.width;
    while (currentX > 0) {
      currentX -= toothWidth / 2;
      path.lineTo(currentX, size.height - toothHeight);
      currentX -= toothWidth / 2;
      path.lineTo(currentX, size.height);
    }

    path.lineTo(0, size.height);
    path.close();

    canvas.drawShadow(path, Colors.black, 4.0, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
