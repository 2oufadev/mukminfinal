import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mukim_app/business_logic/cubit/hadith_cubit/hadith_cubit_cubit.dart';
import 'package:mukim_app/main.dart';
import 'package:mukim_app/presentation/screens/home/home_screen.dart';
import 'package:mukim_app/presentation/screens/login_screen.dart';
import 'package:mukim_app/presentation/screens/settings/maklum.dart';
import 'package:mukim_app/presentation/screens/settings/recipient_list_screen.dart';
import 'package:mukim_app/presentation/screens/settings/special_coupon.dart';
import 'package:mukim_app/utils/app_localization.dart';
import 'package:mukim_app/utils/common_functions.dart';
import 'package:path_provider/path_provider.dart';

import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukim_app/business_logic/cubit/hadith/hadith_cubit.dart';
import 'package:mukim_app/business_logic/cubit/subscription/userstate_cubit.dart';
import 'package:mukim_app/data/models/one_day_hadith_model.dart';
import 'package:mukim_app/presentation/screens/settings/azan.dart';
import 'package:mukim_app/presentation/screens/settings/theme.dart';
import 'package:mukim_app/presentation/screens/wallpapers/wallpaper_screen.dart';
import 'package:mukim_app/presentation/widgets/inputfield.dart';
import 'package:mukim_app/utils/componants.dart';
import 'package:mukim_app/providers/theme.dart';
import 'package:mukim_app/utils/get_theme_color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'naik_taraf.dart';
import 'sumbangan_terbuka.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SettingsScreen extends StatefulWidget {
  final bool? isPremiumUser;
  final bool? checkSubscription;
  const SettingsScreen({Key? key, this.isPremiumUser, this.checkSubscription})
      : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

// Future<void> onCreatedNotificationMethod() async {
//   String databasesPath = await getDatabasesPath();
//   String dbPath = path.join(databasesPath, 'my.db');
//   Database database = await openDatabase(
//     dbPath,
//     version: 1,
//   );
//   List<Map> www = await database.rawQuery('SELECT * FROM "hadith"');
//   if (www.isNotEmpty) {
//     List<dynamic> responseBody = jsonDecode(www.first['value'].toString());
//     List<OneDayHadithModel> oneDayHadithList =
//         responseBody.map((e) => OneDayHadithModel.fromJson(e)).toList();
//     oneDayHadithList.sort((a, b) => a.shown.compareTo(b.shown));
//     NotificationUtils.showHadithNotification(
//         oneDayHadithList.first.categoryName +
//             ' - ' +
//             oneDayHadithList.first.hadithName,
//         oneDayHadithList.first.description,
//         Globals.images_url + oneDayHadithList.first.hadithImage);

//     oneDayHadithList.first.shown = oneDayHadithList.first.shown + 1;
//     await database.insert(
//         'hadith',
//         {
//           'id': 1,
//           'value': json.encode(oneDayHadithList),
//         },
//         conflictAlgorithm: ConflictAlgorithm.replace);
//   } else {}
// }

class _SettingsScreenState extends State<SettingsScreen> {
  bool v1 = true;
  bool v2 = true;
  bool v3 = true;
  double height = 80.0;
  bool subscribed = false;
  bool expanded = false;
  TextEditingController password = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();
  bool isNotifikasiEnabled = true;
  String theme = 'default';
  String email = '';
  String userId = '';
  String package = '';
  bool showSave = false;
  String savedName = '';
  String savedPhone = '';
  String savedPassword = '';
  bool oneDayHadithEnabled = true;
  bool savingData = false;
  late SharedPreferences sharedPref;
  bool loading = true;
  Map<String, dynamic>? userStateMap;
  String loginProvider = '';
  List<OneDayHadithModel> oneDayHadithList = [];
  bool loggedIn = false;

  @override
  void didChangeDependencies() {
    if (widget.checkSubscription != null && widget.checkSubscription!) {
      userStateMap =
          BlocProvider.of<UserStateCubit>(context).checkUserFirstState();
    } else {
      userStateMap = BlocProvider.of<UserStateCubit>(context).checkUserState();
    }

    name.addListener(() {
      if (name.text != savedName &&
          name.text.isNotEmpty &&
          savedName.isNotEmpty) {
        if (!showSave) {
          setState(() {
            showSave = true;
          });
        }
      }
    });

    phone.addListener(() {
      if (phone.text != savedPhone &&
          phone.text.isNotEmpty &&
          savedPhone.isNotEmpty) {
        if (!showSave) {
          setState(() {
            showSave = true;
          });
        }
      }
    });

    password.addListener(() {
      if (password.text != savedPassword &&
          password.text.isNotEmpty &&
          savedPassword.isNotEmpty) {
        if (!showSave) {
          setState(() {
            showSave = true;
          });
        }
      }
    });
    getUserData();

    super.didChangeDependencies();
  }

  getUserData() async {
    sharedPref = await SharedPreferences.getInstance();
    userId = sharedPref.getString('userid') ?? '';
    email = sharedPref.getString('useremail') ?? '';
    savedName = sharedPref.getString('username') ?? '';
    password.text = sharedPref.getString('password') ?? '';
    savedPassword = sharedPref.getString('password') ?? '';
    savedPhone = sharedPref.getString('phone') ?? '';
    loginProvider = sharedPref.getString('loginProvider') ?? '';
    oneDayHadithEnabled = sharedPref.getBool('onedayhadithenabled') ?? true;
    if (savedName.isNotEmpty) {
      name.text = savedName;
    }

    if (savedPhone.isNotEmpty) {
      phone.text = savedPhone;
    }
    if (userId.isNotEmpty) {
      try {
        String url =
            'https://salam.mukminapps.com/api/User/' + userId.toString();
        var result = await http
            .get(Uri.parse(url), headers: {"Accept": "application/json"});
        List responseBody = jsonDecode(result.body);

        if (savedName.isEmpty) {
          name.text = responseBody.first['name'];
          savedName = responseBody.first['name'];
        }

        if (savedPhone.isEmpty) {
          phone.text = responseBody.first['phone'].toString() ?? '';
          savedPhone = responseBody.first['phone'].toString() ?? '';
        }

        setState(() {
          loading = false;
        });
        return responseBody;
      } catch (e) {
        if (mounted) {
          setState(() {
            loading = false;
          });
        }

        return e;
      }
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    theme = Provider.of<ThemeNotifier>(context).appTheme;

    return SafeArea(
      top: false,
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomeScreen()));
          return false;
        },
        child: Scaffold(
            backgroundColor: Color.fromRGBO(82, 82, 82, 1),
            appBar: AppBar(
              leading: InkWell(
                  onTap: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => HomeScreen()));
                  },
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  )),
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
              backgroundColor: Colors.transparent,
              title: Text(
                "Tetapan",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
              ),
              actions: [
                showSave
                    ? Container(
                        alignment: Alignment.center,
                        constraints: BoxConstraints(minWidth: 50),
                        margin: EdgeInsets.only(right: 20),
                        child: InkWell(
                            onTap: () async {
                              if (userId.isNotEmpty) {
                                setState(() {
                                  savingData = true;
                                });

                                var postData = {
                                  'name': name.text,
                                  'email': email,
                                  'password': password.text,
                                  'cpassword': password.text,
                                  'phone': phone.text.isNotEmpty &&
                                          phone.text != 'null'
                                      ? int.parse(phone.text)
                                      : 0,
                                  'user_type': 2
                                };
                                var response = await http.post(
                                    Uri.parse(
                                        'https://salam.mukminapps.com/api/User/$userId/update'),
                                    headers: {
                                      'Content-Type': 'application/json'
                                    },
                                    body: json.encode(postData),
                                    encoding: Encoding.getByName("utf-8"));
                                print(response.body);
                                sharedPref.setString('username', name.text);
                                sharedPref.setString('password', password.text);

                                User? user = FirebaseAuth.instance.currentUser;

                                //Pass in the password to updatePassword.
                                user!.updatePassword(password.text).then((_) {
                                  print("Successfully changed password");
                                }).catchError((error) {
                                  print("Password can't be changed" +
                                      error.toString());
                                  //This might happen, when the wrong password is in, the user isn't found, or if the user hasn't logged in recently.
                                });

                                if (savedPhone.isNotEmpty ||
                                    phone.text.isNotEmpty) {
                                  sharedPref.setString('phone', phone.text);
                                }

                                setState(() {
                                  savingData = false;
                                  showSave = false;
                                });
                                return null;
                              }
                            },
                            child: savingData
                                ? Container(
                                    height: 15,
                                    width: 15,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 1,
                                    ))
                                : Text('Save',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold))),
                      )
                    : Container(),
              ],
            ),
            body: loading
                ? Center(
                    child: CircularProgressIndicator(
                    color: getColor(theme),
                    strokeWidth: 2,
                  ))
                : BlocBuilder<UserStateCubit, UserState>(
                    builder: (context, state) {
                    if (state is LoginState) {
                      subscribed = state.userStateMap!['subscribed'];
                      loggedIn = state.userStateMap!['loggedIn'];
                      package = state.userStateMap!['package'];
                    }
                    return SlidingUpPanel(
                      minHeight: 64,
                      maxHeight: 265,
                      color: Colors.black.withOpacity(0.5),
                      panel: bottomNavBarWithOpacity(
                          context: context,
                          loggedIn: state is LoginState
                              ? state.userStateMap!['loggedIn']
                              : false),
                      body: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: NotificationListener(
                          onNotification: (n) {
                            if (n is ScrollStartNotification) {
                              setState(() {
                                expanded = false;
                              });
                            }
                            return false;
                          },
                          child: ListView(
                            children: [
                              if (savedName != null && savedName.isNotEmpty)
                                Column(
                                  children: [
                                    _buildInputField(
                                        title: 'Nama',
                                        ctrl: name,
                                        type: TextInputType.name),
                                    const SizedBox(height: 8.0),
                                  ],
                                ),
                              if (email != null && email.isNotEmpty)
                                Column(
                                  children: [
                                    _buildInputField(
                                        title: AppLocalizations.of(context)!
                                            .translate('email'),
                                        initial: email,
                                        type: TextInputType.none),
                                    const SizedBox(height: 8.0),
                                  ],
                                ),
                              loginProvider != 'facebook' &&
                                      loginProvider != 'google' &&
                                      savedPhone != null &&
                                      savedPhone.isNotEmpty
                                  ? Column(
                                      children: [
                                        _buildInputField(
                                            title: 'Nombor Telefon',
                                            ctrl: phone,
                                            type: TextInputType.phone),
                                        const SizedBox(height: 8.0),
                                        _buildInputField(
                                            title: 'Kata Laluan',
                                            //  initial: savedPassword,
                                            ctrl: password,
                                            obscur: true,
                                            suffix: showSave
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 12.0),
                                                    child: MaterialButton(
                                                      onPressed: () async {
                                                        if (userId.isNotEmpty) {
                                                          setState(() {
                                                            savingData = true;
                                                          });

                                                          var postData = {
                                                            'name': name.text,
                                                            'email': email,
                                                            'password':
                                                                password.text,
                                                            'cpassword':
                                                                password.text,
                                                            'phone': phone.text
                                                                        .isNotEmpty &&
                                                                    phone.text !=
                                                                        'null'
                                                                ? int.parse(
                                                                    phone.text)
                                                                : 0,
                                                            'user_type': 2
                                                          };
                                                          var response = await http.post(
                                                              Uri.parse(
                                                                  'https://salam.mukminapps.com/api/User/$userId/update'),
                                                              headers: {
                                                                'Content-Type':
                                                                    'application/json'
                                                              },
                                                              body: json.encode(
                                                                  postData),
                                                              encoding: Encoding
                                                                  .getByName(
                                                                      "utf-8"));
                                                          print(response.body);
                                                          sharedPref.setString(
                                                              'username',
                                                              name.text);
                                                          sharedPref.setString(
                                                              'password',
                                                              password.text);

                                                          User? user =
                                                              FirebaseAuth
                                                                  .instance
                                                                  .currentUser;

                                                          //Pass in the password to updatePassword.
                                                          user!
                                                              .updatePassword(
                                                                  password.text)
                                                              .then((_) {
                                                            print(
                                                                "Successfully changed password");
                                                          }).catchError(
                                                                  (error) {
                                                            print("Password can't be changed" +
                                                                error
                                                                    .toString());
                                                            //This might happen, when the wrong password is in, the user isn't found, or if the user hasn't logged in recently.
                                                          });

                                                          if (savedPhone
                                                                  .isNotEmpty ||
                                                              phone.text
                                                                  .isNotEmpty) {
                                                            sharedPref
                                                                .setString(
                                                                    'phone',
                                                                    phone.text);
                                                          }

                                                          setState(() {
                                                            savingData = false;
                                                            showSave = false;
                                                          });
                                                          return null;
                                                        }
                                                      },
                                                      color: getColor(theme,
                                                          isButton: true),
                                                      textColor: Colors.white,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5.0)),
                                                      child: savingData
                                                          ? Container(
                                                              height: 15,
                                                              width: 15,
                                                              child:
                                                                  CircularProgressIndicator(
                                                                color: Colors
                                                                    .white,
                                                                strokeWidth: 1,
                                                              ))
                                                          : Text(
                                                              'tukar',
                                                            ),
                                                    ),
                                                  )
                                                : Container(),
                                            type:
                                                TextInputType.visiblePassword),
                                        const SizedBox(height: 18.0),
                                      ],
                                    )
                                  : Container(),
                              Divider(
                                color: Colors.grey,
                                height: 1,
                              ),
                              ListTile(
                                dense: true,
                                trailing: CircleAvatar(
                                  radius: 13,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.navigate_next_rounded,
                                  ),
                                ),
                                title: Text(
                                  "Tukar Wallpaper",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) =>
                                              WallpaperScreen()))
                                      .then((value) {
                                    setState(() {});
                                  });
                                },
                              ),
                              Divider(
                                color: Colors.grey,
                                height: 1,
                              ),
                              ListTile(
                                dense: true,
                                trailing: CircleAvatar(
                                  radius: 13,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.navigate_next_rounded,
                                  ),
                                ),
                                title: Text(
                                  "Tetapan Azan",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) =>
                                              TetapanAzanScreen()))
                                      .then((value) {
                                    setState(() {});
                                  });
                                },
                              ),
                              Divider(
                                color: Colors.grey,
                                height: 1,
                              ),
                              ListTile(
                                dense: true,
                                trailing: CircleAvatar(
                                  radius: 13,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.navigate_next_rounded,
                                  ),
                                ),
                                title: Text(
                                  "Tukar Tema",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => ThemeScreen()));
                                },
                              ),
                              Divider(
                                color: Colors.grey,
                                height: 1,
                              ),
                              ListTile(
                                dense: true,
                                trailing: SizedBox(
                                  width: 50,
                                  child: BlocBuilder<HadithCubit, HadithState>(
                                      builder: (context, state) {
                                    return CupertinoSwitch(
                                      value: oneDayHadithEnabled,
                                      onChanged: (value) async {
                                        setState(
                                            () => oneDayHadithEnabled = value);
                                        sharedPref.setBool(
                                            'onedayhadithenabled', value);

                                        if (oneDayHadithEnabled) {
                                          BlocProvider.of<HadithCubitCubit>(
                                                  MyApp.navigatorKey
                                                      .currentContext!)
                                              .fetchOneDayHadithList();
                                        } else {
                                          String district = sharedPref
                                                  .getString('district') ??
                                              '';

                                          BlocProvider.of<HadithCubitCubit>(
                                                  context)
                                              .enableAllAzanNotificationsSound(
                                                  district);
                                        }
                                      },
                                      activeColor:
                                          getColor(theme, isButton: true),
                                    );
                                  }),
                                ),
                                title: Text(
                                  "Notifikasi 1 Hari 1 Hadis",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                                onTap: () {},
                              ),
                              if (!Platform.isIOS)
                                Divider(
                                  color: Colors.grey,
                                  height: 1,
                                ),
                              if (!Platform.isIOS)
                                ListTile(
                                  dense: true,
                                  trailing: CircleAvatar(
                                    radius: 13,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.navigate_next_rounded,
                                    ),
                                  ),
                                  title: Text(
                                    "Sumbangan Terbuka",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                  onTap: () {
                                    if (loggedIn) {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) =>
                                                  SumbanganTerbukaScreen()))
                                          .then((value) {
                                        setState(() {});
                                      });
                                    } else {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) =>
                                                  LoginScreen()))
                                          .then((value) {
                                        setState(() {});
                                      });
                                    }
                                  },
                                ),
                              Divider(
                                color: Colors.grey,
                                height: 1,
                              ),
                              if (!subscribed)
                                Column(
                                  children: [
                                    ListTile(
                                      dense: true,
                                      trailing: CircleAvatar(
                                        radius: 13,
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          Icons.navigate_next_rounded,
                                        ),
                                      ),
                                      title: Text(
                                        'Naik taraf ke (Premium)',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                      ),
                                      onTap: () {
                                        if (loggedIn) {
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                                  builder: (context) =>
                                                      NaikTarafScreen()))
                                              .then((value) {
                                            setState(() {});
                                          });
                                        } else {
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                                  builder: (context) =>
                                                      LoginScreen()))
                                              .then((value) {
                                            setState(() {});
                                          });
                                        }
                                      },
                                    ),
                                    Divider(
                                      color: Colors.grey,
                                      height: 1,
                                    ),
                                    ListTile(
                                      dense: true,
                                      trailing: CircleAvatar(
                                        radius: 13,
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          Icons.navigate_next_rounded,
                                        ),
                                      ),
                                      title: Text(
                                        'Kupon Khas',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                      ),
                                      onTap: () {
                                        if (loggedIn) {
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                                  builder: (context) =>
                                                      SpecialCoupon()))
                                              .then((value) {
                                            setState(() {});
                                          });
                                        } else {
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                                  builder: (context) =>
                                                      LoginScreen()))
                                              .then((value) {
                                            setState(() {});
                                          });
                                        }
                                      },
                                    ),
                                    Divider(
                                      color: Colors.grey,
                                      height: 1,
                                    ),
                                  ],
                                ),
                              Column(
                                children: [
                                  ListTile(
                                    dense: true,
                                    trailing: CircleAvatar(
                                      radius: 13,
                                      backgroundColor: Colors.white,
                                      child: Icon(
                                        Icons.navigate_next_rounded,
                                      ),
                                    ),
                                    title: Text(
                                      'Recepient List Pakej Premium',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                      ),
                                    ),
                                    onTap: () {
                                      if (loggedIn) {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                                builder: (context) =>
                                                    RecipientListScreen()))
                                            .then((value) {
                                          setState(() {});
                                        });
                                      } else {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                                builder: (context) =>
                                                    LoginScreen()))
                                            .then((value) {
                                          setState(() {});
                                        });
                                      }
                                    },
                                  ),
                                  Divider(
                                    color: Colors.grey,
                                    height: 1,
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  ListTile(
                                    dense: true,
                                    trailing: CircleAvatar(
                                      radius: 13,
                                      backgroundColor: Colors.white,
                                      child: Icon(
                                        Icons.navigate_next_rounded,
                                      ),
                                    ),
                                    title: Text(
                                      "Maklum Balas",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) => Maklum()))
                                          .then((value) {
                                        setState(() {});
                                      });
                                    },
                                  ),
                                  Divider(
                                    color: Colors.grey,
                                    height: 1,
                                  ),
                                ],
                              ),
                              ListTile(
                                dense: true,
                                title: Center(
                                  child: Text(
                                    "Terma dan Syarat",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                onTap: () async {
                                  try {
                                    await launchUrlString(
                                        'https://mukminapps.com/term-of-use/');
                                  } catch (e) {}
                                },
                              ),
                              Divider(
                                color: Colors.grey,
                                height: 1,
                              ),
                              ListTile(
                                dense: true,
                                title: Center(
                                  child: Text(
                                    "Notis Privasi",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                onTap: () async {
                                  try {
                                    await launchUrlString(
                                        'https://mukminapps.com/privacy-policy/');
                                  } catch (e) {}
                                },
                              ),
                              loggedIn
                                  ? Column(children: [
                                      Divider(
                                        color: Colors.grey,
                                        height: 1,
                                      ),
                                      ListTile(
                                        dense: true,
                                        title: Center(
                                          child: Text(
                                            "Log Keluar",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          try {
                                            sharedPref.setString('userid', '');
                                            sharedPref.setString(
                                                'useremail', '');
                                            sharedPref.setString(
                                                'username', '');
                                            sharedPref.setString(
                                                'password', '');
                                            sharedPref.setString(
                                                'loginProvider', '');
                                            sharedPref.setString(
                                                'subscriptionEndDate', '');
                                            sharedPref.setBool(
                                                'subscribed', false);
                                            if (FirebaseAuth
                                                    .instance.currentUser !=
                                                null) {
                                              FirebaseAuth.instance.signOut();
                                            }
                                            Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        LoginScreen()),
                                                (Route<dynamic> route) =>
                                                    false);
                                          } catch (e) {}
                                        },
                                      )
                                    ])
                                  : Container(),
                              subscribed
                                  ? Column(
                                      children: [
                                        Divider(
                                          color: Colors.grey,
                                          height: 1,
                                        ),
                                        SizedBox(height: 18.0),
                                        Center(
                                          child: Text(
                                              'Tahniah , akaun anda bertaraf premium ($package)',
                                              style: TextStyle(
                                                  color: getColor(theme))),
                                        ),
                                      ],
                                    )
                                  : Container(),
                              SizedBox(height: 8.0),
                              SizedBox(height: 200.0),
                            ],
                          ),
                        ),
                      ),
                    );
                  })),
      ),
    );
  }

  _goToHome() {
    Navigator.of(context).pop();
  }

  _goToWallpaper() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => WallpaperScreen()));
  }

  Widget _buildInputField(
      {required String title,
      Widget? suffix,
      bool obscur = false,
      String? initial,
      TextEditingController? ctrl,
      TextInputType? type}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
            )),
        const SizedBox(height: 8.0),
        CustomInputField(
          suffix: suffix,
          type: type,
          ctrl: ctrl,
          initial: initial,
          obscur: obscur,
          padding: EdgeInsets.symmetric(horizontal: 0.0),
          inputTextColor: getColor(theme),
        ),
      ],
    );
  }
}
