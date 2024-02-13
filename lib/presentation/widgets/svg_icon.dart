import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mukim_app/providers/theme.dart';
import 'package:provider/provider.dart';

class SvgIcon extends StatelessWidget {
  final String? svg;
  final double? h;
  final double? w;
  final bool? shader;
  const SvgIcon({
    Key? key,
    this.shader,
    required this.svg,
    this.h,
    this.w,
  }) : super(key: key);

  List<Color> getGradient(String theme) {
    List<Color> linearGradient = [
      Color.fromRGBO(255, 224, 0, 1),
      Color.fromRGBO(121, 159, 12, 1)
    ];

    switch (theme) {
      case 'biru':
        linearGradient = [
          Color.fromRGBO(70, 205, 208, 1),
          Color.fromRGBO(57, 55, 85, 1)
        ];
        break;
      case 'purple':
        linearGradient = [
          Color.fromRGBO(159, 153, 219, 1),
          Color.fromRGBO(56, 47, 135, 1)
        ];
        break;
      case 'pink':
        linearGradient = [
          Color.fromRGBO(235, 108, 165, 1),
          Color.fromRGBO(94, 39, 64, 1)
        ];
        break;
      default:
    }

    return linearGradient;
  }

  @override
  Widget build(BuildContext context) {
    String theme = Provider.of<ThemeNotifier>(context).appTheme;
    return shader ?? true
        ? Center(
            child: ShaderMask(
              shaderCallback: (r) {
                return LinearGradient(colors: getGradient(theme))
                    .createShader(r);
              },
              child: SvgPicture.asset(
                'assets/$svg.svg',
                fit: BoxFit.contain,
                height: h,
                width: w,
                color: Colors.white,
              ),
            ),
          )
        : Center(
            child: SvgPicture.asset(
              'assets/$svg.svg',
              fit: BoxFit.contain,
              height: h,
              width: w,
            ),
          );
  }
}
