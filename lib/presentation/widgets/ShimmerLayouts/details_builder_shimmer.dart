import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:mouse_parallax/mouse_parallax.dart';
import 'package:mukim_app/utils/componants.dart';
import 'package:shimmer/shimmer.dart';

class DetailsBuilderShimmer extends StatelessWidget {
  final bool? showInfo;
  const DetailsBuilderShimmer({Key? key, this.showInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      child: ParallaxStack(
        layers: [
          ListView(
            children: [
              Shimmer.fromColors(
                enabled: true,
                child: Container(
                    height: height * 0.5,
                    width: width,
                    color: Color(0xFF383838)),
                baseColor: Color(0xFF383838),
                highlightColor: Color(0xFF484848),
              ),
              Container(
                color: HexColor('#171518'),
                child: imageBottomRow(
                    info: '',
                    context: context,
                    sharedImage: '',
                    link: '',
                    description: '',
                    description2: '',
                    reference: '',
                    favColor: [],
                    showInfo: showInfo ?? true,
                    favFuction: (int aa) {},
                    imageId: 1),
              ),
              Container(
                  color: HexColor('#3A343D'),
                  height: width * 0.3,
                  child: ListView.builder(
                      itemCount: 4,
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.only(left: 5, top: 10, bottom: 10),
                      itemBuilder: (context, index) {
                        return Shimmer.fromColors(
                          enabled: true,
                          child: Container(
                              margin: EdgeInsets.only(
                                right: 5,
                              ),
                              height: height * 0.3,
                              width: width * 0.3,
                              color: Color(0xFF383838)),
                          baseColor: Color(0xFF383838),
                          highlightColor: Color(0xFF484848),
                        );
                      })),
              Container(
                color: HexColor('#3A343D'),
                child: GridView.count(
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                  childAspectRatio: 1 / 1,
                  children: List.generate(
                    4,
                    (index) => Shimmer.fromColors(
                      enabled: true,
                      child: Container(
                          height: height * 0.3,
                          width: width * 0.3,
                          color: Color(0xFF383838)),
                      baseColor: Color(0xFF383838),
                      highlightColor: Color(0xFF484848),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
