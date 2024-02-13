import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukim_app/business_logic/cubit/subscription/userstate_cubit.dart';
import 'package:mukim_app/presentation/widgets/zikir/screen4Widget.dart';
import 'package:mukim_app/resources/Imageresources.dart';
import 'package:mukim_app/resources/global.dart';
import 'package:mukim_app/utils/componants.dart';
import 'package:rive/rive.dart' as rive;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bottomSliderWidget.dart';
import 'changeColorScreen.dart';

class HomeScreen5 extends StatefulWidget {
  @override
  _HomeScreen5State createState() => _HomeScreen5State();
}

class _HomeScreen5State extends State<HomeScreen5> {
  bool _isPlaying = false;
  rive.RiveAnimationController? _controller;
  AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer();
  Map<String, dynamic>? userStateMap;
  @override
  void initState() {
    super.initState();
    // _assetsAudioPlayer.setVolume(100);
    _initAudioPlayer();
    _controller = rive.OneShotAnimation(
      'Animation 1',
      autoplay: false,
      onStart: () => setState(() {
        print('startedddd');

        _assetsAudioPlayer.stop();
        try {
          Future.delayed(Duration(milliseconds: 400), () {
            _assetsAudioPlayer.play();
          });
        } catch (e) {
          print('-------${e.toString()}');
        }

        if (Globals.count >= Globals.maximum) {
          Globals.count = 0;
        }
        Globals.count++;
        _isPlaying = true;
      }),
    );
  }

  _initAudioPlayer() async {
    try {
      await _assetsAudioPlayer.open(
        Audio("assets/sounde/click2.mp3"),
      );
    } catch (t) {
      //mp3 unreachable
    }
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    userStateMap = BlocProvider.of<UserStateCubit>(context).checkUserState();
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(ImageResource.bg), fit: BoxFit.cover)),
        child: Container(
          color: Colors.white.withOpacity(0.15),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
              child: FutureBuilder<SharedPreferences>(
                  future: SharedPreferences.getInstance(),
                  builder: (context, snapshot) {
                    String? theme;
                    if (snapshot.hasData && snapshot.data != null) {
                      theme = snapshot.data!.getString('appTheme');
                    }
                    return Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                "assets/theme/${theme ?? "default"}/appbar.png",
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          bottom: 10,
                          width: _size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: InkWell(
                                  onTap: () => Navigator.pop(context),
                                  child: Image.asset(
                                    ImageResource.leftArrow,
                                    height: 24,
                                    width: 24,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: _size.width * 0.06,
                                  top: 5.0,
                                ),
                                child: Text(
                                  "Zikir",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Image.asset(
                                  ImageResource.edit2,
                                  width: 18.w,
                                  height: 18.w,
                                ),
                                onPressed: () {
                                  Globals.changeGradient(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
              preferredSize: Size.fromHeight(
                _size.width * 0.267,
              ),
            ),
            body: SlidingUpPanel(
              minHeight: 64,
              maxHeight: 265,
              color: Colors.black.withOpacity(0.5),
              panel: BlocBuilder<UserStateCubit, UserState>(
                builder: (context, state) => bottomNavBarWithOpacity(
                    context: context,
                    loggedIn: state is LoginState
                        ? state.userStateMap!['loggedIn']
                        : false),
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 40.h,
                    ),
                    Text(
                      "${Globals.count}",
                      style: TextStyle(
                        fontFamily: "digital",
                        fontSize: 64.sp,
                        color: Colors.white,
                        // fontWeight: FontWeight.w400,
                      ),
                    ),
                    GestureDetector(
                      onTap: _animationStart,
                      dragStartBehavior: DragStartBehavior.start,
                      onHorizontalDragStart: (_) {
                        _animationStart();
                      },
                      child: Center(
                        child: Screen4Widget(
                          linearGradient: Globals.selectedGradient4,
                          controller: _controller,
                        ),
                      ),
                    ),
                    BottomSliderWidget(
                      selectedValue: "Design 1",
                      count: Globals.maximum,
                      reset: () {
                        Globals.count = 0;
                        setState(() {});
                      },
                      maximun: (int count) {
                        Globals.maximum = count;
                        setState(() {});
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _animationStart() {
    // if (_isPlaying) {
    // } else {
    _controller!.isActive = true;
    // }
  }

  void _pushRoute() {
    if (Globals.selectedValue == "Design 1") {
      Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => ChangeColorScreen(
              selectedValue: Globals.selectedValue,
            ),
            transitionDuration: Duration.zero,
          )).then((value) {
        if (value.toString() == "true") {
          // Navigator.pushReplacement(
          //   context,
          //   PageRouteBuilder(
          //     pageBuilder: (context, animation1, animation2) => HomeScreen5(),
          //     transitionDuration: Duration.zero,
          //   ),
          // );
          Globals.changeRoute(context);
        } else {
          // if(selectedValue != "Design 4"){
          //
          //   return;
          // }
          _pushRoute();
        }
      });
    } else {
      Globals.changeGradient(context);
    }
  }
}
