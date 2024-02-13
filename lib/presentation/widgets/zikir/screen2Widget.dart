import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mukim_app/resources/Imageresources.dart';
import 'package:spring_button/spring_button.dart';

class Screen2Widget extends StatefulWidget {
  int? count;
  Function? onTap, reset;
  LinearGradient? linearGradient;

  Screen2Widget(
      {this.count, this.onTap, this.reset, required this.linearGradient});

  @override
  _Screen2WidgetState createState() => _Screen2WidgetState();
}

class _Screen2WidgetState extends State<Screen2Widget> {
  Duration duration = const Duration(milliseconds: 500);
  double deltaX = 2;
  Curve curve = Curves.bounceOut;
  double shake(double animation) =>
      2 * (0.5 - (0.5 - curve.transform(animation)).abs());

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 244.w,
      height: 300.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 244.w,
            height: 300.h,
            padding: EdgeInsets.all(12.h),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  widget.linearGradient!.colors.first == Color(0xffEC008C)
                      ? ImageResource.bgCountDown
                      : widget.linearGradient!.colors.first == Color(0xff16A085)
                          ? ImageResource.bgCountDown2
                          : widget.linearGradient!.colors.first ==
                                  Color(0xff1EAAD7)
                              ? ImageResource.bgCountDown3
                              : ImageResource.bgCountDown,
                ),
              ),
            ),
            child: Image.asset(
              ImageResource.bgCountDown1,
            ),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: SpringButton(
                SpringButtonType.WithOpacity,
                Container(
                  width: 70.w,
                  height: 70.w,
                  padding: EdgeInsets.all(5),
                  clipBehavior: Clip.antiAlias,
                  margin: EdgeInsets.only(bottom: 44.h),
                  decoration: BoxDecoration(
                    color: Color(0xff4D4D4D),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    ImageResource.button,
                  ),
                ),
                useCache: true,
                key: UniqueKey(),
                alignment: Alignment.center,
                scaleCoefficient: 0.85,
                duration: 1000,
                onTap: () {
                  widget.onTap!();
                },
              )),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 20.w,
              height: 20.w,
              // padding: EdgeInsets.all(5),
              margin: EdgeInsets.only(right: 50.w),
              child: InkWell(
                highlightColor: Colors.yellow,
                onTap: () {
                  widget.reset!();
                },
                child: Ink(
                  child: Image.asset(
                    ImageResource.button,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              alignment: Alignment.centerRight,
              margin: EdgeInsets.only(top: 50.h),
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              width: 152.w,
              height: 64.h,
              decoration: BoxDecoration(
                color: widget.linearGradient!.colors.first == Color(0xffEC008C)
                    ? Color(0xff640048)
                    : widget.linearGradient!.colors.first == Color(0xff16A085)
                        ? Color(0xff006445)
                        : widget.linearGradient!.colors.first ==
                                Color(0xff1EAAD7)
                            ? Color(0xff004064)
                            : Color(0xff640048),
              ),
              child: RichText(
                text: TextSpan(
                  text: "${_checkCountLength()}",
                  children: [
                    TextSpan(
                      text: "${widget.count ?? "0"}",
                      style: TextStyle(
                        color: Color(
                          0xFFFFF06A,
                        ),
                      ),
                    )
                  ],
                  style: TextStyle(
                    fontFamily: "digital",
                    fontSize: 28,
                    // letterSpacing: 3,
                    color: Color(
                      0x50FFF06A,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  String _checkCountLength() {
    int size = widget.count.toString().length;
    String _s = "";
    for (int i = 4 - size; i > 0; i--) {
      _s += "0";
    }
    return _s;
  }
}
