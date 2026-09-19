import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BluetoothRadar extends StatefulWidget {
  final bool isScanning;

  const BluetoothRadar({super.key, required this.isScanning});

  @override
  State<BluetoothRadar> createState() => _BluetoothRadarState();
}

class _BluetoothRadarState extends State<BluetoothRadar> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    if (widget.isScanning) {
      _pulseController.repeat();
      _spinController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant BluetoothRadar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning && !oldWidget.isScanning) {
      _pulseController.repeat();
      _spinController.repeat();
    } else if (!widget.isScanning && oldWidget.isScanning) {
      _pulseController.stop();
      _pulseController.reset();
      _spinController.stop();
      _spinController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return CustomPaint(
          painter: _PulsePainter(
            progress: _pulseController.value,
            color: context.colors.primary,
            isScanning: widget.isScanning,
          ),
          child: SizedBox(
            width: 240,
            height: 240,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: context.colors.primary,
                      shape: BoxShape.circle,
                      boxShadow: widget.isScanning
                          ? [
                              BoxShadow(
                                color: context.colors.primary.withOpacity(0.6),
                                blurRadius: 15,
                                spreadRadius: 2,
                              )
                            ]
                          : [],
                    ),
                    child: Icon(
                      Icons.print,
                      color: context.colors.onPrimary,
                      size: 32,
                    ),
                  ),
                  if (widget.isScanning)
                    RotationTransition(
                      turns: _spinController,
                      child: SizedBox(
                        width: 90,
                        height: 90,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(context.colors.primary.withOpacity(0.5)),
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PulsePainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isScanning;

  _PulsePainter({required this.progress, required this.color, required this.isScanning});

  @override
  void paint(Canvas canvas, Size size) {
    if (!isScanning) return;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    for (int i = 0; i < 3; i++) {
      // Offset the progress for each ripple
      final currentProgress = (progress + (i * 0.33)) % 1.0;
      final radius = maxRadius * currentProgress;
      
      // Opacity fades out as it expands
      final opacity = (1.0 - currentProgress).clamp(0.0, 1.0);

      // We use a fill paint for a ripple effect
      final paint = Paint()
        ..color = color.withOpacity(opacity * 0.3)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius, paint);
      
      // Add a subtle border to the ripple
      final strokePaint = Paint()
        ..color = color.withOpacity(opacity * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
        
      canvas.drawCircle(center, radius, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PulsePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isScanning != isScanning;
  }
}
