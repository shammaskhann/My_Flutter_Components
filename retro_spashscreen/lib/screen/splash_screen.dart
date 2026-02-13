import 'package:flutter/material.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _textController;
  late final AnimationController _typewriterController;
  late final AnimationController _drawingController;

  @override
  void initState() {
    super.initState();

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _typewriterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _drawingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Sequence: text slide in, then typewriter effect, then drawing effect
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        _textController.forward();
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _typewriterController.forward();
            Future.delayed(const Duration(milliseconds: 800), () {
              if (mounted) {
                _drawingController.forward();
              }
            });
          }
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 4400), () {
      // You can replace this with your actual navigation logic, e.g., using Navigator.pushReplacementNamed or a state management solution to trigger navigation after the splash screen.
      if (mounted) {
        //Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _typewriterController.dispose();
    _drawingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Subtle grid background
            CustomPaint(size: size, painter: GridPainter()),

            // Animated PCMartHQ name with drawing and typewriter effects
            AnimatedBuilder(
              animation: Listenable.merge([
                _textController,
                _typewriterController,
                _drawingController,
              ]),
              builder: (context, child) {
                final slide = 80 * (1 - _textController.value);
                final opacity = _textController.value;

                return Opacity(
                  opacity: opacity,
                  child: Transform.translate(
                    offset: Offset(0, slide),
                    child: CustomPaint(
                      size: const Size(300, 60),
                      painter: TypewriterTextPainter(
                        text: 'PCMartHQ',
                        typewriterProgress: _typewriterController.value,
                        drawingProgress: _drawingController.value,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Typewriter and drawing effect text painter
class TypewriterTextPainter extends CustomPainter {
  final String text;
  final double typewriterProgress;
  final double drawingProgress;

  TypewriterTextPainter({
    required this.text,
    required this.typewriterProgress,
    required this.drawingProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const textStyle = TextStyle(
      fontFamily: 'Dreadnought',
      fontSize: 36,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      letterSpacing: 2,
    );

    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Calculate how many characters to show based on typewriter progress
    final visibleChars = (text.length * typewriterProgress).floor();
    final visibleText = text.substring(0, visibleChars.clamp(0, text.length));

    // Variables for text positioning
    Offset? textOffset;
    TextPainter? visibleTextPainter;

    // Draw the visible text
    if (visibleText.isNotEmpty) {
      final visibleTextSpan = TextSpan(text: visibleText, style: textStyle);
      visibleTextPainter = TextPainter(
        text: visibleTextSpan,
        textDirection: TextDirection.ltr,
      );
      visibleTextPainter.layout();

      // Center the text
      textOffset = Offset(
        (size.width - visibleTextPainter.width) / 2,
        (size.height - visibleTextPainter.height) / 2,
      );

      // Draw the text
      visibleTextPainter!.paint(canvas, textOffset!);

      // Draw typewriter cursor if typing is in progress
      if (typewriterProgress < 1.0) {
        final cursorPaint = Paint()
          ..color = const Color(0xFF6C63FF)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;

        final cursorX = textOffset!.dx + visibleTextPainter!.width + 5;
        final cursorY = textOffset!.dy;
        final cursorHeight = visibleTextPainter!.height;

        // Animated blinking cursor
        final cursorOpacity = (math.sin(typewriterProgress * 20) + 1) / 2;
        cursorPaint.color = const Color(0xFF6C63FF).withOpacity(cursorOpacity);

        canvas.drawLine(
          Offset(cursorX, cursorY),
          Offset(cursorX, cursorY + cursorHeight),
          cursorPaint,
        );
      }
    }

    // Draw drawing effect (outline animation)
    if (drawingProgress > 0 &&
        textOffset != null &&
        visibleTextPainter != null) {
      final drawingPaint = Paint()
        ..color = const Color(0xFF00FFC6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;

      final drawingOpacity = drawingProgress;
      drawingPaint.color = const Color(0xFF00FFC6).withOpacity(drawingOpacity);

      // Draw outline around the text
      final outlinePath = Path();
      final textBounds = Rect.fromLTWH(
        textOffset!.dx - 10,
        textOffset!.dy - 5,
        visibleTextPainter!.width + 20,
        visibleTextPainter!.height + 10,
      );

      outlinePath.addRRect(
        RRect.fromRectAndRadius(textBounds, const Radius.circular(8)),
      );

      // Animate the drawing by using a dash pattern
      final dashLength = 20.0;
      final totalLength = (textBounds.width + textBounds.height) * 2;
      final drawnLength = totalLength * drawingProgress;

      final pathMetrics = outlinePath.computeMetrics().first;
      final path = Path();

      double currentLength = 0;
      bool drawSegment = true;

      for (double i = 0; i < pathMetrics.length; i += dashLength) {
        final end = math.min(i + dashLength, pathMetrics.length);
        if (currentLength < drawnLength) {
          if (drawSegment) {
            path.addPath(pathMetrics.extractPath(i, end), Offset.zero);
          }
          currentLength += end - i;
        }
        drawSegment = !drawSegment;
      }

      canvas.drawPath(path, drawingPaint);
    }
  }

  @override
  bool shouldRepaint(covariant TypewriterTextPainter oldDelegate) {
    return oldDelegate.text != text ||
        oldDelegate.typewriterProgress != typewriterProgress ||
        oldDelegate.drawingProgress != drawingProgress;
  }
}

// Subtle modern grid background
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..strokeWidth = 1;
    const gridSize = 32.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
