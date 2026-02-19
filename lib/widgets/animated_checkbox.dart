import 'package:flutter/material.dart';

class AnimatedCheckbox extends StatefulWidget {
  final bool isChecked;
  final VoidCallback? onTap; // Made nullable
  final Color color;
  final double size;

  const AnimatedCheckbox({
    super.key,
    required this.isChecked,
    required this.onTap,
    this.color = const Color(0xFF6C3FFF),
    this.size = 28.0,
  });

  @override
  State<AnimatedCheckbox> createState() => _AnimatedCheckboxState();
}

class _AnimatedCheckboxState extends State<AnimatedCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isChecked) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnimatedCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isChecked != oldWidget.isChecked) {
      if (widget.isChecked) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onTap != null;

    return GestureDetector(
      onTap: isEnabled ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.isChecked
                  ? widget.color.withValues(alpha: isEnabled ? 1.0 : 0.3)
                  : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.isChecked
                    ? widget.color.withValues(alpha: isEnabled ? 1.0 : 0.3)
                    : (isEnabled
                        ? const Color(0xFF4A4458)
                        : const Color(0xFF2A2738)),
                width: 2,
              ),
            ),
            child: widget.isChecked
                ? CustomPaint(
                    painter: CheckmarkPainter(
                      progress: _checkAnimation.value,
                      color: Colors.white.withValues(alpha: isEnabled ? 1.0 : 0.5),
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }
}

class CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;

  CheckmarkPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final p1 = Offset(size.width * 0.25, size.height * 0.5);
    final p2 = Offset(size.width * 0.45, size.height * 0.7);
    final p3 = Offset(size.width * 0.75, size.height * 0.3);

    if (progress < 0.5) {
      final t = progress * 2;
      path.moveTo(p1.dx, p1.dy);
      path.lineTo(
        p1.dx + (p2.dx - p1.dx) * t,
        p1.dy + (p2.dy - p1.dy) * t,
      );
    } else {
      final t = (progress - 0.5) * 2;
      path.moveTo(p1.dx, p1.dy);
      path.lineTo(p2.dx, p2.dy);
      path.lineTo(
        p2.dx + (p3.dx - p2.dx) * t,
        p2.dy + (p3.dy - p2.dy) * t,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
