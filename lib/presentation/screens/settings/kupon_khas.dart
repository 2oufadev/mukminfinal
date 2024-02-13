import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mukim_app/data/models/firebase_sponsor_model.dart';
import 'package:mukim_app/data/repository/firebase_data_repository.dart';
import 'package:mukim_app/presentation/screens/settings/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:http/http.dart' as http;
import '../../../business_logic/cubit/sponsor/sponsor_cubit.dart';
import '../../../business_logic/cubit/subscription/userstate_cubit.dart';
import '../../../providers/theme.dart';
import '../../../utils/componants.dart';
import '../../../utils/get_theme_color.dart';

class KuponKhas extends StatefulWidget {
  final FirebaseSponsorModel? firebaseSponsorModel;
  const KuponKhas({Key? key, this.firebaseSponsorModel}) : super(key: key);

  @override
  _KuponKhasState createState() => _KuponKhasState();
}

class _KuponKhasState extends State<KuponKhas> {
  Map<String, dynamic>? userStateMap;
  String couponCode = '';
  bool loadingRedeem = false;
  late SharedPreferences sharedPreferences;
  String email = '';
  String username = '';
  String customerId = '';
  String? token = '';

  initSharedPref() async {
    sharedPreferences = await SharedPreferences.getInstance();
    email = sharedPreferences.getString('useremail') ?? '';
    username =
        sharedPreferences.getString('username') ?? email.split('@').first;
    customerId = sharedPreferences.get('userid').toString();
    token = await FirebaseMessaging.instance.getToken();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSharedPref();
  }

  @override
  Widget build(BuildContext context) {
    var cardBgColor = Color.fromRGBO(20, 18, 21, 1);
    String theme = Provider.of<ThemeNotifier>(context).appTheme;
    userStateMap = BlocProvider.of<UserStateCubit>(context).checkUserState();
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Color.fromRGBO(90, 89, 89, 1),
        appBar: AppBar(
          title: Text('Kupon Khas'),
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
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 30),
                  Card(
                    color: cardBgColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 13),
                        Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            children: [
                              Text(
                                "Pesanan Ringkas Penaja",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .copyWith(
                                        color: Colors.white, fontSize: 16),
                              ),
                              SizedBox(height: 3),
                              Text(
                                widget.firebaseSponsorModel != null &&
                                        widget.firebaseSponsorModel!.username !=
                                            null
                                    ? widget.firebaseSponsorModel!.username
                                    : widget.firebaseSponsorModel != null &&
                                            widget.firebaseSponsorModel!
                                                    .userEmail !=
                                                null
                                        ? widget.firebaseSponsorModel!.userEmail
                                            .split('@')
                                            .first
                                        : '',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .copyWith(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white,
                                        fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            width: MediaQuery.of(context).size.width,
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Colors.white),
                              color: Colors.grey[700],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: TextField(
                                      controller: TextEditingController()
                                        ..text =
                                            widget.firebaseSponsorModel!.notes,
                                      enabled: false,
                                      textCapitalization:
                                          TextCapitalization.characters,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          height: 1),
                                      textAlign: TextAlign.left,
                                      buildCounter: (context,
                                              {required currentLength,
                                              required isFocused,
                                              maxLength}) =>
                                          Container(),
                                      maxLengthEnforcement:
                                          MaxLengthEnforcement.enforced,
                                      maxLines: 2,
                                    )),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          child: BlocConsumer<SponsorCubit, SponsorState>(
                              listener: (context, state) async {
                            print('~~~~~~~ Listening');
                            if (state is GetSponsorLoaded) {
                              DateTime afterYear =
                                  DateTime.now().add(Duration(days: 365));

                              var postData = {
                                'customer_id': customerId,
                                'package': state.sponsorModel.package,
                                'sponsor_id': state.sponsorModel.id,
                                'payment_status': 'Sponsored',
                                'status': 'active',
                                'date1': DateFormat('yyyy-MM-dd')
                                    .format(DateTime.now()),
                                'date2':
                                    DateFormat('yyyy-MM-dd').format(afterYear)
                              };
                              var response = await http.post(
                                  Uri.parse(
                                      'https://salam.mukminapps.com/api/subscription/add'),
                                  headers: {'Content-Type': 'application/json'},
                                  body: json.encode(postData),
                                  encoding: Encoding.getByName("utf-8"));

                              print('@@@@@@@@##### ${response.body}');

                              if (response.statusCode == 200) {
                                int sponsorId = state.sponsorModel.id!;
                                print('-------------- $sponsorId');
                                var response = await http.post(
                                    Uri.parse(
                                        'https://salam.mukminapps.com/api/sponsor/$sponsorId/redeem'),
                                    headers: {
                                      'Content-Type': 'application/json'
                                    },
                                    body: json.encode({}),
                                    encoding: Encoding.getByName("utf-8"));
                                print('-------------- ${response.body}');
                                // Future.delayed(Duration(seconds: 2), () {
                                //   FlutterLocalNotificationsPlugin().show(
                                //     Random().nextInt(pow(2, 31).toInt()),
                                //     'Congratulations!',
                                //     'Your subscription have Success and Expires at ${DateFormat("dd/MM/yyyy").format(afterYear)} based on Sponsor',
                                //     NotificationDetails(
                                //         android: AndroidNotificationDetails(
                                //             'scheduledImsakSilent', 'scheduledImsakSilent',
                                //             channelDescription:
                                //                 'your channel description',
                                //             playSound: false,
                                //             color: Colors.green,
                                //             styleInformation:
                                //                 BigTextStyleInformation(''))),
                                //   );
                                // });

                                bool redeemed = await FirebaseDataRepository()
                                    .redeemCoupon(widget.firebaseSponsorModel!,
                                        username, email, token!);

                                if (redeemed) {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SettingsScreen(
                                                checkSubscription: true,
                                              )));
                                }
                              } else {
                                Fluttertoast.showToast(
                                    msg:
                                        'An error occurred while adding Sponsor');
                              }
                            }

                            if (state is GetSponsorError) {
                              Fluttertoast.showToast(msg: state.error);
                            }
                          }, builder: (context, state) {
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: getColor(theme, isButton: true),
                              ),
                              onPressed: () async {
                                if (widget.firebaseSponsorModel != null) {
                                  // var postData =
                                  //     {
                                  //   'customer_id':
                                  //       customerId,
                                  //   'package': sponsorsList
                                  //       .firstWhere((element) =>
                                  //           element.id ==
                                  //           selectedSponsor)
                                  //       .package,
                                  //   'sponsor_id': sponsorsList
                                  //       .firstWhere((element) =>
                                  //           element.id ==
                                  //           selectedSponsor)
                                  //       .id,
                                  //   'payment_status':
                                  //       'Sponsor',
                                  //   'status':
                                  //       'active',
                                  //   'date1': DateFormat(
                                  //           'yyyy-MM-dd')
                                  //       .format(
                                  //           DateTime.now()),
                                  //   'date2': DateFormat(
                                  //           'yyyy-MM-dd')
                                  //       .format(
                                  //           afterYear)
                                  // };
                                  // var response = await http.post(
                                  //     Uri.parse(
                                  //         'https://salam.mukminapps.com/api/subscription/add'),
                                  //     headers: {
                                  //       'Content-Type':
                                  //           'application/json'
                                  //     },
                                  //     body: json.encode(
                                  //         postData),
                                  //     encoding:
                                  //         Encoding.getByName("utf-8"));

                                  // print(
                                  //     response);

                                  // if (response
                                  //         .statusCode ==
                                  //     200) {
                                  //   int sponsorId = sponsorsList
                                  //       .firstWhere((element) =>
                                  //           element.id ==
                                  //           selectedSponsor)
                                  //       .id;
                                  //   var response = await http.post(
                                  //       Uri.parse(
                                  //           'https://salam.mukminapps.com/api/sponsor/$sponsorId/redeem'),
                                  //       headers: {
                                  //         'Content-Type':
                                  //             'application/json'
                                  //       },
                                  //       body:
                                  //           json.encode({}),
                                  //       encoding:
                                  //           Encoding.getByName("utf-8"));

                                  //   Future.delayed(
                                  //       Duration(
                                  //           seconds: 2),
                                  //       () {
                                  //     FlutterLocalNotificationsPlugin()
                                  //         .show(
                                  //       Random()
                                  //           .nextInt(pow(2, 31).toInt()),
                                  //       'Congratulations!',
                                  //       'Your subscription have Success and Expires at ${DateFormat("dd/MM/yyyy").format(afterYear)} based on Sponsor',
                                  //       NotificationDetails(
                                  //           android: AndroidNotificationDetails('scheduledImsakSilent', 'scheduledImsakSilent', channelDescription: 'your channel description', playSound: false, color: Colors.green, styleInformation: BigTextStyleInformation(''))),
                                  //     );
                                  //   });

                                  BlocProvider.of<SponsorCubit>(context)
                                      .getSponsorByCode(
                                          widget.firebaseSponsorModel!.code);
                                } else {
                                  Fluttertoast.showToast(
                                      msg: 'Error occured, Please Try again');
                                }
                              },
                              child: loadingRedeem || state is GetSponsorLoading
                                  ? Container(
                                      height: 15,
                                      width: 15,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 1),
                                      ))
                                  : Text("Klik untuk unlock Premium"),
                            );
                          }),
                        ),
                        SizedBox(height: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
