import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mukim_app/business_logic/cubit/hadith/hadith_cubit.dart';
import 'package:mukim_app/business_logic/cubit/hadith_cubit/hadith_cubit_cubit.dart';
import 'package:mukim_app/business_logic/cubit/subscription/userstate_cubit.dart';
import 'package:mukim_app/data/models/azan_model.dart';
import 'package:mukim_app/data/models/azan_storage_model.dart';
import 'package:mukim_app/presentation/screens/settings/naik_taraf.dart';
import 'package:mukim_app/utils/componants.dart';
import 'package:mukim_app/providers/theme.dart';
import 'package:mukim_app/utils/get_theme_color.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_cache/src/audio_player_utils.dart';

class TetapanAzanDetailScreen extends StatefulWidget {
  final String? title;
  final String? selectedAzan;
  const TetapanAzanDetailScreen({Key? key, this.title, this.selectedAzan})
      : super(key: key);

  @override
  _TetapanAzanDetailScreenState createState() =>
      _TetapanAzanDetailScreenState();
}

class _TetapanAzanDetailScreenState extends State<TetapanAzanDetailScreen> {
  List<AzanModel> azansList = [];
  List<AzanModel> arrangedAzansList = [];
  Map<String, dynamic>? userStateMap;
  String? selectedAzan;
  AudioPlayer? audioPlayer;
  int playingAudio = 0;
  bool audioPlaying = false;
  int selectedAzanMode = 100;
  late SharedPreferences sharedPreferences;
  String zone = '';
  String azanType = '';
  bool loggedIn = false;
  bool subscribed = false;
  Directory? rootPath;
  List<AzanStorageModel> azanList = [];
  bool changing = false;

  @override
  void initState() {
    super.initState();
    selectedAzan = widget.selectedAzan;
    userStateMap = BlocProvider.of<UserStateCubit>(context).checkUserState();
    getShared();
    audioPlayer = AudioPlayer();
    audioPlayer!.playerStateStream.listen((state) async {
      if (state.playing) {
        audioPlaying = true;
      } else {
        audioPlaying = false;
      }

      if (state.processingState == ProcessingState.completed) {
        audioPlaying = false;
      }

      setState(() {});
    });

    azanType = widget.title == 'Subuh'
        ? 'Subuh'
        : widget.title == 'Syuruk' ||
                widget.title == 'Imsak' ||
                widget.title == 'Dhuha'
            ? 'No Azan'
            : 'Normal';

    print(azanType);
  }

  getShared() async {
    sharedPreferences = await SharedPreferences.getInstance();
    selectedAzanMode =
        sharedPreferences.getInt('${widget.title!.toLowerCase()}AzanMode') ?? 0;
    zone = sharedPreferences.getString('district') ?? '';
    String azanStorageList = sharedPreferences.getString('azanstorage') ?? '';
    if (azanStorageList.isNotEmpty) {
      azanList = AzanStorageModel.decode(azanStorageList);
      azanList.forEach((element) {
        print(
            'fileName >>>> ${element.fileName} ,   path >>>> ${element.path}');
      });

      print(azanList.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    String theme = Provider.of<ThemeNotifier>(context).appTheme;

    azansList = BlocProvider.of<HadithCubit>(context).fetchAzans();
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Color.fromRGBO(90, 89, 89, 1),
        appBar: AppBar(
          title: Text(widget.title!),
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
          panel:
              BlocBuilder<UserStateCubit, UserState>(builder: (context, state) {
            if (state is LoginState) {
              userStateMap = state.userStateMap;
              loggedIn =
                  userStateMap != null ? userStateMap!['loggedIn'] : false;
              subscribed =
                  userStateMap != null ? userStateMap!['subscribed'] : false;
            }
            return bottomNavBarWithOpacity(
                context: context,
                loggedIn: state is LoginState
                    ? state.userStateMap!['loggedIn']
                    : false);
          }),
          body:
              BlocBuilder<HadithCubit, HadithState>(builder: (context, state) {
            if (state is AzansListLoaded) {
              azansList = state.azansList;
              if (arrangedAzansList.isNotEmpty) {
                arrangedAzansList.clear();
              }
              azansList.forEach((azan) {
                if (azan.status == 'enable' && azan.type == azanType) {
                  arrangedAzansList.add(azan);
                }
              });

              if (arrangedAzansList != null && arrangedAzansList.length > 1) {
                arrangedAzansList.sort((a, b) => a.order!.compareTo(b.order!));
              }
            }

            // else {
            //   return Column(
            //     children: [
            //       SizedBox(height: (MediaQuery.of(context).size.height / 2) - 75),
            //       CircularProgressIndicator(
            //         color: getColor(theme),
            //       ),
            //     ],
            //   );
            // }

            return Column(
              children: [
                Expanded(
                  flex: 1,
                  child: ListView(
                    children: [
                      SizedBox(height: 8),
                      Theme(
                        data: Theme.of(context)
                            .copyWith(unselectedWidgetColor: Colors.grey),
                        child: RadioListTile(
                          controlAffinity: ListTileControlAffinity.trailing,
                          groupValue: selectedAzanMode,
                          activeColor: getColor(theme),
                          value: 3,
                          onChanged: (value) {
                            sharedPreferences.setString(
                                widget.title!.toLowerCase(), '');
                            setState(() {
                              selectedAzan = '';
                              selectedAzanMode = value as int;
                              sharedPreferences.setInt(
                                  '${widget.title!.toLowerCase()}AzanMode',
                                  value);
                            });
                            BlocProvider.of<HadithCubitCubit>(context)
                                .cancelNotification('Waktu ' + widget.title!);
                          },
                          title: Text(
                            "Tiada notifikasi",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.grey,
                        height: 1,
                      ),
                      Theme(
                        data: Theme.of(context)
                            .copyWith(unselectedWidgetColor: Colors.grey),
                        child: RadioListTile(
                          controlAffinity: ListTileControlAffinity.trailing,
                          groupValue: selectedAzanMode,
                          activeColor: getColor(theme),
                          value: 1,
                          onChanged: (value) async {
                            sharedPreferences.setString(
                                widget.title!.toLowerCase(), '');
                            setState(() {
                              selectedAzan = '';
                              selectedAzanMode = value as int;
                              sharedPreferences.setInt(
                                  '${widget.title!.toLowerCase()}AzanMode',
                                  value);
                            });

                            // await flutterLocalNotificationsPlugin.zonedSchedule(
                            //     Random().nextInt(pow(2, 31).toInt()),
                            //     'Test',
                            //     'Telah masuk waktu solat fardhu ${widget.title} bagi Daerah amda mascalsdam',
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
                            //             importance: Importance.high,
                            //             priority: Priority.max,
                            //             playSound: false,
                            //             styleInformation: BigTextStyleInformation(
                            //                 'Telah masuk waktu solat fardhu Subuh bagi Daerah'))),
                            //     androidAllowWhileIdle: true,
                            //     uiLocalNotificationDateInterpretation:
                            //         UILocalNotificationDateInterpretation
                            //             .absoluteTime,
                            //     payload: '');
                            sharedPreferences.setInt(
                                '${widget.title!.toLowerCase()}AdditionalTime',
                                0);

                            BlocProvider.of<HadithCubitCubit>(context)
                                .changeNotification(
                                    'Waktu ' + widget.title!, 1, 0, 0);
                          },
                          title: Text(
                            "Tiada bunyi",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.grey,
                        height: 1,
                      ),
                      Theme(
                        data: Theme.of(context)
                            .copyWith(unselectedWidgetColor: Colors.grey),
                        child: RadioListTile(
                          controlAffinity: ListTileControlAffinity.trailing,
                          activeColor: getColor(theme),
                          groupValue: selectedAzanMode,
                          value: 0,
                          onChanged: (value) async {
                            sharedPreferences.setString(
                                widget.title!.toLowerCase(), '');
                            sharedPreferences.setInt(
                                '${widget.title!.toLowerCase()}AzanMode',
                                value as int);
                            setState(() {
                              selectedAzan = '';
                              selectedAzanMode = value;
                            });

                            // await flutterLocalNotificationsPlugin.zonedSchedule(
                            //     Random().nextInt(pow(2, 31).toInt()),
                            //     'Test',
                            //     'Telah masuk waktu solat fardhu ${widget.title} bagi Daerah amda mascalsdam',
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
                            //             importance: Importance.high,
                            //             priority: Priority.max,
                            //             playSound: true,
                            //             styleInformation: BigTextStyleInformation(
                            //                 'Telah masuk waktu solat fardhu Subuh bagi Daerah'))),
                            //     androidAllowWhileIdle: true,
                            //     uiLocalNotificationDateInterpretation:
                            //         UILocalNotificationDateInterpretation
                            //             .absoluteTime,
                            //     payload: '');
                            sharedPreferences.setInt(
                                '${widget.title!.toLowerCase()}AdditionalTime',
                                0);
                            BlocProvider.of<HadithCubitCubit>(context)
                                .changeNotification(
                                    'Waktu ' + widget.title!, 0, 0, 0);
                          },
                          title: Text(
                            "Bunyi sistem",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.grey,
                        height: 1,
                      ),
                      BlocBuilder<HadithCubitCubit, HadithCubitState>(
                          builder: (context, state) {
                        if (state is NotificationAudioChanged) {
                          print('changed');
                          changing = false;
                        }

                        if (state is ChanginNotificationAudio) {
                          print('changing');
                          changing = true;
                        }
                        return Column(
                          children: [
                            ...arrangedAzansList
                                .map((azan) => Column(
                                      children: [
                                        ListTile(
                                          onTap: () async {
                                            if (arrangedAzansList
                                                        .indexOf(azan) <=
                                                    3 ||
                                                subscribed) {
                                              sharedPreferences.setInt(
                                                  '${widget.title!.toLowerCase()}AzanMode',
                                                  100);
                                              setState(() {
                                                selectedAzanMode = 100;
                                                selectedAzan = azan.name;
                                              });
                                              SharedPreferences shared =
                                                  await SharedPreferences
                                                      .getInstance();
                                              shared.setString(
                                                  widget.title!.toLowerCase(),
                                                  selectedAzan!);
                                              shared.setString(
                                                  '${widget.title!.toLowerCase()}SoundUrl',
                                                  'https://salam.mukminapps.com/images/' +
                                                      azan.audio!);
                                              print('from Internet');
                                              print(
                                                  '*******https://salam.mukminapps.com/images/' +
                                                      '${azan.audio}');
                                              try {
                                                // await flutterLocalNotificationsPlugin
                                                //     .zonedSchedule(
                                                //         Random().nextInt(
                                                //             pow(2, 31).toInt()),
                                                //         'Test',
                                                //         'Telah masuk waktu solat fardhu ${widget.title} bagi Daerah amda mascalsdam',
                                                //         tz.TZDateTime.now(tz.getLocation('Asia/Kuala_Lumpur')).add(
                                                //             Duration(minutes: 1)),
                                                //         NotificationDetails(
                                                //             iOS:
                                                //                 IOSNotificationDetails(
                                                //               presentAlert: true,
                                                //               presentBadge: true,
                                                //               presentSound: true,
                                                //             ),
                                                //             android: AndroidNotificationDetails(
                                                //                 'scheduledCustomImsakSound${Random().nextInt(pow(2, 31).toInt())}', 'Test',
                                                //                 channelDescription:
                                                //                     'your channel description',
                                                //                 color:
                                                //                     Colors.green,
                                                //                 importance: Importance
                                                //                     .high,
                                                //                 priority:
                                                //                     Priority.max,
                                                //                 playSound: true,
                                                //                 sound: UriAndroidNotificationSound('https://salam.mukminapps.com/images/' +
                                                //                     azan.audio),
                                                //                 styleInformation: BigTextStyleInformation(
                                                //                     'Telah masuk waktu solat fardhu Subuh bagi Daerah'))),
                                                //         androidAllowWhileIdle:
                                                //             true,
                                                //         uiLocalNotificationDateInterpretation:
                                                //             UILocalNotificationDateInterpretation
                                                //                 .absoluteTime,
                                                //         payload: '');
                                                sharedPreferences.setInt(
                                                    '${widget.title!.toLowerCase()}AdditionalTime',
                                                    0);
                                                BlocProvider.of<
                                                            HadithCubitCubit>(
                                                        context)
                                                    .changeNotification(
                                                        'Waktu ' +
                                                            widget.title!,
                                                        2,
                                                        0,
                                                        0);
                                              } catch (e) {
                                                print('!!!!!!!!!!!$e');
                                                Fluttertoast.showToast(
                                                    msg: e.toString(),
                                                    toastLength:
                                                        Toast.LENGTH_LONG);
                                              }
                                            } else {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          NaikTarafScreen()));
                                            }
                                          },
                                          title: Text(
                                            azan.name ?? '',
                                            style: TextStyle(
                                                color:
                                                    arrangedAzansList.indexOf(
                                                                    azan) <=
                                                                3 ||
                                                            subscribed
                                                        ? Colors.white
                                                        : Colors.grey),
                                          ),
                                          trailing: SizedBox(
                                            width: 60,
                                            height: 60,
                                            child: Row(
                                              children: [
                                                InkWell(
                                                  onTap: () async {
                                                    if (arrangedAzansList
                                                                .indexOf(
                                                                    azan) <=
                                                            3 ||
                                                        subscribed) {
                                                      print(
                                                          '~~~~~` subscribed');
                                                      if (audioPlayer!
                                                              .playing &&
                                                          playingAudio ==
                                                              azan.id) {
                                                        audioPlayer!.pause();
                                                      } else if (audioPlayer!
                                                                  .processingState ==
                                                              ProcessingState
                                                                  .idle ||
                                                          audioPlayer!
                                                                  .processingState ==
                                                              ProcessingState
                                                                  .completed ||
                                                          playingAudio !=
                                                              azan.id) {
                                                        print('audio');
                                                        print(azan.audio);

                                                        try {
                                                          await audioPlayer!
                                                              .dynamicSet(
                                                                  url: 'https://salam.mukminapps.com/images/' +
                                                                      azan.audio!)
                                                              .then((value) {
                                                            audioPlayer!.play();
                                                          });
                                                        } catch (e) {
                                                          Fluttertoast.showToast(
                                                              msg: e.toString(),
                                                              toastLength: Toast
                                                                  .LENGTH_LONG);
                                                        }
                                                      } else {
                                                        audioPlayer!.play();
                                                      }
                                                      setState(() {
                                                        playingAudio = azan.id!;
                                                      });
                                                    } else {
                                                      Navigator.of(context).push(
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  NaikTarafScreen()));
                                                    }
                                                  },
                                                  child: Icon(
                                                    audioPlaying &&
                                                            playingAudio ==
                                                                azan.id
                                                        ? Icons
                                                            .pause_circle_filled
                                                        : Icons
                                                            .play_circle_filled,
                                                    color: arrangedAzansList
                                                                    .indexOf(
                                                                        azan) <=
                                                                3 ||
                                                            subscribed
                                                        ? Colors.white
                                                        : Colors.grey,
                                                    size: 22,
                                                  ),
                                                ),
                                                SizedBox(width: 6),
                                                arrangedAzansList
                                                                .indexOf(azan) >
                                                            3 &&
                                                        !subscribed
                                                    ? Icon(Icons.lock,
                                                        color: Colors.white,
                                                        size: 22)
                                                    : azan.name == selectedAzan
                                                        ? Icon(
                                                            Icons
                                                                .check_circle_outline,
                                                            color:
                                                                getColor(theme),
                                                            size: 22,
                                                          )
                                                        : SizedBox(width: 22),
                                                SizedBox(width: 6)
                                              ],
                                            ),
                                          ),
                                        ),
                                        Divider(
                                          color: Colors.grey,
                                          height: 1,
                                        ),
                                      ],
                                    ))
                                .toList(),
                            if (azanType != 'No Azan')
                              ...azanList
                                  .map((azan) => Column(
                                        children: [
                                          ListTile(
                                            onTap: () async {
                                              sharedPreferences.setInt(
                                                  '${widget.title!.toLowerCase()}AzanMode',
                                                  100);
                                              setState(() {
                                                selectedAzanMode = 100;
                                                selectedAzan = azan.fileName;
                                              });
                                              SharedPreferences shared =
                                                  await SharedPreferences
                                                      .getInstance();
                                              shared.setString(
                                                  widget.title!.toLowerCase(),
                                                  selectedAzan!);
                                              shared.setString(
                                                  '${widget.title!.toLowerCase()}SoundUrl',
                                                  azan.path!);

                                              try {
                                                print('*******${azan.path}');
                                                // await flutterLocalNotificationsPlugin
                                                //     .zonedSchedule(
                                                //         Random().nextInt(
                                                //             pow(2, 31).toInt()),
                                                //         'testtt',
                                                //         'Telah masuk waktu solat fardhu ${widget.title} bagi Daerah amda mascalsdam',
                                                //         tz.TZDateTime.now(tz.getLocation('Asia/Kuala_Lumpur')).add(
                                                //             Duration(minutes: 1)),
                                                //         NotificationDetails(
                                                //             iOS:
                                                //                 IOSNotificationDetails(
                                                //               presentAlert: true,
                                                //               presentBadge: true,
                                                //               presentSound: true,
                                                //             ),
                                                //             android: AndroidNotificationDetails(
                                                //                 'scheduledCustomImsakSound${Random().nextInt(pow(2, 31).toInt())}',
                                                //                 'scheduledCustomImsakSound',
                                                //                 channelDescription:
                                                //                     'your channel description',
                                                //                 color:
                                                //                     Colors.green,
                                                //                 importance: Importance
                                                //                     .high,
                                                //                 priority:
                                                //                     Priority.max,
                                                //                 playSound: true,
                                                //                 sound: UriAndroidNotificationSound(
                                                //                     azan.path),
                                                //                 styleInformation: BigTextStyleInformation(
                                                //                     'Telah masuk waktu solat fardhu Subuh bagi Daerah'))),
                                                //         androidAllowWhileIdle:
                                                //             true,
                                                //         uiLocalNotificationDateInterpretation:
                                                //             UILocalNotificationDateInterpretation
                                                //                 .absoluteTime,
                                                //         payload: '');
                                                sharedPreferences.setInt(
                                                    '${widget.title!.toLowerCase()}AdditionalTime',
                                                    0);
                                                BlocProvider.of<
                                                            HadithCubitCubit>(
                                                        context)
                                                    .changeNotification(
                                                        'Waktu ' +
                                                            widget.title!,
                                                        2,
                                                        0,
                                                        0);
                                              } catch (e) {
                                                Fluttertoast.showToast(
                                                    msg: e.toString(),
                                                    toastLength:
                                                        Toast.LENGTH_LONG);
                                              }
                                            },
                                            title: Text(
                                              azan.fileName ?? '',
                                              style: TextStyle(
                                                  color:
                                                      azanList.indexOf(azan) <=
                                                                  3 ||
                                                              subscribed
                                                          ? Colors.white
                                                          : Colors.grey),
                                            ),
                                            trailing: SizedBox(
                                              width: 60,
                                              height: 60,
                                              child: Row(
                                                children: [
                                                  InkWell(
                                                    onTap: () async {
                                                      if (azanList.indexOf(
                                                                  azan) <=
                                                              3 ||
                                                          subscribed) {
                                                        if (audioPlayer!
                                                                .playing &&
                                                            playingAudio ==
                                                                azanList
                                                                    .indexOf(
                                                                        azan)) {
                                                          audioPlayer!.pause();
                                                        } else if (audioPlayer!
                                                                    .processingState ==
                                                                ProcessingState
                                                                    .idle ||
                                                            audioPlayer!
                                                                    .processingState ==
                                                                ProcessingState
                                                                    .completed ||
                                                            playingAudio !=
                                                                azanList
                                                                    .indexOf(
                                                                        azan)) {
                                                          try {
                                                            print('~~~~~~');
                                                            print(azan.path);

                                                            await audioPlayer!
                                                                .dynamicSet(
                                                                    url: azan
                                                                        .path!)
                                                                .then((value) {
                                                              audioPlayer!
                                                                  .play();
                                                            });
                                                          } catch (e) {
                                                            Fluttertoast.showToast(
                                                                msg: e
                                                                    .toString(),
                                                                toastLength: Toast
                                                                    .LENGTH_LONG);
                                                          }
                                                        } else {
                                                          print('~~~~~~');
                                                          print(azan.path);
                                                          audioPlayer!.play();
                                                        }
                                                        setState(() {
                                                          playingAudio =
                                                              azanList.indexOf(
                                                                  azan);
                                                        });
                                                      } else {
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        NaikTarafScreen()));
                                                      }
                                                    },
                                                    child: Icon(
                                                      audioPlaying &&
                                                              playingAudio ==
                                                                  azanList.indexOf(
                                                                      azan)
                                                          ? Icons
                                                              .pause_circle_filled
                                                          : Icons
                                                              .play_circle_filled,
                                                      color: azanList.indexOf(
                                                                      azan) <=
                                                                  3 ||
                                                              subscribed
                                                          ? Colors.white
                                                          : Colors.grey,
                                                      size: 22,
                                                    ),
                                                  ),
                                                  SizedBox(width: 6),
                                                  azanList.indexOf(azan) > 3 &&
                                                          !subscribed
                                                      ? Icon(Icons.lock,
                                                          color: Colors.white,
                                                          size: 22)
                                                      : azan.fileName ==
                                                                  selectedAzan &&
                                                              !changing
                                                          ? Icon(
                                                              Icons
                                                                  .check_circle_outline,
                                                              color: getColor(
                                                                  theme),
                                                              size: 22,
                                                            )
                                                          : azan.fileName ==
                                                                  selectedAzan
                                                              ? Center(
                                                                  child:
                                                                      Container(
                                                                    height: 15,
                                                                    width: 15,
                                                                    child:
                                                                        CircularProgressIndicator(
                                                                      color: getColor(
                                                                          theme),
                                                                      strokeWidth:
                                                                          1,
                                                                    ),
                                                                  ),
                                                                )
                                                              : SizedBox(
                                                                  width: 22),
                                                  SizedBox(width: 6)
                                                ],
                                              ),
                                            ),
                                          ),
                                          Divider(
                                            color: Colors.grey,
                                            height: 1,
                                          ),
                                        ],
                                      ))
                                  .toList(),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
                Expanded(flex: 0, child: SizedBox(height: 10)),
                azanType != 'No Azan'
                    ? Expanded(
                        flex: 0,
                        child: SizedBox(
                          width: 250,
                          height: 43,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xFF807BB2),
                            ),
                            onPressed: () async {
                              FilePickerResult? result = await FilePicker
                                  .platform
                                  .pickFiles(type: FileType.audio);

                              if (result != null) {
                                File file = File(result.files.single.path!);
                                Directory? directory = Platform.isAndroid
                                    ? await getExternalStorageDirectory() //FOR ANDROID
                                    : await getApplicationSupportDirectory(); //FOR iOS
                                final String filePath =
                                    '${directory!.path}/${file.path.split('/').last}';

                                final File filee = File(filePath);
                                await file.copy(filePath);
                                print(filePath);
                                print('path');
                                azanList.add(AzanStorageModel(
                                    fileName: file.path
                                        .split('/')
                                        .last
                                        .split('.')
                                        .first,
                                    path: 'file://' + filePath));

                                sharedPreferences.setString('azanstorage',
                                    AzanStorageModel.encode(azanList));
                                setState(() {});

                                // await flutterLocalNotificationsPlugin.zonedSchedule(
                                //     Random().nextInt(pow(2, 31).toInt()),
                                //     'Test',
                                //     'Telah masuk waktu solat fardhu ${widget.title} bagi Daerah amda mascalsdam',
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
                                //             importance: Importance.high,
                                //             priority: Priority.max,
                                //             playSound: false,
                                //             styleInformation: BigTextStyleInformation(
                                //                 'Telah masuk waktu solat fardhu Subuh bagi Daerah'))),
                                //     androidAllowWhileIdle: true,
                                //     uiLocalNotificationDateInterpretation:
                                //         UILocalNotificationDateInterpretation
                                //             .absoluteTime,
                                //     payload: '');
                              } else {
                                // User canceled the picker

                                Fluttertoast.showToast(
                                    msg: 'Selecting audio cancelled',
                                    toastLength: Toast.LENGTH_LONG);
                              }
                              // if (!loggedIn) {
                              //   Navigator.of(context)
                              //       .push(MaterialPageRoute(
                              //           builder: (context) => LoginScreen()))
                              //       .then((value) {
                              //     setState(() {});
                              //   });
                              // } else if (!subscribed) {
                              //   Navigator.of(context)
                              //       .push(MaterialPageRoute(
                              //           builder: (context) =>
                              //               NaikTarafScreen()))
                              //       .then((value) {
                              //     setState(() {});
                              //   });
                              // } else {
                              //   FilePickerResult result = await FilePicker
                              //       .platform
                              //       .pickFiles(type: FileType.audio);

                              //   if (result != null) {
                              //     File file = File(result.files.single.path);
                              //     print(result.files.single.path);
                              //     print(file.uri);
                              //     azanList.add(AzanStorageModel(
                              //         fileName: file.path
                              //             .split('/')
                              //             .last
                              //             .split('.')
                              //             .first,
                              //         path: file.uri.toString()));

                              //     sharedPreferences.setString('azanstorage',
                              //         AzanStorageModel.encode(azanList));
                              //   } else {
                              //     // User canceled the picker
                              //   }
                              // }
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/images/main_screen_icons/masjid_icon.png',
                                  width: 24,
                                  height: 24,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text("Klik untuk Tambah Azan"),
                                // SizedBox(
                                //   width: 5,
                                // ),
                                // !loggedIn || !subscribed
                                //     ? Icon(Icons.lock,
                                //         color: Colors.white, size: 22)
                                //     : Container()
                              ],
                            ),
                          ),
                        ),
                      )
                    : Container(),
                Expanded(flex: 0, child: SizedBox(height: 200))
              ],
            );
          }),
        ),
      ),
    );
  }
}
