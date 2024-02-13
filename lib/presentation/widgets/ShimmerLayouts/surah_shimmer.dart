import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SurahShimmer extends StatelessWidget {
  const SurahShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: 10,
        shrinkWrap: true,
        padding: EdgeInsets.only(bottom: 65),
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          return Container(
            height: 85,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              children: [
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Shimmer.fromColors(
                      enabled: true,
                      child: Container(
                          height: 20, width: 15, color: Color(0xFF383838)),
                      baseColor: Color(0xFF383838),
                      highlightColor: Color(0xFF484848),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Shimmer.fromColors(
                                enabled: true,
                                child: Container(
                                    height: 10,
                                    width: 50,
                                    color: Color(0xFF383838)),
                                baseColor: Color(0xFF383838),
                                highlightColor: Color(0xFF484848),
                              )),
                          SizedBox(height: 5),
                          Shimmer.fromColors(
                            enabled: true,
                            child: Container(
                                height: 10,
                                width: 55,
                                color: Color(0xFF383838)),
                            baseColor: Color(0xFF383838),
                            highlightColor: Color(0xFF484848),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 110,
                      child: Shimmer.fromColors(
                        enabled: true,
                        child: Container(
                            height: 50, width: 40, color: Color(0xFF383838)),
                        baseColor: Color(0xFF383838),
                        highlightColor: Color(0xFF484848),
                      ),
                    ),
                    SizedBox(width: 15),
                  ],
                ),
                Spacer(),
                Container(
                  width: MediaQuery.of(context).size.width - 50,
                  height: 0.5,
                  decoration: const BoxDecoration(
                    color: Color(0xff929292),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
