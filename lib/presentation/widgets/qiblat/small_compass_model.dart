import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mukim_app/business_logic/cubit/qiblat/blocs/compassProvider.dart';
import 'package:provider/provider.dart';

class SmallCompass1 extends StatefulWidget {
  final double scaled;
  final int design;

  SmallCompass1({Key? key, required this.design, required this.scaled})
      : super(key: key);

  @override
  _SmallCompass1State createState() => _SmallCompass1State();
}

class _SmallCompass1State extends State<SmallCompass1> {
  StreamSubscription? event;

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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      /*width: width / 3.2,
      height: width / 3.2,*/
      width: 100,
      height: 100,
      child: Stack(
        children: [
          Container(
            /*width: width / 3.2,
            height: width / 3.2,*/
            width: 100,
            height: 100,
            child: Transform.rotate(
              alignment: Alignment.center,
              angle:
                  context.watch<CompassProvider>().compassAngle * (-pi / 180),
              child: Image.asset(
                compassBackground[widget.design - 1],
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            /*top: widget.scaled * ((width / ((3.2) * 2) - 100)),
            left: widget.scaled * ((width / ((3.2) * 2)) - 100),*/
            child: AnimatedContainer(
              /*width: 200 * widget.scaled,
              height: 200 * widget.scaled,*/
              width: 100,
              height: 100,
              transformAlignment: Alignment.center,
              alignment: Alignment.center,
              curve: Curves.easeOut,
              duration: Duration(milliseconds: 300),
              transform: Matrix4.rotationZ(
                  context.watch<CompassProvider>().kiblatAngle),
              child: Image.asset(
                arrows[widget.design - 1],
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
