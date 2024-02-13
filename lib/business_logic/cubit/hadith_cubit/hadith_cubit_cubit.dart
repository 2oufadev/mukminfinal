import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:mukim_app/data/models/hadith_category_model.dart';
import 'package:mukim_app/data/models/hadith_model.dart';
import 'package:mukim_app/data/models/hadith_model_separate.dart';
import 'package:mukim_app/data/models/home_screen_model.dart';
import 'package:mukim_app/data/models/month_prayer_model.dart';
import 'package:mukim_app/data/models/one_day_hadith_model.dart';
import 'package:mukim_app/data/repository/hadith_repository.dart';
import 'package:mukim_app/resources/constants.dart';
import 'package:mukim_app/resources/global.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../../main.dart';

part 'hadith_cubit_state.dart';

class HadithCubitCubit extends Cubit<HadithCubitState> {
  final HadithRepository hadithRepository;
  List<HomeScreenModel> homeHadithList = [];
  List<HadithCategoryModel> hadithCategoriesList = [];
  List<ReadyHadithModel> hadithList = [];
  List<OneDayHadithModel> oneDayHadithList = [];

  HadithCubitCubit(this.hadithRepository) : super(HadithCubitInitial());

  List<HomeScreenModel> fetchHadith() {
    emit(HadithImagesLoading());
    hadithRepository.fetchHadithHomeScreen().then((hadithList) {
      this.homeHadithList = hadithList;
      emit(HadithImagesLoaded(hadithList));
    });
    return this.homeHadithList;
  }

  List<ReadyHadithModel> fetchHadithList(
    String widgetId,
  ) {
    emit(HadithListLoading());
    hadithRepository
        .fetchArangedHadith(
      widgetId,
    )
        .then((returnedData) {
      emit(HadithListLoaded(
          returnedData['arragnedList'], returnedData['likedList']));
      this.hadithList = hadithList;
    });

    return this.hadithList;
  }

  void enableAzanNotificationsSilent(String azan, String district) {
    hadithRepository.fetchMonthAzans(DateTime.now()).then((azansList) {
      tz.initializeTimeZones();
      switch (azan) {
        case 'Imsak':
          return enableImsakNotifications(azansList, district, 0, 0);
        case 'Subuh':
          return enableSubuhNotifications(azansList, district, 0, 0);
        case 'Syuruk':
          return enableSyurukNotifications(azansList, district, 0, 0);
        case 'Dhuha':
          return enableDhuhaNotifications(azansList, district, 0, 0);
        case 'Zohor':
          return enableZohorNotifications(azansList, district, 0, 0);
        case 'Asar':
          return enableAsarNotifications(azansList, district, 0, 0);
        case 'Maghrib':
          return enableMaghribNotifications(azansList, district, 0, 0);
        case 'Isyak':
          return enableIsyakNotifications(azansList, district, 0, 0);
      }
    });
  }

  void enableAzanNotificationsSound(String azan, String district) async {
    hadithRepository.fetchMonthAzans(DateTime.now()).then((azansList) {
      tz.initializeTimeZones();
      switch (azan) {
        case 'Imsak':
          return enableImsakSoundNotifications(azansList, district, 0, 0);
        case 'Subuh':
          return enableSubuhSoundNotifications(azansList, district, 0, 0);
        case 'Syuruk':
          return enableSyurukSoundNotifications(azansList, district, 0, 0);
        case 'Dhuha':
          return enableDhuhaSoundNotifications(azansList, district, 0, 0);
        case 'Zohor':
          return enableZohorSoundNotifications(azansList, district, 0, 0);
        case 'Asar':
          return enableAsarSoundNotifications(azansList, district, 0, 0);
        case 'Maghrib':
          return enableMaghribSoundNotifications(azansList, district, 0, 0);
        case 'Isyak':
          return enableIsyakSoundNotifications(azansList, district, 0, 0);
      }
    });
  }

  void fetchMonthAzan(String district) async {
    hadithRepository.fetchMonthAzans(DateTime.now()).then((azansList) {
      print('@@@@@@@@@@@ ${azansList.length}');
    });
  }

  void enableAllAzanNotificationsSound(String district) async {
    print('~~~~~$district');
    // flutterLocalNotificationsPlugin.cancelAll();

    print('canceled');
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    tz.TZDateTime latestNotificationDate =
        tz.TZDateTime.fromMillisecondsSinceEpoch(
            tz.getLocation('Asia/Kuala_Lumpur'),
            sharedPreferences.getInt('latestNotificationDate') ??
                DateTime.now().toUtc().millisecondsSinceEpoch);

    print('<<<<<<<<<<<<$latestNotificationDate');
    print(latestNotificationDate.difference(DateTime.now()).inDays);

    if (latestNotificationDate.difference(DateTime.now()).inDays < 3) {
      try {
        hadithRepository.fetchMonthAzans(DateTime.now()).then((azansList) {
          print('@@@@@@@@@@@ ${azansList.length}');
          tz.initializeTimeZones();
          // testNotif();
          enableImsakSoundNotifications(azansList, district, 0, 0);
          enableSubuhSoundNotifications(azansList, district, 0, 0);
          enableSyurukSoundNotifications(azansList, district, 0, 0);
          enableDhuhaSoundNotifications(azansList, district, 0, 0);
          enableZohorSoundNotifications(azansList, district, 0, 0);
          enableAsarSoundNotifications(azansList, district, 0, 0);
          enableMaghribSoundNotifications(azansList, district, 0, 0);
          enableIsyakSoundNotifications(azansList, district, 0, 0);
          flutterLocalNotificationsPlugin.pendingNotificationRequests().then(
            (value) {
              print(value.length);
              value.forEach((element) {
                print('-------${element.title}---- ${element.id}');
              });
            },
          );
        });
      } catch (e) {}
    }
  }

  testNotif() async {
    int random = Random().nextInt(pow(2, 31).toInt());
    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
          random,
          'Waktu TEST',
          'Telah masuk waktu Imsak bagi Daerah amda mascalsdam',
          tz.TZDateTime.now(tz.getLocation('Asia/Kuala_Lumpur'))
              .add(Duration(seconds: 60)),
          NotificationDetails(
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
              android: AndroidNotificationDetails(
                  '${random.toString()} test', 'TEST',
                  channelDescription: 'your channel description',
                  color: Colors.green,
                  playSound: true,
                  priority: Priority.high,
                  importance: Importance.high,
                  sound: UriAndroidNotificationSound(
                      'https://salam.mukminapps.com/images/1645477616.mp3'),
                  styleInformation: BigTextStyleInformation(''))),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: '');
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), toastLength: Toast.LENGTH_LONG);
    }
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    Directory? directory = Platform.isAndroid
        ? await getExternalStorageDirectory() //FOR ANDROID
        : await getApplicationSupportDirectory(); //FOR iOS
    final String filePath = '${directory!.path}/$fileName.png';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  List<OneDayHadithModel> fetchOneDayHadithList() {
    List<HadithCategoryModel> hadithCategoriesList = [];
    List<OneDayHadithModel> oneDayHadithList = [];
    // NotificationUtils.cancelSchedulesByChannelKey('scheduledHadith');

    hadithRepository.fetchHadithCategories().then((categories) async {
      tz.initializeTimeZones();
      hadithCategoriesList = categories;
      flutterLocalNotificationsPlugin
          .pendingNotificationRequests()
          .then((value) async {
        print(value.length);

        for (PendingNotificationRequest element in value) {
          if (element.title!.contains('HADITH') ||
              element.body!.contains('HADITH')) {
            flutterLocalNotificationsPlugin.cancel(element.id);
            print('canceled ${element.title}  >> ${element.payload}');
          }
        }
      });

      List<Map> oneDayHadithMapList =
          await AudioConstants.database!.rawQuery('SELECT * FROM "hadith"');

      if (oneDayHadithMapList.isNotEmpty) {
        List<dynamic> data =
            jsonDecode(oneDayHadithMapList.first['value'].toString());

        oneDayHadithList =
            data.map((e) => OneDayHadithModel.fromJson(e)).toList();
      } else {
        List<HadithModelSeparate> hadithList =
            await hadithRepository.fetchHadith();
        for (var hadith in hadithList.first.data!) {
          if (hadith.status == 'enable' &&
              oneDayHadithList
                      .indexWhere((element) => element.id == hadith.id) ==
                  -1) {
            int categoryIndex = hadithCategoriesList
                .indexWhere((element) => element.id == hadith.categoryId);

            int hadithShown = 0;

            oneDayHadithList.add(OneDayHadithModel(
                hadith.id,
                hadithCategoriesList[categoryIndex].id,
                hadithShown,
                hadith.name,
                hadithCategoriesList[categoryIndex].name,
                hadith.image,
                hadith.description));
          }
        }
        await AudioConstants.database!.insert(
            'hadith',
            {
              'id': 1,
              'value': json.encode(oneDayHadithList),
            },
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      oneDayHadithList.sort((a, b) => a.shown!.compareTo(b.shown!));
      // tz.TZDateTime now = tz.TZDateTime.now(tz.getLocation('Africa/Cairo'));
      // await flutterLocalNotificationsPlugin
      //     .zonedSchedule(
      //         1231231,
      //         'test',
      //         'test details',
      //         now.add(Duration(minutes: 2)),
      //         NotificationDetails(
      //             iOS: DarwinNotificationDetails(
      //               presentAlert: true,
      //               presentBadge: true,
      //               presentSound: true,
      //             ),
      //             android: AndroidNotificationDetails(
      //                 'scheduledHadith', 'Hadith',
      //                 channelDescription: 'your channel description',
      //                 playSound: true,
      //                 priority: Priority.high,
      //                 importance: Importance.high,
      //                 color: Colors.green,
      //                 actions: [
      //                   // AndroidNotificationAction('1', 'VIEW', contextual: true),
      //                   AndroidNotificationAction('DailyHadithShare', 'SHARE',
      //                       contextual: true)
      //                 ],
      //                 styleInformation: BigPictureStyleInformation(
      //                     FilePathAndroidBitmap(
      //                         oneDayHadithList.first.hadithImage)))),
      //         androidAllowWhileIdle: true,
      //         uiLocalNotificationDateInterpretation:
      //             UILocalNotificationDateInterpretation.absoluteTime,
      //         payload:
      //             '${oneDayHadithList.first.categoryId.toString()}!${oneDayHadithList.first.id.toString()}!${oneDayHadithList.first.categoryName}!${oneDayHadithList.first.categoryName + ' - ' + oneDayHadithList.first.hadithName}!${Globals.images_url + oneDayHadithList.first.hadithImage}')
      //     .then((value) {
      //   print('******************************');
      // });

      for (int i = 0; i < oneDayHadithList.length && i <= 14; i++) {
        tz.TZDateTime now =
            tz.TZDateTime.now(tz.getLocation('Asia/Kuala_Lumpur'));
        int random = Random().nextInt(pow(2, 31).toInt());
        tz.TZDateTime notificationTime = tz.TZDateTime(
            tz.getLocation('Asia/Kuala_Lumpur'),
            now.year,
            now.month,
            now.hour < 11 ? i + (now.day) : i + 1 + (now.day),
            11);

        try {
          await _downloadAndSaveFile(
                  Globals.images_url + oneDayHadithList[i].hadithImage!,
                  oneDayHadithList[i].hadithImage!.split('.').first)
              .then((value) async {
            await flutterLocalNotificationsPlugin
                .zonedSchedule(
                    random,
                    oneDayHadithList[i].categoryName! +
                        ' - ' +
                        oneDayHadithList[i].hadithName!,
                    oneDayHadithList[i].description,
                    notificationTime,
                    NotificationDetails(
                        iOS: DarwinNotificationDetails(
                          presentAlert: true,
                          presentBadge: true,
                          presentSound: true,
                        ),
                        android: AndroidNotificationDetails(
                            'scheduledHadith$random', 'Hadith',
                            channelDescription: 'your channel description',
                            playSound: true,
                            priority: Priority.high,
                            importance: Importance.high,
                            color: Colors.green,
                            actions: [
                              // AndroidNotificationAction('1', 'VIEW', contextual: true),
                              AndroidNotificationAction(
                                  'DailyHadithShare', 'SHARE',
                                  icon:
                                      DrawableResourceAndroidBitmap("app_icon"),
                                  contextual: true)
                            ],
                            styleInformation: BigPictureStyleInformation(
                                FilePathAndroidBitmap(value)))),
                    androidAllowWhileIdle: true,
                    uiLocalNotificationDateInterpretation:
                        UILocalNotificationDateInterpretation.absoluteTime,
                    payload:
                        '${oneDayHadithList[i].categoryId.toString()}!${oneDayHadithList[i].id.toString()}!${oneDayHadithList[i].categoryName}!${oneDayHadithList[i].categoryName! + ' - ' + oneDayHadithList[i].hadithName!}!${Globals.images_url + oneDayHadithList[i].hadithImage!}')
                .then((value) {});
            // NotificationUtils.scheduleHadithNotifications(
            //     notificationTime,
            //     oneDayHadithList[i].categoryName +
            //         ' - ' +
            //         oneDayHadithList[i].hadithName,
            //     oneDayHadithList[i].description,
            //     Globals.images_url + oneDayHadithList[i].hadithImage,
            //     oneDayHadithList[i].categoryId.toString(),
            //     oneDayHadithList[i].id.toString(),
            //     oneDayHadithList[i].categoryName);
            oneDayHadithList[i].shown = oneDayHadithList[i].shown! + 1;
            await AudioConstants.database!.insert(
                'hadith',
                {
                  'id': 1,
                  'value': json.encode(oneDayHadithList),
                },
                conflictAlgorithm: ConflictAlgorithm.replace);
            print(
                '~~~~~~~~~~~~~$notificationTime  ${tz.TZDateTime.now(tz.getLocation('Asia/Kuala_Lumpur'))}');
          });
        } catch (e) {}
      }
    });

    return this.oneDayHadithList;
  }

  List<HadithCategoryModel> fetchHadithCategories() {
    hadithRepository.fetchArangedHadithCategories().then((hadithCategories) {
      emit(HadithCategoriesLoaded(hadithCategories));
      hadithCategoriesList = hadithCategories;
    });

    return hadithCategoriesList;
  }

  void enableImsakNotifications(List<PrayerModel> azansList, String district,
      int additionalTimeMode, int additionalTime) {
    DateTime now = DateTime.now();
    tz.TZDateTime dateTime =
        tz.TZDateTime.now(tz.getLocation('Asia/Kuala_Lumpur'));
    azansList.forEach((element) async {
      DateTime date = DateFormat('dd-MMM-yyyy HH:mm')
          .parse(element.date! + ' ${element.imsak}');

      if (now.compareTo(date) < 0) {
        int random = Random().nextInt(pow(2, 31).toInt());

        tz.TZDateTime finalDateTime = dateTime
            .add(date.difference(now))
            .add(Duration(minutes: additionalTime));

        await flutterLocalNotificationsPlugin
            .zonedSchedule(
                random,
                additionalTimeMode == 1
                    ? 'Peringatan Waktu Imsak'
                    : additionalTimeMode == 2
                        ? 'Peringatan Waktu Imsak'
                        : 'Waktu Imsak',
                additionalTimeMode == 1
                    ? '${-additionalTime} Minit lagi akan masuk waktu Imsak bagi Daerah $district (${element.imsak})'
                    : additionalTimeMode == 2
                        ? '$additionalTime Minit telah masuk waktu Imsak bagi Daerah $district (${element.imsak})'
                        : 'Telah masuk waktu Imsak bagi Daerah $district (${element.imsak})',
                finalDateTime,
                NotificationDetails(
                    iOS: DarwinNotificationDetails(
                      presentAlert: true,
                      presentBadge: true,
                      presentSound: false,
                    ),
                    android: AndroidNotificationDetails(
                        'scheduledImsakSilent$random', 'Imsak',
                        channelDescription: 'your channel description',
                        playSound: false,
                        priority: Priority.high,
                        importance: Importance.high,
                        color: Colors.green,
                        styleInformation: BigTextStyleInformation(''))),
                androidAllowWhileIdle: true,
                payload: finalDateTime.toString(),
                uiLocalNotificationDateInterpretation:
                    UILocalNotificationDateInterpretation.absoluteTime)
            .then((value) {});
      }
    });
  }

  // void enableImsakCustomNotifications(
  //     List<PrayerModel> azansList, String district) {
  //   DateTime now = DateTime.now();
  //   tz.TZDateTime dateTime =
  //       tz.TZDateTime.now(tz.getLocation('Asia/Kuala_Lumpur'));
  //   azansList.forEach((element) async {
  //     DateTime date = DateFormat('dd-MMM-yyyy HH:mm')
  //         .parse(element.date! + ' ${element.imsak}');

  //     if (now.compareTo(date) < 0) {
  //       int random = Random().nextInt(pow(2, 31).toInt());

  //       await flutterLocalNotificationsPlugin.zonedSchedule(
  //           random,
  //           'Waktu Imsak',
  //           'Telah masuk waktu solat fardhu Imsak bagi Daerah $district (${element.imsak})',
  //           dateTime.add(date.difference(now)),
  //           NotificationDetails(
  //               android: AndroidNotificationDetails(
  //                   'scheduledImsakSilent', 'scheduledImsakSilent',
  //                   channelDescription: 'your channel description',
  //                   playSound: false,
  //                   color: Colors.green,
  //                   styleInformation: BigTextStyleInformation(
  //                       'Telah masuk waktu solat fardhu Imsak bagi Daerah $district (${element.imsak})'))),
  //           androidAllowWhileIdle: true,
  //           uiLocalNotificationDateInterpretation:
  //               UILocalNotificationDateInterpretation.absoluteTime);
  //     }
  //   });
  // }

  void enableSubuhCustomNotifications(
      List<PrayerModel> azansList,
      String district,
      String azanUrl,
      int additionalTimeMode,
      int additionalTime) {
    DateTime now = DateTime.now();
    tz.TZDateTime dateTime =
        tz.TZDateTime.now(tz.getLocation('Asia/Kuala_Lumpur'));
    azansList.forEach((element) async {
      DateTime date = DateFormat('dd-MMM-yyyy HH:mm')
          .parse(element.date! + ' ${element.subuh}');

      if (now.compareTo(date) < 0) {
        int random = Random().nextInt(pow(2, 31).toInt());
        tz.TZDateTime finalDateTime = dateTime
            .add(date.difference(now))
            .add(Duration(minutes: additionalTime));

        await flutterLocalNotificationsPlugin
            .zonedSchedule(
                random,
                additionalTimeMode == 1
                    ? 'Peringatan Waktu Subuh'
                    : additionalTimeMode == 2
                        ? 'Peringatan Waktu Subuh'
                        : 'Waktu Subuh',
                additionalTimeMode == 1
                    ? '${-additionalTime} Minit lagi akan masuk waktu Subuh bagi Daerah $district (${element.subuh})'
                    : additionalTimeMode == 2
                        ? '$additionalTime Minit telah masuk waktu Subuh bagi Daerah $district (${element.subuh})'
                        : 'Telah masuk waktu solat fardhu Subuh bagi Daerah $district (${element.subuh})',
                finalDateTime,
                NotificationDetails(
                    android: AndroidNotificationDetails(
                        'scheduledSubuhCustom$random', 'Subuh',
                        channelDescription: 'your channel description',
                        playSound: true,
                        priority: Priority.high,
                        importance: Importance.high,
                        sound: UriAndroidNotificationSound(azanUrl),
                        color: Colors.green,
                        styleInformation: BigTextStyleInformation('')),
                    iOS: DarwinNotificationDetails(
                      presentAlert: true,
                      presentBadge: true,
                      presentSound: true,
                    )),
                androidAllowWhileIdle: true,
                payload: finalDateTime.toString(),
                uiLocalNotificationDateInterpretation:
                    UILocalNotificationDateInterpretation.absoluteTime)
            .then((value) {
          print('enabled custom sound $random');
        });
      }
    });
  }

  // void enableSyurukCustomNotifications(
  //     List<PrayerModel> azansList, String district) {
  //   DateTime now = DateTime.now();
  //   tz.TZDateTime dateTime =
  //       tz.TZDateTime.now(tz.getLocation('Asia/Kuala_Lumpur'));
  //   azansList.forEach((element) async {
  //     DateTime date = DateFormat('dd-MMM-yyyy HH:mm')
  //         .parse(element.date! + ' ${element.imsak}');

  //     if (now.compareTo(date) < 0) {
  //       int random = Random().nextInt(pow(2, 31).toInt());

  //       await flutterLocalNotificationsPlugin.zonedSchedule(
  //           random,
  //           'Waktu Imsak',
  //           'Telah masuk waktu solat fardhu Imsak bagi Daerah $district (${element.imsak})',
  //           dateTime.add(date.difference(now)),
  //           NotificationDetails(
  //               android: AndroidNotificationDetails(
  //                   'scheduledImsakSilent', 'scheduledImsakSilent',
  //                   channelDescription: 'your channel description',
  //                   playSound: false,
  //                   color: Colors.green,
  //                   styleInformation: BigTextStyleInformation(
  //                       'Telah masuk waktu solat fardhu Imsak bagi Daerah $district (${element.imsak})'))),
  //           androidAllowWhileIdle: true,
  //           uiLocalNotificationDateInterpretation:
  //               UILocalNotificationDateInterpretation.absoluteTime);
  //     }
  //   });
  // }

  // void enableDhuhaCustomNotifications(
  //     List<PrayerModel> azansList, String district) {
  //   DateTime now = DateTime.now();
  //   tz.TZDateTime dateTime =
  //       tz.TZDateTime.now(tz.getLocation('Asia/Kuala_Lumpur'));
  //   azansList.forEach((element) async {
  //     DateTime date = DateFormat('dd-MMM-yyyy HH:mm')
  //         .parse(element.date! + ' ${element.imsak}');

  //     if (now.compareTo(date) < 0) {
  //       int random = Random().nextInt(pow(2, 31).toInt());

  //       await flutterLocalNotificationsPlugin.zonedSchedule(
  //           random,
  //           'Waktu Imsak',
  //           'Telah masuk waktu solat fardhu Imsak bagi Daerah $district (${element.imsak})',
  //           dateTime.add(date.difference(now)),
  //           NotificationDetails(
  //               android: AndroidNotificationDetails(
  //                   'scheduledImsakSilent', 'scheduledImsakSilent',
  //                   channelDescription: 'your channel description',
  //                   playSound: false,
  //                   color: Colors.green,
  //                   styleInformation: BigTextStyleInformation(
  //                       'Telah masuk waktu solat fardhu Imsak bagi Daerah $district (${element.imsak})'))),
  //           androidAllowWhileIdle: true,
  //           uiLocalNotificationDateInterpretation:
  //               UILocalNotificationDateInterpretation.absoluteTime);
  //     }
  //   });
  // }

  void enableZohorCustomNotifications(
      List<PrayerModel> azansList,
      String district,
      String azanUrl,
      int additionalTimeMode,
      int additionalTime) {
    DateTime now = DateTime.now();
    tz.TZDateTime dateTime =
        tz.TZDateTime.now(tz.getLocation('Asia/Kuala_Lumpur'));
    azansList.forEach((element) async {
      DateTime date = DateFormat('dd-MMM-yyyy HH:mm')
          .parse(element.date! + ' ${element.zohor}');

      if (now.compareTo(date) < 0) {
        int random = Random().nextInt(pow(2, 31).toInt());
        tz.TZDateTime finalDateTime = dateTime
            .add(date.difference(now))
            .add(Duration(minutes: additionalTime));

        await flutterLocalNotificationsPlugin.zonedSchedule(
            random,
            additionalTimeMode == 1
                ? 'Peringatan Waktu Zohor'
                : additionalTimeMode == 2
                    ? 'Peringatan Waktu Zohor'
                    : 'Waktu Zohor',
            additionalTimeMode == 1
                ? '${-additionalTime} Minit lagi akan masuk waktu Zohor bagi Daerah $district (${element.zohor})'
                : additionalTimeMode == 2
                    ? '$additionalTime Minit telah masuk waktu Zohor bagi Daerah $district (${element.zohor})'
                    : 'Telah masuk waktu solat fardhu Zohor bagi Daerah $district (${element.zohor})',
            finalDateTime,
            NotificationDetails(
                iOS: DarwinNotificationDetails(
                  presentAlert: true,
                  presentBadge: true,
                  presentSound: true,
                ),
                android: AndroidNotificationDetails(
                    'scheduledZohorCustom$random', 'Zohor',
                    channelDescription: 'your channel description',
                    playSound: true,
                    sound: UriAndroidNotificationSound(azanUrl),
                    color: Colors.green,
                    priority: Priority.high,
                    importance: Importance.high,
                    styleInformation: BigTextStyleInformation(''))),
            androidAllowWhileIdle: true,
            payload: finalDateTime.toString(),
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime);
      }
    });
  }

  void enableAsarCustomNotifications(
      List<PrayerModel> azansList,
      String district,
      String azanUrl,
      int additionalTimeMode,
      int additionalTime) {
    DateTime now = DateTime.now();
    tz.TZDateTime dateTime =
        tz.TZDateTime.now(tz.getLocation('Asia/Kuala_Lumpur'));
    azansList.forEach((element) async {
      DateTime date = DateFormat('dd-MMM-yyyy HH:mm')
          .parse(element.date! + ' ${element.asar}');

      if (now.compareTo(date) < 0) {
        int random = Random().nextInt(pow(2, 31).toInt());
        tz.TZDateTime finalDateTime = dateTime
            .add(date.difference(now))
            .add(Duration(minutes: additionalTime));

        await flutterLocalNotificationsPlugin.zonedSchedule(
            random,
            additionalTimeMode == 1
                ? 'Peringatan Waktu Asar'
                : additionalTimeMode == 2
                    ? 'Peringatan Waktu Asar'
                    : 'Waktu Asar',
            additionalTimeMode == 1
                ? '${-additionalTime} Minit lagi akan masuk waktu Asar bagi Daerah $district (${element.asar})'
                : additionalTimeMode == 2
                    ? '$additionalTime Minit telah masuk waktu Asar bagi Daerah $district (${element.asar})'
                    : 'Telah masuk waktu solat fardhu Asar bagi Daerah $district (${element.asar})',
            finalDateTime,
            NotificationDetails(
                iOS: DarwinNotificationDetails(
                  presentAlert: true,
                  presentBadge: true,
                  presentSound: true,
                ),
                android: AndroidNotificationDetails(
                    'scheduledAsarCustom$random', 'Asar',
                    channelDescription: 'your channel description',
                    playSound: true,
                    sound: UriAndroidNotificationSound(azanUrl),
                    color: Colors.green,
                    priority: Priority.high,
                    importance: Importance.high,
                    styleInformation: BigTextStyleInformation(''))),
            androidAllowWhileIdle: true,
            payload: finalDateTime.toString(),
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime);
      }
    });
  }

  void enableMaghribCustomNotifications(
      List<PrayerModel> azansList,
      String district,
      String azanUrl,
      int additionalTimeMode,
      int additionalTime) {
    DateTime now = DateTime.now();
    tz.TZDateTime dateTime =
        tz.TZDateTime.now(tz.getLocation('Asia/Kuala_Lumpur'));
    azansList.forEach((element) async {
      DateTime date = DateFormat('dd-MMM-yyyy HH:mm')
          .parse(element.date! + ' ${element.maghrib}');

      if (now.compareTo(date) < 0) {
        int random = Random().nextInt(pow(2, 31).toInt());
        tz.TZDateTime finalDateTime = dateTime
            .add(date.difference(now))
            .add(Duration(minutes: additionalTime));

        await flutterLocalNotificationsPlugin.zonedSchedule(
            random,
            additionalTimeMode == 1
                ? 'Peringatan Waktu Maghrib'
                : additionalTimeMode == 2
                    ? 'Peringatan Waktu Maghrib'
                    : 'Waktu Maghrib',
            additionalTimeMode == 1
                ? '${-additionalTime} Minit lagi akan masuk waktu Maghrib bagi Daerah $district (${element.maghrib})'
                : additionalTimeMode == 2
                    ? '$additionalTime Minit telah masuk waktu Maghrib bagi Daerah $district (${element.maghrib})'
                    : 'Telah masuk waktu solat fardhu Maghrib bagi Daerah $district (${element.maghrib})',
            finalDateTime,
            NotificationDetails(
                iOS: DarwinNotificationDetails(
                  presentAlert: true,
                  presentBadge: true,
                  presentSound: true,
                ),
                android: AndroidNotificationDetails(
                    'scheduledMaghribCustom$random', 'Maghrib',
                    channelDescription: 'your channel description',
                    playSound: true,
                    sound: UriAndroidNotificationSound(azanUrl),
                    color: Colors.green,
                    priority: Priority.high,
                    importance: Importance.high,
                    styleInformation: BigTextStyleInformation(''))),
            androidAllowWhileIdle: true,
            payload: finalDateTime.toString(),
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime);
      }
    });
  }

  void enableIsyakCustomNotifications(
      List<PrayerModel> azansList,
      String district,
      String azanUrl,
      int additionalTimeMode,
      int additionalTime) {
    DateTime now = DateTime.now();
    tz.TZDateTime dateTime =
        tz.TZDateTime.now(tz.getLocation('Asia/Kuala_Lumpur'));
    azansList.forEach((element) async {
      DateTime date = DateFormat('dd-MMM-yyyy HH:mm')
          .parse(element.date! + ' ${element.isyak}');

      if (now.compareTo(date) < 0) {
        int random = Random().nextInt(pow(2, 31).toInt());
        tz.TZDateTime finalDateTime = dateTime
            .add(date.difference(now))
            .add(Duration(minutes: additionalTime));

        await flutterLocalNotificationsPlugin.zonedSchedule(
            random,
            additionalTimeMode == 1
                ? 'Peringatan Waktu Isyak'
                : additionalTimeMode == 2
                    ? 'Peringatan Waktu Isyak'
                    : 'Waktu Isyak',
            additionalTimeMode == 1
                ? '${-additionalTime} Minit lagi akan masuk waktu Isyak bagi Daerah $district (${element.isyak})'
                : additionalTimeMode == 2
                    ? '$additionalTime Minit telah masuk waktu Isyak bagi Daerah $district (${element.isyak})'
                    : 'Telah masuk waktu solat fardhu Isyak bagi Daerah $district (${element.isyak})',
            finalDateTime,
            NotificationDetails(
                iOS: DarwinNotificationDetails(
                  presentAlert: true,
                  presentBadge: true,
                  presentSound: true,
                ),
                android: AndroidNotificationDetails(
                    'scheduledIsyakCustom$random', 'Isyak',
                    channelDescription: 'your channel description',
                    playSound: true,
                    sound: UriAndroidNotificationSound(azanUrl),
                    color: Colors.green,
                    priority: Priority.high,
                    importance: Importance.high,
                    styleInformation: BigTextStyleInformation(''))),
            androidAllowWhileIdle: true,
            payload: finalDateTime.toString(),
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime);
      }
    });
  }

  void enableSubuhNotifications(List<PrayerModel> azansList, String district,
      int additionalTimeMode, int additionalTime) {
    DateTime now = DateTime.now();
    tz.TZDateTime dateTime =
        tz.TZDateTime.now(tz.getLocation('Asia/Kuala_Lumpur'));
    azansList.forEach((element) async {
      DateTime date = DateFormat('dd-MMM-yyyy HH:mm')
          .parse(element.date! + ' ${element.subuh}');

      if (now.compareTo(date) < 0) {
        int random = Random().nextInt(pow(2, 31).toInt());
        tz.TZDateTime finalDateTime = dateTime
            .add(date.difference(now))
            .add(Duration(minutes: additionalTime));

        await flutterLocalNotificationsPlugin.zonedSchedule(
            random,
            additionalTimeMode == 1
                ? 'Peringatan Waktu Subuh'
                : additionalTimeMode == 2
                    ? 'Peringatan Waktu Subuh'
                    : 'Waktu Subuh',
            additionalTimeMode == 1
                ? '${-additionalTime} Minit lagi akan masuk waktu Subuh bagi Daerah $district (${element.subuh})'
                : additionalTimeMode == 2
                    ? '$additionalTime Minit telah masuk waktu Subuh bagi Daerah $district (${element.subuh})'
                    : 'Telah masuk waktu solat fardhu Subuh bagi Daerah $district (${element.subuh})',
            finalDateTime,
            NotificationDetails(
                iOS: DarwinNotificationDetails(
                  presentAlert: true,
                  presentBadge: true,
                  presentSound: false,
                ),
                android: AndroidNotificationDetails(
                    'scheduledSubuhSilent$random', 'Subuh',
                    channelDescription: 'your channel description',
                    playSound: false,
                    priority: Priority.high,
                    importance: Importance.high,
                    color: Colors.green,
                    styleInformation: BigTextStyleInformation(''))),
            androidAllowWhileIdle: true,
            payload: finalDateTime.toString(),
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime);
      }
    });
  }

  void enableSyurukNotifications(List<PrayerModel> azansList, String district,
      int additionalTimeMode, int additionalTime) {
    DateTime now = DateTime.now();
    tz.TZDateTime dateTime =
        tz.TZDateTime.now(tz.getLocation('Asia/Kuala_Lumpur'));
    azansList.forEach((element) async {
      DateTime date = DateFormat('dd-MMM-yyyy HH:mm')
          .parse(element.date! + ' ${element.syuruk}');

      if (now.compareTo(date) < 0) {
        int random = Random().nextInt(pow(2, 31).toInt());
        tz.TZDateTime finalDateTime = dateTime
            .add(date.difference(now))
            .add(Duration(minutes: additionalTime));

        await flutterLocalNotificationsPlugin.zonedSchedule(
            random,
            additionalTimeMode == 1
                ? 'Peringatan Waktu Syuruk'
                : additionalTimeMode == 2
                    ? 'Peringatan Waktu Syuruk'
                    : 'Waktu Syuruk',
            additionalTimeMode == 1
                ? '${-additionalTime} Minit lagi akan masuk waktu Syuruk bagi Daerah $district (${element.syuruk})'
                : additionalTimeMode == 2
                    ? '$additionalTime Minit telah masuk waktu Syuruk bagi Daerah $district (${element.syuruk})'
                    : 'Telah masuk waktu Syuruk bagi Daerah $district (${element.syuruk})',
            finalDateTime,
            NotificationDetails(
                iOS: DarwinNotificationDetails(
                  presentAlert: true,
                  presentBadge: true,
                  presentSound: false,
                ),
                android: AndroidNotificationDetails(
                    'scheduledSyurukSilent$random', 'Syuruk',
                    channelDescription: 'your channel description',
                    playSound: false,
                    color: Colors.green,
                    priority: Priority.high,
                    importance: Importance.high,
                    styleInformation: BigTextStyleInformation(''))),
            androidAllowWhileIdle: true,
            payload: finalDateTime.toString(),
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime);
      }
    });
  }

  void enableDhuhaNotifications(List<PrayerModel> azansList, String district,
      int additionalTimeMode, int additionalTime) {
    DateTime now = DateTime.now();
    tz.TZDateTime dateTime =
        tz.TZDateTime.now(tz.getLocation('Asia/Kuala_Lumpur'));
    azansList.forEach((element) async {
      DateTime date = DateFormat('dd-MMM-yyyy HH:mm')
          .parse(element.date! + ' ${element.syuruk}')
          .add(Duration(minutes: 20));

      if (now.compareTo(date) < 0) {
        int random = Random().nextInt(pow(2, 31).toInt());
        tz.TZDateTime finalDateTime = dateTime
            .add(date.difference(now))
            .add(Duration(minutes: additionalTime));

        await flutterLocalNotificationsPlugin.zonedSchedule(
            random,
            additionalTimeMode == 1
                ? 'Peringatan Waktu Dhuha'
                : additionalTimeMode == 2
                    ? 'Peringatan Waktu Dhuha'
                    : 'Waktu Dhuha',
            additionalTimeMode == 1
                ? '${-additionalTime} Minit lagi akan masuk waktu Dhuha bagi Daerah $district (${date.hour}:${date.minute})'
                : additionalTimeMode == 2
                    ? '$additionalTime Minit telah masuk waktu Dhuha bagi Daerah $district (${date.hour}:${date.minute})'
                    : 'Telah masuk waktu Dhuha bagi Daerah $district (${date.hour}:${date.minute})',
            finalDateTime,
            NotificationDetails(
                iOS: DarwinNotificationDetails(
                  presentAlert: true,
                  presentBadge: true,
                  presentSound: false,
                ),
                android: AndroidNotificationDetails(
                    'scheduledDhuhaSilent$random', 'Dhuha',
                    channelDescription: 'your channel description',
                    playSound: false,
                    priority: Priority.high,
                    importance: Importance.high,
                    color: Colors.green,
                    styleInformation: BigTextStyleInformation(''))),
            androidAllowWhileIdle: true,
            payload: finalDateTime.toString(),
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime);
      }
    });
  }

  void cancelNotification(String notificationTitle) {
    flutterLocalNotificationsPlugin.pendingNotificationRequests().then((value) {
      value.forEach((element) {
        if (element.title!.contains(notificationTitle)) {
          flutterLocalNotificationsPlugin.cancel(element.id);
          print('canceled ${element.id}');
        }
      });
    });
  }

  void changeNotification(String notificationTitle, int mode,
      int additionalTimeMode, int additionalTime) {
    emit(ChanginNotificationAudio());
    flutterLocalNotificationsPlugin
        .pendingNotificationRequests()
        .then((value) async {
      print(value.length);
      if (additionalTimeMode == 0) {
        print(notificationTitle);
        for (PendingNotificationRequest element in value) {
          print(element.title);
          if (element.title == notificationTitle ||
              element.title == 'Peringatan ' + notificationTitle) {
            flutterLocalNotificationsPlugin.cancel(element.id);
            print('canceled ${element.title}  >> ${element.payload}');
          }
        }
      } else {
        print('----- $notificationTitle');
        for (PendingNotificationRequest element in value) {
          if (element.title == 'Peringatan ' + notificationTitle) {
            flutterLocalNotificationsPlugin.cancel(element.id);
            print('canceled ${element.title}   >> ${element.payload}');
          }
        }
      }
      String azan = '';

      switch (notificationTitle) {
        case "Waktu Imsak":
          print('waktu imsak');

          azan = 'Imsak';
          break;
        case "Waktu Subuh":
          print('waktu subuh');

          azan = 'Subuh';
          break;

        case "Waktu Syuruk":
          print('waktu syuruk');

          azan = 'Syuruk';
          break;

        case "Waktu Dhuha":
          print('waktu dhuha');

          azan = 'Dhuha';
          break;

        case "Waktu Zohor":
          print('waktu zohor');

          azan = 'Zohor';
          break;

        case "Waktu Asar":
          print('waktu asar');

          azan = 'Asar';
          break;

        case "Waktu Maghrib":
          print('waktu maghrib');

          azan = 'Maghrib';
          break;
        case "Waktu Isyak":
          print('waktu isyak');

          azan = 'Isyak';
          break;

        default:
          break;
      }

      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();

      String district = sharedPreferences.getString('district') ?? '';

      String soundUrl = '';
      hadithRepository.fetchMonthAzans(DateTime.now()).then((azansList) async {
        emit(NotificationAudioChanged());

        switch (azan) {
          case 'Imsak':
            soundUrl = sharedPreferences.getString('imsakSoundUrl') ?? '';
            print('soundUrl >>>>>> $soundUrl');
            if (mode == 0) {
              print('mode 0 >>>>>> $additionalTimeMode --- $additionalTime');
              return enableImsakSoundNotifications(
                  azansList, district, additionalTimeMode, additionalTime);
            } else if (mode == 1) {
              print('mode 1 >>>>>> $additionalTimeMode --- $additionalTime');

              return enableImsakNotifications(
                  azansList, district, additionalTimeMode, additionalTime);
            }
            print('mode else  >>>>>> $additionalTimeMode --- $additionalTime');

            // return enableImsakSoundNotifications(
            //     azansList, district, additionalTimeMode, additionalTime);

            return;

          case 'Subuh':
            soundUrl = sharedPreferences.getString('subuhSoundUrl') ?? '';
            print('sound :>>> $soundUrl');
            if (mode == 0) {
              print('mode 0 >>>>>> $additionalTimeMode --- $additionalTime');

              return enableSubuhSoundNotifications(
                  azansList, district, additionalTimeMode, additionalTime);
            } else if (mode == 1) {
              print('mode 1 >>>>>> $additionalTimeMode --- $additionalTime');

              return enableSubuhNotifications(
                  azansList, district, additionalTimeMode, additionalTime);
            } else if (mode == 2) {
              print('mode 2 >>>>>> $additionalTimeMode --- $additionalTime');

              return enableSubuhCustomNotifications(azansList, district,
                  soundUrl, additionalTimeMode, additionalTime);
            }
            print('mode else >>>>>> $additionalTimeMode --- $additionalTime');

            return;

          case 'Syuruk':
            soundUrl = sharedPreferences.getString('syurukSoundUrl') ?? '';
            if (mode == 0) {
              print('mode 0 >>>>>> $additionalTimeMode --- $additionalTime');

              return enableSyurukSoundNotifications(
                  azansList, district, additionalTimeMode, additionalTime);
            } else if (mode == 1) {
              print('mode 1 >>>>>> $additionalTimeMode --- $additionalTime');

              return enableSyurukNotifications(
                  azansList, district, additionalTimeMode, additionalTime);
            }
            print('mode else  >>>>>> $additionalTimeMode --- $additionalTime');

            return;

          case 'Dhuha':
            soundUrl = sharedPreferences.getString('dhuhaSoundUrl') ?? '';
            if (mode == 0) {
              print('mode 0 >>>>>> $additionalTimeMode --- $additionalTime');

              return enableDhuhaSoundNotifications(
                  azansList, district, additionalTimeMode, additionalTime);
            } else if (mode == 1) {
              print('mode 1 >>>>>> $additionalTimeMode --- $additionalTime');

              return enableDhuhaNotifications(
                  azansList, district, additionalTimeMode, additionalTime);
            }

            print('mode else >>>>>> $additionalTimeMode --- $additionalTime');
            return;

          case 'Zohor':
            soundUrl = sharedPreferences.getString('zohorSoundUrl') ?? '';
            if (mode == 0) {
              print('mode 0 >>>>>> $additionalTimeMode --- $additionalTime');

              return enableZohorSoundNotifications(
                  azansList, district, additionalTimeMode, additionalTime);
            } else if (mode == 1) {
              print('mode 1 >>>>>> $additionalTimeMode --- $additionalTime');

              return enableZohorNotifications(
                  azansList, district, additionalTimeMode, additionalTime);
            } else if (mode == 2) {
              print('mode 2 >>>>>> $additionalTimeMode --- $additionalTime');

              return enableZohorCustomNotifications(azansList, district,
                  soundUrl, additionalTimeMode, additionalTime);
            }
            print('mode else >>>>>> $additionalTimeMode --- $additionalTime');

            return;

          case 'Asar':
            soundUrl = sharedPreferences.getString('asarSoundUrl') ?? '';
            if (mode == 0) {
              print('mode 0 >>>>>> $additionalTimeMode --- $additionalTime');

              return enableAsarSoundNotifications(
                  azansList, district, additionalTimeMode, additionalTime);
            } else if (mode == 1) {
              print('mode 1 >>>>>> $additionalTimeMode --- $additionalTime');

              return enableAsarNotifications(
                  azansList, district, additionalTimeMode, additionalTime);
            } else if (mode == 2) {
              print('mode 2 >>>>>> $additionalTimeMode --- $additionalTime');

              return enableAsarCustomNotifications(azansList, district,
                  soundUrl, additionalTimeMode, additionalTime);
            }
            print('mode else >>>>>> $additionalTimeMode --- $additionalTime');

            return;

          case 'Maghrib':
            soundUrl = sharedPreferences.getString('maghribSoundUrl') ?? '';
            if (mode == 0) {
              print('mode 0 >>>>>> $additionalTimeMode --- $additionalTime');

              return enableMaghribSoundNotifications(
                  azansList, district, additionalTimeMode, additionalTime);
            } else if (mode == 1) {
              print('mode 1 >>>>>> $additionalTimeMode --- $additionalTime');

              return enableMaghribNotifications(
                  azansList, district, additionalTimeMode, additionalTime);
            } else if (mode == 2) {
              print('mode 2 >>>>>> $additionalTimeMode --- $additionalTime');

              return enableMaghribCustomNotifications(azansList, district,
                  soundUrl, additionalTimeMode, additionalTime);
            }
            print('mode else >>>>>> $additionalTimeMode --- $additionalTime');

            return;

          case 'Isyak':
            soundUrl = sharedPreferences.getString('isyakSoundUrl') ?? '';
            if (mode == 0) {
              print('mode 0 >>>>>> $additionalTimeMode --- $additionalTime');

              return enableIsyakSoundNotifications(
                  azansList, district, additionalTimeMode, additionalTime);
            } else if (mode == 1) {
              print('mode 1 >>>>>> $additionalTimeMode --- $additionalTime');

              return enableIsyakNotifications(
                  azansList, district, additionalTimeMode, additionalTime);
            } else if (mode == 2) {
              print('mode 2 >>>>>> $additionalTimeMode --- $additionalTime');

              return enableIsyakCustomNotifications(azansList, district,
                  soundUrl, additionalTimeMode, additionalTime);
            }
            print('mode else >>>>>> $additionalTimeMode --- $additionalTime');

            return;
        }
      });
    });

    Future.delayed(Duration(seconds: 10), () {
      flutterLocalNotificationsPlugin
          .pendingNotificationRequests()
          .then((value) async {
        print(value.length);
        for (PendingNotificationRequest element in value) {
          print('${element.title} >>>>>> ${element.payload}');
        }
      });
    });
  }

  void enableZohorNotifications(List<PrayerModel> azansList, String district,
      int additionalTimeMode, int additionalTime) {
    DateTime now = DateTime.now();
    tz.TZDateTime dateTime =
        tz.TZDateTime.now(tz.getLocation('Asia/Kuala_Lumpur'));
    azansList.forEach((element) async {
      DateTime date = DateFormat('dd-MMM-yyyy HH:mm')
          .parse(element.date! + ' ${element.zohor}');

      if (now.compareTo(date) < 0) {
        int random = Random().nextInt(pow(2, 31).toInt());
        tz.TZDateTime finalDateTime = dateTime
            .add(date.difference(now))
            .add(Duration(minutes: additionalTime));

        await flutterLocalNotificationsPlugin.zonedSchedule(
            random,
            additionalTimeMode == 1
                ? 'Peringatan Waktu Zohor'
                : additionalTimeMode == 2
                    ? 'Peringatan Waktu Zohor'
                    : 'Waktu Zohor',
            additionalTimeMode == 1
                ? '${-additionalTime} Minit lagi akan masuk waktu Zohor bagi Daerah $district (${element.zohor})'
                : additionalTimeMode == 2
                    ? '$additionalTime Minit telah masuk waktu Zohor bagi Daerah $district (${element.zohor})'
                    : 'Telah masuk waktu solat fardhu Zohor bagi Daerah $district (${element.zohor})',
            finalDateTime,
            NotificationDetails(
                iOS: DarwinNotificationDetails(
                  presentAlert: true,
                  presentBadge: true,
                  presentSound: false,
                ),
                android: AndroidNotificationDetails(
                    'scheduledZohorSilent$random', 'Zohor',
                    channelDescription: 'your channel description',
                    playSound: false,
                    color: Colors.green,
                    priority: Priority.high,
                    importance: Importance.high,
                    styleInformation: BigTextStyleInformation(''))),
            androidAllowWhileIdle: true,
            payload: finalDateTime.toString(),
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime);
      }
    });
  }

  void enableAsarNotifications(List<PrayerModel> azansList, String district,
      int additionalTimeMode, int additionalTime) {
    DateTime now = DateTime.now();
    tz.TZDateTime dateTime =
        tz.TZDateTime.now(tz.getLocation('Asia/Kuala_Lumpur'));
    azansList.forEach((element) async {
      DateTime date = DateFormat('dd-MMM-yyyy HH:mm')
          .parse(element.date! + ' ${element.asar}');

      if (now.compareTo(date) < 0) {
        int random = Random().nextInt(pow(2, 31).toInt());
        tz.TZDateTime finalDateTime = dateTime
            .add(date.difference(now))
            .add(Duration(minutes: additionalTime));

        await flutterLocalNotificationsPlugin.zonedSchedule(
            random,
            additionalTimeMode == 1
                ? 'Peringatan Waktu Asar'
                : additionalTimeMode == 2
                    ? 'Peringatan Waktu Asar'
                    : 'Waktu Asar',
            additionalTimeMode == 1
                ? '${-additionalTime} Minit lagi akan masuk waktu Asar bagi Daerah $district (${element.asar})'
                : additionalTimeMode == 2
                    ? '$additionalTime Minit telah masuk waktu Asar bagi Daerah $district (${element.asar})'
                    : 'Telah masuk waktu solat fardhu Asar bagi Daerah $district (${element.asar})',
            finalDateTime,
            NotificationDetails(
                iOS: DarwinNotificationDetails(
                  presentAlert: true,
                  presentBadge: true,
                  presentSound: false,
                ),
                android: AndroidNotificationDetails(
                    'scheduledAsarSilent$random', 'Asar',
                    channelDescription: 'your channel description',
                    playSound: false,
                    color: Colors.green,
                    priority: Priority.high,
                    importance: Importance.high,
                    styleInformation: BigTextStyleInformation(''))),
            androidAllowWhileIdle: true,
            payload: finalDateTime.toString(),
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime);
      }
    });
  }

  void enableMaghribNotifications(List<PrayerModel> azansList, String district,
      int additionalTimeMode, int additionalTime) {
    DateTime now = DateTime.now();
    tz.TZDateTime dateTime =
        tz.TZDateTime.now(tz.getLocation('Asia/Kuala_Lumpur'));
    azansList.forEach((element) async {
      DateTime date = DateFormat('dd-MMM-yyyy HH:mm')
          .parse(element.date! + ' ${element.maghrib}');

      if (now.compareTo(date) < 0) {
        int random = Random().nextInt(pow(2, 31).toInt());
        tz.TZDateTime finalDateTime = dateTime
            .add(date.difference(now))
            .add(Duration(minutes: additionalTime));

        await flutterLocalNotificationsPlugin.zonedSchedule(
            random,
            additionalTimeMode == 1
                ? 'Peringatan Waktu Maghrib'
                : additionalTimeMode == 2
                    ? 'Peringatan Waktu Maghrib'
                    : 'Waktu Maghrib',
            additionalTimeMode == 1
                ? '${-additionalTime} Minit lagi akan masuk waktu Maghrib bagi Daerah $district (${element.maghrib})'
                : additionalTimeMode == 2
                    ? '$additionalTime Minit telah masuk waktu Maghrib bagi Daerah $district (${element.maghrib})'
                    : 'Telah masuk waktu solat fardhu Maghrib bagi Daerah $district (${element.maghrib})',
            finalDateTime,
            NotificationDetails(
                iOS: DarwinNotificationDetails(
                  presentAlert: true,
                  presentBadge: true,
                  presentSound: false,
                ),
                android: AndroidNotificationDetails(
                    'scheduledMaghribSilent$random', 'Maghrib',
                    channelDescription: 'your channel description',
                    playSound: false,
                    color: Colors.green,
                    priority: Priority.high,
                    importance: Importance.high,
                    styleInformation: BigTextStyleInformation(''))),
            androidAllowWhileIdle: true,
            payload: finalDateTime.toString(),
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime);

        // NotificationUtils.scheduleSoundAzanNotifications(
        //     date,
        //     'Waktu Maghrib',
        //     'Telah masuk waktu solat fardhu Maghrib bagi Daerah $district (${element.maghrib})',
        //     'scheduledMaghribSound');
      }
    });
  }

  void enableIsyakNotifications(List<PrayerModel> azansList, String district,
      int additionalTimeMode, int additionalTime) {
    DateTime now = DateTime.now();
    tz.TZDateTime dateTime =
        tz.TZDateTime.now(tz.getLocation('Asia/Kuala_Lumpur'));
    azansList.forEach((element) async {
      DateTime date = DateFormat('dd-MMM-yyyy HH:mm')
          .parse(element.date! + ' ${element.isyak}');

      if (now.compareTo(date) < 0) {
        int random = Random().nextInt(pow(2, 31).toInt());
        tz.TZDateTime finalDateTime = dateTime
            .add(date.difference(now))
            .add(Duration(minutes: additionalTime));

        await flutterLocalNotificationsPlugin.zonedSchedule(
            random,
            additionalTimeMode == 1
                ? 'Peringatan Waktu Isyak'
                : additionalTimeMode == 2
                    ? 'Peringatan Waktu Isyak'
                    : 'Waktu Isyak',
            additionalTimeMode == 1
                ? '${-additionalTime} Minit lagi akan masuk waktu Isyak bagi Daerah $district (${element.isyak})'
                : additionalTimeMode == 2
                    ? '$additionalTime Minit telah masuk waktu Isyak bagi Daerah $district (${element.isyak})'
                    : 'Telah masuk waktu solat fardhu Isyak bagi Daerah $district (${element.isyak})',
            finalDateTime,
            NotificationDetails(
                iOS: DarwinNotificationDetails(
                  presentAlert: true,
                  presentBadge: true,
                  presentSound: false,
                ),
                android: AndroidNotificationDetails(
                    'scheduledIsyakSilent$random', 'Isyak',
                    channelDescription: 'your channel description',
                    playSound: false,
                    color: Colors.green,
                    priority: Priority.high,
                    importance: Importance.high,
                    styleInformation: BigTextStyleInformation(''))),
            androidAllowWhileIdle: true,
            payload: finalDateTime.toString(),
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime);
      }
    });
  }

  void enableImsakSoundNotifications(List<PrayerModel> azansList,
      String district, int additionalTimeMode, int additionalTime) {
    DateTime now = DateTime.now();
    tz.TZDateTime dateTime =
        tz.TZDateTime.now(tz.getLocation('Asia/Kuala_Lumpur'));
    flutterLocalNotificationsPlugin
        .pendingNotificationRequests()
        .then((value) async {
      print(value.length);

      for (PendingNotificationRequest element in value) {
        print(element.title);
        if (element.title == 'Imsak' ||
            element.title == 'Peringatan ' + 'Imsak') {
          flutterLocalNotificationsPlugin.cancel(element.id);
          print('canceled ${element.title}  >> ${element.payload}');
        }
      }
    });

    azansList.forEach((element) async {
      DateTime date = DateFormat('dd-MMM-yyyy HH:mm')
          .parse(element.date! + ' ${element.imsak}');

      if (now.compareTo(date) < 0) {
        int random = Random().nextInt(pow(2, 31).toInt());

        tz.TZDateTime finalDateTime = additionalTimeMode == 1
            ? dateTime
                .add(date.difference(now))
                .subtract(Duration(minutes: -additionalTime))
            : additionalTimeMode == 2
                ? dateTime
                    .add(date.difference(now))
                    .add(Duration(minutes: additionalTime))
                : dateTime.add(date.difference(now));

        print(
            'date now >>>> $dateTime ::: notificationTime >>>>> $finalDateTime  diff:> ${date.difference(now)} ');

        await flutterLocalNotificationsPlugin
            .zonedSchedule(
                random,
                additionalTimeMode == 1
                    ? 'Peringatan Waktu Imsak'
                    : additionalTimeMode == 2
                        ? 'Peringatan Waktu Imsak'
                        : 'Waktu Imsak',
                additionalTimeMode == 1
                    ? '${-additionalTime} Minit lagi akan masuk waktu Imsak bagi Daerah $district (${element.imsak})'
                    : additionalTimeMode == 2
                        ? '$additionalTime Minit telah masuk waktu Imsak bagi Daerah $district (${element.imsak})'
                        : 'Telah masuk waktu Imsak bagi Daerah $district (${element.imsak})',
                finalDateTime,
                NotificationDetails(
                    iOS: DarwinNotificationDetails(
                      presentAlert: true,
                      presentBadge: true,
                      presentSound: true,
                    ),
                    android: AndroidNotificationDetails(
                        'scheduledImsakSound$random', 'Imsak',
                        channelDescription: 'your channel description',
                        color: Colors.green,
                        playSound: true,
                        priority: Priority.high,
                        importance: Importance.high,
                        styleInformation: BigTextStyleInformation(''))),
                androidAllowWhileIdle: true,
                payload: finalDateTime.toString(),
                uiLocalNotificationDateInterpretation:
                    UILocalNotificationDateInterpretation.absoluteTime)
            .then((value) async {
          print('enabled Imsak $finalDateTime');
          SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
          sharedPreferences.setInt('latestNotificationDate',
              finalDateTime.toUtc().millisecondsSinceEpoch);
        });

        // NotificationUtils.scheduleSoundAzanNotifications(
        //         date,
        //         'Waktu Imsak',
        //         'Telah masuk waktu solat fardhu Imsak bagi Daerah $district (${element.imsak})',
        //         'scheduledImsakSound')
        //     .onError((error, stackTrace) => print(error.toString()));
      }
    });
  }

  void enableSubuhSoundNotifications(List<PrayerModel> azansList,
      String district, int additionalTimeMode, int additionalTime) {
    DateTime now = DateTime.now();
    tz.TZDateTime dateTime =
        tz.TZDateTime.now(tz.getLocation('Asia/Kuala_Lumpur'));
    flutterLocalNotificationsPlugin
        .pendingNotificationRequests()
        .then((value) async {
      print(value.length);

      for (PendingNotificationRequest element in value) {
        print(element.title);
        if (element.title == 'Subuh' ||
            element.title == 'Peringatan ' + 'Subuh') {
          flutterLocalNotificationsPlugin.cancel(element.id);
          print('canceled ${element.title}  >> ${element.payload}');
        }
      }
    });
    azansList.forEach((element) async {
      DateTime date = DateFormat('dd-MMM-yyyy HH:mm')
          .parse(element.date! + ' ${element.subuh}');

      if (now.compareTo(date) < 0) {
        int random = Random().nextInt(pow(2, 31).toInt());

        tz.TZDateTime finalDateTime = additionalTimeMode == 1
            ? dateTime
                .add(date.difference(now))
                .subtract(Duration(minutes: -additionalTime))
            : additionalTimeMode == 2
                ? dateTime
                    .add(date.difference(now))
                    .add(Duration(minutes: additionalTime))
                : dateTime.add(date.difference(now));

        print(
            'date now >>>> $dateTime ::: notificationTime >>>>> $finalDateTime  diff:> ${date.difference(now)} ');

        await flutterLocalNotificationsPlugin
            .zonedSchedule(
                random,
                additionalTimeMode == 1
                    ? 'Peringatan Waktu Subuh'
                    : additionalTimeMode == 2
                        ? 'Peringatan Waktu Subuh'
                        : 'Waktu Subuh',
                additionalTimeMode == 1
                    ? '${-additionalTime} Minit lagi akan masuk waktu Subuh bagi Daerah $district (${element.subuh})'
                    : additionalTimeMode == 2
                        ? '$additionalTime Minit telah masuk waktu Subuh bagi Daerah $district (${element.subuh})'
                        : 'Telah masuk waktu solat fardhu Subuh bagi Daerah $district (${element.subuh})',
                finalDateTime,
                NotificationDetails(
                    iOS: DarwinNotificationDetails(
                      presentAlert: true,
                      presentBadge: true,
                      presentSound: true,
                    ),
                    android: AndroidNotificationDetails(
                        'scheduledSubuhSound$random', 'Subuh',
                        channelDescription: 'your channel description',
                        color: Colors.green,
                        playSound: true,
                        importance: Importance.max,
                        priority: Priority.max,
                        styleInformation: BigTextStyleInformation(''))),
                androidAllowWhileIdle: true,
                payload: finalDateTime.toString(),
                uiLocalNotificationDateInterpretation:
                    UILocalNotificationDateInterpretation.absoluteTime)
            .then((value) => print('enabled subuh $random'));

        // NotificationUtils.scheduleSoundAzanNotifications(
        //     date,
        //     'Waktu Subuh',
        //     'Telah masuk waktu solat fardhu Subuh bagi Daerah $district (${element.subuh})',
        //     'scheduledSubuhSound');
      }
    });
  }

  void enableSyurukSoundNotifications(List<PrayerModel> azansList,
      String district, int additionalTimeMode, int additionalTime) {
    DateTime now = DateTime.now();
    tz.TZDateTime dateTime =
        tz.TZDateTime.now(tz.getLocation('Asia/Kuala_Lumpur'));

    flutterLocalNotificationsPlugin
        .pendingNotificationRequests()
        .then((value) async {
      print(value.length);

      for (PendingNotificationRequest element in value) {
        print(element.title);
        if (element.title == 'Syuruk' ||
            element.title == 'Peringatan ' + 'Syuruk') {
          flutterLocalNotificationsPlugin.cancel(element.id);
          print('canceled ${element.title}  >> ${element.payload}');
        }
      }
    });
    azansList.forEach((element) async {
      DateTime date = DateFormat('dd-MMM-yyyy HH:mm')
          .parse(element.date! + ' ${element.syuruk}');

      if (now.compareTo(date) < 0) {
        int random = Random().nextInt(pow(2, 31).toInt());
        tz.TZDateTime finalDateTime = dateTime
            .add(date.difference(now))
            .add(Duration(minutes: additionalTime));

        await flutterLocalNotificationsPlugin
            .zonedSchedule(
                random,
                additionalTimeMode == 1
                    ? 'Peringatan Waktu Syuruk'
                    : additionalTimeMode == 2
                        ? 'Peringatan Waktu Syuruk'
                        : 'Waktu Syuruk',
                additionalTimeMode == 1
                    ? '${-additionalTime} Minit lagi akan masuk waktu Syuruk bagi Daerah $district (${element.syuruk})'
                    : additionalTimeMode == 2
                        ? '$additionalTime Minit telah masuk waktu Syuruk bagi Daerah $district (${element.syuruk})'
                        : 'Telah masuk waktu Syuruk bagi Daerah $district (${element.syuruk})',
                finalDateTime,
                NotificationDetails(
                    iOS: DarwinNotificationDetails(
                      presentAlert: true,
                      presentBadge: true,
                      presentSound: true,
                    ),
                    android: AndroidNotificationDetails(
                        'scheduledSyurukSound$random', 'Syuruk',
                        channelDescription: 'your channel description',
                        color: Colors.green,
                        playSound: true,
                        priority: Priority.high,
                        importance: Importance.high,
                        styleInformation: BigTextStyleInformation(''))),
                androidAllowWhileIdle: true,
                payload: finalDateTime.toString(),
                uiLocalNotificationDateInterpretation:
                    UILocalNotificationDateInterpretation.absoluteTime)
            .then((value) => print('enabled Syuruk $random'));

        // NotificationUtils.scheduleSoundAzanNotifications(
        //     date,
        //     'Waktu Syuruk',
        //     'Telah masuk waktu solat fardhu Syuruk bagi Daerah $district (${element.syuruk})',
        //     'scheduledSyurukSound');
      }
    });
  }

  void enableDhuhaSoundNotifications(List<PrayerModel> azansList,
      String district, int additionalTimeMode, int additionalTime) {
    DateTime now = DateTime.now();
    tz.TZDateTime dateTime =
        tz.TZDateTime.now(tz.getLocation('Asia/Kuala_Lumpur'));

    flutterLocalNotificationsPlugin
        .pendingNotificationRequests()
        .then((value) async {
      print(value.length);

      for (PendingNotificationRequest element in value) {
        print(element.title);
        if (element.title == 'Dhuha' ||
            element.title == 'Peringatan ' + 'Dhuha') {
          flutterLocalNotificationsPlugin.cancel(element.id);
          print('canceled ${element.title}  >> ${element.payload}');
        }
      }
    });
    azansList.forEach((element) async {
      DateTime date = DateFormat('dd-MMM-yyyy HH:mm')
          .parse(element.date! + ' ${element.syuruk}')
          .add(Duration(minutes: 20));

      if (now.compareTo(date) < 0) {
        int random = Random().nextInt(pow(2, 31).toInt());
        tz.TZDateTime finalDateTime = dateTime
            .add(date.difference(now))
            .add(Duration(minutes: additionalTime));

        await flutterLocalNotificationsPlugin
            .zonedSchedule(
                random,
                additionalTimeMode == 1
                    ? 'Peringatan Waktu Dhuha'
                    : additionalTimeMode == 2
                        ? 'Peringatan Waktu Dhuha'
                        : 'Waktu Dhuha',
                additionalTimeMode == 1
                    ? '${-additionalTime} Minit lagi akan masuk waktu Dhuha bagi Daerah $district (${date.hour}:${date.minute})'
                    : additionalTimeMode == 2
                        ? '$additionalTime Minit telah masuk waktu Dhuha bagi Daerah $district (${date.hour}:${date.minute})'
                        : 'Telah masuk waktu Dhuha bagi Daerah $district (${date.hour}:${date.minute})',
                finalDateTime,
                NotificationDetails(
                    iOS: DarwinNotificationDetails(
                      presentAlert: true,
                      presentBadge: true,
                      presentSound: true,
                    ),
                    android: AndroidNotificationDetails(
                        'scheduledDhuhaSound$random', 'Dhuha',
                        channelDescription: 'your channel description',
                        color: Colors.green,
                        playSound: true,
                        priority: Priority.high,
                        importance: Importance.high,
                        styleInformation: BigTextStyleInformation(''))),
                androidAllowWhileIdle: true,
                payload: finalDateTime.toString(),
                uiLocalNotificationDateInterpretation:
                    UILocalNotificationDateInterpretation.absoluteTime)
            .then((value) => print('enabled Dhuha $random'));

        // NotificationUtils.scheduleSoundAzanNotifications(
        //     date,
        //     'Waktu Dhuha',
        //     'Telah masuk waktu solat fardhu Dhuha bagi Daerah $district (${date.hour}:${date.minute})',
        //     'scheduledDhuhaSound');
      }
    });
  }

  void enableZohorSoundNotifications(List<PrayerModel> azansList,
      String district, int additionalTimeMode, int additionalTime) {
    DateTime now = DateTime.now();
    tz.TZDateTime dateTime =
        tz.TZDateTime.now(tz.getLocation('Asia/Kuala_Lumpur'));
    flutterLocalNotificationsPlugin
        .pendingNotificationRequests()
        .then((value) async {
      print(value.length);

      for (PendingNotificationRequest element in value) {
        print(element.title);
        if (element.title == 'Zohor' ||
            element.title == 'Peringatan ' + 'Zohor') {
          flutterLocalNotificationsPlugin.cancel(element.id);
          print('canceled ${element.title}  >> ${element.payload}');
        }
      }
    });
    azansList.forEach((element) async {
      DateTime date = DateFormat('dd-MMM-yyyy HH:mm')
          .parse(element.date! + ' ${element.zohor}');

      if (now.compareTo(date) < 0) {
        int random = Random().nextInt(pow(2, 31).toInt());
        tz.TZDateTime finalDateTime = dateTime
            .add(date.difference(now))
            .add(Duration(minutes: additionalTime));

        await flutterLocalNotificationsPlugin
            .zonedSchedule(
                random,
                additionalTimeMode == 1
                    ? 'Peringatan Waktu Zohor'
                    : additionalTimeMode == 2
                        ? 'Peringatan Waktu Zohor'
                        : 'Waktu Zohor',
                additionalTimeMode == 1
                    ? '${-additionalTime} Minit lagi akan masuk waktu Zohor bagi Daerah $district (${element.zohor})'
                    : additionalTimeMode == 2
                        ? '$additionalTime Minit telah masuk waktu Zohor bagi Daerah $district (${element.zohor})'
                        : 'Telah masuk waktu solat fardhu Zohor bagi Daerah $district (${element.zohor})',
                finalDateTime,
                NotificationDetails(
                    iOS: DarwinNotificationDetails(
                      presentAlert: true,
                      presentBadge: true,
                      presentSound: true,
                    ),
                    android: AndroidNotificationDetails(
                        'scheduledZohorSound$random', 'Zohor',
                        channelDescription: 'your channel description',
                        color: Colors.green,
                        playSound: true,
                        priority: Priority.high,
                        importance: Importance.high,
                        styleInformation: BigTextStyleInformation(''))),
                androidAllowWhileIdle: true,
                payload: finalDateTime.toString(),
                uiLocalNotificationDateInterpretation:
                    UILocalNotificationDateInterpretation.absoluteTime)
            .then((value) => print('enabled Zohor $finalDateTime'));

        // NotificationUtils.scheduleSoundAzanNotifications(
        //     date,
        //     'Waktu Zohor',
        //     'Telah masuk waktu solat fardhu Zohor bagi Daerah $district (${element.zohor})',
        //     'scheduledZohorSound');
      }
    });
  }

  void enableAsarSoundNotifications(List<PrayerModel> azansList,
      String district, int additionalTimeMode, int additionalTime) {
    DateTime now = DateTime.now();
    tz.TZDateTime dateTime =
        tz.TZDateTime.now(tz.getLocation('Asia/Kuala_Lumpur'));
    flutterLocalNotificationsPlugin
        .pendingNotificationRequests()
        .then((value) async {
      print(value.length);

      for (PendingNotificationRequest element in value) {
        print(element.title);
        if (element.title == 'Asar' ||
            element.title == 'Peringatan ' + 'Asar') {
          flutterLocalNotificationsPlugin.cancel(element.id);
          print('canceled ${element.title}  >> ${element.payload}');
        }
      }
    });
    azansList.forEach((element) async {
      DateTime date = DateFormat('dd-MMM-yyyy HH:mm')
          .parse(element.date! + ' ${element.asar}');

      if (now.compareTo(date) < 0) {
        int random = Random().nextInt(pow(2, 31).toInt());
        tz.TZDateTime finalDateTime = dateTime
            .add(date.difference(now))
            .add(Duration(minutes: additionalTime));

        print(
            'date now >>>> $dateTime ::: notificationTime >>>>> $finalDateTime  diff:> ${date.difference(now)} ');

        await flutterLocalNotificationsPlugin
            .zonedSchedule(
                random,
                additionalTimeMode == 1
                    ? 'Peringatan Waktu Asar'
                    : additionalTimeMode == 2
                        ? 'Peringatan Waktu Asar'
                        : 'Waktu Asar',
                additionalTimeMode == 1
                    ? '${-additionalTime} Minit lagi akan masuk waktu Asar bagi Daerah $district (${element.asar})'
                    : additionalTimeMode == 2
                        ? '$additionalTime Minit telah masuk waktu Asar bagi Daerah $district (${element.asar})'
                        : 'Telah masuk waktu solat fardhu Asar bagi Daerah $district (${element.asar})',
                finalDateTime,
                NotificationDetails(
                    android: AndroidNotificationDetails(
                        'scheduledAsarSound$random', 'Asar',
                        channelDescription: 'your channel description',
                        color: Colors.green,
                        playSound: true,
                        priority: Priority.high,
                        importance: Importance.high,
                        styleInformation: BigTextStyleInformation(''))),
                androidAllowWhileIdle: true,
                payload: finalDateTime.toString(),
                uiLocalNotificationDateInterpretation:
                    UILocalNotificationDateInterpretation.absoluteTime)
            .then((value) => print('enabled Asar  $finalDateTime '));

        // NotificationUtils.scheduleSoundAzanNotifications(
        //     date,
        //     'Waktu Asar',
        //     'Telah masuk waktu solat fardhu Asar bagi Daerah $district (${element.asar})',
        //     'scheduledAsarSound');
      }
    });
  }

  void enableMaghribSoundNotifications(List<PrayerModel> azansList,
      String district, int additionalTimeMode, int additionalTime) {
    DateTime now = DateTime.now();
    tz.TZDateTime dateTime =
        tz.TZDateTime.now(tz.getLocation('Asia/Kuala_Lumpur'));
    flutterLocalNotificationsPlugin
        .pendingNotificationRequests()
        .then((value) async {
      print(value.length);

      for (PendingNotificationRequest element in value) {
        print(element.title);
        if (element.title == 'Maghrib' ||
            element.title == 'Peringatan ' + 'Maghrib') {
          flutterLocalNotificationsPlugin.cancel(element.id);
          print('canceled ${element.title}  >> ${element.payload}');
        }
      }
    });
    azansList.forEach((element) async {
      DateTime date = DateFormat('dd-MMM-yyyy HH:mm')
          .parse(element.date! + ' ${element.maghrib}');

      if (now.compareTo(date) < 0) {
        int random = Random().nextInt(pow(2, 31).toInt());
        tz.TZDateTime finalDateTime = dateTime
            .add(date.difference(now))
            .add(Duration(minutes: additionalTime));

        await flutterLocalNotificationsPlugin
            .zonedSchedule(
                random,
                additionalTimeMode == 1
                    ? 'Peringatan Waktu Maghrib'
                    : additionalTimeMode == 2
                        ? 'Peringatan Waktu Maghrib'
                        : 'Waktu Maghrib',
                additionalTimeMode == 1
                    ? '${-additionalTime} Minit lagi akan masuk waktu Maghrib bagi Daerah $district (${element.maghrib})'
                    : additionalTimeMode == 2
                        ? '$additionalTime Minit telah masuk waktu Maghrib bagi Daerah $district (${element.maghrib})'
                        : 'Telah masuk waktu solat fardhu Maghrib bagi Daerah $district (${element.maghrib})',
                finalDateTime,
                NotificationDetails(
                    iOS: DarwinNotificationDetails(
                      presentAlert: true,
                      presentBadge: true,
                      presentSound: true,
                    ),
                    android: AndroidNotificationDetails(
                        'scheduledMaghribSound$random', 'Maghrib',
                        channelDescription: 'your channel description',
                        color: Colors.green,
                        playSound: true,
                        priority: Priority.high,
                        importance: Importance.high,
                        styleInformation: BigTextStyleInformation(''))),
                androidAllowWhileIdle: true,
                payload: finalDateTime.toString(),
                uiLocalNotificationDateInterpretation:
                    UILocalNotificationDateInterpretation.absoluteTime)
            .then((value) => print('enabled Maghrib $random'));

        // NotificationUtils.scheduleSoundAzanNotifications(
        //     date,
        //     'Waktu Maghrib',
        //     'Telah masuk waktu solat fardhu Maghrib bagi Daerah $district (${element.maghrib})',
        //     'scheduledMaghribSound');
      }
    });
  }

  void enableIsyakSoundNotifications(List<PrayerModel> azansList,
      String district, int additionalTimeMode, int additionalTime) {
    DateTime now = DateTime.now();
    tz.TZDateTime dateTime =
        tz.TZDateTime.now(tz.getLocation('Asia/Kuala_Lumpur'));
    flutterLocalNotificationsPlugin
        .pendingNotificationRequests()
        .then((value) async {
      print(value.length);

      for (PendingNotificationRequest element in value) {
        print(element.title);
        if (element.title == 'Isyak' ||
            element.title == 'Peringatan ' + 'Isyak') {
          flutterLocalNotificationsPlugin.cancel(element.id);
          print('canceled ${element.title}  >> ${element.payload}');
        }
      }
    });
    azansList.forEach((element) async {
      DateTime date = DateFormat('dd-MMM-yyyy HH:mm')
          .parse(element.date! + ' ${element.isyak}');

      if (now.compareTo(date) < 0) {
        int random = Random().nextInt(pow(2, 31).toInt());
        tz.TZDateTime finalDateTime = dateTime
            .add(date.difference(now))
            .add(Duration(minutes: additionalTime));

        await flutterLocalNotificationsPlugin
            .zonedSchedule(
                random,
                additionalTimeMode == 1
                    ? 'Peringatan Waktu Isyak'
                    : additionalTimeMode == 2
                        ? 'Peringatan Waktu Isyak'
                        : 'Waktu Isyak',
                additionalTimeMode == 1
                    ? '${-additionalTime} Minit lagi akan masuk waktu Isyak bagi Daerah $district (${element.isyak})'
                    : additionalTimeMode == 2
                        ? '$additionalTime Minit telah masuk waktu Isyak bagi Daerah $district (${element.isyak})'
                        : 'Telah masuk waktu solat fardhu Isyak bagi Daerah $district (${element.isyak})',
                finalDateTime,
                NotificationDetails(
                    iOS: DarwinNotificationDetails(
                      presentAlert: true,
                      presentBadge: true,
                      presentSound: true,
                    ),
                    android: AndroidNotificationDetails(
                        'scheduledIsyakSound$random', 'Isyak',
                        channelDescription: 'your channel description',
                        color: Colors.green,
                        playSound: true,
                        priority: Priority.high,
                        importance: Importance.high,
                        styleInformation: BigTextStyleInformation(''))),
                androidAllowWhileIdle: true,
                payload: finalDateTime.toString(),
                uiLocalNotificationDateInterpretation:
                    UILocalNotificationDateInterpretation.absoluteTime)
            .then((value) => print('enabled Isyak $random'));

        // NotificationUtils.scheduleSoundAzanNotifications(
        //     date,
        //     'Waktu Isyak',
        //     'Telah masuk waktu solat fardhu Isyak bagi Daerah $district (${element.isyak})',
        //     'scheduledIsyakSound');
      }
    });
  }
}
