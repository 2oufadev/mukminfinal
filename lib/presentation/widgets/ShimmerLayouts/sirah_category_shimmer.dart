import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SirahCategoryShimmer extends StatelessWidget {
  const SirahCategoryShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
        child: Shimmer.fromColors(
          enabled: true,
          child: Container(
            width: 343,
            height: 48,
            decoration: new BoxDecoration(
                color: Color(0xFF383838),
                borderRadius: BorderRadius.circular(8)),
            alignment: Alignment.center,
          ),
          baseColor: Color(0xFF383838),
          highlightColor: Color(0xFF484848),
        ));
  }
}
