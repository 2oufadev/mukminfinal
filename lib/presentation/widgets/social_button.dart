import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocialButton extends StatelessWidget {
  final Color? color;
  final String svg;
  final Function() onPressed;
  const SocialButton(
      {this.color, Key? key, required this.onPressed, required this.svg})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(100.0),
      color: color,
      child: IconButton(
        splashRadius: 25.0,
        icon: SvgPicture.asset('assets/$svg.svg'),
        onPressed: onPressed,
      ),
    );
  }
}
