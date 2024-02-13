import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rive/rive.dart' as rive;

class Screen4Widget extends StatefulWidget {
  rive.RiveAnimationController? controller;
  LinearGradient? linearGradient;
  Screen4Widget({this.controller, required this.linearGradient});

  @override
  _Screen4WidgetState createState() => _Screen4WidgetState();
}

class _Screen4WidgetState extends State<Screen4Widget> {
  Duration duration = const Duration(milliseconds: 500);
  double deltaX = 2;
  Curve curve = Curves.bounceOut;
  double shake(double animation) =>
      2 * (0.5 - (0.5 - curve.transform(animation)).abs());
  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(widget.linearGradient),
      width: double.infinity,
      height: 255.h,
      // color: Colors.red,
      child: widget.linearGradient!.colors.first == Color(0xffEC008C)
          ? rive.RiveAnimation.asset(
              'assets/animation/animation_1.riv',
              controllers: [widget.controller!],
            )
          : widget.linearGradient!.colors.first == Color(0xff16A085)
              ? rive.RiveAnimation.asset(
                  'assets/animation/animation_2.riv',
                  controllers: [widget.controller!],
                )
              : widget.linearGradient!.colors.first == Color(0xff1EAAD7)
                  ? rive.RiveAnimation.asset(
                      'assets/animation/animation_3.riv',
                      controllers: [widget.controller!],
                    )
                  : rive.RiveAnimation.asset(
                      'assets/animation/animation_1.riv',
                      controllers: [widget.controller!],
                    ),
      // child: rive.RiveAnimation.asset(
      //                   'assets/animation/animation_1.riv',
      //                   controllers: [_controller],
      //                 ),
    );
  }
}
