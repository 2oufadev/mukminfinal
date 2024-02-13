import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mukim_app/business_logic/cubit/subscription/userstate_cubit.dart';
import 'package:mukim_app/presentation/screens/settings/naik_taraf.dart';
import 'package:mukim_app/presentation/widgets/zikir/screen1Widget.dart';
import 'package:mukim_app/presentation/widgets/zikir/screen2Widget.dart';
import 'package:mukim_app/presentation/widgets/zikir/screen3Widget.dart';
import 'package:mukim_app/presentation/widgets/zikir/screen4Widget.dart';
import 'package:mukim_app/resources/Imageresources.dart';
import 'package:mukim_app/resources/global.dart';
import 'package:mukim_app/utils/app_localization.dart';
import 'package:mukim_app/utils/get_theme_color.dart';
import 'package:rive/rive.dart' as rive;
import 'package:shared_preferences/shared_preferences.dart';

class ChangeColorScreen extends StatefulWidget {
  String? selectedValue;

  ChangeColorScreen({this.selectedValue});

  @override
  _ChangeColorScreenState createState() => _ChangeColorScreenState();
}

class _ChangeColorScreenState extends State<ChangeColorScreen> {
  List<String> _list = [];
  rive.RiveAnimationController? _controller;
  bool subscribed = false;
  Map<String, dynamic>? userStateMap;
  String? theme;
  String selectedTheme = '';
  LinearGradient? selectedGradient1;
  LinearGradient? selectedGradient2;
  LinearGradient? selectedGradient3;
  LinearGradient? selectedGradient4;

  @override
  void initState() {
    super.initState();
    _list.add("Design 1");
    _list.add("Design 2");
    _list.add("Design 3");
    _list.add("Design 4");

    selectedTheme = widget.selectedValue ?? _list[0];
    selectedGradient1 = Globals.selectedGradient1;
    selectedGradient2 = Globals.selectedGradient2;
    selectedGradient3 = Globals.selectedGradient3;
    selectedGradient4 = Globals.selectedGradient4;

    _controller = rive.OneShotAnimation(
      'Animation 1',
      autoplay: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    userStateMap = BlocProvider.of<UserStateCubit>(context).checkUserState();
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, true);
        return Future.value(false);
      },
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
            body: BlocBuilder<UserStateCubit, UserState>(
                builder: (context, state) {
              if (state is LoginState) {
                subscribed = state.userStateMap!['subscribed'];
              }
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 100.h),
                    if (selectedTheme == "Design 4")
                      Screen1Widget(
                        linearGradient: selectedGradient1!,
                        count: Globals.count,
                        maximum: Globals.maximum,
                      ),
                    if (selectedTheme == "Design 2")
                      Screen2Widget(
                        linearGradient: selectedGradient2,
                        count: Globals.count,
                      ),
                    if (selectedTheme == "Design 3")
                      Container(
                        height: 300.h,
                        child: Screen3Widget(
                          linearGradient: selectedGradient3!,
                          count: Globals.count,
                        ),
                      ),
                    if (selectedTheme == "Design 1")
                      GestureDetector(
                        onTap: _animationStart,
                        dragStartBehavior: DragStartBehavior.start,
                        onHorizontalDragStart: (_) {
                          _animationStart();
                        },
                        child: Container(
                          height: 300.h,
                          child: Screen4Widget(
                            linearGradient: selectedGradient4,
                            controller: _controller,
                          ),
                        ),
                      ),
                    SizedBox(height: 60.h),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 0.h, horizontal: 15.w),
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Color(0xff1B1B1B),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedTheme,
                        underline: Container(),
                        dropdownColor: Color(0xff1B1B1B),
                        items: _list.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                ),
                                !subscribed && value != 'Design 1'
                                    ? Container(
                                        height: 30,
                                        width: 30,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.black38),
                                        child: Icon(Icons.lock,
                                            color: Colors.white),
                                      )
                                    : Container()
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (String? val) {
                          selectedTheme = val!;
                          setState(() {});
                        },
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          vertical: 15.h, horizontal: 15.w),
                      margin: EdgeInsets.symmetric(horizontal: 20.w),
                      decoration: BoxDecoration(
                          color: Color(0xff1B1B1B),
                          borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Pilih Warna",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            height: 40,
                            child: ListView.builder(
                                itemCount: Globals.gradientList.length,
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (conte, index) {
                                  return Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5),
                                    child: InkWell(
                                      onTap: () {
                                        if (selectedTheme == "Design 4") {
                                          selectedGradient1 =
                                              Globals.gradientList[index];
                                        }
                                        if (selectedTheme == "Design 2") {
                                          selectedGradient2 =
                                              Globals.gradientList[index];
                                        }
                                        if (selectedTheme == "Design 3") {
                                          selectedGradient3 =
                                              Globals.gradientList[index];
                                        }
                                        if (selectedTheme == "Design 1") {
                                          selectedGradient4 =
                                              Globals.gradientList[index];
                                        }

                                        setState(() {});
                                      },
                                      child: Container(
                                        height: 30,
                                        width: 30,
                                        child: Stack(
                                          children: [
                                            Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Globals.gradientList[
                                                            index] ==
                                                        _getSelectedGradient()
                                                    ? Border.all(
                                                        color: Colors.white,
                                                        width: 2)
                                                    : null,
                                                gradient:
                                                    Globals.gradientList[index],
                                              ),
                                            ),
                                            !subscribed && index != 0
                                                ? Container(
                                                    height: 30,
                                                    width: 30,
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.black38),
                                                    child: Icon(Icons.lock,
                                                        color: Colors.white),
                                                  )
                                                : Container()
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    SizedBox(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: !subscribed
                              ? Colors.grey
                              : getColor(theme!, isButton: true),
                        ),
                        onPressed: () async {
                          if (subscribed) {
                            Globals.selectedValue = selectedTheme;
                            if (selectedTheme == "Design 4") {
                              Globals.selectedGradient1 = selectedGradient1;
                            } else if (selectedTheme == "Design 2") {
                              Globals.selectedGradient2 = selectedGradient2;
                            } else if (selectedTheme == "Design 3") {
                              Globals.selectedGradient3 = selectedGradient3;
                            } else if (selectedTheme == "Design 1") {
                              Globals.selectedGradient4 = selectedGradient4;
                            }
                            Navigator.pop(context, true);
                          } else {
                            Navigator.of(context)
                                .push(MaterialPageRoute(
                                    builder: (context) => NaikTarafScreen()))
                                .then((value) {
                              setState(() {});
                            });
                          }
                        },
                        child: Text(
                            AppLocalizations.of(context)!.translate('apply')),
                      ),
                      width: _size.width * 0.7,
                      height: 40,
                    ),
                    SizedBox(height: 25),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  void _animationStart() {
    _controller!.isActive = true;
  }

  Gradient _getSelectedGradient() {
    if (selectedTheme == "Design 4") {
      return selectedGradient1!;
    } else if (selectedTheme == "Design 2") {
      return selectedGradient2!;
    } else if (selectedTheme == "Design 3") {
      return selectedGradient3!;
    } else if (selectedTheme == "Design 1") {
      return selectedGradient4!;
    } else {
      return selectedGradient1!;
    }
  }
}
