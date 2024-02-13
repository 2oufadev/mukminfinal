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
import 'package:mukim_app/presentation/screens/settings/kupon_khas.dart';
import 'package:mukim_app/presentation/screens/settings/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../business_logic/cubit/subscription/userstate_cubit.dart';
import '../../../providers/theme.dart';
import '../../../utils/componants.dart';
import '../../../utils/get_theme_color.dart';

class SpecialCoupon extends StatefulWidget {
  final String? code;
  const SpecialCoupon({Key? key, this.code}) : super(key: key);

  @override
  _SpecialCouponState createState() => _SpecialCouponState();
}

class _SpecialCouponState extends State<SpecialCoupon> {
  Map<String, dynamic>? userStateMap;
  bool loadingRedeem = false;
  late SharedPreferences sharedPreferences;
  String email = '';
  String username = '';
  String? customerId = '';
  String? token = '';
  TextEditingController _couponController = TextEditingController();

  initSharedPref() async {
    sharedPreferences = await SharedPreferences.getInstance();
    email = sharedPreferences.getString('useremail') ?? '';
    username =
        sharedPreferences.getString('username') ?? email.split('@').first;
    customerId = sharedPreferences.get('userid').toString() ?? '';
    token = await FirebaseMessaging.instance.getToken();

    if (widget.code != null) {
      redeemCode(widget.code!);
    }
  }

  redeemCode(String code) async {
    _couponController.text = code;
    setState(() {
      loadingRedeem = true;
    });
    final firebaseSponsorModel =
        await FirebaseDataRepository().checkSponsorCoupon(code);

    print('********');
    if (firebaseSponsorModel != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: ((context) => KuponKhas(
                    firebaseSponsorModel: firebaseSponsorModel,
                  ))));
    } else {
      Fluttertoast.showToast(
          msg: "Incorrect Code",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 12.0);
    }

    setState(() {
      loadingRedeem = false;
    });
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
          title: Text('Special Coupon'),
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
                          child: Text(
                            "Coupon Code",
                            style:
                                Theme.of(context).textTheme.headline6!.copyWith(
                                      color: Colors.white,
                                    ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            width: MediaQuery.of(context).size.width,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Colors.white),
                              color: Colors.white,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: TextField(
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        height: 1),
                                    textAlign: TextAlign.center,
                                    buildCounter: (context,
                                            {required currentLength,
                                            required isFocused,
                                            maxLength}) =>
                                        Container(),
                                    maxLengthEnforcement:
                                        MaxLengthEnforcement.enforced,
                                    maxLines: 1,
                                    decoration: InputDecoration.collapsed(
                                      hintText: 'Enter Code Coupon',
                                      hintStyle:
                                          TextStyle(fontSize: 14, height: 2),
                                    ),
                                    controller: _couponController,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: getColor(theme, isButton: true),
                            ),
                            onPressed: () async {
                              setState(() {
                                loadingRedeem = true;
                              });
                              final firebaseSponsorModel =
                                  await FirebaseDataRepository()
                                      .checkSponsorCoupon(
                                          _couponController.text);

                              print('********');
                              if (firebaseSponsorModel != null) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: ((context) => KuponKhas(
                                              firebaseSponsorModel:
                                                  firebaseSponsorModel,
                                            ))));
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Incorrect Code",
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.white,
                                    textColor: Colors.black,
                                    fontSize: 12.0);
                              }

                              setState(() {
                                loadingRedeem = false;
                              });
                            },
                            child: loadingRedeem
                                ? Container(
                                    height: 15,
                                    width: 15,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 1),
                                    ))
                                : Text("Teruskan"),
                          ),
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
