import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:location/location.dart';
import 'package:mukim_app/business_logic/cubit/hadith_cubit/hadith_cubit_cubit.dart';
import 'package:mukim_app/data/models/firebase_user_model.dart';
import 'package:mukim_app/data/repository/firebase_data_repository.dart';
import 'package:mukim_app/main.dart';
import 'package:mukim_app/presentation/screens/home/home_screen.dart';
import 'package:mukim_app/presentation/screens/qiblat/search.dart';
import 'package:mukim_app/presentation/widgets/background.dart';
import 'package:mukim_app/resources/Imageresources.dart';
import 'package:mukim_app/utils/app_localization.dart';
import 'package:mukim_app/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mukim_app/providers/theme.dart';
import 'package:mukim_app/utils/styles.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../custom_route.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  static const routeName = '/auth';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  Duration get loginTime => Duration(milliseconds: timeDilation.ceil() * 2250);
  final GoogleSignIn googleSignIn = GoogleSignIn();
  late SharedPreferences sharedPref;
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  bool? firstTime;
  Animation<double>? _skipScaleAnimation;
  AnimationController? _skipController;
  bool? hadithEnabled;
  Future<String?> _handleFacebookLogin() async {
    try {
      final LoginResult loginResult = await FacebookAuth.i.login();
      if (loginResult.status == LoginStatus.success) {
        final userData = await FacebookAuth.i.getUserData();

        if (userData['email'] != null) {
          sharedPref.setString('useremail', userData['email']);
        }
        sharedPref.setString('username', userData['name']);
        sharedPref.setString('password', '');
        sharedPref.setString('phone', '');
        sharedPref.setString('loginProvider', 'facebook');

        String url = 'https://salam.mukminapps.com/api/Users';
        var result = await http
            .get(Uri.parse(url), headers: {"Accept": "application/json"});
        List responseBody = jsonDecode(result.body);
        var aaa = responseBody.firstWhere(
            (element) => element['email'] == userData['email'],
            orElse: () {});
        if (aaa == null) {
          var postData = {
            'name': userData['name'],
            'email': userData['email'] != null ? userData['email'] : '',
            'phone': '',
            'password': '123456',
            'cpassword': '123456',
            'user_type': 2
          };
          var response = await http.post(
              Uri.parse('https://salam.mukminapps.com/api/User/add'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode(postData),
              encoding: Encoding.getByName("utf-8"));

          List responseBodyy = jsonDecode(response.body);

          if (responseBodyy != null && responseBodyy.isNotEmpty) {
            sharedPref.setString('userid', responseBodyy.last['id'].toString());
          }
        } else {
          sharedPref.setString('userid', aaa['id'].toString());
        }

        final OAuthCredential facebookAuthCredential =
            FacebookAuthProvider.credential(loginResult.accessToken!.token);

        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithCredential(facebookAuthCredential);
        String? userToken = await FirebaseMessaging.instance.getToken();
        await FirebaseDataRepository().addUser(FirebaseUserModel(
            userCredential.user!.uid,
            userData['name'],
            userData['email'],
            userToken ?? ''));
        return null;
      } else {
        return loginResult.message;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<String?> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        sharedPref.setString('useremail', googleSignInAccount.email);
        sharedPref.setString('username', googleSignInAccount.displayName!);
        sharedPref.setString('password', '');
        sharedPref.setString('phone', '');
        sharedPref.setString('loginProvider', 'google');

        String url = 'https://salam.mukminapps.com/api/Users';
        var result = await http
            .get(Uri.parse(url), headers: {"Accept": "application/json"});
        List responseBody = jsonDecode(result.body);
        var aaa = responseBody.firstWhere(
            (element) => element['email'] == googleSignInAccount.email,
            orElse: () {
          print('emptyyyyyyy');
        });
        if (aaa == null) {
          print('nulllll');
          var postData = {
            'name': googleSignInAccount.displayName,
            'email': googleSignInAccount.email,
            'phone': '',
            'password': '123456',
            'cpassword': '123456',
            'user_type': 2
          };
          var response = await http.post(
              Uri.parse('https://salam.mukminapps.com/api/User/add'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode(postData),
              encoding: Encoding.getByName("utf-8"));

          List responseBodyy = jsonDecode(response.body);

          if (responseBodyy != null && responseBodyy.isNotEmpty) {
            sharedPref.setString('userid', responseBodyy.last['id'].toString());
          }
        } else {
          sharedPref.setString('userid', aaa['id'].toString());
        }

        GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        OAuthCredential googleAuthCredential = GoogleAuthProvider.credential(
            idToken: googleSignInAuthentication.idToken,
            accessToken: googleSignInAuthentication.accessToken!);
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithCredential(googleAuthCredential);
        String? userToken = await FirebaseMessaging.instance.getToken();
        await FirebaseDataRepository().addUser(FirebaseUserModel(
          userCredential.user!.uid,
          googleSignInAccount.displayName!,
          googleSignInAccount.email,
          userToken!,
        ));

        Fluttertoast.showToast(
            msg: "Welcome ${googleSignInAccount.displayName}",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 12.0);
      } else {
        return 'User has cancelled Login';
      }

      return null;
    } catch (e) {
      print(e);
      return 'Unexpected Error, Please Try Again ${e.toString()}';
    }
  }

  Future<String?> _loginUser(LoginData data) async {
    try {
      String name = data.name.split('@').first;
      var postData = {
        'email': data.name,
        'password': data.password,
      };

      var response = await http.post(
          Uri.parse('https://salam.mukminapps.com/api/User/signin'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(postData),
          encoding: Encoding.getByName("utf-8"));

      Map responseBodyy = jsonDecode(response.body);
      if (responseBodyy['data'] != null) {
        sharedPref.setString('userid', responseBodyy['data']['id'].toString());
        sharedPref.setString('useremail', data.name);
        sharedPref.setString('username', name);
        sharedPref.setString('password', data.password);
        sharedPref.setString('loginProvider', 'email');
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: data.name, password: data.password)
            .onError((error, stackTrace) async {
          return await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: data.name, password: data.password);
        });
        String? userToken = await FirebaseMessaging.instance.getToken();
        await FirebaseDataRepository().addUser(FirebaseUserModel(
          userCredential.user!.uid,
          name,
          data.name,
          userToken!,
        ));

        return null;
      } else {
        return 'Incorrect email and password';
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> _registerUser(SignupData data) async {
    try {
      String url = 'https://salam.mukminapps.com/api/Users';
      var result = await http
          .get(Uri.parse(url), headers: {"Accept": "application/json"});
      List responseBody = jsonDecode(result.body);
      var aaa = responseBody.firstWhere(
          (element) => element['email'] == data.name,
          orElse: () {});
      if (aaa == null) {
        String name = data.name!.split('@').first;
        var postData = {
          'name': data.username,
          'email': data.name,
          'phone': data.phone.toString(),
          'password': data.password,
          'cpassword': data.password,
          'user_type': 2
        };
        var response = await http.post(
            Uri.parse('https://salam.mukminapps.com/api/User/add'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(postData),
            encoding: Encoding.getByName("utf-8"));
        sharedPref.setString('useremail', data.name ?? '');
        sharedPref.setString('username', data.username ?? '');
        sharedPref.setString('password', data.password ?? '');
        sharedPref.setString('phone', data.phone.toString());
        List responseBodyy = jsonDecode(response.body);
        print('*****************');
        print(responseBodyy.toSet());
        print('*****************');
        if (responseBodyy != null && responseBodyy.isNotEmpty) {
          UserCredential userCredential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                  email: data.name ?? '', password: data.password ?? '');
          String? userToken = await FirebaseMessaging.instance.getToken();
          await FirebaseDataRepository().addUser(FirebaseUserModel(
            userCredential.user!.uid,
            data.username ?? '',
            data.name ?? '',
            userToken ?? '',
          ));

          sharedPref.setString('userid', responseBodyy.last['id'].toString());
        }
      } else {
        return 'Email already exists';
      }
    } catch (e) {
      print(e.toString());
    }

    return null;
  }

  Color getColor(String theme) {
    Color color = Color.fromRGBO(82, 77, 159, 1);

    switch (theme ?? 'default') {
      case 'purple':
        color = Color.fromRGBO(159, 153, 219, 1);
        break;
      case 'biru':
        color = Color.fromRGBO(70, 205, 208, 1);
        break;
      case 'pink':
        color = Color.fromRGBO(234, 108, 165, 1);
        break;
      default:
    }
    return color;
  }

  @override
  void initState() {
    getSharedPreferences();

    checkLocationPermission();
    _skipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
      reverseDuration: const Duration(milliseconds: 300),
    );
    _skipScaleAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _skipController!,
      curve: const Interval(.4, 1.0, curve: Curves.easeOutBack),
    ));
    Future.delayed(Duration(seconds: 1), () {
      _skipController!.forward();
    });
    super.initState();
  }

  checkLocationPermission() async {
    Location location = new Location();
    print('checking Location');
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    double lat = sharedPref.getDouble('latitude') ?? 0;
    double lng = sharedPref.getDouble('longitude') ?? 0;
    if (lat == 0) {
      print('location <<<<<<>>>>>>>>>>>>> 0');
      _locationData =
          await location.getLocation().whenComplete(() => print('completed'));

      print(_locationData.latitude);
      print(_locationData.longitude);

      sharedPref.setDouble('latitude', _locationData.latitude!);
      sharedPref.setDouble('longitude', _locationData.longitude!);

      List<Placemark> addresses = await placemarkFromCoordinates(
          _locationData.latitude!, _locationData.longitude!);
//AIzaSyDxnRT1NxgOqg51V97G_XDGvxOqDVmYhHw

      String cityName = addresses.first.administrativeArea!;

      if (cityName == null) {
        addresses.forEach((element) {
          if (element.administrativeArea != null) {
            cityName = element.administrativeArea!;
            return;
          }
        });
      }
      print('cityName :>>>> $cityName');
      String districtName = cityName != null
          ? modifyDistrictName(cityName.toLowerCase(), addresses)
          : '';
      print('districtName :>>>> $districtName');

      if (districtName.isEmpty) {
        Fluttertoast.showToast(
            msg: "Tidak dapat mengesan lokasi anda",
            toastLength: Toast.LENGTH_LONG,
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
                  builder: (BuildContext context, ScrollController controller) {
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
            BlocProvider.of<HadithCubitCubit>(context)
                .enableAllAzanNotificationsSound(
                    sharedPref.getString('district') ?? '');
          }
        });
      } else {
        sharedPref.setString('city', cityName);
        sharedPref.setString('district', districtName);

        BlocProvider.of<HadithCubitCubit>(context)
            .enableAllAzanNotificationsSound(districtName);
      }
    } else {
      print('location != 0 ');
      if (sharedPref.getString('district') != null &&
          sharedPref.getString('district')!.isNotEmpty) {
        BlocProvider.of<HadithCubitCubit>(context)
            .enableAllAzanNotificationsSound(
                sharedPref.getString('district') ?? '');
      } else {
        double? lat = sharedPref.getDouble('latitude');
        double? long = sharedPref.getDouble(
          'longitude',
        );

        List<Placemark> addresses = await placemarkFromCoordinates(lat!, long!);

        String cityName = addresses.first.administrativeArea!;

        if (cityName == null) {
          addresses.forEach((element) {
            if (element.administrativeArea != null) {
              cityName = element.administrativeArea!;
              return;
            }
          });
        }
        print('cityName :>>>> $cityName');
        String districtName = cityName != null
            ? modifyDistrictName(cityName.toLowerCase(), addresses)
            : '';
        print('districtName :>>>> $districtName');

        if (districtName.isEmpty) {
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
              BlocProvider.of<HadithCubitCubit>(context)
                  .enableAllAzanNotificationsSound(
                      sharedPref.getString('district') ?? '');
            }
          });
        } else {
          sharedPref.setString('city', cityName);
          sharedPref.setString('district', districtName);

          BlocProvider.of<HadithCubitCubit>(context)
              .enableAllAzanNotificationsSound(districtName);
        }
      }
    }

    // if (districtName == null) {
    //   addresses.forEach((element) {
    //     if (element.locality != null) {
    //       districtName = element.locality;
    //       return;
    //     }
    //   });
    // }
  }

  getSharedPreferences() async {
    sharedPref = await SharedPreferences.getInstance();
    firstTime = sharedPref.getBool('firstTime') ?? true;
    hadithEnabled = sharedPref.getBool('onedayhadithenabled') ?? true;
    if (hadithEnabled!) {
      BlocProvider.of<HadithCubitCubit>(MyApp.navigatorKey.currentContext!)
          .fetchOneDayHadithList();
    }
  }

  @override
  Widget build(BuildContext context) {
    String theme = Provider.of<ThemeNotifier>(context).appTheme;
    return Container(
      color: Styles.backGroundColor,
      child: BackGround(
        img: "assets/theme/${theme ?? "default"}/background.png",
        child: Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              FlutterLogin(
                  title: 'MUKMIN APP',
                  logo: AssetImage(
                    ImageResource.loginLogo,
                  ),
                  termsOfService: [
                    TermOfService(
                        id: '1',
                        mandatory: true,
                        text:
                            "Saya mengakui dan mengesahkan bahawa saya telah membaca dan bersetuju menerima terma dan syarat berserta privasi data yang telah ditetapkan",
                        linkUrl: "https://mukminapps.com/privacy-policy/"),
                  ],
                  theme: LoginTheme(
                    switchAuthTextColor: getColor(theme),
                    primaryColor: Colors.transparent,
                    titleStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                    cardTheme: CardTheme(
                      color: Colors.transparent,
                      elevation: 0,
                    ),
                    accentColor: Colors.transparent,
                    buttonTheme: LoginButtonTheme(
                        splashColor: getColor(theme),
                        backgroundColor: getColor(theme),
                        elevation: 0.0,
                        highlightElevation: 6.0),
                  ),
                  loginProviders: [
                    LoginProvider(
                      icon: FontAwesomeIcons.google,
                      //  label: 'Google',
                      callback: () async {
                        return _handleGoogleSignIn();
                      },
                    ),
                    LoginProvider(
                      icon: FontAwesomeIcons.facebook,
                      //  label: 'Facebook',
                      callback: () async {
                        return _handleFacebookLogin();
                      },
                    ),
                  ],
                  userValidator: (value) {
                    if (!value!.contains('@') || !value.endsWith('.com')) {
                      return AppLocalizations.of(context)!
                          .translate('email_must_contain');
                    }

                    return null;
                  },
                  phoneValidator: (value) {
                    print('``````$value');

                    if (value != null &&
                        value.isNotEmpty &&
                        !isNumeric(value)) {
                      return AppLocalizations.of(context)!
                          .translate('phone_numbers_error');
                    } else {
                      return null;
                    }
                  },
                  passwordValidator: (value) {
                    if (value!.isEmpty) {
                      return AppLocalizations.of(context)!
                          .translate('password_is_empty');
                    }
                    return null;
                  },
                  onLogin: (loginData) async {
                    // await Future.delayed(loginTime);
                    return _loginUser(loginData);
                  },
                  onSignup: (loginData) async {
                    //  await Future.delayed(loginTime);
                    return _registerUser(loginData);
                  },
                  onSubmitAnimationCompleted: () {
                    // _skipController.reverse();
                    Future.delayed(Duration(milliseconds: 300), () {
                      Navigator.of(context).pushReplacement(FadePageRoute(
                        builder: (context) =>
                            HomeScreen(firstTime: true, skipped: false),
                      ));
                    });
                  },
                  onRecoverPassword: (name) {
                    return _goToHome();
                    // Show new password dialog
                  },
                  messages: LoginMessages(
                    userHint:
                        AppLocalizations.of(context)!.translate('email') + ' *',
                    passwordHint: 'Pilih kata laluan *',
                    confirmPasswordHint: 'Sahkan kata laluan *',
                    loginButton: 'Log Masuk',
                    signupButton: 'Daftar',
                    forgotPasswordButton: 'Terlupa kata laluan?',
                    recoverPasswordIntro: AppLocalizations.of(context)!
                        .translate('reset_password'),
                    recoverPasswordButton:
                        AppLocalizations.of(context)!.translate('help_me'),
                    goBackButton:
                        AppLocalizations.of(context)!.translate('go_back'),
                    confirmPasswordError:
                        AppLocalizations.of(context)!.translate('not_match'),
                    providersTitleFirst: AppLocalizations.of(context)!
                        .translate('or_login_with'),
                    recoverPasswordDescription: '',
                    recoverPasswordSuccess: 'Password rescued successfully',
                  ),
                  showDebugButtons: false,
                  skipWidget: ScaleTransition(
                    scale: _skipScaleAnimation!,
                    child: InkWell(
                        onTap: () {
                          if (firstTime!) {
                            sharedPref.setBool('firstTime', false);
                          }
                          _skipController!.reverse();
                          Future.delayed(Duration(milliseconds: 300), () {
                            Navigator.of(context)
                                .pushReplacement(MaterialPageRoute(
                                    builder: (context) => HomeScreen(
                                          firstTime: firstTime!,
                                          skipped: true,
                                        )));
                          });
                        },
                        child: Text(
                            AppLocalizations.of(context)!.translate('skip'),
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold))),
                  ),
                  appleSignInWidget: Platform.isIOS
                      ? Column(
                          children: [
                            SignInWithAppleButton(
                              style: SignInWithAppleButtonStyle.white,
                              onPressed: () async {
                                final credential =
                                    await SignInWithApple.getAppleIDCredential(
                                  scopes: [
                                    AppleIDAuthorizationScopes.email,
                                    AppleIDAuthorizationScopes.fullName,
                                  ],
                                );

                                if (credential != null) {
                                  String? username =
                                      credential.givenName != null &&
                                              credential.familyName != null
                                          ? credential.givenName! +
                                              ' ' +
                                              credential.familyName!
                                          : credential.givenName != null
                                              ? credential.givenName
                                              : credential.email != null
                                                  ? credential.email!
                                                      .split('@')
                                                      .first
                                                  : '';
                                  final oAuthProvider =
                                      OAuthProvider('apple.com');
                                  OAuthCredential credent =
                                      oAuthProvider.credential(
                                    idToken: credential.identityToken,
                                    accessToken: credential.authorizationCode,
                                  );
                                  final userCredential = await FirebaseAuth
                                      .instance
                                      .signInWithCredential(credent);
                                  final firebaseUser = userCredential.user;
                                  String? token = await FirebaseMessaging
                                      .instance
                                      .getToken();
                                  print('~~~~~${credent.asMap()}');
                                  print(credential.userIdentifier);
                                  QuerySnapshot querySnapshot =
                                      await FirebaseDataRepository()
                                          .getUserDataByToken(
                                              firebaseUser!.uid);

                                  String email = '';

                                  if (querySnapshot != null &&
                                      querySnapshot.docs.isNotEmpty) {
                                    email =
                                        querySnapshot.docs.first.get('email');
                                    sharedPref.setString('useremail', email);
                                  } else {
                                    await FirebaseDataRepository()
                                        .addUser(FirebaseUserModel(
                                      firebaseUser.uid,
                                      username!,
                                      credential.email!,
                                      token!,
                                    ));
                                    if (firebaseUser.email != null) {
                                      email = firebaseUser.email!;
                                      sharedPref.setString(
                                          'useremail', firebaseUser.email!);
                                    } else {
                                      // sharedPref.setString(
                                      //     'useremail', credential.userIdentifier);
                                    }
                                  }

                                  sharedPref.setString('username', username!);
                                  sharedPref.setString('password', '');
                                  sharedPref.setString('phone', '');
                                  sharedPref.setString(
                                      'loginProvider', 'apple');

                                  String url =
                                      'https://salam.mukminapps.com/api/Users';
                                  var result = await http.get(Uri.parse(url),
                                      headers: {"Accept": "application/json"});
                                  List responseBody = jsonDecode(result.body);

                                  var aaa = responseBody.indexWhere((element) =>
                                      element['email'] != null &&
                                      element['email'].toString() == email);

                                  if (aaa == -1) {
                                    var postData = {
                                      'name': credential.givenName != null
                                          ? credential.givenName
                                          : email != null
                                              ? email.split('@').first
                                              : 'user',
                                      'email': email != null ? email : '',
                                      'phone': '',
                                      'password': '123456',
                                      'cpassword': '123456',
                                      'user_type': 2
                                    };
                                    var response = await http.post(
                                        Uri.parse(
                                            'https://salam.mukminapps.com/api/User/add'),
                                        headers: {
                                          'Content-Type': 'application/json'
                                        },
                                        body: json.encode(postData),
                                        encoding: Encoding.getByName("utf-8"));
                                    print(response.body);
                                    List responseBodyy =
                                        jsonDecode(response.body);

                                    if (responseBodyy != null &&
                                        responseBodyy.isNotEmpty) {
                                      sharedPref.setString('userid',
                                          responseBodyy.last['id'].toString());
                                    }
                                  } else {
                                    sharedPref.setString('userid',
                                        responseBody[aaa]['id'].toString());
                                  }

                                  Future.delayed(Duration(milliseconds: 300),
                                      () {
                                    Navigator.of(context)
                                        .pushReplacement(FadePageRoute(
                                      builder: (context) => HomeScreen(
                                          firstTime: true, skipped: false),
                                    ));
                                  });
                                } else {
                                  print('null credential');
                                }
                                try {} catch (e) {
                                  print(e);
                                }

                                // Now send the credential (especially `credential.authorizationCode`) to your server to create a session
                                // after they have been validated with Apple (see `Integration` section for more information on how to do this)
                              },
                            ),
                            SizedBox(height: 10)
                          ],
                        )
                      : Container()),
            ],
          ),
        ),
      ),
    );
  }

  bool isNumeric(String str) {
    try {
      var value = int.parse(str);
      return true;
    } on FormatException {
      print('errorrr');
      return false;
    } finally {
      return true;
    }
  }

  _goToHome() {
    if (firstTime!) {
      sharedPref.setBool('firstTime', false);
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => HomeScreen(
              firstTime: firstTime!,
              skipped: false,
            )));
  }
}
