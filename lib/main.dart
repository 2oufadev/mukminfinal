import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mukim_app/business_logic/cubit/ayat_cubit/ayat_cubit_cubit.dart';
import 'package:mukim_app/business_logic/cubit/bottom_bar/cubit.dart';
import 'package:mukim_app/business_logic/cubit/bottom_bar/states.dart';
import 'package:mukim_app/business_logic/cubit/doa_cubit/doa_cubit.dart';
import 'package:mukim_app/business_logic/cubit/hadith/hadith_cubit.dart';
import 'package:mukim_app/business_logic/cubit/hadith_cubit/hadith_cubit_cubit.dart';
import 'package:mukim_app/business_logic/cubit/motivation_cubit/motivation_cubit_cubit.dart';
import 'package:mukim_app/business_logic/cubit/payment/payment_cubit.dart';
import 'package:mukim_app/business_logic/cubit/qiblat/blocs/compassProvider.dart';
import 'package:mukim_app/business_logic/cubit/qiblat/blocs/qiblat/cubit/qiblat_cubit.dart';
import 'package:mukim_app/business_logic/cubit/screens_details/screens_details_cubit.dart';
import 'package:mukim_app/business_logic/cubit/sponsor/sponsor_cubit.dart';
import 'package:mukim_app/business_logic/cubit/subscription/userstate_cubit.dart';
import 'package:mukim_app/custom_route.dart';
import 'package:mukim_app/data/api/mukmin_api.dart';
import 'package:mukim_app/data/api/payment_api.dart';
import 'package:mukim_app/data/repository/ayat_repository.dart';
import 'package:mukim_app/data/repository/doa_repository.dart';
import 'package:mukim_app/data/repository/hadith_repository.dart';
import 'package:mukim_app/data/repository/motivation_repository.dart';
import 'package:mukim_app/data/repository/mukmin_repository.dart';
import 'package:mukim_app/data/repository/payment_repository.dart';
import 'package:mukim_app/data/repository/sponsors_repository.dart';
import 'package:mukim_app/presentation/screens/Juzuk/juzuk_audio_rep.dart';
import 'package:mukim_app/presentation/screens/hadith/hadeth_detail_screens.dart';
import 'package:mukim_app/presentation/screens/home/home_screen.dart';
import 'package:mukim_app/presentation/screens/sirah/Peristiwa_Penting.dart';
import 'package:mukim_app/presentation/screens/splash/splash_screen.dart';
import 'package:mukim_app/resources/constants.dart';
import 'package:mukim_app/resources/global.dart';
import 'package:mukim_app/utils/app_localization.dart';
import 'package:mukim_app/utils/bloc_observer.dart';
import 'package:mukim_app/providers/theme.dart';
import 'package:provider/provider.dart' as provider;
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:timezone/data/latest_all.dart' as tz;

import 'presentation/screens/ayat.dart';
import 'presentation/screens/doa/Doa_Taubat.dart';
import 'presentation/screens/motivasi.dart';
import 'presentation/screens/settings/special_coupon.dart';
// import '../init.dart';

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
    Navigator.pop(MyApp.navigatorKey.currentContext!);
  } catch (e) {
    print('error: $e');
    Navigator.pop(MyApp.navigatorKey.currentContext!);
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await setupFlutterNotifications();
  showFlutterNotification(message);
  print('background ~~~~~~~~~${message.toMap()}');
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print('Handling a background message ${message.messageId}');
}

/// Create a [AndroidNotificationChannel] for heads up notifications
AndroidNotificationChannel? channel;

bool isFlutterLocalNotificationsInitialized = false;

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel!);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;

  if (notification != null && !kIsWeb) {
    print(notification);
    print(android);
    print(!kIsWeb);
    print(notification.hashCode);
    print(notification.title);
    print(notification.body);

    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
            Random().nextInt(pow(2, 31).toInt()).toString(), channel!.name,
            channelDescription: channel!.description,
            playSound: true,
            color: Colors.green,
            styleInformation: BigTextStyleInformation(''),
            importance: Importance.high
            // TODO add a proper drawable resource to android, for now using
            //      one that already exists in example app.
            ),
      ),
    );
  }
}

List<String> payloadList = [];

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
    StreamController<ReceivedNotification>.broadcast();

final StreamController<String> selectNotificationStream =
    StreamController<String>.broadcast();

const MethodChannel platform =
    MethodChannel('dexterx.dev/flutter_local_notifications_example');
const String portName = 'notification_send_port';

/// A notification action which triggers a url launch event
const String urlLaunchActionId = 'id_1';

/// A notification action which triggers a App navigation event
const String navigationActionId = 'id_3';

/// Defines a iOS/MacOS notification category for text input actions.
const String darwinNotificationCategoryText = 'textCategory';

/// Defines a iOS/MacOS notification category for plain actions.
const String darwinNotificationCategoryPlain = 'plainCategory';

void onDidReceiveLocalNotification(
    int id, String title, String body, String payload) async {
  // display a dialog with the notification details, tap ok to go to another page
  showDialog(
    context: MyApp.navigatorKey.currentContext!,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          child: Text('Ok'),
          onPressed: () async {
            Navigator.of(context, rootNavigator: true).pop();
            // await Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => SecondScreen(payload),
            //   ),
            // );
          },
        )
      ],
    ),
  );
}

@pragma('vm:entry-point')
Future<void> notificationTapBackground(
    NotificationResponse notificationResponse) async {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');

  if (notificationResponse.actionId == 'DailyHadithShare') {
    http.Response response = await http
        .get(Uri.parse(notificationResponse.payload!.split('!').last.trim()));
    await Share.shareXFiles(
      [
        XFile.fromData(
          response.bodyBytes,
          mimeType: 'image/png',
        )
      ],
      text: notificationResponse.payload!.split('!')[3],
      subject: 'Share Image',
    );
  }
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String title;
  final String body;
  final String payload;
}

String initialRoute = '';

String? selectedNotificationPayload;

// void notificationTapBackground(NotificationResponse notificationResponse) {
//   // handle action

//   if (notificationResponse != null && notificationResponse.payload != null) {
//     List<String> payloadList = notificationResponse.payload.split('!');

//     if (notificationResponse.actionId == '1') {
//       print('11111111');

//       Get.to(HadithDetailScreen(
//         payloadList.first,
//         payloadList[2],
//         selectedId: int.parse(payloadList[1]),
//       ));
//     } else if (notificationResponse.actionId == '2') {
//       shareImage(payloadList[3], payloadList.last);
//     }
//   }
// }

Future<void> _configureLocalTimeZone() async {
  if (kIsWeb || Platform.isLinux) {
    return;
  }
  tz.initializeTimeZones();
}

void main() async {
  // GestureBinding.instance?.resamplingEnabled = true;
  // WidgetsFlutterBinding.ensureInitialized();
  // await init();
  WidgetsFlutterBinding.ensureInitialized();
  await createDatabase();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (!kIsWeb) {
    await setupFlutterNotifications();
  }

  FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
    String linkString = dynamicLinkData.link.toString();
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
                code: dynamicLinkData.link.toString().split('/').last),
          ));
    }
  }).onError((error) {
    print('error !~~~~~~~~ $error');
    // Handle errors
  });
  // AwesomeNotifications().setListeners(
  //     onActionReceivedMethod: NotificationsController.onActionReceivedMethod,
  //     onNotificationCreatedMethod:
  //         NotificationsController.onNotificationCreatedMethod,
  //     onNotificationDisplayedMethod:
  //         NotificationsController.onNotificationDisplayedMethod,
  //     onDismissActionReceivedMethod:
  //         NotificationsController.onDismissActionReceivedMethod);
//   final NotificationAppLaunchDetails notificationAppLaunchDetails =
//       await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
//   final didNotificationLaunchApp =
//       notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;
// final initialRoute = didNotificationLaunchApp ? '/second' : '/first';
  final NotificationAppLaunchDetails? notificationAppLaunchDetails = !kIsWeb &&
          Platform.isLinux
      ? null
      : await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  initialRoute = '/splash';

  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    print('launched');
    print(notificationAppLaunchDetails!.notificationResponse!.payload);

    if (notificationAppLaunchDetails.notificationResponse!.payload != null &&
        notificationAppLaunchDetails
            .notificationResponse!.payload!.isNotEmpty) {
      print('aaaa');
      initialRoute = '/hadith';
      payloadList = notificationAppLaunchDetails.notificationResponse!.payload!
          .split('!');
    } else {
      initialRoute = '/splash';
    }
  } else {
    print('notLaunched');
  }
  print('done');

  /// Note: permissions aren't requested here just to demonstrate that can be
  /// done later

  // const MacOSInitializationSettings initializationSettingsMacOS =
  //     MacOSInitializationSettings(
  //   requestAlertPermission: false,
  //   requestBadgePermission: false,
  //   requestSoundPermission: false,
  // );

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  final List<DarwinNotificationCategory> darwinNotificationCategories =
      <DarwinNotificationCategory>[
    DarwinNotificationCategory(
      darwinNotificationCategoryText,
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.text(
          'text_1',
          'Action 1',
          buttonTitle: 'Send',
          placeholder: 'Placeholder',
        ),
      ],
    ),
    DarwinNotificationCategory(
      darwinNotificationCategoryPlain,
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.plain('id_1', 'Action 1'),
        DarwinNotificationAction.plain(
          'id_2',
          'Action 2 (destructive)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.destructive,
          },
        ),
        DarwinNotificationAction.plain(
          navigationActionId,
          'Action 3 (foreground)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.foreground,
          },
        ),
        DarwinNotificationAction.plain(
          'id_4',
          'Action 4 (auth required)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.authenticationRequired,
          },
        ),
      ],
      options: <DarwinNotificationCategoryOption>{
        DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
      },
    )
  ];

  /// Note: permissions aren't requested here just to demonstrate that can be
  /// done later
  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
    onDidReceiveLocalNotification:
        (int? id, String? title, String? body, String? payload) async {
      didReceiveLocalNotificationStream.add(
        ReceivedNotification(
          id: id ?? 0,
          title: title ?? '',
          body: body ?? '',
          payload: payload ?? '',
        ),
      );
    },
    notificationCategories: darwinNotificationCategories,
  );
  final LinuxInitializationSettings initializationSettingsLinux =
      LinuxInitializationSettings(
    defaultActionName: 'Open notification',
    defaultIcon: AssetsLinuxIcon('icons/app_icon.png'),
  );
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
    macOS: initializationSettingsDarwin,
    linux: initializationSettingsLinux,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  Bloc.observer = MyBlocObserver();
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  Globals.initGridient();
  HttpOverrides.global = new MyHttpOverrides();
  // AwesomeNotifications()
  //     .actionStream
  //     .listen((ReceivedAction receivedNotification) {
  //   Navigator.of(MyApp.navigatorKey.currentContext).push(MaterialPageRoute(
  //     builder: (context) => HomePage(title: ''),
  //   ));
  // });
  initializeDateFormatting('ms_MS').then((_) => runApp(MyApp()));
}

void onDidReceiveNotificationResponse(
    NotificationResponse? notificationResponse) async {
  if (notificationResponse != null &&
      notificationResponse.payload != null &&
      notificationResponse.payload!.isNotEmpty) {
    List<String> payloadList = notificationResponse.payload!.split('!');

    if (payloadList.isNotEmpty) {
      print('payload not emptyyyyyyyy');
      payloadList.forEach((element) {
        print(element);
      });
      Navigator.push(
          MyApp.navigatorKey.currentContext!,
          MaterialPageRoute(
              builder: (context) => HadithDetailScreen(
                    payloadList.first,
                    payloadList[2],
                    selectedId: int.parse(payloadList[1]),
                  )));
    } else {
      print('~~~~~~~~~~~~~~');
    }
  }
}

Future createDatabase() async {
  String databasesPath = await getDatabasesPath();
  String dbPath = path.join(databasesPath, 'my.db');
  AudioConstants.audioPlayer.stop();
  AudioConstants.duration = Duration();
  AudioConstants.position = Duration();
  AudioConstants.playing = false;
  Globals.globalIndWord = 0;
  AudioConstants.database = await openDatabase(dbPath, version: 2,
      onCreate: (Database db, int version) async {
    await db.execute(
        "CREATE TABLE Surah (id INTEGER PRIMARY KEY,surahId TEXT, value TEXT, page TEXT)");
    await db.execute(
        "CREATE TABLE Page (id INTEGER PRIMARY KEY,pageId TEXT, value TEXT)");
    await db.execute(
        "CREATE TABLE Ayah (id INTEGER PRIMARY KEY,ayahId TEXT, value TEXT,qari TEXT)");
    await db
        .execute("CREATE TABLE Surahs (id INTEGER PRIMARY KEY, value TEXT)");
    await db.execute(
        "CREATE TABLE downloadedSurahs (id INTEGER PRIMARY KEY, value TEXT)");
    await db.execute("CREATE TABLE hadithFav (id INTEGER PRIMARY KEY)");
    await db.execute("CREATE TABLE doaFav (id INTEGER PRIMARY KEY)");

    await db.execute("CREATE TABLE motivFav (id INTEGER PRIMARY KEY)");
    await db.execute("CREATE TABLE ayatFav (id INTEGER PRIMARY KEY)");
    await db.execute(
        "CREATE TABLE bookmarks (page INTEGER PRIMARY KEY, surahName TEXT, surahId INTEGER, juz INTEGER)");
    await db.execute(
        "CREATE TABLE wordsbookmarks (page INTEGER PRIMARY KEY, verse_key TEXT, position INTEGER, surahName TEXT, surahId INTEGER, juz INTEGER)");

    await db.execute(
        "CREATE TABLE recent (page INTEGER PRIMARY KEY, surahName TEXT, surahId INTEGER, juz INTEGER)");

    await db
        .execute("CREATE TABLE hadith (id INTEGER PRIMARY KEY, value TEXT)");
    await db.execute(
        "CREATE TABLE azanTimes (id INTEGER PRIMARY KEY,zoneCode TEXT, data TEXT)");
    await db.execute(
        "CREATE TABLE azanTimesMonthly (id INTEGER PRIMARY KEY,zoneCode TEXT,month INTEGER, data TEXT)");
  });
  getSurah();
}

class MyApp extends StatelessWidget {
  // This widget is the roFot of your application.
  HadithCubit? hadithCubit;
  MukminRepository? mukminRepository;
  MotivationRepository? motivationRepository;
  AyatRepository? ayatRepository;
  DoaRepository? doaRepository;
  HadithRepository? hadithRepository;
  SponsorsRepository? sponsorsRepository;
  PaymentRepository? paymentRepository;
  static final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  MyApp() {
    mukminRepository = MukminRepository(MukminApi());
    motivationRepository = MotivationRepository(MukminApi());
    hadithCubit = HadithCubit(mukminRepository!);
    ayatRepository = AyatRepository(MukminApi());
    doaRepository = DoaRepository(MukminApi());
    hadithRepository = HadithRepository(MukminApi());
    sponsorsRepository = SponsorsRepository(MukminApi());
    paymentRepository = PaymentRepository(PaymentApi());
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: Size(375, 832),
        builder: (context, child) {
          return provider.MultiProvider(
            providers: [
              provider.ChangeNotifierProvider(create: (_) => ThemeNotifier()),
              provider.ChangeNotifierProvider(create: (_) => CompassProvider()),
              provider.ChangeNotifierProvider<JuzukAudioRep>(
                  create: (context) => JuzukAudioRep()),
            ],
            child: MultiBlocProvider(
              providers: [
                BlocProvider(create: (BuildContext context) => MukminCubit()),
                BlocProvider(create: (BuildContext context) => hadithCubit!),
                BlocProvider(
                    create: (BuildContext context) =>
                        UserStateCubit(mukminRepository!)),
                BlocProvider(
                  create: (context) => QiblatCubit(),
                ),
                BlocProvider(
                  create: (BuildContext context) =>
                      ScreensDetailsCubit(mukminRepository!),
                ),
                BlocProvider(
                  create: (BuildContext context) =>
                      AyatCubitCubit(ayatRepository!),
                ),
                BlocProvider(
                  create: (BuildContext context) =>
                      HadithCubitCubit(hadithRepository!),
                ),
                BlocProvider(
                  create: (BuildContext context) =>
                      MotivationCubitCubit(motivationRepository!),
                ),
                BlocProvider(
                  create: (BuildContext context) => DoaCubit(doaRepository!),
                ),
                BlocProvider(
                  create: (BuildContext context) =>
                      SponsorCubit(sponsorsRepository!),
                ),
                BlocProvider(
                    create: (BuildContext context) =>
                        PaymentCubit(paymentRepository!))
              ],
              child: BlocConsumer<MukminCubit, MukminStates>(
                  builder: (context, state) {
                    return MaterialApp(
                      navigatorKey: navigatorKey,
                      debugShowCheckedModeBanner: false,
                      title: 'MUKMIN APP',
                      theme: ThemeData(
                        primarySwatch: Colors.deepPurple,
                        inputDecorationTheme: InputDecorationTheme(),
                      ),
                      initialRoute: initialRoute,
                      localizationsDelegates: [
                        AppLocalizations.delegate,
                      ],
                      routes: {
                        '/Hero': (BuildContext context) => Peristiwa_Penting(),
                        '/home': (BuildContext context) => HomeScreen(),
                        '/splash': (BuildContext context) => SplashScreen(),
                        '/hadith': (BuildContext context) => HadithDetailScreen(
                            payloadList.isNotEmpty ? payloadList.first : '',
                            payloadList.isNotEmpty ? payloadList[2] : '',
                            selectedId: payloadList.isNotEmpty
                                ? int.parse(payloadList[1])
                                : 0)
                      },
                    );
                  },
                  listener: (context, state) {}),
            ),
          );
        });
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
