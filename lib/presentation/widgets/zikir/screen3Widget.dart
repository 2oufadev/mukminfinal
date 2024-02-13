import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Screen3Widget extends StatefulWidget {
  int count;
  LinearGradient linearGradient;
  Screen3Widget({this.count = 0, required this.linearGradient});

  @override
  _Screen3WidgetState createState() => _Screen3WidgetState();
}

class _Screen3WidgetState extends State<Screen3Widget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // width: _size.width * 0.7,
      height: 125.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70.w,
            height: 110.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.linearGradient.colors.first == Color(0xffEC008C)
                  ? Color(0xff000000)
                  : widget.linearGradient.colors.first == Color(0xff16A085)
                      ? Color(0xffffffff)
                      : widget.linearGradient.colors.first == Color(0xff1EAAD7)
                          ? Color(0xff091B4A)
                          : Color(0xff000000),
            ),
            child: Text(
              "${_getCount(index: 0)}",
              style: TextStyle(
                fontSize: 64.sp,
                color: widget.linearGradient.colors.first == Color(0xffEC008C)
                    ? Color(0xffFFFFFF)
                    : widget.linearGradient.colors.first == Color(0xff16A085)
                        ? Color(0xff000000)
                        : widget.linearGradient.colors.first ==
                                Color(0xff1EAAD7)
                            ? Color(0xff3CE3F2)
                            : Color(0xffFFFFFF),
                fontFamily: "digital",
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Container(
            width: 70.w,
            height: 110.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.linearGradient.colors.first == Color(0xffEC008C)
                  ? Color(0xff000000)
                  : widget.linearGradient.colors.first == Color(0xff16A085)
                      ? Color(0xffffffff)
                      : widget.linearGradient.colors.first == Color(0xff1EAAD7)
                          ? Color(0xff091B4A)
                          : Color(0xff000000),
            ),
            child: Text(
              "${_getCount(index: 1)}",
              style: TextStyle(
                fontSize: 64.sp,
                color: widget.linearGradient.colors.first == Color(0xffEC008C)
                    ? Color(0xffFFFFFF)
                    : widget.linearGradient.colors.first == Color(0xff16A085)
                        ? Color(0xff000000)
                        : widget.linearGradient.colors.first ==
                                Color(0xff1EAAD7)
                            ? Color(0xff3CE3F2)
                            : Color(0xffFFFFFF),
                fontFamily: "digital",
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Container(
            width: 70.w,
            height: 110.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.linearGradient.colors.first == Color(0xffEC008C)
                  ? Color(0xff000000)
                  : widget.linearGradient.colors.first == Color(0xff16A085)
                      ? Color(0xffffffff)
                      : widget.linearGradient.colors.first == Color(0xff1EAAD7)
                          ? Color(0xff091B4A)
                          : Color(0xff000000),
            ),
            child: Text(
              "${_getCount(index: 2)}",
              style: TextStyle(
                fontSize: 64.sp,
                color: widget.linearGradient.colors.first == Color(0xffEC008C)
                    ? Color(0xffFFFFFF)
                    : widget.linearGradient.colors.first == Color(0xff16A085)
                        ? Color(0xff000000)
                        : widget.linearGradient.colors.first ==
                                Color(0xff1EAAD7)
                            ? Color(0xff3CE3F2)
                            : Color(0xffFFFFFF),
                fontFamily: "digital",
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Container(
            width: 70.w,
            height: 110.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.linearGradient.colors.first == Color(0xffEC008C)
                  ? Color(0xff000000)
                  : widget.linearGradient.colors.first == Color(0xff16A085)
                      ? Color(0xffffffff)
                      : widget.linearGradient.colors.first == Color(0xff1EAAD7)
                          ? Color(0xff091B4A)
                          : Color(0xff000000),
            ),
            child: Text(
              "${_getCount(index: 3)}",
              style: TextStyle(
                fontSize: 64.sp,
                color: widget.linearGradient.colors.first == Color(0xffEC008C)
                    ? Color(0xffFFFFFF)
                    : widget.linearGradient.colors.first == Color(0xff16A085)
                        ? Color(0xff000000)
                        : widget.linearGradient.colors.first ==
                                Color(0xff1EAAD7)
                            ? Color(0xff3CE3F2)
                            : Color(0xffFFFFFF),
                fontFamily: "digital",
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCount({int index = 0}) {
    String count = widget.count.toString();
    for (int i = 4 - count.length; i > 0; i--) {
      count = "0$count";
    }
    try {
      count = count[(index)];
    } catch (e) {
      count = "0";
    }
    return count;
  }
}
