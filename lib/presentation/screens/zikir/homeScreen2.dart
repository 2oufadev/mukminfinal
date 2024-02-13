import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mukim_app/business_logic/cubit/subscription/userstate_cubit.dart';
import 'package:mukim_app/presentation/widgets/zikir/screen2Widget.dart';
import 'package:mukim_app/resources/Imageresources.dart';
import 'package:mukim_app/resources/global.dart';
import 'package:mukim_app/utils/componants.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bottomSliderWidget.dart';

class HomeScreen2 extends StatefulWidget {
  @override
  _HomeScreen2State createState() => _HomeScreen2State();
}

class _HomeScreen2State extends State<HomeScreen2> {
  AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer();
  Map<String, dynamic>? userStateMap;
  @override
  void initState() {
    super.initState();

    _assetsAudioPlayer.open(
      Audio("assets/sounde/click.mp3"),
    );
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
            image: AssetImage(ImageResource.bg),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.white.withOpacity(0.15),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
              child: FutureBuilder<SharedPreferences>(
                  future: SharedPreferences.getInstance(),
                  builder: (context, snapshot) {
                    String? theme;
                    if (snapshot.hasData) {
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
                    SizedBox(height: 74.h),
                    Center(
                      child: Screen2Widget(
                        linearGradient: Globals.selectedGradient2,
                        count: Globals.count,
                        onTap: () {
                          _assetsAudioPlayer.stop();
                          _assetsAudioPlayer.play();
                          Globals.count++;
                          setState(() {});
                        },
                        reset: () {
                          _assetsAudioPlayer.stop();
                          _assetsAudioPlayer.play();
                          Globals.count = 0;
                          setState(() {});
                        },
                      ),
                    ),
                    SizedBox(height: 40.h),
                    BottomSliderWidget(
                      selectedValue: "Design 2",
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
}
