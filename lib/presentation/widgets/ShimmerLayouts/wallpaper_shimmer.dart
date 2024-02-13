import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class WallpaperShimmer extends StatelessWidget {
  const WallpaperShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
          itemCount: 4,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.5,
          ),
          itemBuilder: (c, index) {
            return Padding(
                padding: const EdgeInsets.all(2.0),
                child: Shimmer.fromColors(
                  enabled: true,
                  child: Container(color: Color(0xFF383838)),
                  baseColor: Color(0xFF383838),
                  highlightColor: Color(0xFF484848),
                ));
          }),
    );
  }
}
