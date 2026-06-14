import 'dart:math' as math;
import 'package:flutter/material.dart';

/// The visual state of a stepper step node
enum StepperStepState { completed, active, inactive, failed }

/// Data model representing a step in the stepper
class StepperStep {
  final String title;
  final String subtitle;
  final StepperStepState state;

  const StepperStep({
    required this.title,
    required this.subtitle,
    required this.state,
  });
}

/// A highly customizable, premium Vertical Stepper widget
class VerticalStepper extends StatelessWidget {
  final List<StepperStep> steps;
  final double nodeSize;
  final double activeDashedSize;
  final double lineWidth;
  final double stepHeight;
  final Color activeDashedBorderColor;
  final Color inactiveNodeColor;
  final Color inactiveDotColor;
  final Color failedBorderColor;
  final Color completedLineColor;
  final Color inactiveLineColor;
  final LinearGradient? goldGradient;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  const VerticalStepper({
    super.key,
    required this.steps,
    this.nodeSize = 36.0,
    this.activeDashedSize = 48.0,
    this.lineWidth = 2.0,
    this.stepHeight = 88.0,
    this.activeDashedBorderColor = const Color(0xFFC98C28),
    this.inactiveNodeColor = const Color(0xFF2A2A2A),
    this.inactiveDotColor = const Color(0xFF8E8E93),
    this.failedBorderColor = const Color(0xFFFF453A),
    this.completedLineColor = const Color(0xFFC98C28),
    this.inactiveLineColor = const Color(0xFF1E2022),
    this.goldGradient,
    this.titleStyle,
    this.subtitleStyle,
  });

  @override
  Widget build(BuildContext context) {
    // Default premium gold gradient matching user specifications
    final defaultGradient =
        goldGradient ??
        LinearGradient(
          colors: const [
            Color(0xFFAF7413),
            Color(0xFFC98C28),
            Color(0xFFE2B744),
            Color(0xFFFFED81),
            Color(0xFFE1C24E),
            Color(0xFFA06008),
          ],
          stops: const [0.0477, 0.1933, 0.3893, 0.5054, 0.6210, 0.9074],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;

        // A line leading out of this step is gold if the step is completed.
        final bool isLineGold =
            !isLast && step.state == StepperStepState.completed;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stepper vertical line and node container
            SizedBox(
              width: activeDashedSize,
              height: isLast ? activeDashedSize : stepHeight,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Bottom connector line
                  if (!isLast)
                    Positioned(
                      top: activeDashedSize / 2,
                      bottom: 0,
                      child: Container(
                        width: lineWidth,
                        color: isLineGold
                            ? completedLineColor
                            : inactiveLineColor,
                      ),
                    ),
                  // Top connector line (for continuous connection)
                  if (index > 0)
                    Positioned(
                      top: 0,
                      bottom: isLast
                          ? activeDashedSize / 2
                          : stepHeight - (activeDashedSize / 2),
                      child: Container(
                        width: lineWidth,
                        color:
                            steps[index - 1].state == StepperStepState.completed
                            ? completedLineColor
                            : inactiveLineColor,
                      ),
                    ),
                  // The Node
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: step.state == StepperStepState.active
                            ? 0.0
                            : (activeDashedSize - nodeSize) / 2,
                      ),
                      child: _buildNode(step, defaultGradient),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16.0),
            // Step text details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: (activeDashedSize - nodeSize) / 2 + 4.0),
                  _buildTitleWidget(step),
                  const SizedBox(height: 4.0),
                  Text(
                    step.subtitle,
                    style:
                        (subtitleStyle ??
                                const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 12.0,
                                ))
                            .copyWith(
                              color: step.state != StepperStepState.inactive
                                  ? (subtitleStyle?.color ?? Colors.white54)
                                  : (subtitleStyle?.color ?? Colors.white54)
                                        .withValues(alpha: 0.22),
                            ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildNode(StepperStep step, LinearGradient gradient) {
    switch (step.state) {
      case StepperStepState.completed:
        return Container(
          width: nodeSize,
          height: nodeSize,
          decoration: BoxDecoration(shape: BoxShape.circle, gradient: gradient),
          child: Center(
            child: Container(
              width: nodeSize * 0.6,
              height: nodeSize * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: CustomPaint(
                size: Size(nodeSize * 0.6, nodeSize * 0.6),
                painter: CheckmarkPainter(
                  color: Colors.black,
                  strokeWidth: 1.8,
                ),
              ),
            ),
          ),
        );
      case StepperStepState.active:
        return SizedBox(
          width: activeDashedSize,
          height: activeDashedSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer dashed border
              CustomPaint(
                size: Size(activeDashedSize, activeDashedSize),
                painter: DashedCirclePainter(
                  color: activeDashedBorderColor,
                  strokeWidth: 1.5,
                  dashesCount: 24,
                ),
              ),
              // Inner gold circle
              Container(
                width: nodeSize,
                height: nodeSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: gradient,
                ),
                child: Center(
                  child: Container(
                    width: nodeSize * 0.22,
                    height: nodeSize * 0.22,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      case StepperStepState.inactive:
        return Container(
          width: nodeSize,
          height: nodeSize,
          decoration: BoxDecoration(
            color: inactiveNodeColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: nodeSize * 0.22,
              height: nodeSize * 0.22,
              decoration: BoxDecoration(
                color: inactiveDotColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      case StepperStepState.failed:
        return Container(
          width: nodeSize,
          height: nodeSize,
          decoration: BoxDecoration(
            color: inactiveNodeColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: nodeSize * 0.6,
              height: nodeSize * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: failedBorderColor, width: 1.5),
              ),
              child: CustomPaint(
                size: Size(nodeSize * 0.6, nodeSize * 0.6),
                painter: CrossPainter(
                  color: failedBorderColor,
                  strokeWidth: 1.8,
                ),
              ),
            ),
          ),
        );
    }
  }

  Widget _buildTitleWidget(StepperStep step) {
    final baseStyle =
        (titleStyle ?? const TextStyle(fontFamily: 'Manrope', fontSize: 15.0))
            .copyWith(
              fontWeight: step.state != StepperStepState.inactive
                  ? FontWeight.w700
                  : FontWeight.w500,
              color: step.state != StepperStepState.inactive
                  ? (titleStyle?.color ?? Colors.white)
                  : (titleStyle?.color ?? Colors.white).withValues(alpha: 0.24),
            );

    if (step.title.contains("(Failed)")) {
      final parts = step.title.split("(Failed)");
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(text: parts[0], style: baseStyle),
            TextSpan(
              text: "(Failed)",
              style: baseStyle.copyWith(color: const Color(0xFFFF453A)),
            ),
            if (parts.length > 1) TextSpan(text: parts[1], style: baseStyle),
          ],
        ),
      );
    }

    return Text(step.title, style: baseStyle);
  }
}

/// Painter that draws a dashed circular border surrounding the active node
class DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int dashesCount;

  DashedCirclePainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.dashesCount = 24,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final double dashAngle = (2 * math.pi) / dashesCount;
    final double dashLengthAngle = dashAngle * 0.6; // 60% dash length, 40% gap

    for (int i = 0; i < dashesCount; i++) {
      final double startAngle = i * dashAngle;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(radius, radius), radius: radius),
        startAngle,
        dashLengthAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DashedCirclePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashesCount != dashesCount;
  }
}

/// Painter that draws a custom pixel-perfect checkmark inside nodes
class CheckmarkPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  CheckmarkPainter({required this.color, this.strokeWidth = 2.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.28, size.height * 0.5);
    path.lineTo(size.width * 0.45, size.height * 0.68);
    path.lineTo(size.width * 0.72, size.height * 0.35);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CheckmarkPainter oldDelegate) => false;
}

/// Painter that draws a custom pixel-perfect cross inside nodes for failed states
class CrossPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  CrossPainter({required this.color, this.strokeWidth = 2.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    canvas.drawLine(Offset(w * 0.3, h * 0.3), Offset(w * 0.7, h * 0.7), paint);
    canvas.drawLine(Offset(w * 0.7, h * 0.3), Offset(w * 0.3, h * 0.7), paint);
  }

  @override
  bool shouldRepaint(covariant CrossPainter oldDelegate) => false;
}
