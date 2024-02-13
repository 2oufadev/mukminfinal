import 'package:flutter/material.dart';

// import '../../../constants.dart';

class Ripple extends StatelessWidget {
  final double radius;

  const Ripple({
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double PaddingL = 32.0;
    return Positioned(
      left: screenWidth / 3 - radius,
      top: 8 * PaddingL - radius,
      child: Container(
        width: 2 * radius,
        height: 2 * radius,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xff1B1B1B),
        ),
      ),
    );
  }
}
