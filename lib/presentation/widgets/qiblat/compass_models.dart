import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Compass1 extends StatefulWidget {
  final double scaled;
  final int design;
  Compass1({Key? key, required this.design, required this.scaled})
      : super(key: key);
  @override
  _Compass1State createState() => _Compass1State();
}

class _Compass1State extends State<Compass1>
    with SingleTickerProviderStateMixin {
  List<String> compassBackground = [
    './assets/images/compasses/img_2.png',
    './assets/images/compasses/img_1.png',
    './assets/images/compasses/img_3.png',
  ];
  List<String> arrows = [
    './assets/images/compasses/arr_1.png',
    './assets/images/compasses/arr_2.png',
    './assets/images/compasses/arr_3.png',
  ];

  double? angle;
  @override
  void initState() {
    getAngle();
    super.initState();
  }

  getAngle() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    angle = sharedPreferences.getDouble('angle');
  }

  final Iterable<Duration> pauses = [
    const Duration(milliseconds: 500),
  ];
  bool isVib = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
        width: width / 1.7, height: width / 1.7, child: _quaba(width));
  }

  Widget _quaba(width) {
    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (_, AsyncSnapshot<QiblahDirection> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return CircularProgressIndicator();

        final qiblahDirection = snapshot.data;
        bool isValid = false;
        double _angle = 0;
        if (qiblahDirection != null) {
          _angle = ((qiblahDirection.qiblah ?? 0) * (pi / 180) * -1);
          if (angle != null)
            isValid = qiblahDirection.offset - qiblahDirection.direction >=
                    (angle! - 1) &&
                qiblahDirection.offset - qiblahDirection.direction <=
                    (angle! + 1);

          if (isValid) {
            if (isVib) {
              Vibrate.vibrateWithPauses(pauses);
            }
            isVib = false;
          } else {
            isVib = true;
          }
        }

        return Stack(
          children: [
            Container(
              width: widget.scaled * width / 1.7,
              height: widget.scaled * width / 1.7,
              child: Image.asset(
                isValid
                    ? 'assets/images/compasses/img_2_selected.png'
                    : compassBackground[widget.design - 1],
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: widget.scaled * ((width / ((1.7) * 2) - 100)),
              left: widget.scaled * ((width / ((1.7) * 2)) - 100),
              child: AnimatedContainer(
                transformAlignment: Alignment.center,
                alignment: Alignment.center,
                curve: Curves.linear,
                transform: Matrix4.rotationZ(_angle),
                child: SizedBox(
                  width: 205 * widget.scaled,
                  height: 200 * widget.scaled,
                  child: Image.asset(
                    arrows[widget.design - 1],
                    fit: BoxFit.contain,
                  ),
                ),
                duration: Duration(milliseconds: 500),
              ),
            ),
          ],
        );
      },
    );
  }
}
