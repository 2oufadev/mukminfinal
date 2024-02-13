import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class QuranShimmer extends StatelessWidget {
  const QuranShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 4,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemBuilder: (context, index) {
        Color bgcolor;
        if (index % 2 == 0) {
          bgcolor = const Color(0xff3a343d);
        } else {
          bgcolor = Colors.black38;
        }

        return Container(
          color: bgcolor,
          padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
          child: Column(
            children: [
              Row(
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Shimmer.fromColors(
                        enabled: true,
                        child: Container(
                          width: 34,
                          height: 20,
                          decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(5),
                                  topRight: Radius.circular(5)),
                              color: Color(0xFF383838)),
                        ),
                        baseColor: Color(0xFF383838),
                        highlightColor: Color(0xFF484848),
                      ),
                      const SizedBox(height: 10),
                      Shimmer.fromColors(
                        enabled: true,
                        child: Icon(
                          Icons.play_circle_outline_outlined,
                          size: 30,
                          color: Color(0xFF383838),
                        ),
                        baseColor: Color(0xFF383838),
                        highlightColor: Color(0xFF484848),
                      )
                    ],
                  ),
                  const SizedBox(
                    width: 21,
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                              alignment: Alignment.centerRight,
                              child:

                                  // the arabic verse we have to change

                                  Shimmer.fromColors(
                                enabled: true,
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.6,
                                  height: 30,
                                  decoration: const BoxDecoration(
                                      color: Color(0xFF383838)),
                                ),
                                baseColor: Color(0xFF383838),
                                highlightColor: Color(0xFF484848),
                              )),
                          SizedBox(height: 5),
                          Shimmer.fromColors(
                            enabled: true,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.5,
                              height: 12,
                              decoration:
                                  const BoxDecoration(color: Color(0xFF383838)),
                            ),
                            baseColor: Color(0xFF383838),
                            highlightColor: Color(0xFF484848),
                          ),
                          SizedBox(height: 5),
                          Shimmer.fromColors(
                            enabled: true,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              height: 12,
                              decoration:
                                  const BoxDecoration(color: Color(0xFF383838)),
                            ),
                            baseColor: Color(0xFF383838),
                            highlightColor: Color(0xFF484848),
                          ),
                          SizedBox(height: 2),
                          Shimmer.fromColors(
                            enabled: true,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.5,
                              height: 12,
                              decoration:
                                  const BoxDecoration(color: Color(0xFF383838)),
                            ),
                            baseColor: Color(0xFF383838),
                            highlightColor: Color(0xFF484848),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        );
      },
    );
  }
}
