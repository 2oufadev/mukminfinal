import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mukim_app/data/models/redeemed_user_model.dart';
import 'package:mukim_app/data/repository/firebase_data_repository.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../business_logic/cubit/subscription/userstate_cubit.dart';
import '../../../data/models/firebase_sponsor_model.dart';
import '../../../providers/theme.dart';
import '../../../utils/componants.dart';

class RecipientListScreen extends StatefulWidget {
  const RecipientListScreen({Key? key}) : super(key: key);

  @override
  _RecipientListScreenState createState() => _RecipientListScreenState();
}

class _RecipientListScreenState extends State<RecipientListScreen> {
  Map<String, dynamic>? userStateMap;
  List<dynamic> couponsIdsList = [];
  List<FirebaseSponsorModel> couponsList = [];
  bool loading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCouponsIds();
  }

  getCouponsIds() async {
    couponsList = await FirebaseDataRepository().getCouponsList(couponsIdsList);
    setState(() {
      loading = false;
    });
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
          title: Text('Recipient List'),
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
          body: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: Container(
                  height: MediaQuery.of(context).size.height - 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(15)),
                  padding: loading
                      ? EdgeInsets.zero
                      : const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10),
                  child: loading
                      ? Shimmer.fromColors(
                          enabled: true,
                          child: Container(
                            height: 165,
                            decoration: new BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Color(0xFF383838)),
                          ),
                          baseColor: Color(0xFF383838),
                          highlightColor: Color(0xFF484848),
                        )
                      : couponsList == null || couponsList.isEmpty
                          ? Center(
                              child: Text(
                                "You haven't created coupons yet",
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .copyWith(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                              ),
                            )
                          : SingleChildScrollView(
                              child: Column(
                                children: [
                                  SizedBox(height: 20),
                                  Column(
                                    children: [
                                      Text(
                                        "Recipient List for Sponsor",
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6!
                                            .copyWith(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 30),
                                      ...couponsList.map((e) => listChild(e)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget listChild(FirebaseSponsorModel sponsorModel) {
    print(sponsorModel.redeemedUsers.toSet());
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '  Coupon Code: ${sponsorModel.code} - ${DateFormat('dd/MM/yyyy').format(sponsorModel.createdDate)}',
            style: TextStyle(color: Colors.white, fontSize: 12),
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 65,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.only(topLeft: Radius.circular(15))),
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('  Name',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              Expanded(
                flex: 35,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.only(topRight: Radius.circular(15))),
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text('Date',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              )
            ],
          ),
          Table(
            border: TableBorder.all(color: Colors.white),
            columnWidths: {
              0: FractionColumnWidth(0.65),
              1: FractionColumnWidth(0.35),
            },
            children: [
              ...sponsorModel.redeemedUsers
                  .cast<RedeemedUserModel>()
                  .map(
                    (e) => TableRow(children: [
                      Container(
                        height: 40,
                        padding: const EdgeInsets.all(12.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(e.username,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ),
                      Container(
                        height: 40,
                        padding: const EdgeInsets.all(12.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                              DateFormat('dd/MM/yyyy').format(e.redeemedDate),
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ),
                    ]),
                  )
                  .toList()
            ],
          ),
          SizedBox(height: 10),
          Text(
            ' *There are ${sponsorModel.slots} Slots Remaining',
            style: TextStyle(color: Colors.white, fontSize: 12),
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}
