import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:mouse_parallax/mouse_parallax.dart';
import 'package:mukim_app/utils/componants.dart';
import 'package:shimmer/shimmer.dart';

class MotivationShimmer extends StatelessWidget {
  const MotivationShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return ParallaxStack(
      layers: [
        ListView(
          children: [
            Container(
                height: height * 0.5, //image covers all screen
                width: width,
                child: Shimmer.fromColors(
                  enabled: true,
                  child: Container(
                      height: height * 0.5,
                      width: width,
                      color: Color(0xFF383838)),
                  baseColor: Color(0xFF383838),
                  highlightColor: Color(0xFF484848),
                )),
            Container(
              color: HexColor('#171518'),
              child: imageBottomRow(
                info: '',
                context: context,
                sharedImage: '',
                link: '',
                reference: '',
                description: '',
                description2: '',
                showInfo: false,
                favColor: [],
                imageId: 1,
                favFuction: (int aa) {},
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              color: HexColor('#3A343D'),
              child: GridView.count(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: 1 / 1,
                children: List.generate(
                  6,
                  (index) => Shimmer.fromColors(
                    enabled: true,
                    child: Container(color: Color(0xFF383838)),
                    baseColor: Color(0xFF383838),
                    highlightColor: Color(0xFF484848),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
