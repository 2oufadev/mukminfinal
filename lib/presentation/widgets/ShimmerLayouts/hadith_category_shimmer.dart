import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HadithCategoryShimmer extends StatelessWidget {
  const HadithCategoryShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return SliverPadding(
      padding: EdgeInsets.all(15.0),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 20.0,
          crossAxisSpacing: 5.0,
          childAspectRatio: 1 / 1.3,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return Column(
              children: [
                Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Shimmer.fromColors(
                    enabled: true,
                    child: Container(
                        height: (width - 40) / 3,
                        width: (width - 40) / 3,
                        color: Color(0xFF383838)),
                    baseColor: Color(0xFF383838),
                    highlightColor: Color(0xFF484848),
                  ),
                ),
                SizedBox(
                  height: 2.0,
                ),
                Shimmer.fromColors(
                  enabled: true,
                  child: Container(
                      height: 15, width: 50, color: Color(0xFF383838)),
                  baseColor: Color(0xFF383838),
                  highlightColor: Color(0xFF484848),
                )
              ],
            );
          },
          childCount: 15,
        ),
      ),
    );
  }
}
