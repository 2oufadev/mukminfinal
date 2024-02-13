import 'package:flutter/material.dart';
import 'package:mukim_app/resources/Imageresources.dart';
import 'package:shimmer/shimmer.dart';

class DuaCategoryShimmer extends StatelessWidget {
  const DuaCategoryShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // alignment: Alignment.bottomCenter,
      decoration: new BoxDecoration(
          // color: Colors.yellow,
          image: DecorationImage(
              alignment: Alignment.bottomCenter,
              fit: BoxFit.contain,
              image: AssetImage(
                ImageResource.background,
              ))),
      child: GridView.count(
          primary: false,
          physics: BouncingScrollPhysics(),
          childAspectRatio: 1 / 0.7,
          padding: const EdgeInsets.all(8),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 2,
          children: List.generate(6, (index) {
            return Shimmer.fromColors(
              enabled: true,
              child: Container(
                decoration: new BoxDecoration(
                    color: Color(0xFF383838),
                    borderRadius: BorderRadius.circular(8)),
              ),
              baseColor: Color(0xFF383838),
              highlightColor: Color(0xFF484848),
            );
          })),
    );
  }
}
