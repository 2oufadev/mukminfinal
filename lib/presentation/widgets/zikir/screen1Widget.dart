import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class Screen1Widget extends StatefulWidget {
  int? count, maximum;
  Function? onTap;
  LinearGradient linearGradient;

  Screen1Widget(
      {this.count = 0, this.maximum, this.onTap, required this.linearGradient});

  @override
  _Screen1WidgetState createState() => _Screen1WidgetState();
}

class _Screen1WidgetState extends State<Screen1Widget> {
  Duration duration = const Duration(milliseconds: 500);
  double deltaX = 2;
  Curve curve = Curves.bounceOut;
  double shake(double animation) =>
      2 * (0.5 - (0.5 - curve.transform(animation)).abs());

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280.w,
      height: 280.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Container(
          //   width: _size.width * 0.7,
          //   height: _size.width * 0.7,
          //   child: CircularProgressIndicator(
          //     value: 0.8,
          //     strokeWidth: 10,
          //     valueColor:
          //         AlwaysStoppedAnimation<Color>(Color(0xffFC6767)),
          //     backgroundColor: Color(0xff555555),
          //   ),
          // ),

          SfRadialGauge(
            axes: <RadialAxis>[
              RadialAxis(
                minimum: 0,
                maximum: widget.maximum!.toDouble(),
                startAngle: 140,
                endAngle: 140,
                showTicks: false,
                axisLineStyle: AxisLineStyle(
                  thickness: 0.1,
                  color: const Color(0xff555555),
                  thicknessUnit: GaugeSizeUnit.factor,
                  cornerStyle: CornerStyle.startCurve,
                ),
                pointers: <GaugePointer>[
                  RangePointer(
                    value: widget.count!.toDouble(),
                    width: 0.1,
                    sizeUnit: GaugeSizeUnit.factor,
                    cornerStyle: CornerStyle.startCurve,
                    gradient: SweepGradient(
                      colors: <Color>[
                        widget.linearGradient.colors.first,
                        widget.linearGradient.colors.last,
                      ],
                    ),
                  ),
                  MarkerPointer(
                    value: widget.count!.toDouble(),
                    markerWidth: 15,
                    markerHeight: 15,
                    markerType: MarkerType.circle,
                    color: Colors.white,
                  )
                ],
              )
            ],
          ),
          TweenAnimationBuilder<double>(
            key: UniqueKey(),
            tween: Tween(begin: 0.0, end: 1.0),
            duration: duration,
            builder: (context, animation, child) => Transform.translate(
              offset: Offset(deltaX * shake(animation), 0),
              child: Container(
                width: 200.w,
                height: 200.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: widget.linearGradient,
                ),
                child: Center(
                  child: Text(
                    "${widget.count}",
                    style: TextStyle(
                        fontFamily: "digital",
                        fontSize: 64.sp,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
