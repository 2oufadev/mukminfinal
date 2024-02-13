import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mukim_app/main.dart';
import 'package:mukim_app/presentation/screens/ayat.dart';
import 'package:mukim_app/presentation/screens/doa/Doa_Taubat.dart';
import 'package:mukim_app/presentation/screens/hadith/hadeth_detail_screens.dart';
import 'package:mukim_app/presentation/screens/home/home_screen.dart';
import 'package:mukim_app/presentation/screens/login_screen.dart';
import 'package:mukim_app/custom_route.dart';
import 'package:mukim_app/presentation/screens/motivasi.dart';
import 'package:mukim_app/presentation/screens/settings/special_coupon.dart';
import 'package:mukim_app/presentation/widgets/background.dart';
import 'package:mukim_app/presentation/widgets/logo_widget.dart';
import 'package:mukim_app/providers/theme.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';
import 'package:http/http.dart' as http;

import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLoadingScreen = true;
  bool disappear = true;
  bool show = true;
  SharedPreferences? sharedPreferences;
  String username = '';
  Timer? t;
  @override
  void initState() {
    initialize();
    initTime();
    initializeNotificationsListener();
    t?.cancel();
    t = null;

    t = Timer(Duration(seconds: 2), () {
      print('timer!!!!!!!!!!');
      _goToLoadingScreen();
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    t?.cancel();
    print('canceled timerrrrr');
    super.dispose();
  }

  void initializeNotificationsListener() async {
    // AwesomeNotifications().actionStream.listen((event) {
    //   print(event.toMap());
    //   print('alallalala');

    //   Map<String, String> data = event.payload;
    //   print(data);
    //   switch (event.buttonKeyPressed) {
    //     case 'VIEW':
    //       t?.cancel();
    //       t = null;
    //       return Navigator.pushReplacement(
    //           navigatorKey.currentContext,
    //           MaterialPageRoute(
    //               builder: (context) => HadithDetailScreen(
    //                     data['id'],
    //                     data['title'],
    //                     selectedId: int.parse(data['hadithId']),
    //                   )));

    //     case 'SHARE':
    //       return shareImage(event.title, event.bigPicturePath);
    //   }
    // });
  }

  shareImage(String title, String imgUrl) async {
    try {
      http.Response response = await http.get(Uri.parse(imgUrl));
      await Share.shareXFiles(
        [
          XFile.fromData(
            response.bodyBytes,
            mimeType: 'image/png',
          )
        ],
        text: title,
        subject: 'Share Image',
      );
      Navigator.pop(context);
    } catch (e) {
      print('error: $e');
      Navigator.pop(context);
    }
  }

  initialize() async {
    sharedPreferences = await SharedPreferences.getInstance();
    username = sharedPreferences!.getString('useremail') ?? '';

    // await Future.delayed(Duration(seconds: 7));
    // if (mounted)
    //   setState(() {
    //     disappear = true;
    //   });

    // if (mounted)
    //   setState(() {
    //     show = true;
    //     isLoadingScreen = true;
    //   });
  }

  @override
  Widget build(BuildContext context) {
    String theme = Provider.of<ThemeNotifier>(context).appTheme;
    return Scaffold(
      backgroundColor: Colors.white,
      body: BackGround(
        img: "assets/theme/${theme ?? "default"}/background.png",
        child: Center(
          child: isLoadingScreen
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image(
                      image: new AssetImage(
                        'assets/hello.gif',
                      ),
                      height: 60,
                      width: 60,
                    ),
                    const SizedBox(height: 16.0),
                    AnimatedOpacity(
                      opacity: show ? 1 : 0,
                      duration: Duration(milliseconds: 1000),
                      child: SvgPicture.asset(
                        'assets/splash.svg',
                        height: 55,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    AnimatedOpacity(
                      opacity: show ? 1 : 0,
                      duration: Duration(milliseconds: 1000),
                      child: Text(
                        'Assalamu’alaikum warahmatullahi wabarakatuh',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                )
              : Opacity(
                  opacity: disappear ? 0 : 1,
                  child: Container(
                      color: Colors.white,
                      height: MediaQuery.of(context).size.height,
                      child: Logo())),
        ),
      ),
    );
  }

  Future<Null> initUniLinks(BuildContext context) async {
    if (username.isNotEmpty) {
      Navigator.of(context).pushReplacement(FadePageRoute(
        builder: (context) => HomeScreen(),
      ));
    } else {
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => LoginScreen(),
        transitionDuration: Duration.zero,
      ));
    }
    // try {
    //   Uri initialLink = await getInitialUri();
    //   print('link>>>> $initialLink');

    //   if (initialLink != null) {
    //     String last = initialLink.toString().toLowerCase().split('?').last;
    //     print('laaaaast $last');
    //     if (last.contains('motivasi')) {
    //       List<String> splittedString = last.split('-');

    //       print('id ${last.substring(8)}');
    //       Navigator.of(context).pushReplacement(FadePageRoute(
    //         builder: (context) =>
    //             MotivasiScreen(id: int.parse(splittedString.last.trim())),
    //       ));
    //     } else if (last.contains('hadith')) {
    //       List<String> splittedString = last.split('-');
    //       print('~~~~~~~~ ${splittedString.last}');
    //       for (String element in splittedString) {
    //         splittedString[splittedString.indexOf(element)] =
    //             element[0].toUpperCase() + element.substring(1);
    //       }
    //       List<String> titleList =
    //           splittedString.sublist(1, splittedString.length - 2);

    //       String title = titleList.join(' ');
    //       print(title.trim());
    //       Navigator.of(context).pushReplacement(FadePageRoute(
    //         builder: (context) => HadithDetailScreen(
    //             splittedString[splittedString.length - 2], title.trim(),
    //             selectedId: int.parse(splittedString.last.trim())),
    //       ));
    //     } else if (last.contains('doa')) {
    //       List<String> splittedString = last.split('-');
    //       for (String element in splittedString) {
    //         splittedString[splittedString.indexOf(element)] =
    //             element[0].toUpperCase() + element.substring(1);
    //       }
    //       List<String> titleList =
    //           splittedString.sublist(1, splittedString.length - 2);

    //       String title = titleList.join(' ');

    //       Navigator.of(context).pushReplacement(FadePageRoute(
    //         builder: (context) => Doa_Taubat(
    //             fromHome: false,
    //             screenHeight: MediaQuery.of(context).size.height,
    //             id: splittedString[splittedString.length - 2],
    //             title: title.trim(),
    //             selectedId: int.parse(splittedString.last.trim())),
    //       ));
    //     } else if (last.contains('ayat')) {
    //       List<String> splittedString = last.split('-');
    //       print('~~~~~~~~ ${splittedString.last}');

    //       Navigator.of(context).pushReplacement(FadePageRoute(
    //         builder: (context) =>
    //             AyatScreen(selectedId: int.parse(splittedString.last.trim())),
    //       ));
    //     } else if (last.contains('special-coupon')) {
    //       Navigator.of(context).pushReplacement(
    //         MaterialPageRoute(builder: (context) => SpecialCoupon()),
    //       );
    //     }
    //   } else {
    //     if (username.isNotEmpty) {
    //       Navigator.of(context).pushReplacement(FadePageRoute(
    //         builder: (context) => HomeScreen(),
    //       ));
    //     } else {
    //       Navigator.of(context).pushReplacement(PageRouteBuilder(
    //         pageBuilder: (context, animation1, animation2) => LoginScreen(),
    //         transitionDuration: Duration.zero,
    //       ));
    //     }
    //   }
    // } on PlatformException {
    //   print('platfrom exception unilink');
    // }
  }

  Future<void> initTime() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kuala_Lumpur'));
  }

  _goToLoadingScreen() {
    initUniLinks(MyApp.navigatorKey.currentContext!);
  }
}
