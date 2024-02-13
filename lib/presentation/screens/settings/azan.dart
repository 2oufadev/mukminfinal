import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mukim_app/business_logic/cubit/hadith_cubit/hadith_cubit_cubit.dart';
import 'package:mukim_app/business_logic/cubit/subscription/userstate_cubit.dart';
import 'package:mukim_app/utils/componants.dart';
import 'package:mukim_app/providers/theme.dart';
import 'package:mukim_app/utils/get_theme_color.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'azan_detail.dart';

class TetapanAzanScreen extends StatefulWidget {
  const TetapanAzanScreen({Key? key}) : super(key: key);

  @override
  _TetapanAzanScreenState createState() => _TetapanAzanScreenState();
}

class _TetapanAzanScreenState extends State<TetapanAzanScreen> {
  Map<String, dynamic>? userStateMap;
  String imsakSelectedAzan = '';
  String subuhSelectedAzan = '';
  String syurukSelectedAzan = '';
  String dhuhaSelectedAzan = '';
  String zohorSelectedAzan = '';
  String asarSelectedAzan = '';
  String maghribSelectedAzan = '';
  String isyakSelectedAzan = '';
  int imsakAdditionalTime = 0;
  int subuhAdditionalTime = 0;
  int syurukAdditionalTime = 0;
  int dhuhaAdditionalTime = 0;
  int zohorAdditionalTime = 0;
  int asarAdditionalTime = 0;
  int maghribAdditionalTime = 0;
  int isyakAdditionalTime = 0;
  bool imsakChanged = false;
  bool subuhChanged = false;
  bool syurukChanged = false;
  bool dhuhaChanged = false;
  bool zohorChanged = false;
  bool asarChanged = false;
  bool maghribChanged = false;
  bool isyakChanged = false;
  String theme = '';
  late SharedPreferences sharedPreferences;
  String saving = '';
  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSharedData();
  }

  getSharedData() async {
    sharedPreferences = await SharedPreferences.getInstance();
    imsakSelectedAzan = sharedPreferences.getString('imsak') ?? '';
    subuhSelectedAzan = sharedPreferences.getString('subuh') ?? '';
    syurukSelectedAzan = sharedPreferences.getString('syuruk') ?? '';
    dhuhaSelectedAzan = sharedPreferences.getString('dhuha') ?? '';
    zohorSelectedAzan = sharedPreferences.getString('zohor') ?? '';
    asarSelectedAzan = sharedPreferences.getString('asar') ?? '';
    maghribSelectedAzan = sharedPreferences.getString('maghrib') ?? '';
    isyakSelectedAzan = sharedPreferences.getString('isyak') ?? '';
    imsakAdditionalTime = sharedPreferences.getInt('imsakAdditionalTime') ?? 0;
    subuhAdditionalTime = sharedPreferences.getInt('subuhAdditionalTime') ?? 0;
    syurukAdditionalTime =
        sharedPreferences.getInt('syurukAdditionalTime') ?? 0;
    dhuhaAdditionalTime = sharedPreferences.getInt('dhuhaAdditionalTime') ?? 0;
    zohorAdditionalTime = sharedPreferences.getInt('zohorAdditionalTime') ?? 0;
    asarAdditionalTime = sharedPreferences.getInt('asarAdditionalTime') ?? 0;
    maghribAdditionalTime =
        sharedPreferences.getInt('maghribAdditionalTime') ?? 0;
    isyakAdditionalTime = sharedPreferences.getInt('isyakAdditionalTime') ?? 0;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    theme = Provider.of<ThemeNotifier>(context).appTheme;

    userStateMap = BlocProvider.of<UserStateCubit>(context).checkUserState();

    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Color.fromRGBO(90, 89, 89, 1),
        appBar: AppBar(
          title: Text('Tetapan Azan'),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  "assets/theme/${theme ?? "default"}/appbar.png",
                ),
                fit: BoxFit.cover,
              ),
            ),
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
          body: ListView(
            children: [
              SizedBox(height: 8),
              _azanListTile(
                context,
                title: "Imsak",
                subtitle: imsakSelectedAzan,
              ),
              _azanListTile(
                context,
                title: "Subuh",
                subtitle: subuhSelectedAzan,
              ),
              _azanListTile(
                context,
                title: "Syuruk",
                subtitle: syurukSelectedAzan,
              ),
              _azanListTile(
                context,
                title: "Dhuha",
                subtitle: dhuhaSelectedAzan,
              ),
              _azanListTile(
                context,
                title: "Zohor",
                subtitle: zohorSelectedAzan,
              ),
              _azanListTile(context, title: "Asar", subtitle: asarSelectedAzan),
              _azanListTile(
                context,
                title: "Maghrib",
                subtitle: maghribSelectedAzan,
              ),
              _azanListTile(
                context,
                title: "Isyak",
                subtitle: isyakSelectedAzan,
              ),
              SizedBox(
                height: 200,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _azanListTile(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    String time = '';
    if (title == 'Imsak') {
      if (imsakAdditionalTime < 0) {
        time = '${-imsakAdditionalTime} mins before';
      } else if (imsakAdditionalTime > 0) {
        time = '$imsakAdditionalTime mins after';
      } else {
        time = 'On Time';
      }
    } else if (title == 'Subuh') {
      if (subuhAdditionalTime < 0) {
        time = '${-subuhAdditionalTime} mins before';
      } else if (subuhAdditionalTime > 0) {
        time = '$subuhAdditionalTime mins after';
      } else {
        time = 'On Time';
      }
    } else if (title == 'Syuruk') {
      if (syurukAdditionalTime < 0) {
        time = '${-syurukAdditionalTime} mins before';
      } else if (syurukAdditionalTime > 0) {
        time = '$syurukAdditionalTime mins after';
      } else {
        time = 'On Time';
      }
    } else if (title == 'Dhuha') {
      if (dhuhaAdditionalTime < 0) {
        time = '${-dhuhaAdditionalTime} mins before';
      } else if (dhuhaAdditionalTime > 0) {
        time = '$dhuhaAdditionalTime mins after';
      } else {
        time = 'On Time';
      }
    } else if (title == 'Zohor') {
      if (zohorAdditionalTime < 0) {
        time = '${-zohorAdditionalTime} mins before';
      } else if (zohorAdditionalTime > 0) {
        time = '$zohorAdditionalTime mins after';
      } else {
        time = 'On Time';
      }
    } else if (title == 'Asar') {
      if (asarAdditionalTime < 0) {
        time = '${-asarAdditionalTime} mins before';
      } else if (asarAdditionalTime > 0) {
        time = '$asarAdditionalTime mins after';
      } else {
        time = 'On Time';
      }
    } else if (title == 'Maghrib') {
      if (maghribAdditionalTime < 0) {
        time = '${-maghribAdditionalTime} mins before';
      } else if (maghribAdditionalTime > 0) {
        time = '$maghribAdditionalTime mins after';
      } else {
        time = 'On Time';
      }
    } else if (title == 'Isyak') {
      if (isyakAdditionalTime < 0) {
        time = '${-isyakAdditionalTime} mins before';
      } else if (isyakAdditionalTime > 0) {
        time = '$isyakAdditionalTime mins after';
      } else {
        time = 'On Time';
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 13),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TetapanAzanDetailScreen(title: title, selectedAzan: subtitle),
            ),
          ).then((value) => getSharedData());
        },
        child: Ink(
          decoration: BoxDecoration(
            color: Color.fromRGBO(27, 27, 27, 1),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.all(11),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 88,
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.subtitle1!.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          subtitle,
                          style:
                              Theme.of(context).textTheme.subtitle2!.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                        CircleAvatar(
                          radius: 13,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.navigate_next_rounded,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: (title == 'Imsak' && imsakChanged) ||
                        (title == 'Subuh' && subuhChanged) ||
                        (title == 'Syuruk' && syurukChanged) ||
                        (title == 'Dhuha' && dhuhaChanged) ||
                        (title == 'Zohor' && zohorChanged) ||
                        (title == 'Asar' && asarChanged) ||
                        (title == 'Maghrib' && maghribChanged) ||
                        (title == 'Isyak' && isyakChanged)
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.end,
                children: [
                  if ((title == 'Imsak' && imsakChanged) ||
                      (title == 'Subuh' && subuhChanged) ||
                      (title == 'Syuruk' && syurukChanged) ||
                      (title == 'Dhuha' && dhuhaChanged) ||
                      (title == 'Zohor' && zohorChanged) ||
                      (title == 'Asar' && asarChanged) ||
                      (title == 'Maghrib' && maghribChanged) ||
                      (title == 'Isyak' && isyakChanged))
                    InkWell(
                      onTap: () async {
                        if (title == 'Imsak') {
                          sharedPreferences.setInt(
                              'imsakAdditionalTime', imsakAdditionalTime);
                          saving = 'Imsak';

                          loading = true;

                          setState(() {});
                          int mode =
                              sharedPreferences.getInt('imsakAzanMode') ?? 0;
                          print(mode);
                          print(imsakAdditionalTime);

                          // await FlutterLocalNotificationsPlugin().zonedSchedule(
                          //     Random().nextInt(pow(2, 31).toInt()),
                          //     'Test',
                          //     'test',
                          //     tz.TZDateTime.now(
                          //             tz.getLocation('Asia/Kuala_Lumpur'))
                          //         .add(Duration(minutes: 1)),
                          //     NotificationDetails(
                          //         iOS: IOSNotificationDetails(
                          //           presentAlert: true,
                          //           presentBadge: true,
                          //           presentSound: true,
                          //         ),
                          //         android: AndroidNotificationDetails(
                          //             'scheduledCustomImsakSound${Random().nextInt(pow(2, 31).toInt())}',
                          //             'Test',
                          //             channelDescription:
                          //                 'your channel description',
                          //             color: Colors.green,
                          //             importance: Importance.max,
                          //             priority: Priority.max,
                          //             playSound: false,
                          //             styleInformation: BigTextStyleInformation(
                          //                 'Telah masuk waktu solat fardhu Subuh bagi Daerah'))),
                          //     androidAllowWhileIdle: true,
                          //     uiLocalNotificationDateInterpretation:
                          //         UILocalNotificationDateInterpretation
                          //             .absoluteTime,
                          //     payload: '');

                          BlocProvider.of<HadithCubitCubit>(context)
                              .changeNotification(
                                  'Waktu Imsak',
                                  mode,
                                  imsakAdditionalTime < 0
                                      ? 1
                                      : imsakAdditionalTime > 0
                                          ? 2
                                          : 0,
                                  imsakAdditionalTime);
                        } else if (title == 'Subuh') {
                          sharedPreferences.setInt(
                              'subuhAdditionalTime', subuhAdditionalTime);
                          saving = 'Subuh';
                          loading = true;
                          setState(() {});
                          int mode =
                              sharedPreferences.getInt('subuhAzanMode') ?? 0;
                          print(mode);
                          BlocProvider.of<HadithCubitCubit>(context)
                              .changeNotification(
                                  'Waktu Subuh',
                                  mode,
                                  subuhAdditionalTime < 0
                                      ? 1
                                      : subuhAdditionalTime > 0
                                          ? 2
                                          : 0,
                                  subuhAdditionalTime);
                        } else if (title == 'Syuruk') {
                          sharedPreferences.setInt(
                              'syurukAdditionalTime', syurukAdditionalTime);
                          saving = 'Syuruk';
                          loading = true;
                          setState(() {});
                          int mode =
                              sharedPreferences.getInt('syurukAzanMode') ?? 0;
                          print(mode);
                          BlocProvider.of<HadithCubitCubit>(context)
                              .changeNotification(
                                  'Waktu Syuruk',
                                  mode,
                                  syurukAdditionalTime < 0
                                      ? 1
                                      : syurukAdditionalTime > 0
                                          ? 2
                                          : 0,
                                  syurukAdditionalTime);
                        } else if (title == 'Dhuha') {
                          sharedPreferences.setInt(
                              'dhuhaAdditionalTime', dhuhaAdditionalTime);
                          saving = 'Dhuha';
                          loading = true;
                          setState(() {});
                          int mode =
                              sharedPreferences.getInt('dhuhaAzanMode') ?? 0;
                          print(mode);
                          BlocProvider.of<HadithCubitCubit>(context)
                              .changeNotification(
                                  'Waktu Dhuha',
                                  mode,
                                  dhuhaAdditionalTime < 0
                                      ? 1
                                      : dhuhaAdditionalTime > 0
                                          ? 2
                                          : 0,
                                  dhuhaAdditionalTime);
                        } else if (title == 'Zohor') {
                          sharedPreferences.setInt(
                              'zohorAdditionalTime', zohorAdditionalTime);
                          saving = 'Zohor';
                          loading = true;
                          setState(() {});

                          int mode =
                              sharedPreferences.getInt('zohorAzanMode') ?? 0;
                          print(mode);
                          BlocProvider.of<HadithCubitCubit>(context)
                              .changeNotification(
                                  'Waktu Zohor',
                                  mode,
                                  zohorAdditionalTime < 0
                                      ? 1
                                      : zohorAdditionalTime > 0
                                          ? 2
                                          : 0,
                                  zohorAdditionalTime);
                        } else if (title == 'Asar') {
                          sharedPreferences.setInt(
                              'asarAdditionalTime', asarAdditionalTime);
                          saving = 'Asar';
                          loading = true;
                          setState(() {});

                          int mode =
                              sharedPreferences.getInt('asarAzanMode') ?? 0;

                          BlocProvider.of<HadithCubitCubit>(context)
                              .changeNotification(
                                  'Waktu Asar',
                                  mode,
                                  asarAdditionalTime < 0
                                      ? 1
                                      : asarAdditionalTime > 0
                                          ? 2
                                          : 0,
                                  asarAdditionalTime);
                        } else if (title == 'Maghrib') {
                          sharedPreferences.setInt(
                              'maghribAdditionalTime', maghribAdditionalTime);
                          saving = 'Maghrib';
                          loading = true;
                          setState(() {});
                          int mode =
                              sharedPreferences.getInt('maghribAzanMode') ?? 0;
                          print(mode);
                          BlocProvider.of<HadithCubitCubit>(context)
                              .changeNotification(
                                  'Waktu Maghrib',
                                  mode,
                                  maghribAdditionalTime < 0
                                      ? 1
                                      : maghribAdditionalTime > 0
                                          ? 2
                                          : 0,
                                  maghribAdditionalTime);
                        } else if (title == 'Isyak') {
                          sharedPreferences.setInt(
                              'isyakAdditionalTime', isyakAdditionalTime);
                          saving = 'Isyak';
                          loading = true;
                          setState(() {});
                          int mode =
                              sharedPreferences.getInt('isyakAzanMode') ?? 0;
                          print(mode);
                          BlocProvider.of<HadithCubitCubit>(context)
                              .changeNotification(
                                  'Waktu Isyak',
                                  mode,
                                  isyakAdditionalTime < 0
                                      ? 1
                                      : isyakAdditionalTime > 0
                                          ? 2
                                          : 0,
                                  isyakAdditionalTime);
                        }

                        Future.delayed(Duration(seconds: 2), () {
                          Fluttertoast.showToast(
                              msg: "Perubahan Disimpan",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.green,
                              textColor: Colors.white,
                              fontSize: 12.0);
                          loading = false;
                          if (saving == 'Imsak') {
                            imsakChanged = false;
                          } else if (saving == 'Subuh') {
                            subuhChanged = false;
                          } else if (saving == 'Syuruk') {
                            syurukChanged = false;
                          } else if (saving == 'Dhuha') {
                            dhuhaChanged = false;
                          } else if (saving == 'Zohor') {
                            zohorChanged = false;
                          } else if (saving == 'Asar') {
                            asarChanged = false;
                          } else if (saving == 'Maghrib') {
                            maghribChanged = false;
                          } else if (saving == 'Isyak') {
                            isyakChanged = false;
                          }

                          saving = '';

                          setState(() {});
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, right: 8.0, bottom: 8.0),
                        child: Container(
                          height: 22,
                          alignment: Alignment.center,
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                              color: getColor(theme, isButton: true),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomRight: Radius.circular(10))),
                          child: saving == title && loading
                              ? Container(
                                  height: 15,
                                  width: 15,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 1,
                                  ),
                                )
                              : Text('Gunakan',
                                  style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          child: Text(time,
                              style: TextStyle(color: Colors.white))),
                      SizedBox(width: 10),
                      InkWell(
                        onTap: () {
                          if (title == 'Imsak') {
                            imsakAdditionalTime--;

                            if (imsakAdditionalTime !=
                                (sharedPreferences
                                        .getInt('imsakAdditionalTime') ??
                                    0)) {
                              imsakChanged = true;
                            } else {
                              imsakChanged = false;
                            }

                            setState(() {});
                          } else if (title == 'Subuh') {
                            subuhAdditionalTime--;
                            if (subuhAdditionalTime !=
                                (sharedPreferences
                                        .getInt('subuhAdditionalTime') ??
                                    0)) {
                              subuhChanged = true;
                            } else {
                              subuhChanged = false;
                            }
                            setState(() {});
                          } else if (title == 'Syuruk') {
                            syurukAdditionalTime--;
                            if (syurukAdditionalTime !=
                                (sharedPreferences
                                        .getInt('syurukAdditionalTime') ??
                                    0)) {
                              syurukChanged = true;
                            } else {
                              syurukChanged = false;
                            }
                            setState(() {});
                          } else if (title == 'Dhuha') {
                            dhuhaAdditionalTime--;
                            if (dhuhaAdditionalTime !=
                                (sharedPreferences
                                        .getInt('dhuhaAdditionalTime') ??
                                    0)) {
                              dhuhaChanged = true;
                            } else {
                              dhuhaChanged = false;
                            }
                            setState(() {});
                          } else if (title == 'Zohor') {
                            zohorAdditionalTime--;
                            if (zohorAdditionalTime !=
                                (sharedPreferences
                                        .getInt('zohorAdditionalTime') ??
                                    0)) {
                              zohorChanged = true;
                            } else {
                              zohorChanged = false;
                            }
                            setState(() {});
                          } else if (title == 'Asar') {
                            asarAdditionalTime--;
                            if (asarAdditionalTime !=
                                (sharedPreferences
                                        .getInt('asarAdditionalTime') ??
                                    0)) {
                              asarChanged = true;
                            } else {
                              asarChanged = false;
                            }
                            setState(() {});
                          } else if (title == 'Maghrib') {
                            maghribAdditionalTime--;
                            if (maghribAdditionalTime !=
                                (sharedPreferences
                                        .getInt('maghribAdditionalTime') ??
                                    0)) {
                              maghribChanged = true;
                            } else {
                              maghribChanged = false;
                            }
                            setState(() {});
                          } else if (title == 'Isyak') {
                            isyakAdditionalTime--;
                            if (isyakAdditionalTime !=
                                (sharedPreferences
                                        .getInt('isyakAdditionalTime') ??
                                    0)) {
                              isyakChanged = true;
                            } else {
                              isyakChanged = false;
                            }
                            setState(() {});
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: Container(
                            alignment: Alignment.center,
                            height: 22,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    topRight: Radius.circular(0),
                                    bottomRight: Radius.circular(0))),
                            child: Center(
                                child: Icon(Icons.remove,
                                    size: 20, color: Colors.black)),
                          ),
                        ),
                      ),
                      SizedBox(width: 2),
                      InkWell(
                        onTap: () {
                          if (title == 'Imsak') {
                            imsakAdditionalTime++;

                            if (imsakAdditionalTime !=
                                (sharedPreferences
                                        .getInt('imsakAdditionalTime') ??
                                    0)) {
                              imsakChanged = true;
                            } else {
                              imsakChanged = false;
                            }
                            setState(() {});
                          } else if (title == 'Subuh') {
                            subuhAdditionalTime++;
                            if (subuhAdditionalTime !=
                                (sharedPreferences
                                        .getInt('subuhAdditionalTime') ??
                                    0)) {
                              subuhChanged = true;
                            } else {
                              subuhChanged = false;
                            }
                            setState(() {});
                          } else if (title == 'Syuruk') {
                            syurukAdditionalTime++;
                            if (syurukAdditionalTime !=
                                (sharedPreferences
                                        .getInt('syurukAdditionalTime') ??
                                    0)) {
                              syurukChanged = true;
                            } else {
                              syurukChanged = false;
                            }
                            setState(() {});
                          } else if (title == 'Dhuha') {
                            dhuhaAdditionalTime++;
                            if (dhuhaAdditionalTime !=
                                (sharedPreferences
                                        .getInt('dhuhaAdditionalTime') ??
                                    0)) {
                              dhuhaChanged = true;
                            } else {
                              dhuhaChanged = false;
                            }
                            setState(() {});
                          } else if (title == 'Zohor') {
                            zohorAdditionalTime++;
                            if (zohorAdditionalTime !=
                                (sharedPreferences
                                        .getInt('zohorAdditionalTime') ??
                                    0)) {
                              zohorChanged = true;
                            } else {
                              zohorChanged = false;
                            }
                            setState(() {});
                          } else if (title == 'Asar') {
                            asarAdditionalTime++;
                            if (asarAdditionalTime !=
                                (sharedPreferences
                                        .getInt('asarAdditionalTime') ??
                                    0)) {
                              asarChanged = true;
                            } else {
                              asarChanged = false;
                            }
                            setState(() {});
                          } else if (title == 'Maghrib') {
                            maghribAdditionalTime++;
                            if (maghribAdditionalTime !=
                                (sharedPreferences
                                        .getInt('maghribAdditionalTime') ??
                                    0)) {
                              maghribChanged = true;
                            } else {
                              maghribChanged = false;
                            }
                            setState(() {});
                          } else if (title == 'Isyak') {
                            isyakAdditionalTime++;
                            if (isyakAdditionalTime !=
                                (sharedPreferences
                                        .getInt('isyakAdditionalTime') ??
                                    0)) {
                              isyakChanged = true;
                            } else {
                              isyakChanged = false;
                            }
                            setState(() {});
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: Container(
                            alignment: Alignment.center,
                            height: 22,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                    topLeft: Radius.circular(0),
                                    bottomLeft: Radius.circular(0))),
                            child: Center(
                                child: Icon(Icons.add,
                                    size: 20, color: Colors.black)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
