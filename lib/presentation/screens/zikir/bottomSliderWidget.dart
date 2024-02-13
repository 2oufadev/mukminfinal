import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mukim_app/resources/Imageresources.dart';
import 'package:mukim_app/resources/constants.dart';
import 'package:mukim_app/utils/get_theme_color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'dialogChangeMaximumNumber.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:just_audio_cache/src/audio_player_utils.dart';

class BottomSliderWidget extends StatefulWidget {
  int count;
  Function(int)? maximun;
  Function? reset;
  String? selectedValue;

  BottomSliderWidget(
      {this.count = 0, this.maximun, this.reset, this.selectedValue});

  @override
  _BottomSliderWidgetState createState() => _BottomSliderWidgetState();
}

class _BottomSliderWidgetState extends State<BottomSliderWidget> {
  String theme = "default";
  CarouselController _controller = CarouselController();
  List<ZikrEntity> zikrList = [];
  bool loading = true;
  AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        theme = prefs.getString("appTheme") ?? "default";
      });
    });
    getTasbihData();
    super.initState();
  }

  getTasbihData() async {
    try {
      String url = 'https://salam.mukminapps.com/api/Zikr';
      var result = await http
          .get(Uri.parse(url), headers: {"Accept": "application/json"});
      List responseBody = jsonDecode(result.body);
      print('~~~~~~${responseBody.toSet()}');
      for (var zikr in responseBody) {
        if (zikr['status'] == 'enable') {
          zikrList.add(ZikrEntity(
              'https://salam.mukminapps.com/images/${zikr['arabic_image']}',
              // zikr['arabic_audio'] == '1650941606.mp3'
              //     ? "assets/images/allahuakahbar.png"
              //     : zikr['arabic_audio'] == '1650941466.mp3'
              //         ? "assets/images/alhamdulillaj.png"
              //         : zikr['arabic_audio'] == '1650941202.mp3'
              //             ? "assets/images/subhanallah.png"
              //             : "assets/images/subhanallah.png",
              zikr['name'].toString().split('\/').first,
              zikr['name'].toString().split('\/').last,
              'https://salam.mukminapps.com/images/' + zikr['arabic_audio'],
              int.parse(zikr['order'])));

          if (zikrList.length > 1) {
            zikrList.sort((a, b) => a.order.compareTo(b.order));
          }
        }
      }
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 10.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => widget.reset!(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "RESET",
                      style: TextStyle(color: Colors.white, fontSize: 12.sp),
                    ),
                    SizedBox(width: 10.w),
                    Image.asset(
                      ImageResource.reset,
                      width: 20.w,
                      height: 20.w,
                    ),
                  ],
                ),
              ),
              Expanded(child: Container()),
              GestureDetector(
                onTap: _showChangeMaximumnumberDialog,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${widget.count}",
                      style: TextStyle(
                          fontFamily: "digital",
                          color: Colors.white,
                          fontSize: 24.sp),
                    ),
                    SizedBox(width: 10.w),
                    Image.asset(
                      ImageResource.edit,
                      width: 16.w,
                      height: 16.w,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        CarouselSlider.builder(
          carouselController: _controller,
          itemCount: loading ? 1 : zikrList.length,
          itemBuilder: (context, index, i) {
            return loading
                ? Shimmer.fromColors(
                    enabled: true,
                    child: Container(
                      width: double.infinity,
                      height: 170.h,
                      margin: EdgeInsets.symmetric(horizontal: 10.w),
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 10.h),
                      decoration: new BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Color(0xFF383838)),
                    ),
                    baseColor: Color(0xFF383838),
                    highlightColor: Color(0xFF484848),
                  )
                : Container(
                    width: double.infinity,
                    height: 170.h,
                    clipBehavior: Clip.antiAlias,
                    margin: EdgeInsets.symmetric(horizontal: 10.w),
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.h),
                      image: DecorationImage(
                        image: AssetImage(ImageResource.sliderImg),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                _controller.previousPage(
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.easeIn);
                              },
                              child: Icon(
                                Icons.keyboard_arrow_left_rounded,
                                color: Colors.white,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _controller.nextPage(
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.easeIn);
                              },
                              child: Icon(
                                Icons.keyboard_arrow_right_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  await audioPlayer
                                      .dynamicSet(
                                          url: zikrList[index].audioLink)
                                      .onError((error, stackTrace) {
                                    print('!!!!!!$error');
                                  }).then((value) async {
                                    audioPlayer.play().onError(
                                        (error, stackTrace) =>
                                            print('error $error'));

                                    AudioConstants.playingNext = false;
                                  });
                                },
                                child: Icon(
                                  Icons.play_circle_fill_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                width: 22.w,
                                height: 22.w,
                              )
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(zikrList[index].arabicTextImg,
                                height: 30.sp, frameBuilder: (context, child,
                                    frame, wasSynchronouslyLoaded) {
                              if (frame == null) {
                                return Shimmer.fromColors(
                                  enabled: true,
                                  child: Container(
                                      height: 30.sp,
                                      width: 50.sp,
                                      color: Color(0xFF383838)),
                                  baseColor: Color(0xFF383838),
                                  highlightColor: Color(0xFF484848),
                                );
                              }

                              return child;
                            }),
                            SizedBox(height: 20.h),
                            Text(
                              zikrList[index].topText,
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  color: getColor(theme),
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.italic),
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              zikrList[index].bottomText,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  );
          },
          options: CarouselOptions(
              onPageChanged: (index, reason) {
                print(zikrList[index].arabicTextImg);
              },
              autoPlay: false,
              height: 170.h,
              initialPage: 0,
              viewportFraction: 0.95),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }

  void _showChangeMaximumnumberDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: DialogChangeMaximumNumber(
              selectedValue: widget.selectedValue,
              count: widget.count,
              maximumCount: widget.maximun ?? null,
            ),
          );
        });
  }
}

class ZikrEntity {
  final String arabicTextImg, topText, bottomText, audioLink;
  final int order;
  ZikrEntity(this.arabicTextImg, this.topText, this.bottomText, this.audioLink,
      this.order);
}
