import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mukim_app/business_logic/cubit/hadith_cubit/hadith_cubit_cubit.dart';
import 'package:mukim_app/business_logic/cubit/qiblat/blocs/main_screen_bloc.dart';
import 'package:mukim_app/business_logic/cubit/qiblat/blocs/qiblat/cubit/qiblat_cubit.dart';
import 'package:mukim_app/business_logic/cubit/qiblat/states/main_screen_state.dart';
import 'package:mukim_app/business_logic/cubit/subscription/userstate_cubit.dart';
import 'package:mukim_app/presentation/screens/MasjidBerhampiran.dart';
import 'package:mukim_app/presentation/screens/qiblat/compasses_choises.dart';
import 'package:mukim_app/presentation/screens/qiblat/google_earth.dart';
import 'package:mukim_app/presentation/screens/qiblat/search.dart';
import 'package:mukim_app/presentation/screens/qiblat/simple_google_earth.dart';
import 'package:mukim_app/presentation/screens/qiblat/takwim_solat.dart';
import 'package:mukim_app/presentation/screens/settings/naik_taraf.dart';
import 'package:mukim_app/presentation/screens/settings/settings_screen.dart';
import 'package:mukim_app/presentation/screens/zikir/homeScreen.dart';
import 'package:mukim_app/presentation/widgets/qiblat/compass_models.dart';
import 'package:mukim_app/presentation/widgets/qiblat/time_counter.dart';
import 'package:mukim_app/resources/Imageresources.dart';
import 'package:mukim_app/resources/global.dart';
import 'package:mukim_app/utils/app_localization.dart';
import 'package:mukim_app/utils/get_theme_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:mukim_app/utils/componants.dart';
import 'package:mukim_app/utils/utils.dart';
import 'package:mukim_app/utils/video_player_360.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:weather/weather.dart';
import 'package:weather_icons/weather_icons.dart';

import 'kiblat_kaba.dart';

class Kibat2 extends StatefulWidget {
  String cityName;
  String zone;
  bool refreshNotifications;
  bool fromHome;

  Kibat2(
      {required this.cityName,
      this.zone = 'WLY01',
      this.refreshNotifications = false,
      this.fromHome = false});

  @override
  _Kibat2State createState() => _Kibat2State();
}

class _Kibat2State extends State<Kibat2> with TickerProviderStateMixin {
  String theme = "default";
  String? district = '';
  String? cityName = '';
  bool loadingLocation = false;
  ScrollController _mainScrollController = ScrollController();
  List<String> azans = [
    'Imsak',
    'Subuh',
    'Syuruk',
    'Dhuha',
    'Zohor',
    'Asar',
    'Maghrib',
    'Isyak'
  ];

  List<IconData> icons = [
    WeatherIcons.night_alt_cloudy_high,
    WeatherIcons.sunrise,
    WeatherIcons.day_cloudy,
    WeatherIcons.day_sunny,
    WeatherIcons.cloud,
    WeatherIcons.sunset,
    WeatherIcons.night_clear
  ];

  bool scrolled = false;
  late SharedPreferences prefs;
  bool nextAzanFlag = true;
  DateTime time = DateTime.now();
  bool amFlag = false;
  var _today = HijriCalendar.now();
  bool fiveSecondsFlag = true;
  Weather? x;
  String hijriNewMonthName = '';
  bool loggedIn = false;
  bool subscribed = false;
  double turns = 0.0;
  AnimationController? animationController;
  bool getLocationBool = false;
  double latitude = 0;
  double longitude = 0;
  int compassDesign = 0;
  bool calibration = false;
  DateTime anyDay(int hYear, int hMonth, int hDay) {
    return HijriCalendar().hijriToGregorian(hYear, hMonth, hDay);
  }

  DateTime nextAzan(List<DateTime> azansList, DateTime now) {
    DateTime azan = DateTime.now();
    for (azan in azansList) {
      if (azan.difference(now) > Duration(seconds: 0)) {
        break;
      }
    }
    return azan;
  }

  String getNextAzanDuration(Duration d) {
    List<String> ls = d.toString().split(':');

    return "(" + ls[0] + 'h ' + ls[1] + 'm ' + ls[2].split('.')[0] + 's )';
  }

  String hours(DateTime t) {
    if (t.hour <= 12) {
      amFlag = true;
      return t.hour.toString();
    } else if (t.hour > 12) {
      amFlag = false;
      return (t.hour - 12).toString();
    } else {
      return '00';
    }
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    print(widget.refreshNotifications);
    initShared();
    animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    animationController!.addListener(() {
      if (animationController!.isCompleted) {
        animationController!.repeat();
      }
    });

    if (widget.fromHome) {
      QiblatCubit.get(context).getData(cityName!, district!);
      // bloc = MainBloc(cityName: cityName!, zone: district!);
      // bloc.add(1);
      Map<String, dynamic> userState =
          BlocProvider.of<UserStateCubit>(context).checkUserState();
      Future.delayed(Duration(seconds: 5)).then((value) {
        fiveSecondsFlag = false;
      });
      try {
        hours(DateTime.now()); //initializing amFlag
      } catch (e) {}

      if (_today.hMonth == 1) {
        hijriNewMonthName = 'Muharram';
      } else if (_today.hMonth == 2) {
        hijriNewMonthName = 'Safar';
      } else if (_today.hMonth == 3) {
        hijriNewMonthName = "Rabi'ulawal";
      } else if (_today.hMonth == 4) {
        hijriNewMonthName = "Rabi'ulakhir";
      } else if (_today.hMonth == 5) {
        hijriNewMonthName = 'Jamadilawwal';
      } else if (_today.hMonth == 6) {
        hijriNewMonthName = 'Jamadilakhir';
      } else if (_today.hMonth == 7) {
        hijriNewMonthName = 'Rejab';
      } else if (_today.hMonth == 8) {
        hijriNewMonthName = "Sya'ban";
      } else if (_today.hMonth == 9) {
        hijriNewMonthName = 'Ramadhan';
      } else if (_today.hMonth == 10) {
        hijriNewMonthName = 'Shawwal';
      } else if (_today.hMonth == 11) {
        hijriNewMonthName = 'Zulkaedah';
      } else if (_today.hMonth == 12) {
        hijriNewMonthName = 'Zulhijjah';
      }
    } else if (widget.zone == null ||
        widget.zone.isEmpty ||
        widget.cityName == null ||
        widget.cityName!.isEmpty) {
      print('null zone');
      QiblatCubit.get(context).getData(widget.cityName!, widget.zone);

      // bloc = MainBloc(cityName: widget.cityName!, zone: widget.zone);
      // bloc.add(1);
      getLoc();
    } else {
      print('not null zone');
      if (calibration) {
        openCalibrationDialog(context);
      }
      QiblatCubit.get(context).getData(widget.cityName!, widget.zone);

      // bloc = MainBloc(cityName: widget.cityName!, zone: widget.zone);
      // bloc.add(1);
      Map<String, dynamic> userState =
          BlocProvider.of<UserStateCubit>(context).checkUserState();
      Future.delayed(Duration(seconds: 5)).then((value) {
        fiveSecondsFlag = false;
      });
      try {
        hours(DateTime.now()); //initializing amFlag
      } catch (e) {}

      if (_today.hMonth == 1) {
        hijriNewMonthName = 'Muharram';
      } else if (_today.hMonth == 2) {
        hijriNewMonthName = 'Safar';
      } else if (_today.hMonth == 3) {
        hijriNewMonthName = "Rabi'ulawal";
      } else if (_today.hMonth == 4) {
        hijriNewMonthName = "Rabi'ulakhir";
      } else if (_today.hMonth == 5) {
        hijriNewMonthName = 'Jamadilawwal';
      } else if (_today.hMonth == 6) {
        hijriNewMonthName = 'Jamadilakhir';
      } else if (_today.hMonth == 7) {
        hijriNewMonthName = 'Rejab';
      } else if (_today.hMonth == 8) {
        hijriNewMonthName = "Sya'ban";
      } else if (_today.hMonth == 9) {
        hijriNewMonthName = 'Ramadhan';
      } else if (_today.hMonth == 10) {
        hijriNewMonthName = 'Shawwal';
      } else if (_today.hMonth == 11) {
        hijriNewMonthName = 'Zulkaedah';
      } else if (_today.hMonth == 12) {
        hijriNewMonthName = 'Zulhijjah';
      }
    }

    super.initState();
  }

  initShared() async {
    prefs = await SharedPreferences.getInstance();
    if (district!.isEmpty) {
      district = prefs.getString('district') ?? '';
      cityName = prefs.getString('city') ?? '';
    }

    compassDesign = prefs.getInt('compassDesign') ?? 0;

    if (prefs.getBool('cal') == null) {
      calibration = true;
    } else {
      calibration = prefs.getBool('cal') ?? true;
    }

    if (widget.refreshNotifications) {
      print('hellooooo');
      BlocProvider.of<HadithCubitCubit>(context)
          .enableAllAzanNotificationsSound(district!);
    }
    if (mounted) {
      setState(() {
        theme = prefs.getString('appTheme') ?? 'default';
      });
    }
  }

  Future<bool> checkLocationPermission() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return false;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        setState(() {});
        return false;
      }
    }

    _locationData = await location.getLocation();

    latitude = _locationData.latitude ?? 0;
    longitude = _locationData.longitude ?? 0;
    prefs.setDouble('latitude', _locationData.latitude ?? 0);
    prefs.setDouble('longitude', _locationData.longitude ?? 0);
    return true;
  }

  getLoc() {
    checkLocationPermission().then((value) async {
      if (value) {
        var currentPostion = LatLng(latitude, longitude);

        List<Placemark> addresses =
            await placemarkFromCoordinates(latitude, longitude);

        cityName = addresses.first.administrativeArea!;
        if (cityName == null) {
          addresses.forEach((element) {
            if (element.administrativeArea != null) {
              cityName = element.administrativeArea!;
              return;
            }
          });
        }
        district = cityName != null
            ? modifyDistrictName(cityName!.toLowerCase(), addresses)
            : '';

        // if (districtName == null) {
        //   addresses.forEach((element) {
        //     if (element.locality != null) {
        //       districtName = element.locality;
        //       return;
        //     }
        //   });
        // }
        if (cityName == null) cityName = '';
        if (district == null) district = '';
        print('district name');
        print(district!);
        if (district!.isEmpty || cityName!.isEmpty) {
          if (mounted) {
            setState(() {
              loadingLocation = true;
            });
          }
          Fluttertoast.showToast(
              msg: "Tidak dapat mengesan lokasi anda",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.white,
              textColor: Colors.black,
              fontSize: 12.0);
          showModalBottomSheet(
            context: context,
            clipBehavior: Clip.hardEdge,
            backgroundColor: Colors.transparent,
            enableDrag: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            builder: (BuildContext context) {
              return AnimatedPadding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                duration: const Duration(milliseconds: 100),
                child: Stack(children: [
                  DraggableScrollableSheet(
                    initialChildSize: 1,
                    builder:
                        (BuildContext context, ScrollController controller) {
                      return Container(
                        height: MediaQuery.of(context).size.height,
                        child: SearchScreen(
                          oldCity: '',
                          oldZone: '',
                          manual: true,
                          login: true,
                        ),
                      );
                    },
                  ),
                ]),
              );
            },
          ).then((value) async {
            if (value == true) {
              print(prefs.getString('city'));
              print(prefs.getString('district'));
              district = prefs.getString('district') ?? '';
              QiblatCubit.get(context)
                  .getData(prefs.getString('city') ?? '', district!);

              // bloc =
              //     MainBloc(cityName: prefs.getString('city'), zone: district!);
              // bloc.add(1);
              Map<String, dynamic> userState =
                  BlocProvider.of<UserStateCubit>(context).checkUserState();
              Future.delayed(Duration(seconds: 5)).then((value) {
                fiveSecondsFlag = false;
              });
              try {
                hours(DateTime.now()); //initializing amFlag
              } catch (e) {}

              if (_today.hMonth == 1) {
                hijriNewMonthName = 'Muharram';
              } else if (_today.hMonth == 2) {
                hijriNewMonthName = 'Safar';
              } else if (_today.hMonth == 3) {
                hijriNewMonthName = "Rabi'ulawal";
              } else if (_today.hMonth == 4) {
                hijriNewMonthName = "Rabi'ulakhir";
              } else if (_today.hMonth == 5) {
                hijriNewMonthName = 'Jamadilawwal';
              } else if (_today.hMonth == 6) {
                hijriNewMonthName = 'Jamadilakhir';
              } else if (_today.hMonth == 7) {
                hijriNewMonthName = 'Rejab';
              } else if (_today.hMonth == 8) {
                hijriNewMonthName = "Sya'ban";
              } else if (_today.hMonth == 9) {
                hijriNewMonthName = 'Ramadhan';
              } else if (_today.hMonth == 10) {
                hijriNewMonthName = 'Shawwal';
              } else if (_today.hMonth == 11) {
                hijriNewMonthName = 'Zulkaedah';
              } else if (_today.hMonth == 12) {
                hijriNewMonthName = 'Zulhijjah';
              }

              Future.delayed(Duration(seconds: 1), () {
                setState(() {
                  loadingLocation = false;
                  getLocationBool = false;
                  animationController!.stop();
                });
              });
            }
          });
        } else {
          // bloc = MainBloc(cityName: cityName!, zone: district!);
          // bloc.add(1);
          QiblatCubit.get(context).getData(cityName!, district!);

          Map<String, dynamic> userState =
              BlocProvider.of<UserStateCubit>(context).checkUserState();
          Future.delayed(Duration(seconds: 5)).then((value) {
            fiveSecondsFlag = false;
          });
          try {
            hours(DateTime.now()); //initializing amFlag
          } catch (e) {}

          if (_today.hMonth == 1) {
            hijriNewMonthName = 'Muharram';
          } else if (_today.hMonth == 2) {
            hijriNewMonthName = 'Safar';
          } else if (_today.hMonth == 3) {
            hijriNewMonthName = "Rabi'ulawal";
          } else if (_today.hMonth == 4) {
            hijriNewMonthName = "Rabi'ulakhir";
          } else if (_today.hMonth == 5) {
            hijriNewMonthName = 'Jamadilawwal';
          } else if (_today.hMonth == 6) {
            hijriNewMonthName = 'Jamadilakhir';
          } else if (_today.hMonth == 7) {
            hijriNewMonthName = 'Rejab';
          } else if (_today.hMonth == 8) {
            hijriNewMonthName = "Sya'ban";
          } else if (_today.hMonth == 9) {
            hijriNewMonthName = 'Ramadhan';
          } else if (_today.hMonth == 10) {
            hijriNewMonthName = 'Shawwal';
          } else if (_today.hMonth == 11) {
            hijriNewMonthName = 'Zulkaedah';
          } else if (_today.hMonth == 12) {
            hijriNewMonthName = 'Zulhijjah';
          }
          Future.delayed(Duration(seconds: 1), () {
            setState(() {
              loadingLocation = false;
              getLocationBool = false;
              animationController!.stop();
            });
          });
        }
      }
    });
  }

  openCalibrationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Color(0xff3a343d),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Spacer(),
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.cancel_outlined,
                          color: Colors.white,
                          size: 26,
                        ))
                  ],
                ),
                Text(
                  AppLocalizations.of(context)!.translate('compass_accuracy'),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.white),
                ),
                SizedBox(
                  height: 25,
                ),
                Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.red[500]!,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(25))),
                    child: Image.asset('assets/images/calibration.jpg')),
                SizedBox(
                  height: 25,
                ),
                Text(
                  AppLocalizations.of(context)!
                      .translate('kindly_rotate_your_phone'),
                  style: TextStyle(fontSize: 14, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                        onTap: () {
                          setCalibration(false);
                          Navigator.pop(context);
                        },
                        child: Text(
                          AppLocalizations.of(context)!
                              .translate('never_show_again'),
                          style:
                              TextStyle(fontSize: 16, color: Color(0xff969696)),
                        )),
                    InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'OKAY',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        )),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  MainBloc? bloc;

  @override
  Widget build(BuildContext context) {
    nextAzanFlag = true;
    final width = MediaQuery.of(context).size.width;
    print('!!!!!!!');
    if (!scrolled && widget.fromHome) {
      print('scrolled');
      Future.delayed(Duration(seconds: 2), () {
        _mainScrollController.animateTo(
            MediaQuery.of(context).size.height - 220,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut);
        scrolled = true;
      });
    }
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: HexColor('#3A343D'),
        body: BlocBuilder<UserStateCubit, UserState>(builder: (context, state) {
          if (state is LoginState) {
            loggedIn = state.userStateMap!['loggedIn'];
            subscribed = state.userStateMap!['subscribed'];
            print(subscribed);
          }
          return DefaultTabController(
            length: 2,
            child: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  //sliver app bar
                  SliverAppBar(
                    expandedHeight: width * 0.267,
                    floating: true,
                    pinned: false,
                    snap: true,
                    leading: Container(),
                    backgroundColor: HexColor('#3A343D'),
                    actionsIconTheme: IconThemeData(opacity: 0.01),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        alignment: Alignment.centerRight,
                        children: <Widget>[
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
                            bottom: 20,
                            width: MediaQuery.of(context).size.width,
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
                                Text(
                                  "Arah Kiblat",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) => CmpassTheme(
                                            oldCity: widget.cityName!,
                                            oldDistrict: widget.zone,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Icon(
                                      Icons.settings_outlined,
                                      size: 24,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: SlidingUpPanel(
                minHeight: 64,
                maxHeight: 265,
                color: Colors.black.withOpacity(0.5),
                panel: bottomNavBarWithOpacity(
                    context: context, loggedIn: loggedIn),
                body: SingleChildScrollView(
                  controller: _mainScrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //compass handler widget
                      Container(
                        height: width / 1.7 + 80,
                        width: width,
                        child: Stack(
                          children: [
                            //go to city search page
                            Positioned(
                                child: Container(
                                  width: 40,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        children: [
                                          Tooltip(
                                            message: 'Select Location',
                                            child: InkWell(
                                                onTap: () {
                                                  Navigator.of(context)
                                                      .pushReplacement(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          SearchScreen(
                                                        oldCity:
                                                            widget.cityName!,
                                                        oldZone: widget.zone,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Icon(
                                                  Icons.gps_fixed,
                                                  size: 20,
                                                  color: Colors.white,
                                                )),
                                          ),
                                          SizedBox(height: 3),
                                          Text('GPS',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12))
                                        ],
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Column(
                                        children: [
                                          Tooltip(
                                            message: 'AR Kiblat',
                                            child: InkWell(
                                                onTap: () {
                                                  Navigator.of(context)
                                                      .pushReplacement(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          TrianglesLine(
                                                              oldCity: widget
                                                                  .cityName!,
                                                              oldDistrict:
                                                                  widget.zone),
                                                    ),
                                                  );
                                                },
                                                child: Icon(
                                                  Icons.view_in_ar,
                                                  size: 20,
                                                  color: Colors.white,
                                                )),
                                          ),
                                          SizedBox(height: 3),
                                          Text('AR',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12))
                                        ],
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Column(
                                        children: [
                                          Tooltip(
                                            message: 'Kaaba 360˚',
                                            child: InkWell(
                                                onTap: () async {
                                                  await VideoPlayer360.playVideoURL(
                                                      "https://salam.mukminapps.com/images/makkah360.jpg",
                                                      showPlaceholder: true,
                                                      context: context);
                                                },
                                                child: Image.asset(
                                                  ImageResource.kaaba360,
                                                  height: 25,
                                                  width: 25,
                                                  color: Colors.white,
                                                )),
                                          ),
                                          SizedBox(height: 3),
                                          Text('360˚',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12))
                                        ],
                                      ),

                                      // SizedBox(
                                      //   height: 20,
                                      // ),
                                      // Column(
                                      //   children: [
                                      //     Tooltip(
                                      //       message: '3D Earth',
                                      //       child: InkWell(
                                      //           onTap: () async {
                                      //             navigateTo(
                                      //                 context: context,
                                      //                 screen:
                                      //                     SimpleGoogleEarth());
                                      //           },
                                      //           child: Icon(
                                      //             Icons.public,
                                      //             size: 20,
                                      //             color: Colors.white,
                                      //           )),
                                      //     ),
                                      //     SizedBox(height: 3),
                                      //     Text('Glob',
                                      //         style: TextStyle(
                                      //             color: Colors.white,
                                      //             fontWeight: FontWeight.bold,
                                      //             fontSize: 12))
                                      //   ],
                                      // ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Column(
                                        children: [
                                          Tooltip(
                                            message: 'Info',
                                            child: InkWell(
                                                onTap: () async {
                                                  openCalibrationDialog(
                                                      context);
                                                  setCalibration(true);
                                                },
                                                child: Icon(
                                                  Icons.info_outline,
                                                  size: 20,
                                                  color: Colors.white,
                                                )),
                                          ),
                                          SizedBox(height: 3),
                                          Text('Info',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12))
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                top: 20,
                                right: 20),
                            //compass chose
                            Positioned(
                              top: 30,
                              left: 7 * width / 34,
                              child: Compass1(
                                design: compassDesign != 0 ? compassDesign : 1,
                                scaled: 1,
                              ),
                            ),
                            fiveSecondsFlag
                                ? Positioned(
                                    child: Center(
                                        child: Container(
                                      width: 130,
                                      height: 60,
                                      decoration: BoxDecoration(
                                          // color: Colors.black,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                    )),
                                  )
                                : SizedBox()
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      //city general data container
                      Container(
                        key: UniqueKey(),
                        padding:
                            EdgeInsets.only(left: 20, right: 20, bottom: 20),
                        width: width - 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            color: HexColor('1B1B1B')),
                        child: Stack(
                          children: [
                            Column(
                              children: [
                                SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.near_me_rounded,
                                      size: 25,
                                      color: getColor(theme),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Container(
                                        //width: 200,

                                        child: loadingLocation
                                            ? Shimmer.fromColors(
                                                enabled: true,
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.black
                                                            .withOpacity(0.25),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(9)),
                                                    height: 16,
                                                    width: 70),
                                                baseColor: Colors.black
                                                    .withOpacity(0.25),
                                                highlightColor:
                                                    Color(0xFF787878),
                                              )
                                            : Text(
                                                ' $district',
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              )),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    RotationTransition(
                                      turns: Tween(begin: 0.0, end: 1.0)
                                          .animate(animationController!),
                                      child: InkWell(
                                        onTap: () {
                                          // getLocation();

                                          animationController!.forward();

                                          getLoc();
                                        },
                                        child: Image.asset(
                                          'assets/images/main_screen_icons/refresh.png',
                                          width: 25,
                                          height: 25,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 20,
                                      color: getColor(theme),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: BlocConsumer<QiblatCubit,
                                          QiblatState>(
                                        listener: (context, state) {},
                                        builder: (context, state) {
                                          return loadingLocation
                                              ? Shimmer.fromColors(
                                                  enabled: true,
                                                  child: Container(
                                                      decoration: BoxDecoration(
                                                          color: Colors.black
                                                              .withOpacity(
                                                                  0.25),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(9)),
                                                      height: 16,
                                                      width: 70),
                                                  baseColor: Colors.black
                                                      .withOpacity(0.25),
                                                  highlightColor:
                                                      Color(0xFF787878),
                                                )
                                              : Text(
                                                  '${state is DataChanged ? state.timeNow : ''}',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white),
                                                );
                                        },
                                      ),
                                    ),
                                    Icon(
                                      Icons.thermostat_rounded,
                                      size: 25,
                                      color: getColor(theme),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    BlocConsumer<QiblatCubit, QiblatState>(
                                      listener: (context, state) {},
                                      builder: (context, state) {
                                        return loadingLocation
                                            ? Shimmer.fromColors(
                                                enabled: true,
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.black
                                                            .withOpacity(0.25),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(9)),
                                                    height: 16,
                                                    width: 50),
                                                baseColor: Colors.black
                                                    .withOpacity(0.25),
                                                highlightColor:
                                                    Color(0xFF787878),
                                              )
                                            : loadingLocation
                                                ? Container()
                                                : Text(
                                                    ' ${state is DataChanged ? state.temperature : ''}' +
                                                        ' C',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12),
                                                  );
                                      },
                                    ),
                                  ],
                                ),

                                //calender row
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 20,
                                      color: getColor(theme),
                                    ),
                                    SizedBox(
                                      width: 14,
                                    ),
                                    loadingLocation
                                        ? Shimmer.fromColors(
                                            enabled: true,
                                            child: Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withOpacity(0.25),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            9)),
                                                height: 16,
                                                width: 100),
                                            baseColor:
                                                Colors.black.withOpacity(0.25),
                                            highlightColor: Color(0xFF787878),
                                          )
                                        : Text(
                                            modifyDate(
                                                DateFormat('E dd LLL yyyy')
                                                    .format(
                                                        _today.hijriToGregorian(
                                                            _today.hYear,
                                                            _today.hMonth,
                                                            _today.hDay))),
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white)),
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Icon(
                                        Icons.circle,
                                        color: Colors.white,
                                        size: 10,
                                      ),
                                    ),
                                    loadingLocation
                                        ? Shimmer.fromColors(
                                            enabled: true,
                                            child: Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withOpacity(0.25),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            9)),
                                                height: 16,
                                                width: 70),
                                            baseColor:
                                                Colors.black.withOpacity(0.25),
                                            highlightColor: Color(0xFF787878),
                                          )
                                        : Expanded(
                                            flex: 1,
                                            child: Text(
                                                '${_today.hDay}' +
                                                    '  ' +
                                                    '$hijriNewMonthName' +
                                                    ' ' +
                                                    '${_today.hYear}' +
                                                    ' H',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white)),
                                          ),
                                  ],
                                )
                              ],
                            ),
                            BlocConsumer<QiblatCubit, QiblatState>(
                              listener: (context, state) {},
                              builder: (context, state) {
                                return Positioned(
                                  top: 0,
                                  right: 0,
                                  child: state is DataChanged
                                      ? state.weatherIcon.isNotEmpty
                                          ? Container(
                                              child: Image.asset(
                                                state.weatherIcon,
                                                width: 100,
                                                height: 100,
                                              ),
                                            )
                                          : Container()
                                      : Container(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text('Waktu Solat hari ini:',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16)),
                      ),
                      ...List.generate(azans.length, (index) {
                        return BlocConsumer<QiblatCubit, QiblatState>(
                          listener: (context, state) {},
                          builder: (context, state) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  top: 4.0, left: 20, right: 20),
                              child: Container(
                                height: 44,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(16)),
                                    color: HexColor('1B1B1B'),
                                    gradient: state is DataChanged
                                        ? (state.nextAzan == 0 && index == 7) ||
                                                (state.nextAzan != 0 &&
                                                    state.nextAzan - 1 == index)
                                            ? LinearGradient(
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                                colors: [
                                                    HexColor("EC008C"),
                                                    HexColor('FC6767')
                                                  ])
                                            : null
                                        : LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                                HexColor("EC008C"),
                                                HexColor('FC6767')
                                              ])),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10.0),
                                        child: Text('${azans[index]}',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16)),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: state is DataChanged
                                          ? state.nextAzan == index
                                              ? CountDownTimer(
                                                  secondsRemaining: state
                                                      .nextAzanTime.inSeconds,
                                                  whenTimeExpires: () {
                                                    print(
                                                        '#####################');
                                                  },
                                                  countDownTimerStyle:
                                                      TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 10),
                                                )
                                              : SizedBox.shrink()
                                          : SizedBox.shrink(),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Center(
                                        child: Text(
                                          '${state is DataChanged ? state.azansTimesList[index] : ''}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 20.0),
                                        child: state is DataChanged
                                            ? state.weatherIcons != null &&
                                                    state
                                                        .weatherIcons.isNotEmpty
                                                ? Image.asset(
                                                    state.weatherIcons[index],
                                                    height: 40,
                                                    width: 40,
                                                  )
                                                : Container()
                                            : Container(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 16,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) => TakwimSolat(
                                                  cityName: cityName!,
                                                  zone: district!)));
                                    },
                                    child: Container(
                                      width: (width - 60) / 3,
                                      height: 64,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)),
                                          color: HexColor('524D9F')),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text('Takwim Solat',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w400))
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  InkWell(
                                    onTap: () {
                                      navigateTo(
                                          context: context,
                                          screen: MasjidBerhampiran());
                                    },
                                    child: Container(
                                      width: (width - 60) / 3,
                                      height: 64,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)),
                                          color: HexColor('524D9F')),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/images/main_screen_icons/masjid_icon.png',
                                            width: 24,
                                            height: 24,
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text('Masjid Berhampiran',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w400))
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  InkWell(
                                    onTap: () async {
                                      if (subscribed) {
                                        Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CmpassTheme(
                                                      oldCity: widget.cityName!,
                                                      oldDistrict: widget.zone,
                                                    )));
                                      } else {
                                        await showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                                    insetPadding:
                                                        EdgeInsets.all(10),
                                                    elevation: 203,
                                                    title: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        SizedBox(
                                                          width: 30,
                                                        ),
                                                        Text(
                                                          'Premium',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 18),
                                                        ),
                                                        InkWell(
                                                          child: Icon(
                                                            Icons
                                                                .highlight_remove_outlined,
                                                            color: Colors.white,
                                                          ),
                                                          onTap: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        )
                                                      ],
                                                    ),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8)),
                                                    backgroundColor:
                                                        HexColor('3A343D'),
                                                    content: Text(
                                                      'Fungsi ini adalah untuk pengguna akaun Premium sahaja. Sila\nnaiktaraf ke akan Premium untuk menggunakan fungsi ini.',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    ),
                                                    actions: [
                                                      Center(
                                                        child: InkWell(
                                                            onTap: () {
                                                              //write your premium here

                                                              Navigator.of(
                                                                      context)
                                                                  .pushReplacement(
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              CmpassTheme(
                                                                                oldCity: widget.cityName!,
                                                                                oldDistrict: widget.zone,
                                                                              )));
                                                            },
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      12.0),
                                                              child: Container(
                                                                height: 32,
                                                                width: 168,
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.all(Radius.circular(
                                                                            5)),
                                                                    color: HexColor(
                                                                        '524D9F')),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Image.asset(
                                                                      './assets/images/main_screen_icons/external_link_icon.png',
                                                                      height:
                                                                          16,
                                                                      width: 16,
                                                                    ),
                                                                    SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Text(
                                                                      "Naik taraf akaun",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              10),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            )),
                                                      ),
                                                    ]));
                                      }
                                    },
                                    child: Container(
                                      width: (width - 60) / 3,
                                      height: 64,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)),
                                          color: HexColor('524D9F')),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/images/main_screen_icons/compass_icon.png',
                                            width: 24,
                                            height: 24,
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text('Design Kiblat (Premium)',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w400))
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      navigateTo(
                                          context: context, screen: Zikir());
                                    },
                                    child: Container(
                                      width: (width - 60) / 3,
                                      height: 64,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)),
                                          color: HexColor('524D9F')),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/images/main_screen_icons/zikir_icon.png',
                                            width: 24,
                                            height: 24,
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text('Zikir',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w400))
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  // InkWell(
                                  //   onTap: () {
                                  //     navigateTo(
                                  //         context: context,
                                  //         screen: SimpleGoogleEarth());
                                  //   },
                                  //   child: Container(
                                  //     width: (width - 60) / 3,
                                  //     height: 64,
                                  //     decoration: BoxDecoration(
                                  //         borderRadius: BorderRadius.all(
                                  //             Radius.circular(5)),
                                  //         color: HexColor('524D9F')),
                                  //     child: Column(
                                  //       mainAxisAlignment:
                                  //           MainAxisAlignment.center,
                                  //       children: [
                                  //         Icon(
                                  //           Icons.public,
                                  //           color: Colors.white,
                                  //           size: 24,
                                  //         ),
                                  //         SizedBox(
                                  //           height: 10,
                                  //         ),
                                  //         Text('3D Earth Globes',
                                  //             textAlign: TextAlign.center,
                                  //             style: TextStyle(
                                  //                 color: Colors.white,
                                  //                 fontSize: 10,
                                  //                 fontWeight:
                                  //                     FontWeight.w400))
                                  //       ],
                                  //     ),
                                  //   ),
                                  // ),
                                  // SizedBox(width: 10),
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) => TrianglesLine(
                                              oldCity: widget.cityName!,
                                              oldDistrict: widget.zone),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: (width - 60) / 3,
                                      height: 64,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)),
                                          color: HexColor('524D9F')),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.view_in_ar,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text('Augmented Reality',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w400))
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  InkWell(
                                    onTap: () async {
                                      await VideoPlayer360.playVideoURL(
                                          "https://salam.mukminapps.com/images/makkah360.jpg",
                                          showPlaceholder: true,
                                          context: context);
                                    },
                                    child: Container(
                                      width: (width - 60) / 3,
                                      height: 64,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)),
                                          color: HexColor('524D9F')),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            ImageResource.kaaba360,
                                            color: Colors.white,
                                            height: 24,
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text('Kaaba 360˚',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w400))
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // InkWell(
                                  //   onTap: () {
                                  //     navigateTo(
                                  //         context: context, screen: Zikir());
                                  //   },
                                  //   child: Container(
                                  //     width: (width - 60) / 3,
                                  //     height: 64,
                                  //     decoration: BoxDecoration(
                                  //         borderRadius: BorderRadius.all(
                                  //             Radius.circular(5)),
                                  //         color: HexColor('524D9F')),
                                  //     child: Column(
                                  //       mainAxisAlignment:
                                  //           MainAxisAlignment.center,
                                  //       children: [
                                  //         Image.asset(
                                  //           'assets/images/main_screen_icons/zikir_icon.png',
                                  //           width: 24,
                                  //           height: 24,
                                  //         ),
                                  //         SizedBox(
                                  //           height: 10,
                                  //         ),
                                  //         Text('Zikir',
                                  //             textAlign: TextAlign.center,
                                  //             style: TextStyle(
                                  //                 color: Colors.white,
                                  //                 fontSize: 10,
                                  //                 fontWeight:
                                  //                     FontWeight.w400))
                                  //       ],
                                  //     ),
                                  //   ),
                                  // ),
                                  // SizedBox(width: 10),
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) => SearchScreen(
                                            oldCity: widget.cityName!,
                                            oldZone: widget.zone,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: (width - 60) / 3,
                                      height: 64,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)),
                                          color: HexColor('524D9F')),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/images/main_screen_icons/tukas_lukasi.png',
                                            width: 24,
                                            height: 24,
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text('Tukar Lokasi',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w400))
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SettingsScreen()),
                                      );
                                    },
                                    child: Container(
                                      width: (width - 60) / 3,
                                      height: 64,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)),
                                          color: HexColor('524D9F')),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.settings_outlined,
                                              size: 24, color: Colors.white),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text('Tetapan',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w400))
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      !subscribed
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              NaikTarafScreen()));
                                },
                                child: Container(
                                    height: 44,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(16)),
                                        color: HexColor('1B1B1B'),
                                        gradient: LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              HexColor("EC008C"),
                                              HexColor('FC6767')
                                            ])),
                                    child: Text('Naik taraf ke Premium',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold))),
                              ),
                            )
                          : Container(),
                      SizedBox(
                        height: 200,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  setCalibration(bool show) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool('cal', show);
  }

  modifyDate(String date) {
    String modifiedDay = '';
    if (date.contains('Wed')) {
      modifiedDay = date.replaceAll(
          'Wed', AppLocalizations.of(context)!.translate('wednsday'));
    } else if (date.contains('Thu')) {
      modifiedDay = date.replaceAll(
          'Thu', AppLocalizations.of(context)!.translate('thursday'));
    } else if (date.contains('Fri')) {
      modifiedDay = date.replaceAll(
          'Fri', AppLocalizations.of(context)!.translate('friday'));
    } else if (date.contains('Sat')) {
      modifiedDay = date.replaceAll(
          'Sat', AppLocalizations.of(context)!.translate('saturday'));
    } else if (date.contains('Sun')) {
      modifiedDay = date.replaceAll(
          'Sun', AppLocalizations.of(context)!.translate('sunday'));
    } else if (date.contains('Mon')) {
      modifiedDay = date.replaceAll(
          'Mon', AppLocalizations.of(context)!.translate('monday'));
    } else if (date.contains('Tue')) {
      modifiedDay = date.replaceAll(
          'Tue', AppLocalizations.of(context)!.translate('tuesday'));
    } else {
      modifiedDay = date;
    }

    if (modifiedDay.contains('Jan')) {
      return modifiedDay.replaceAll(
          'Jan', AppLocalizations.of(context)!.translate('january'));
    } else if (modifiedDay.contains('Feb')) {
      return modifiedDay.replaceAll(
          'Feb', AppLocalizations.of(context)!.translate('february'));
    } else if (modifiedDay.contains('Mars')) {
      return modifiedDay.replaceAll(
          'Mars', AppLocalizations.of(context)!.translate('mars'));
    } else if (modifiedDay.contains('Apr')) {
      return modifiedDay.replaceAll(
          'Apr', AppLocalizations.of(context)!.translate('april'));
    } else if (modifiedDay.contains('May')) {
      return modifiedDay.replaceAll(
          'May', AppLocalizations.of(context)!.translate('may'));
    } else if (modifiedDay.contains('Jun')) {
      return modifiedDay.replaceAll(
          'Jun', AppLocalizations.of(context)!.translate('june'));
    } else if (modifiedDay.contains('Jul')) {
      return modifiedDay.replaceAll(
          'Jul', AppLocalizations.of(context)!.translate('july'));
    } else if (modifiedDay.contains('Aug')) {
      return modifiedDay.replaceAll(
          'Aug', AppLocalizations.of(context)!.translate('august'));
    } else if (modifiedDay.contains('Sep')) {
      return modifiedDay.replaceAll(
          'Sep', AppLocalizations.of(context)!.translate('september'));
    } else if (modifiedDay.contains('Oct')) {
      return modifiedDay.replaceAll(
          'Oct', AppLocalizations.of(context)!.translate('october'));
    } else if (modifiedDay.contains('Nov')) {
      return modifiedDay.replaceAll(
          'Nov', AppLocalizations.of(context)!.translate('november'));
    } else if (modifiedDay.contains('Dec')) {
      return modifiedDay.replaceAll(
          'Dec', AppLocalizations.of(context)!.translate('december'));
    } else {
      return modifiedDay;
    }
  }

  getLocation() async {
    await checkLocationPermission().then((value) async {
      if (value) {
        Location location = new Location();

        LocationData _locationData = await location.getLocation();

        var currentPostion =
            LatLng(_locationData.latitude!, _locationData.longitude!);

        List<Placemark> addresses = await placemarkFromCoordinates(
            _locationData.latitude!, _locationData.longitude!);

        cityName = addresses.first.administrativeArea;

        if (cityName == null) {
          addresses.forEach((element) {
            if (element.administrativeArea != null) {
              cityName = element.administrativeArea;
              return;
            }
          });
        }
        district = cityName != null
            ? modifyDistrictName(cityName!.toLowerCase(), addresses)
            : '';

        if (cityName == null) cityName = '';
        if (district == null) district = '';

        prefs.setString('district', district!);
        prefs.setString('city', cityName!);

        var dateNow = DateFormat('E dd MMM yyyy').format(DateTime.now());
        HijriCalendar hijriCalendar = HijriCalendar.fromDate(DateTime.now());

        String hijriNewMonthName = getHijriMonthName(hijriCalendar.hMonth);

        var hijriDateNow = hijriCalendar.hDay.toString() +
            ' ' +
            hijriNewMonthName +
            ' ' +
            hijriCalendar.hYear.toString() +
            'H';

        String zoneCode = Globals.zonesCode.entries.firstWhere(
          (element) => element.key == district,
          orElse: () {
            return MapEntry('Sepang', 'SGR01');
          },
        ).value;

        QiblatCubit.get(context).getData(cityName!, district!);
        // bloc = MainBloc(cityName: cityName!, zone: district!);
        // bloc.add(1);
      }
    });

    if (mounted) setState(() {});
  }
}
