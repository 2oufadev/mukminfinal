import 'dart:io';

import 'package:flutter/material.dart';

class BackGround extends StatelessWidget {
  const BackGround({required this.child, this.img, Key? key}) : super(key: key);
  final Widget child;
  final String? img;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          Container(
            decoration: img != null && !img!.contains('assets')
                ? BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover, image: FileImage(File(img!))),
                  )
                : img != null
                    ? BoxDecoration(
                        image: DecorationImage(
                            fit: BoxFit.cover, image: AssetImage(img!)),
                      )
                    : null,
            child: child,
          ),
        ],
      ),
    );
  }
}
