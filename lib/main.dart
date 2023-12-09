import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:ui';

void main() => runApp(
  MaterialApp(
    home: AnimatedPathDemo(),
  ),
);

class AnimatedPathPainter extends CustomPainter {
  final Animation<double> _animation;

  AnimatedPathPainter(this._animation) : super(repaint: _animation);

  // Function to create the initial path
  Path _createAnyPath(Size size) {
    return Path()
      ..moveTo(size.height / 4, size.height / 4)
      ..lineTo(size.height, size.width / 2)
      ..lineTo(size.height / 2, size.width)
      ..quadraticBezierTo(size.height / 2, 100, size.width, size.height);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Retrieve the current animation percentage
    final animationPercent = _animation.value;

    // Create animated paths based on the current animation percentage
    final paths = createAnimatedPath(_createAnyPath(size), animationPercent);

    // Set up paint properties
    final Paint paint = Paint();
    paint.color = Colors.amberAccent;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 10.0;

    // Draw the start and end paths on the canvas
    canvas.drawPath(paths.startPath, paint);
    canvas.drawPath(paths.endPath, paint);
  }

  // Function to create animated paths based on the animation percentage
  AnimatedPaths createAnimatedPath(Path originalPath, double animationPercent) {
    // Calculate the total length of the original path
    final totalLength = originalPath
        .computeMetrics()
        .fold(0.0, (double prev, PathMetric metric) => prev + metric.length);

    // Calculate the current length based on the animation percentage
    final currentLength = totalLength * animationPercent;

    // Extract the animated paths
    return extractPaths(originalPath, currentLength < 50 ? 0 : currentLength - 50, currentLength);
  }

  // Function to extract animated paths within a specified length range
  AnimatedPaths extractPaths(Path originalPath, double startLength, double endLength) {
    var currentLength = 0.0;

    // Initialize paths for the start and end
    final startPath = Path();
    final endPath = Path();

    // Iterate through the metrics of the original path
    var metricsIterator = originalPath.computeMetrics().iterator;

    while (metricsIterator.moveNext()) {
      var metric = metricsIterator.current;
      var nextLength = currentLength + metric.length;

      // Check if the current segment is the last one within the specified range
      final isLastSegment = nextLength > endLength;
      if (isLastSegment) {
        // Extract and add the start and end segments to their respective paths
        final startSegment = metric.extractPath(startLength, endLength);
        final endSegment = metric.extractPath(startLength, endLength);

        startPath.addPath(startSegment, Offset.zero);
        endPath.addPath(endSegment, Offset.zero);

        break;
      } else {
        // There might be a more efficient way of extracting an entire path
        final pathSegment = metric.extractPath(0.0, metric.length);
        startPath.addPath(pathSegment, Offset.zero);
        endPath.addPath(pathSegment, Offset.zero);
      }

      currentLength = nextLength;
    }

    // Return the animated paths
    return AnimatedPaths(startPath, endPath);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// Class to represent the start and end paths
class AnimatedPaths {
  final Path startPath;
  final Path endPath;

  AnimatedPaths(this.startPath, this.endPath);
}

class AnimatedPathDemo extends StatefulWidget {
  @override
  _AnimatedPathDemoState createState() => _AnimatedPathDemoState();
}

class _AnimatedPathDemoState extends State<AnimatedPathDemo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Function to start the animation
  void _startAnimation() {
    _controller.stop();
    _controller.reset();
    _controller.repeat(
      period: const Duration(milliseconds: 500),
      reverse: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animated Paint')),
      body: SizedBox(
        height: 300,
        width: 300,
        child: CustomPaint(
          painter: AnimatedPathPainter(_controller),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startAnimation,
        child: Icon(Icons.play_arrow),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller
    _controller = AnimationController(
      vsync: this,
    );
  }

  @override
  void dispose() {
    // Dispose of the animation controller
    _controller.dispose();
    super.dispose();
  }
}
