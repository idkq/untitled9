import 'package:flutter/material.dart';

class ElbowLinePainter extends CustomPainter {
  final Offset startPoint;
  final Offset endPoint;
  final double radius;

  ElbowLinePainter({required this.startPoint, required this.endPoint, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    var point1 = startPoint;
    var point2 = endPoint;
    var turn = 25.0 * radius;
    var inverseX = point2.dx < point1.dx;
    var inverseY = point2.dy < point1.dy;

    if (inverseX && inverseY) {
      point1 = endPoint;
      point2 = startPoint;
      inverseX = false;
      inverseY = false;
    }

    Path path = Path();
    path.moveTo(point1.dx, point1.dy);
    path.lineTo(((point2.dx - point1.dx) / 2).abs() - (inverseX ? -turn : turn), point1.dy);
    path.arcToPoint(
      Offset(((point2.dx - point1.dx) / 2).abs(), point1.dy + (inverseY ? -turn : turn)),
      radius: Radius.circular(30 * radius),
      clockwise: !inverseX && !inverseY,
    );
    path.lineTo(((point2.dx - point1.dx) / 2).abs(), point2.dy - (inverseY ? -turn : turn));
    path.arcToPoint(
      Offset(((point2.dx - point1.dx) / 2).abs() + (inverseX ? -turn : turn), point2.dy),
      radius: Radius.circular(30 * radius),
      clockwise: inverseX || inverseY,
    );
    path.lineTo(point2.dx, point2.dy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: Text('Elbow Line Demo')),
      body: Container(
        color: Colors.grey,
        width: 300,
        height: 300,
        child: CustomPaint(
          painter: ElbowLinePainter(
            startPoint: Offset(30, 300),
            endPoint: Offset(300, 30),
            radius: 1,
          ),
          child: Container(),
        ),
      ),
    ),
  ));
}
