import 'dart:async';
import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:mukim_app/presentation/screens/qiblat/search.dart';
import 'package:mukim_app/business_logic/cubit/ayat_cubit/ayat_cubit_cubit.dart';
import 'package:mukim_app/business_logic/cubit/doa_cubit/doa_cubit.dart';
import 'package:mukim_app/business_logic/cubit/hadith_cubit/hadith_cubit_cubit.dart';
import 'package:mukim_app/business_logic/cubit/motivation_cubit/motivation_cubit_cubit.dart';
import 'package:mukim_app/business_logic/cubit/subscription/userstate_cubit.dart';
import 'package:mukim_app/carousel_custom/carousel_slider.dart';
import 'package:mukim_app/data/api/adhan_api.dart';
import 'package:mukim_app/data/models/home_screen_model.dart';
import 'package:mukim_app/presentation/widgets/background.dart';
import 'package:mukim_app/presentation/widgets/post_item.dart';
import 'package:mukim_app/resources/Imageresources.dart';
import 'package:mukim_app/resources/global.dart';
import 'package:mukim_app/utils/app_localization.dart';
import 'package:mukim_app/utils/componants.dart';
import 'package:mukim_app/providers/theme.dart';
import 'package:mukim_app/utils/get_theme_color.dart';
import 'package:mukim_app/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../custom_route.dart';
import '../../../main.dart';
import '../Takwim_Hijri.dart';
import '../ayat.dart';
import '../doa/Doa_Taubat.dart';
import '../hadith/hadeth_detail_screens.dart';
import '../motivasi.dart';
import '../qiblat/main_screen.dart';
import '../settings/settings_screen.dart';
import '../settings/special_coupon.dart';

class HomeScreen extends StatefulWidget {
  final bool? firstTime;
  final bool? skipped;
  const HomeScreen(
      {Key? key,
      this.firstTime,
      this.skipped,
      this.notificationAppLaunchDetails})
      : super(key: key);

  final NotificationAppLaunchDetails? notificationAppLaunchDetails;

  bool get didNotificationLaunchApp =>
      notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  double height = 80.0;
  bool expanded = false;
  ScrollController? ctrl;
  String walpaper = ImageResource.wallBackground;
  bool loading = true;
  SharedPreferences? pref;
  List<HomeScreenModel> hadithImages = [];
  List<HomeScreenModel> ayatImages = [];
  List<HomeScreenModel> doaImages = [];
  List<HomeScreenModel> motivImages = [];
  String districtName = '';
  String? cityName = '';
  String username = '';
  bool loadingLocation = true;
  String dateNow = '';
  String hijriDateNow = '';
  var currentPostion;
  String currentAdhan = '';
  String currentAdhanTime = '';
  String nextAdhan = '';
  String nextAdhanT = '';
  StreamSubscription? timersubscription;
  double latitude = 0;
  double longitude = 0;
  List<DateTime>? dadhanTomorrow;
  List<DateTime>? adhanTimes;
  bool permenantDenied = false;
  Map<String, dynamic>? userStateMap;
  String? theme;
  PanelController? panelController;
  bool shrink = true;
  AnimationController? animationController;

  @override
  void initState() {
    super.initState();
    ctrl = ScrollController();
    panelController = PanelController();
    animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    animationController!.addListener(() {
      if (animationController!.isCompleted) {
        animationController!.repeat();
      }
    });
    shrink = false;

    Future.delayed(Duration(milliseconds: 1000), () {
      if (mounted) {
        if (panelController != null && panelController!.isAttached) {
          panelController!.animatePanelToPosition(1);
        }
      }
    });

    _requestPermissions();
    _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();

    FirebaseMessaging.onMessage.listen(showFlutterNotification);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(message.toMap());
      if (message.toMap()['category'] == 'FLUTTER_NOTIFICATION_CLICK') {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SettingsScreen(
                      checkSubscription: true,
                    )));
      }
    });

    redirect();
    setupToken();
    Future.delayed(Duration(milliseconds: 2500), () {
      if (mounted) {
        if (panelController != null && panelController!.isAttached)
          panelController!.animatePanelToPosition(0);
      }
    });

    Future.delayed(Duration(milliseconds: 3500), () {
      if (mounted) {
        setState(() {
          shrink = true;
        });
      }
    });

    _checkNotificationPermission();

    if (widget.skipped != null && widget.skipped!) {
      userStateMap = {'loggedIn': false};
    } else if (widget.firstTime != null && widget.firstTime!) {
      userStateMap =
          BlocProvider.of<UserStateCubit>(context).checkUserFirstState();
    } else {
      userStateMap = BlocProvider.of<UserStateCubit>(context).checkUserState();
    }

    hadithImages = BlocProvider.of<HadithCubitCubit>(context).fetchHadith();
    doaImages = BlocProvider.of<DoaCubit>(context).fetchDoa();
    ayatImages = BlocProvider.of<AyatCubitCubit>(context).fetchAyat();
    motivImages =
        BlocProvider.of<MotivationCubitCubit>(context).fetchMotivasi();
    Future.delayed(Duration(seconds: 2), () {
      _getUserLocation(context);
    });
  }

  redirect() async {
    final PendingDynamicLinkData? initialLink =
        await FirebaseDynamicLinks.instance.getInitialLink();

    if (initialLink != null) {
      String linkString = initialLink.link.toString();
      print(linkString);
      if (linkString.contains('Hadith')) {
        List<String> splittedString = linkString.split('-');

        for (String element in splittedString) {
          splittedString[splittedString.indexOf(element)] =
              element[0].toUpperCase() + element.substring(1);
        }
        List<String> titleList =
            splittedString.sublist(1, splittedString.length - 2);

        String title = titleList.join(' ');

        Navigator.of(MyApp.navigatorKey.currentContext!)
            .pushReplacement(FadePageRoute(
          builder: (context) => HadithDetailScreen(
              splittedString[splittedString.length - 2], title.trim(),
              selectedId: int.parse(splittedString.last.trim())),
        ));
      } else if (linkString.contains('Motivasi')) {
        List<String> splittedString = linkString.split('-');

        Navigator.of(MyApp.navigatorKey.currentContext!)
            .pushReplacement(FadePageRoute(
          builder: (context) =>
              MotivasiScreen(id: int.parse(splittedString.last.trim())),
        ));
      } else if (linkString.contains('Doa')) {
        List<String> splittedString = linkString.split('-');
        for (String element in splittedString) {
          splittedString[splittedString.indexOf(element)] =
              element[0].toUpperCase() + element.substring(1);
        }
        List<String> titleList =
            splittedString.sublist(1, splittedString.length - 2);

        String title = titleList.join(' ');

        Navigator.of(MyApp.navigatorKey.currentContext!)
            .pushReplacement(FadePageRoute(
          builder: (context) => Doa_Taubat(
              fromHome: false,
              screenHeight: MediaQuery.of(context).size.height,
              id: splittedString[splittedString.length - 2],
              title: title.trim(),
              selectedId: int.parse(splittedString.last.trim())),
        ));
      } else if (linkString.contains('Ayat')) {
        List<String> splittedString = linkString.split('-');

        Navigator.of(MyApp.navigatorKey.currentContext!)
            .pushReplacement(FadePageRoute(
          builder: (context) =>
              AyatScreen(selectedId: int.parse(splittedString.last.trim())),
        ));
      } else {
        Navigator.push(
            MyApp.navigatorKey.currentContext!,
            MaterialPageRoute(
              builder: (context) => SpecialCoupon(
                  code: initialLink.link.toString().split('/').last),
            ));
      }
      // final Uri deepLink = initialLink.link;
      // if (deepLink.toString().contains('https://mukminapps.com/')) {
      //   await Future.delayed(Duration(seconds: 2), () {
      //     Navigator.push(
      //         MyApp.navigatorKey.currentContext,
      //         MaterialPageRoute(
      //           builder: (context) =>
      //               SpecialCoupon(code: deepLink.toString().split('/').last),
      //         ));
      //   });
      // }
    }
  }

  Future<void> saveTokenToDatabase(String token) async {
    // Assume user is logged in for this example

    if (FirebaseAuth.instance.currentUser != null) {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('Users').doc(userId).update({
        'token': token,
      });
    }
  }

  Future<void> setupToken() async {
    // Get the token each time the application loads
    String? token = await FirebaseMessaging.instance.getToken();

    // Save the initial token to the database
    await saveTokenToDatabase(token!);

    // Any time the token refreshes, store this in the database too.
    FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);
  }

  void _requestPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationStream.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body)
              : null,
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                await Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => HomeScreen(),
                  ),
                );
              },
              child: const Text('Ok'),
            )
          ],
        ),
      );
    });
  }

  void _configureSelectNotificationSubject() {
    selectNotificationStream.stream.listen((String payload) async {
      await Navigator.pushNamed(context, '/secondPage');
    });
  }

  @override
  void dispose() {
    if (timersubscription != null) {
      timersubscription!.cancel();
    }
    animationController!.dispose();
    didReceiveLocalNotificationStream.close();
    selectNotificationStream.close();
    super.dispose();
  }

  void _checkNotificationPermission() {
    // AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    //   if (!isAllowed) {
    //     showDialog(
    //         context: context,
    //         builder: (context) => AlertDialog(
    //               title: Text('Allow Notifications'),
    //               content:
    //                   Text('Mukmin App would like to send you notifications'),
    //               actions: [
    //                 TextButton(
    //                   onPressed: () {
    //                     Navigator.pop(context);
    //                   },
    //                   child: Text('Dont\'t allow',
    //                       style: TextStyle(color: Colors.grey, fontSize: 18)),
    //                 ),
    //                 TextButton(
    //                   onPressed: () => AwesomeNotifications()
    //                       .requestPermissionToSendNotifications()
    //                       .then((_) => Navigator.pop(context)),
    //                   child: Text('Allow',
    //                       style: TextStyle(
    //                           color: Color(0xFF807BB2), fontSize: 18)),
    //                 )
    //               ],
    //             ));
    //   }
    // });
  }

  void _getUserLocation(BuildContext context) async {
    pref = await SharedPreferences.getInstance();
    setState(() {
      walpaper = pref?.getString('walpaper') ?? ImageResource.wallBackground;
      loading = false;
      username = pref!.getString('username') ?? '';
    });

    if (pref!.getString('city') != null &&
        pref!.getString('city')!.isNotEmpty &&
        pref!.getString('district') != null &&
        pref!.getString('district')!.isNotEmpty) {
      cityName = pref!.getString('city') ?? '';
      districtName = pref!.getString('district') ?? '';
      String date = DateFormat('E dd MMM yyyy').format(DateTime.now());
      print('district exists');
      print(districtName);
      modifyDate(date, context);
      BlocProvider.of<HadithCubitCubit>(context)
          .enableAllAzanNotificationsSound(districtName);
      bool hadithEnabled = pref!.getBool('onedayhadithenabled') ?? true;
      if (hadithEnabled) {
        BlocProvider.of<HadithCubitCubit>(MyApp.navigatorKey.currentContext!)
            .fetchOneDayHadithList();
      }
      HijriCalendar hijriCalendar = HijriCalendar.fromDate(DateTime.now());

      String hijriNewMonthName = getHijriMonthName(hijriCalendar.hMonth);

      hijriDateNow = hijriCalendar.hDay.toString() +
          ' ' +
          hijriNewMonthName +
          ' ' +
          hijriCalendar.hYear.toString() +
          'H';

      String zoneCode = Globals.zonesCode.entries.firstWhere(
        (element) => element.key.toLowerCase() == districtName.toLowerCase(),
        orElse: () {
          return MapEntry('Sepang', 'SGR01');
        },
      ).value;

      adhanTimes = await Api.fetchPrayerTimes(zoneCode);
      dadhanTomorrow = await Api.fetchTomorrowPrayerTimes(zoneCode);

      if (adhanTimes != null &&
          adhanTimes!.isNotEmpty &&
          dadhanTomorrow != null &&
          dadhanTomorrow!.isNotEmpty) {
        Future.delayed(Duration(seconds: 1), () {
          if (mounted)
            setState(() {
              loadingLocation = false;
            });
        });
      } else {
        print('((((((((((((((((((((---------------------');
        print(adhanTimes!.length);
        print(dadhanTomorrow!.length);
        print('((((((((((((((((((((---------------------');

        Fluttertoast.showToast(
            msg: 'Error in loading Azans, Please click refresh icon');
      }
    } else {
      print('district doesnt exist');
      latitude = pref!.getDouble('latitude') ?? 0;
      longitude = pref!.getDouble('longitude') ?? 0;

      if (latitude == 0 || longitude == 0) {
        print('latitude >>>>> 0');
        await checkLocationPermission().then((value) async {
          if (value) {
            latitude = pref!.getDouble('latitude') ?? 0;
            longitude = pref!.getDouble('longitude') ?? 0;
            currentPostion = LatLng(latitude, longitude);

            List<Placemark> addresses =
                await placemarkFromCoordinates(latitude, longitude);

            cityName = addresses.first.administrativeArea;
            if (cityName == null) {
              addresses.forEach((element) {
                if (element.administrativeArea != null) {
                  cityName = element.administrativeArea;
                  return;
                }
              });
            }
            districtName = cityName != null
                ? modifyDistrictName(cityName!.toLowerCase(), addresses)
                : '';

            if (cityName == null) cityName = '';
            if (districtName == null) districtName = '';

            if (districtName.isEmpty || cityName!.isEmpty) {
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
                        builder: (BuildContext context,
                            ScrollController controller) {
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
                  String zoneCode = Globals.zonesCode.entries.firstWhere(
                    (element) =>
                        element.key.toLowerCase() ==
                        pref!.getString('district')!.toLowerCase(),
                    orElse: () {
                      return MapEntry('Sepang', 'SGR01');
                    },
                  ).value;
                  adhanTimes = await Api.fetchPrayerTimes(zoneCode);
                  dadhanTomorrow = await Api.fetchTomorrowPrayerTimes(zoneCode);

                  print('city is available');
                  print(pref!.getString('city'));
                  String date =
                      DateFormat('E dd MMM yyyy').format(DateTime.now());

                  modifyDate(date, context);
                  HijriCalendar hijriCalendar =
                      HijriCalendar.fromDate(DateTime.now());

                  String hijriNewMonthName =
                      getHijriMonthName(hijriCalendar.hMonth);

                  hijriDateNow = hijriCalendar.hDay.toString() +
                      ' ' +
                      hijriNewMonthName +
                      ' ' +
                      hijriCalendar.hYear.toString() +
                      'H';

                  if (adhanTimes != null &&
                      adhanTimes!.isNotEmpty &&
                      dadhanTomorrow != null &&
                      dadhanTomorrow!.isNotEmpty) {
                    Future.delayed(Duration(seconds: 1), () {
                      if (mounted)
                        setState(() {
                          loadingLocation = false;
                        });
                    });
                  } else {
                    Fluttertoast.showToast(
                        msg:
                            'Error in loading Azans, Please click refresh icon');
                  }
                }
              });
            } else {
              pref!.setString('district', districtName);
              pref!.setString('city', cityName!);
              print('district is not empty');
              print(districtName);
              String date = DateFormat('E dd MMM yyyy').format(DateTime.now());

              modifyDate(date, context);
              BlocProvider.of<HadithCubitCubit>(context)
                  .enableAllAzanNotificationsSound(districtName);
              bool hadithEnabled = pref!.getBool('onedayhadithenabled') ?? true;
              if (hadithEnabled) {
                BlocProvider.of<HadithCubitCubit>(
                        MyApp.navigatorKey.currentContext!)
                    .fetchOneDayHadithList();
              }
              HijriCalendar hijriCalendar =
                  HijriCalendar.fromDate(DateTime.now());

              String hijriNewMonthName =
                  getHijriMonthName(hijriCalendar.hMonth);

              hijriDateNow = hijriCalendar.hDay.toString() +
                  ' ' +
                  hijriNewMonthName +
                  ' ' +
                  hijriCalendar.hYear.toString() +
                  'H';

              String zoneCode = Globals.zonesCode.entries.firstWhere(
                (element) =>
                    element.key.toLowerCase() == districtName.toLowerCase(),
                orElse: () {
                  return MapEntry('Sepang', 'SGR01');
                },
              ).value;

              adhanTimes = await Api.fetchPrayerTimes(zoneCode);
              dadhanTomorrow = await Api.fetchTomorrowPrayerTimes(zoneCode);

              if (adhanTimes != null &&
                  adhanTimes!.isNotEmpty &&
                  dadhanTomorrow != null &&
                  dadhanTomorrow!.isNotEmpty) {
                Future.delayed(Duration(seconds: 1), () {
                  if (mounted)
                    setState(() {
                      loadingLocation = false;
                    });
                });
              } else {
                Fluttertoast.showToast(
                    msg: 'Error in loading Azans, Please click refresh icon');
              }
            }
          }
        });
      } else {
        currentPostion = LatLng(latitude, longitude);
        print('latitude exists');

        List<Placemark> addresses =
            await placemarkFromCoordinates(latitude, longitude);

        cityName = addresses.first.administrativeArea;
        if (cityName == null) {
          addresses.forEach((element) {
            if (element.administrativeArea != null) {
              cityName = element.administrativeArea!;
              return;
            }
          });
        }

        districtName = cityName != null
            ? modifyDistrictName(cityName!.toLowerCase(), addresses)
            : '';

        if (cityName == null) cityName = '';
        if (districtName == null) districtName = '';

        if (districtName.isEmpty) {
          print('district from latitude is empty');
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
              String zoneCode = Globals.zonesCode.entries.firstWhere(
                (element) =>
                    element.key.toLowerCase() ==
                    pref!.getString('district')!.toLowerCase(),
                orElse: () {
                  return MapEntry('Sepang', 'SGR01');
                },
              ).value;
              adhanTimes = await Api.fetchPrayerTimes(zoneCode);
              dadhanTomorrow = await Api.fetchTomorrowPrayerTimes(zoneCode);

              String date = DateFormat('E dd MMM yyyy').format(DateTime.now());

              modifyDate(date, context);
              HijriCalendar hijriCalendar =
                  HijriCalendar.fromDate(DateTime.now());

              String hijriNewMonthName =
                  getHijriMonthName(hijriCalendar.hMonth);

              hijriDateNow = hijriCalendar.hDay.toString() +
                  ' ' +
                  hijriNewMonthName +
                  ' ' +
                  hijriCalendar.hYear.toString() +
                  'H';

              if (adhanTimes != null &&
                  adhanTimes!.isNotEmpty &&
                  dadhanTomorrow != null &&
                  dadhanTomorrow!.isNotEmpty) {
                Future.delayed(Duration(seconds: 1), () {
                  if (mounted)
                    setState(() {
                      loadingLocation = false;
                    });
                });
              } else {
                Fluttertoast.showToast(
                    msg: 'Error in loading Azans, Please click refresh icon');
              }
            }
          });
        } else {
          pref!.setString('district', districtName);
          pref!.setString('city', cityName!);
          print('district from latitude is not empty');
          print(districtName);
          String zoneCode = Globals.zonesCode.entries.firstWhere(
            (element) =>
                element.key.toLowerCase() == districtName.toLowerCase(),
            orElse: () {
              return MapEntry('Sepang', 'SGR01');
            },
          ).value;
          adhanTimes = await Api.fetchPrayerTimes(zoneCode);
          dadhanTomorrow = await Api.fetchTomorrowPrayerTimes(zoneCode);

          String date = DateFormat('E dd MMM yyyy').format(DateTime.now());

          modifyDate(date, context);
          HijriCalendar hijriCalendar = HijriCalendar.fromDate(DateTime.now());

          String hijriNewMonthName = getHijriMonthName(hijriCalendar.hMonth);

          hijriDateNow = hijriCalendar.hDay.toString() +
              ' ' +
              hijriNewMonthName +
              ' ' +
              hijriCalendar.hYear.toString() +
              'H';
          BlocProvider.of<HadithCubitCubit>(context)
              .enableAllAzanNotificationsSound(districtName);
          bool hadithEnabled = pref!.getBool('onedayhadithenabled') ?? true;
          if (hadithEnabled) {
            BlocProvider.of<HadithCubitCubit>(
                    MyApp.navigatorKey.currentContext!)
                .fetchOneDayHadithList();
          }

          if (adhanTimes != null &&
              adhanTimes!.isNotEmpty &&
              dadhanTomorrow != null &&
              dadhanTomorrow!.isNotEmpty) {
            Future.delayed(Duration(seconds: 1), () {
              if (mounted)
                setState(() {
                  loadingLocation = false;
                });
            });
          } else {
            Fluttertoast.showToast(
                msg: 'Error in loading Azans, Please click refresh icon');
          }
        }
      }
    }
  }

  modifyDate(String date, BuildContext context) {
    String modifiedDay = '';
    if (date.contains('Wed')) {
      modifiedDay = date.replaceAll(
          'Wed', AppLocalizations.of(context)!.translate('wednsday'));
    } else if (date.contains('Thu')) {
      print('~~~~~~~~~~');
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
      dateNow = modifiedDay.replaceAll(
          'Jan', AppLocalizations.of(context)!.translate('january'));
    } else if (modifiedDay.contains('Feb')) {
      print('~~~~~~~~~~');
      dateNow = modifiedDay.replaceAll(
          'Feb', AppLocalizations.of(context)!.translate('february'));
    } else if (modifiedDay.contains('Mars')) {
      dateNow = modifiedDay.replaceAll(
          'Mars', AppLocalizations.of(context)!.translate('mars'));
    } else if (modifiedDay.contains('Apr')) {
      dateNow = modifiedDay.replaceAll(
          'Apr', AppLocalizations.of(context)!.translate('april'));
    } else if (modifiedDay.contains('May')) {
      dateNow = modifiedDay.replaceAll(
          'May', AppLocalizations.of(context)!.translate('may'));
    } else if (modifiedDay.contains('Jun')) {
      dateNow = modifiedDay.replaceAll(
          'Jun', AppLocalizations.of(context)!.translate('june'));
    } else if (modifiedDay.contains('Jul')) {
      dateNow = modifiedDay.replaceAll(
          'Jul', AppLocalizations.of(context)!.translate('july'));
    } else if (modifiedDay.contains('Aug')) {
      dateNow = modifiedDay.replaceAll(
          'Aug', AppLocalizations.of(context)!.translate('august'));
    } else if (modifiedDay.contains('Sep')) {
      dateNow = modifiedDay.replaceAll(
          'Sep', AppLocalizations.of(context)!.translate('september'));
    } else if (modifiedDay.contains('Oct')) {
      dateNow = modifiedDay.replaceAll(
          'Oct', AppLocalizations.of(context)!.translate('october'));
    } else if (modifiedDay.contains('Nov')) {
      dateNow = modifiedDay.replaceAll(
          'Nov', AppLocalizations.of(context)!.translate('november'));
    } else if (modifiedDay.contains('Dec')) {
      dateNow = modifiedDay.replaceAll(
          'Dec', AppLocalizations.of(context)!.translate('december'));
    } else {
      dateNow = modifiedDay;
    }
  }

  _refresh() async {
    await checkLocationPermission().then((value) async {
      if (value) {
        currentPostion = LatLng(latitude, longitude);

        List<Placemark> addresses =
            await placemarkFromCoordinates(latitude, longitude);

        cityName = addresses.first.administrativeArea;
        if (cityName == null || cityName!.isEmpty) {
          for (Placemark element in addresses) {
            if (element.administrativeArea != null &&
                element.administrativeArea!.isNotEmpty) {
              cityName = element.administrativeArea!;
              return;
            }
          }
        }
        districtName = cityName != null
            ? modifyDistrictName(cityName!.toLowerCase(), addresses)
            : '';

        print('###########################');
        // if (districtName == null) {
        //   addresses.forEach((element) {
        //     if (element.locality != null) {
        //       districtName = element.locality;
        //       return;
        //     }
        //   });
        // }
        if (cityName == null) cityName = '';
        if (districtName == null) districtName = '';
        print('district name>>>>1');
        print(districtName);
        if (districtName.isEmpty || cityName!.isEmpty) {
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
              String zoneCode = Globals.zonesCode.entries.firstWhere(
                (element) =>
                    element.key.toLowerCase() ==
                    pref!.getString('district')!.toLowerCase(),
                orElse: () {
                  return MapEntry('Sepang', 'SGR01');
                },
              ).value;
              adhanTimes = await Api.fetchPrayerTimes(zoneCode);
              dadhanTomorrow =
                  await Api.fetchTomorrowPrayerTimes(zoneCode).then((value) {
                print('aaabbbcc');
                if (adhanTimes != null &&
                    adhanTimes!.isNotEmpty &&
                    dadhanTomorrow != null &&
                    dadhanTomorrow!.isNotEmpty) {
                  Future.delayed(Duration(seconds: 1), () {
                    if (mounted)
                      setState(() {
                        loadingLocation = false;
                      });
                  });
                } else {
                  Fluttertoast.showToast(
                      msg: 'Error in loading Azans, Please click refresh icon');
                }
                return value;
              });

              print('city is available');
              print(pref!.getString('city'));
              String date = DateFormat('E dd MMM yyyy').format(DateTime.now());
              districtName = pref!.getString('district')!;
              cityName = pref!.getString('city');
              modifyDate(date, context);
              HijriCalendar hijriCalendar =
                  HijriCalendar.fromDate(DateTime.now());

              String hijriNewMonthName =
                  getHijriMonthName(hijriCalendar.hMonth);

              hijriDateNow = hijriCalendar.hDay.toString() +
                  ' ' +
                  hijriNewMonthName +
                  ' ' +
                  hijriCalendar.hYear.toString() +
                  'H';

              BlocProvider.of<HadithCubitCubit>(context)
                  .enableAllAzanNotificationsSound(districtName);
              bool hadithEnabled = pref!.getBool('onedayhadithenabled') ?? true;
              if (hadithEnabled) {
                BlocProvider.of<HadithCubitCubit>(
                        MyApp.navigatorKey.currentContext!)
                    .fetchOneDayHadithList();
              }
            }
          });
        } else {
          pref!.setString('district', districtName);
          pref!.setString('city', cityName!);
          print('district is not empty');
          print(districtName);
          print(cityName);
          String date = DateFormat('E dd MMM yyyy').format(DateTime.now());

          modifyDate(date, context);

          HijriCalendar hijriCalendar = HijriCalendar.fromDate(DateTime.now());

          String hijriNewMonthName = getHijriMonthName(hijriCalendar.hMonth);

          hijriDateNow = hijriCalendar.hDay.toString() +
              ' ' +
              hijriNewMonthName +
              ' ' +
              hijriCalendar.hYear.toString() +
              'H';

          String zoneCode = Globals.zonesCode.entries.firstWhere(
            (element) =>
                element.key.toLowerCase() == districtName.toLowerCase(),
            orElse: () {
              return MapEntry('Sepang', 'SGR01');
            },
          ).value;
          print('~~zonecodeeee~~${zoneCode}');
          adhanTimes = await Api.fetchPrayerTimes(zoneCode);
          dadhanTomorrow = await Api.fetchTomorrowPrayerTimes(zoneCode);
          BlocProvider.of<HadithCubitCubit>(context)
              .enableAllAzanNotificationsSound(districtName);
          bool hadithEnabled = pref!.getBool('onedayhadithenabled') ?? true;
          if (hadithEnabled) {
            BlocProvider.of<HadithCubitCubit>(
                    MyApp.navigatorKey.currentContext!)
                .fetchOneDayHadithList();
          }
          if (adhanTimes != null &&
              adhanTimes!.isNotEmpty &&
              dadhanTomorrow != null &&
              dadhanTomorrow!.isNotEmpty) {
            print('delayeed ~~~~~~');
            Future.delayed(Duration(seconds: 1), () {
              if (mounted)
                setState(() {
                  loadingLocation = false;
                });
            });
          } else {
            Fluttertoast.showToast(
                msg: 'Error in loading Azans, Please click refresh icon');
          }
        }
      }

      animationController!.stop();
    });
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
        setState(() {
          permenantDenied = true;
        });
        return false;
      }
    }

    _locationData = await location.getLocation();

    latitude = _locationData.latitude ?? 0;
    longitude = _locationData.longitude ?? 0;
    pref!.setDouble('latitude', _locationData.latitude ?? 0);
    pref!.setDouble('longitude', _locationData.longitude ?? 0);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    theme = Provider.of<ThemeNotifier>(context).appTheme;

    return SafeArea(
      top: false,
      child: BackGround(
        img: walpaper,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            automaticallyImplyLeading: false,
            toolbarHeight: 0.0,
          ),
          backgroundColor: Colors.transparent,
          body: SlidingUpPanel(
            controller: panelController,
            minHeight: 64,
            maxHeight: 265,
            color: Colors.black.withOpacity(0.5),
            panel: BlocBuilder<UserStateCubit, UserState>(
                builder: (context, state) {
              if (state is LoginState) {
                userStateMap = state.userStateMap;
              }
              return bottomNavBarWithOpacity(
                  context: context,
                  loggedIn: widget.firstTime != null &&
                          widget.firstTime! &&
                          widget.skipped != null &&
                          !widget.skipped!
                      ? true
                      : userStateMap != null &&
                              userStateMap!['loggedIn'] != null
                          ? userStateMap!['loggedIn']
                          : false);
            }),
            body: NotificationListener(
              onNotification: (n) {
                if (n is ScrollStartNotification) {
                  setState(() {
                    expanded = false;
                  });
                }
                return false;
              },
              child: ListView(
                controller: ctrl,
                scrollDirection: Axis.vertical,
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    width: double.infinity,
                    height: shrink
                        ? MediaQuery.of(context).size.height
                        : MediaQuery.of(context).size.height / 2,
                    child: StreamBuilder<Object>(
                        stream: Stream.periodic(Duration(seconds: 1),
                            (count) => Duration(seconds: count)),
                        initialData: DateTime.now(),
                        builder: (context, snapshot) {
                          DateTime current = DateTime.now();
                          current.add(Duration(seconds: 1));
                          var h = current.hour;
                          var m = current.minute;
                          var hh = h > 12 ? h - 12 : h;
                          var pm = h > 12;
                          var mm = m >= 10 ? '$m' : '0$m';

                          if (adhanTimes != null && adhanTimes!.isNotEmpty) {
                            if (current.compareTo(adhanTimes![0]) <= 0) {
                              currentAdhan = 'Isyak';
                              nextAdhan = 'Imsak';
                              currentAdhanTime =
                                  DateFormat('hh:mm a').format(adhanTimes![6]);
                              nextAdhanT =
                                  DateFormat('hh:mm a').format(adhanTimes![0]);
                            } else if (current.compareTo(adhanTimes![1]) <= 0) {
                              currentAdhan = 'Imsak';
                              nextAdhan = 'Subuh';
                              currentAdhanTime =
                                  DateFormat('hh:mm a').format(adhanTimes![0]);
                              nextAdhanT =
                                  DateFormat('hh:mm a').format(adhanTimes![1]);
                            } else if (current.compareTo(adhanTimes![2]) <= 0) {
                              currentAdhan = 'Subuh';
                              nextAdhan = 'Syuruk';
                              currentAdhanTime =
                                  DateFormat('hh:mm a').format(adhanTimes![1]);
                              nextAdhanT =
                                  DateFormat('hh:mm a').format(adhanTimes![2]);
                            } else if (current.compareTo(adhanTimes![3]) <= 0) {
                              currentAdhan = 'Syuruk';
                              nextAdhan = 'Dhuha';
                              currentAdhanTime =
                                  DateFormat('hh:mm a').format(adhanTimes![2]);
                              nextAdhanT =
                                  DateFormat('hh:mm a').format(adhanTimes![3]);
                            } else if (current.compareTo(adhanTimes![4]) <= 0) {
                              currentAdhan = 'Dhuha';
                              nextAdhan = 'Zohor';
                              currentAdhanTime =
                                  DateFormat('hh:mm a').format(adhanTimes![3]);
                              nextAdhanT =
                                  DateFormat('hh:mm a').format(adhanTimes![4]);
                            } else if (current.compareTo(adhanTimes![5]) <= 0) {
                              currentAdhan = 'Zohor';
                              nextAdhan = 'Asar';
                              currentAdhanTime =
                                  DateFormat('hh:mm a').format(adhanTimes![4]);
                              nextAdhanT =
                                  DateFormat('hh:mm a').format(adhanTimes![5]);
                            } else if (current.compareTo(adhanTimes![6]) <= 0) {
                              currentAdhan = 'Asar';
                              nextAdhan = 'Maghrib';
                              currentAdhanTime =
                                  DateFormat('hh:mm a').format(adhanTimes![5]);
                              nextAdhanT =
                                  DateFormat('hh:mm a').format(adhanTimes![6]);
                            } else if (current.compareTo(adhanTimes![7]) <= 0) {
                              currentAdhan = 'Maghrib';
                              nextAdhan = 'Isyak';
                              currentAdhanTime =
                                  DateFormat('hh:mm a').format(adhanTimes![6]);
                              nextAdhanT =
                                  DateFormat('hh:mm a').format(adhanTimes![7]);
                            } else {
                              if (dadhanTomorrow != null &&
                                  dadhanTomorrow!.isNotEmpty) {
                                currentAdhan = 'Isyak';
                                nextAdhan = 'Imsak';
                                currentAdhanTime = DateFormat('hh:mm a')
                                    .format(adhanTimes![7]);
                                nextAdhanT = DateFormat('hh:mm a')
                                    .format(dadhanTomorrow![0]);
                              }
                            }
                          }

                          return Column(
                            children: [
                              // SizedBox(height: 64.0),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                child: Container(
                                  constraints: BoxConstraints(minHeight: 140),
                                  // borderRadius: BorderRadius.circular(8.0),
                                  decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(9)),
                                  child: permenantDenied
                                      ? Center(
                                          child: ElevatedButton(
                                              child: Text(
                                                'Please Enable Location',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              onPressed: () {
                                                AppSettings
                                                    .openLocationSettings();
                                              }))
                                      : Padding(
                                          padding: const EdgeInsets.only(
                                              right: 16.0,
                                              left: 10.0,
                                              top: 8.0,
                                              bottom: 0.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  SvgPicture.asset(
                                                    ImageResource.mosque,
                                                    color: getColor(theme!),
                                                  ),
                                                  const SizedBox(width: 4.0),
                                                  loadingLocation
                                                      ? Shimmer.fromColors(
                                                          enabled: true,
                                                          child: Container(
                                                              decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .black
                                                                      .withOpacity(
                                                                          0.25),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              9)),
                                                              height: 16,
                                                              width: 150),
                                                          baseColor: Colors
                                                              .black
                                                              .withOpacity(
                                                                  0.25),
                                                          highlightColor:
                                                              Color(0xFF787878),
                                                        )
                                                      : Text(
                                                          'Sekarang: ' +
                                                              currentAdhan,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 14)),
                                                  const SizedBox(width: 8.0),
                                                  loadingLocation
                                                      ? Shimmer.fromColors(
                                                          enabled: true,
                                                          child: Container(
                                                              decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .black
                                                                      .withOpacity(
                                                                          0.25),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              9)),
                                                              height: 18,
                                                              width: 50),
                                                          baseColor: Colors
                                                              .black
                                                              .withOpacity(
                                                                  0.25),
                                                          highlightColor:
                                                              Color(0xFF787878),
                                                        )
                                                      : Text(currentAdhanTime,
                                                          style: TextStyle(
                                                              fontSize: 12.0,
                                                              color: Colors
                                                                  .white)),
                                                ],
                                              ),
                                              const SizedBox(height: 8.0),
                                              Row(
                                                children: [
                                                  Expanded(
                                                      child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .baseline,
                                                    textBaseline:
                                                        TextBaseline.alphabetic,
                                                    children: [
                                                      Text('$hh:$mm',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 40,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          )),
                                                      const SizedBox(
                                                          width: 4.0),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 8.0),
                                                        child: Text(
                                                            pm ? 'PM' : 'AM',
                                                            style: TextStyle(
                                                                fontSize: 12.0,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                      ),
                                                    ],
                                                  )),
                                                  Expanded(
                                                      child: Material(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    color: Colors.black
                                                        .withOpacity(0.15),
                                                    child: InkWell(
                                                      onTap: () {
                                                        navigateTo(
                                                          context: context,
                                                          screen: Kibat2(
                                                                cityName:
                                                                    cityName!,
                                                                zone:
                                                                    districtName,
                                                                fromHome: false,
                                                              ) ??
                                                              HomeScreen(),
                                                        );
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                    16.0,
                                                                vertical: 8.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .baseline,
                                                          textBaseline:
                                                              TextBaseline
                                                                  .alphabetic,
                                                          children: [
                                                            loadingLocation
                                                                ? Shimmer
                                                                    .fromColors(
                                                                    enabled:
                                                                        true,
                                                                    child: Container(
                                                                        decoration: BoxDecoration(
                                                                            color: Colors.black.withOpacity(
                                                                                0.25),
                                                                            borderRadius: BorderRadius.circular(
                                                                                9)),
                                                                        height:
                                                                            18,
                                                                        width:
                                                                            150),
                                                                    baseColor: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.25),
                                                                    highlightColor:
                                                                        Color(
                                                                            0xFF787878),
                                                                  )
                                                                : Text(
                                                                    'Kemudian: $nextAdhan',
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                    )),
                                                            const SizedBox(
                                                                height: 8.0),
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .baseline,
                                                              textBaseline:
                                                                  TextBaseline
                                                                      .alphabetic,
                                                              children: [
                                                                loadingLocation
                                                                    ? Shimmer
                                                                        .fromColors(
                                                                        enabled:
                                                                            true,
                                                                        child: Container(
                                                                            decoration:
                                                                                BoxDecoration(color: Colors.black.withOpacity(0.25), borderRadius: BorderRadius.circular(9)),
                                                                            height: 18,
                                                                            width: 100),
                                                                        baseColor: Colors
                                                                            .black
                                                                            .withOpacity(0.25),
                                                                        highlightColor:
                                                                            Color(0xFF787878),
                                                                      )
                                                                    : Text(
                                                                        nextAdhanT
                                                                            .toString(),
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        )),
                                                                const SizedBox(
                                                                    width: 4.0),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ))
                                                ],
                                              ),
                                              Container(
                                                width: double.infinity,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Icon(
                                                      Icons.near_me_rounded,
                                                      color: getColor(theme!),
                                                      size: 18,
                                                    ),
                                                    SizedBox(width: 5),
                                                    loadingLocation
                                                        ? Shimmer.fromColors(
                                                            enabled: true,
                                                            child: Container(
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.25),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            9)),
                                                                height: 16,
                                                                width: 100),
                                                            baseColor: Colors
                                                                .black
                                                                .withOpacity(
                                                                    0.25),
                                                            highlightColor:
                                                                Color(
                                                                    0xFF787878),
                                                          )
                                                        : Text(
                                                            districtName,
                                                            maxLines: 1,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 10.0),
                                                          ),
                                                    SizedBox(width: 5),
                                                    RotationTransition(
                                                      turns: Tween(
                                                              begin: 0.0,
                                                              end: 1.0)
                                                          .animate(
                                                              animationController!),
                                                      child: InkWell(
                                                        onTap: () {
                                                          animationController!
                                                              .forward();

                                                          _refresh();
                                                        },
                                                        child: Image.asset(
                                                          'assets/images/main_screen_icons/refresh.png',
                                                          width: 25,
                                                          height: 25,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                        flex: 1,
                                                        child: TextButton.icon(
                                                            onPressed: () {},
                                                            icon: Icon(
                                                              Icons
                                                                  .date_range_rounded,
                                                              color: getColor(
                                                                  theme!),
                                                              size: 18,
                                                            ),
                                                            label:
                                                                loadingLocation
                                                                    ? Shimmer
                                                                        .fromColors(
                                                                        enabled:
                                                                            true,
                                                                        child: Container(
                                                                            decoration:
                                                                                BoxDecoration(color: Colors.black.withOpacity(0.25), borderRadius: BorderRadius.circular(9)),
                                                                            height: 16,
                                                                            width: MediaQuery.of(context).size.width * 0.3),
                                                                        baseColor: Colors
                                                                            .black
                                                                            .withOpacity(0.25),
                                                                        highlightColor:
                                                                            Color(0xFF787878),
                                                                      )
                                                                    : InkWell(
                                                                        onTap:
                                                                            () {
                                                                          Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                builder: (context) => Takwim_Hijri(),
                                                                              ));
                                                                        },
                                                                        child:
                                                                            Text(
                                                                          dateNow +
                                                                              ' • ' +
                                                                              hijriDateNow,
                                                                          // softWrap: true,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,

                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 10.0),
                                                                        ),
                                                                      ))),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          );
                        }),
                  ),
                  BlocBuilder<HadithCubitCubit, HadithCubitState>(
                      builder: (context, state) {
                    if (state is HadithImagesLoaded) {
                      hadithImages = state.hadithList;
                    }

                    return Container(
                      width: double.infinity,
                      child: CarouselSlider(
                          options: CarouselOptions(
                            height: 445,
                            initialPage: 0,
                            viewportFraction: 1,
                            enlargeCenterPage: false,
                            enableInfiniteScroll: false,
                          ),
                          items: List.generate(
                              state is HadithImagesLoading
                                  ? 2
                                  : hadithImages != null
                                      ? hadithImages.length
                                      : 0, (index) {
                            print(userStateMap);
                            return PostItem(
                                description: userStateMap != null &&
                                        userStateMap!['subscribed'] != null &&
                                        userStateMap!['subscribed'] &&
                                        hadithImages != null &&
                                        hadithImages.isNotEmpty
                                    ? 'Infografik ini dikongsi oleh $username (Premium) dari MukminApps.Terokai Applikasi PERCUMA TANPA IKLAN di '
                                    // imagesList[cubit.imageIndex]
                                    //     .description
                                    : userStateMap != null &&
                                            hadithImages != null &&
                                            hadithImages.isNotEmpty
                                        ? 'Terokai Pelbagai Infografik, Arah Kiblat, Bacaan Al Quran, Hadith, Motivasi dan lain-lain dalam Applikasi PERCUMA TANPA IKLAN di '
                                        : '',
                                description2: userStateMap != null &&
                                        hadithImages != null &&
                                        hadithImages.isNotEmpty
                                    ? 'Hadith-${hadithImages[index].categoryName}-${hadithImages[index].categoryId}-0'
                                    : '',
                                loggedIn: userStateMap != null && userStateMap!['loggedIn'] != null
                                    ? userStateMap!['loggedIn']
                                    : false,
                                subscribed: userStateMap != null &&
                                        userStateMap!['subscribed'] != null
                                    ? userStateMap!['subscribed']
                                    : false,
                                loading: hadithImages != null && hadithImages.isNotEmpty
                                    ? false
                                    : false,
                                img: hadithImages != null && hadithImages.isNotEmpty
                                    ? hadithImages[index].image
                                    : '',
                                categoryName:
                                    hadithImages != null && hadithImages.isNotEmpty
                                        ? hadithImages[index].categoryName
                                        : '',
                                type: 1,
                                categoryId: hadithImages != null && hadithImages.isNotEmpty
                                    ? hadithImages[index].categoryId
                                    : 0,
                                reference: '');
                          })),
                    );
                  }),
                  SizedBox(height: 5),
                  BlocBuilder<AyatCubitCubit, AyatCubitState>(
                      builder: (context, state) {
                    if (state is AyatImagesLoaded) {
                      ayatImages = state.ayatList;
                    }
                    return Container(
                      width: double.infinity,
                      child: CarouselSlider(
                          options: CarouselOptions(
                            height: 445,
                            initialPage: 0,
                            viewportFraction: 1,
                            enlargeCenterPage: false,
                            enableInfiniteScroll: false,
                          ),
                          items: List.generate(
                              state is AyatImagesLoading
                                  ? 2
                                  : ayatImages != null
                                      ? ayatImages.length
                                      : 0, (index) {
                            return PostItem(
                                description: userStateMap != null &&
                                        userStateMap!['subscribed'] != null &&
                                        userStateMap!['subscribed']
                                    ? 'Infografik ini dikongsi oleh $username (Premium) dari MukminApps.Terokai Applikasi PERCUMA TANPA IKLAN di '

                                    // imagesList[cubit.imageIndex]
                                    //     .description
                                    : userStateMap != null
                                        ? 'Terokai Pelbagai Infografik, Arah Kiblat, Bacaan Al Quran, Hadith, Motivasi dan lain-lain dalam Applikasi PERCUMA TANPA IKLAN di '
                                        : '',
                                description2: 'Ayat-0',
                                loggedIn: userStateMap != null &&
                                        userStateMap!['loggedIn'] != null
                                    ? userStateMap!['loggedIn']
                                    : false,
                                subscribed: userStateMap != null &&
                                        userStateMap!['subscribed'] != null
                                    ? userStateMap!['subscribed']
                                    : false,
                                loading:
                                    ayatImages != null && ayatImages.isNotEmpty
                                        ? false
                                        : true,
                                img: ayatImages != null && ayatImages.isNotEmpty
                                    ? ayatImages[index].image
                                    : '',
                                categoryName:
                                    ayatImages != null && ayatImages.isNotEmpty
                                        ? ayatImages[index].categoryName
                                        : '',
                                type: 2,
                                categoryId:
                                    ayatImages != null && ayatImages.isNotEmpty
                                        ? ayatImages[index].categoryId
                                        : 0,
                                reference: '');
                          })),
                    );
                  }),
                  SizedBox(height: 5),
                  BlocBuilder<DoaCubit, DoaState>(builder: (context, state) {
                    if (state is DoaImagesLoaded) {
                      doaImages = state.doaList;
                    }
                    return Container(
                      width: double.infinity,
                      child: CarouselSlider(
                        options: CarouselOptions(
                          height: 445,
                          initialPage: 0,
                          viewportFraction: 1,
                          enlargeCenterPage: false,
                          enableInfiniteScroll: false,
                        ),
                        items: List.generate(
                            state is DoaImagesLoading
                                ? 2
                                : doaImages != null
                                    ? doaImages.length
                                    : 0, (index) {
                          return PostItem(
                              description: userStateMap != null &&
                                      userStateMap!['subscribed'] != null &&
                                      userStateMap!['subscribed'] &&
                                      doaImages != null &&
                                      doaImages.isNotEmpty
                                  ? 'Infografik ini dikongsi oleh $username (Premium) dari MukminApps.Terokai Applikasi PERCUMA TANPA IKLAN di '
                                  // imagesList[cubit.imageIndex]
                                  //     .description
                                  : userStateMap != null &&
                                          doaImages != null &&
                                          doaImages.isNotEmpty
                                      ? 'Terokai Pelbagai Infografik, Arah Kiblat, Bacaan Al Quran, Hadith, Motivasi dan lain-lain dalam Applikasi PERCUMA TANPA IKLAN di '
                                      : '',
                              description2: userStateMap != null &&
                                      hadithImages != null &&
                                      hadithImages.isNotEmpty
                                  ? 'Doa-${doaImages[index].categoryName}-${doaImages[index].categoryId}-0'
                                  : '',
                              loggedIn: userStateMap != null &&
                                      userStateMap!['loggedIn'] != null
                                  ? userStateMap!['loggedIn']
                                  : false,
                              subscribed: userStateMap != null &&
                                      userStateMap!['subscribed'] != null
                                  ? userStateMap!['subscribed']
                                  : false,
                              loading: doaImages != null && doaImages.isNotEmpty
                                  ? false
                                  : true,
                              img: doaImages != null && doaImages.isNotEmpty
                                  ? doaImages[index].image
                                  : '',
                              categoryName:
                                  doaImages != null && doaImages.isNotEmpty
                                      ? doaImages[index].categoryName
                                      : '',
                              type: 3,
                              categoryId: doaImages != null && doaImages.isNotEmpty
                                  ? doaImages[index].categoryId
                                  : 0,
                              reference: '');
                        }),
                      ),
                    );
                  }),
                  SizedBox(height: 5),
                  BlocBuilder<MotivationCubitCubit, MotivationCubitState>(
                      builder: (context, state) {
                    if (state is MotivasiImagesLoaded) {
                      motivImages = state.motivasiList;
                    }
                    return Container(
                      width: double.infinity,
                      child: CarouselSlider(
                        options: CarouselOptions(
                          height: 445,
                          initialPage: 0,
                          viewportFraction: 1,
                          enlargeCenterPage: false,
                          enableInfiniteScroll: false,
                        ),
                        items: List.generate(
                            state is MotivasiImagesLoading
                                ? 2
                                : motivImages != null
                                    ? motivImages.length
                                    : 0, (index) {
                          return PostItem(
                              description: userStateMap != null &&
                                      userStateMap!['subscribed'] != null &&
                                      userStateMap!['subscribed']
                                  ? 'Infografik ini dikongsi oleh $username (Premium) dari MukminApps.Terokai Applikasi PERCUMA TANPA IKLAN di '

                                  // imagesList[cubit.imageIndex]
                                  //     .description
                                  : userStateMap != null
                                      ? 'Terokai Pelbagai Infografik, Arah Kiblat, Bacaan Al Quran, Hadith, Motivasi dan lain-lain dalam Applikasi PERCUMA TANPA IKLAN di '
                                      : '',
                              description2: 'Motivasi-0',
                              loggedIn: userStateMap != null &&
                                      userStateMap!['loggedIn'] != null
                                  ? userStateMap!['loggedIn']
                                  : false,
                              subscribed: userStateMap != null &&
                                      userStateMap!['subscribed'] != null
                                  ? userStateMap!['subscribed']
                                  : false,
                              loading:
                                  motivImages != null && motivImages.isNotEmpty
                                      ? false
                                      : true,
                              img: motivImages != null && motivImages.isNotEmpty
                                  ? motivImages[index].image
                                  : '',
                              categoryName:
                                  motivImages != null && motivImages.isNotEmpty
                                      ? motivImages[index].categoryName
                                      : '',
                              type: 4,
                              categoryId:
                                  motivImages != null && motivImages.isNotEmpty
                                      ? motivImages[index].categoryId
                                      : 0,
                              reference:
                                  motivImages != null && motivImages.isNotEmpty
                                      ? motivImages[index].reference
                                      : '');
                        }),
                      ),
                    );
                  }),
                  SizedBox(height: 200.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
