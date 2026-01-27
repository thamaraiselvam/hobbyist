import 'package:flutter/material.dart';
import 'dart:math' as math;

class TadaAnimation extends StatefulWidget {
  final Widget child;
  final bool animate;

  const TadaAnimation({
    Key? key,
    required this.child,
    required this.animate,
  }) : super(key: key);

  @override
  State<TadaAnimation> createState() => _TadaAnimationState();
}

class _TadaAnimationState extends State<TadaAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.1),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 0.9),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.9, end: 1.1),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 0.9),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.9, end: 1.0),
        weight: 10,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -0.1),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.1, end: 0.1),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.1, end: -0.1),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.1, end: 0.1),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.1, end: 0),
        weight: 10,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(TadaAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !oldWidget.animate) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

class PartyPopperAnimation extends StatefulWidget {
  final Offset position;

  const PartyPopperAnimation({
    Key? key,
    required this.position,
  }) : super(key: key);

  @override
  State<PartyPopperAnimation> createState() => _PartyPopperAnimationState();
}

class _PartyPopperAnimationState extends State<PartyPopperAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Confetti> confettiList = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Generate confetti particles
    final random = math.Random();
    for (int i = 0; i < 15; i++) {
      confettiList.add(
        Confetti(
          color: _getRandomColor(random),
          angle: random.nextDouble() * 2 * math.pi,
          speed: 50 + random.nextDouble() * 100,
          size: 4 + random.nextDouble() * 6,
        ),
      );
    }

    _controller.forward();
  }

  Color _getRandomColor(math.Random random) {
    final colors = [
      const Color(0xFF6C3FFF),
      const Color(0xFF8B5CF6),
      const Color(0xFFFF6B35),
      const Color(0xFF00D9A0),
      const Color(0xFFFFCC00),
      const Color(0xFFFF2D55),
    ];
    return colors[random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ConfettiPainter(
            confettiList: confettiList,
            progress: _controller.value,
            origin: widget.position,
          ),
        );
      },
    );
  }
}

class Confetti {
  final Color color;
  final double angle;
  final double speed;
  final double size;

  Confetti({
    required this.color,
    required this.angle,
    required this.speed,
    required this.size,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<Confetti> confettiList;
  final double progress;
  final Offset origin;

  ConfettiPainter({
    required this.confettiList,
    required this.progress,
    required this.origin,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var confetti in confettiList) {
      final distance = confetti.speed * progress;
      final x = origin.dx + math.cos(confetti.angle) * distance;
      final y = origin.dy + math.sin(confetti.angle) * distance + (progress * progress * 100); // Gravity effect

      final opacity = (1 - progress).clamp(0.0, 1.0);
      paint.color = confetti.color.withOpacity(opacity);

      canvas.drawCircle(
        Offset(x, y),
        confetti.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}
