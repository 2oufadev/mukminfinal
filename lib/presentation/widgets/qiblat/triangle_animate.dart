import 'package:flutter/material.dart';

class Triangle extends StatelessWidget {
  final bool direction;
  const Triangle({Key? key, required this.direction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: TrianglePainter(
            strokeColor: Colors.white,
            strokeWidth: 2,
            paintingStyle: PaintingStyle.fill,
            direction: direction),
        child: Container(
          height: 180,
          width: 200,
        ));
  }
}

class TrianglePainter extends CustomPainter {
  final bool direction;
  final Color strokeColor;
  final PaintingStyle paintingStyle;
  final double strokeWidth;

  TrianglePainter(
      {this.strokeColor = Colors.black,
      this.strokeWidth = 3,
      this.paintingStyle = PaintingStyle.stroke,
      required this.direction});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = paintingStyle;

    canvas.drawPath(getTrianglePath(size.width, size.height), paint);
  }

  Path getTrianglePath(double x, double y) {
    return direction
        ? (Path()
          ..moveTo(0, 0)
          ..lineTo(x, y / 2)
          ..lineTo(0, y)
          ..lineTo(0, 0))
        : (Path()
          ..moveTo(x, 0)
          ..lineTo(0, y / 2)
          ..lineTo(x, y)
          ..lineTo(x, 0));
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.paintingStyle != paintingStyle ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
