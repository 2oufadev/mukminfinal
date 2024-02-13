import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
import 'package:mukim_app/data/models/sponsor_model.dart';
import 'package:mukim_app/presentation/screens/settings/settings_screen.dart';
import 'package:mukim_app/presentation/screens/settings/subscription_webview.dart';
import 'package:mukim_app/presentation/screens/settings/taja_infaq2.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../business_logic/cubit/sponsor/sponsor_cubit.dart';
import '../../../business_logic/cubit/subscription/userstate_cubit.dart';
import '../../../data/api/payment_api.dart';
import '../../../data/repository/payment_repository.dart';
import '../../../providers/theme.dart';
import '../../../utils/componants.dart';
import '../../../utils/get_theme_color.dart';

class TajaInfaq extends StatefulWidget {
  final String email, username, selected;
  final int mode;
  const TajaInfaq(
      {Key? key,
      required this.email,
      required this.username,
      required this.selected,
      required this.mode})
      : super(key: key);

  @override
  _TajaInfaqState createState() => _TajaInfaqState();
}

const String _kConsumableId = 'consumable';

class _TajaInfaqState extends State<TajaInfaq> {
  Map<String, dynamic>? userStateMap;
  String descriptionText = '';
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  List<String> _notFoundIds = <String>[];
  List<ProductDetails> _products = <ProductDetails>[];
  List<PurchaseDetails> _purchases = <PurchaseDetails>[];
  List<String> _consumables = <String>[];
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = false;
  String? _queryProductError;
  final bool _kAutoConsume = Platform.isIOS || true;
  List<SponsorModel>? sponsorsList;
  bool sponsorAdded = false;
  List<ProductDetails> _buildProductList() {
    if (!_isAvailable) {
      return [];
    }
    const ListTile productHeader = ListTile(title: Text('Products for Sale'));
    final List<ProductDetails> productList = [];
    if (_notFoundIds.isNotEmpty) {}

    // This loading previous purchases code is just a demo. Please do not use this as it is.
    // In your app you should always verify the purchase data using the `verificationData` inside the [PurchaseDetails] object before trusting it.
    // We recommend that you use your own server to verify the purchase data.
    final Map<String, PurchaseDetails> purchases =
        Map<String, PurchaseDetails>.fromEntries(
            _purchases.map((PurchaseDetails purchase) {
      if (purchase.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchase);
      }
      return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
    }));
    productList.addAll(_products.map(
      (ProductDetails productDetails) {
        final PurchaseDetails? previousPurchase = purchases[productDetails.id];
        return productDetails;
      },
    ));

    return productList;
  }

  @override
  Widget build(BuildContext context) {
    var cardBgColor = Color.fromRGBO(20, 18, 21, 1);
    String theme = Provider.of<ThemeNotifier>(context).appTheme;
    userStateMap = BlocProvider.of<UserStateCubit>(context).checkUserState();
    return SafeArea(
      top: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Color.fromRGBO(90, 89, 89, 1),
        appBar: AppBar(
          title: Text('Taja (Infaq)'),
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
            child: BlocConsumer<SponsorCubit, SponsorState>(
                listener: (context, state) {
              if (state is SponsorsLoaded) {
                sponsorsList = state.sponsorsList;
                if (sponsorsList != null && sponsorsList!.isNotEmpty) {
                  int index = sponsorsList!.indexWhere((element) =>
                      element.name!.toLowerCase().trim() ==
                          widget.username.toLowerCase().trim() &&
                      DateFormat('yyyy-MM-dd')
                              .parse(element.createdAt!.split('T').first)
                              .day ==
                          DateTime.now().day);
                  if (index != -1) {
                    sponsorAdded = true;
                    _loading = false;
                    FlutterLocalNotificationsPlugin().show(
                      Random().nextInt(pow(2, 31).toInt()),
                      'Congratulations!',
                      'Your sponsor packages are now available for users to redeem',
                      NotificationDetails(
                          android: AndroidNotificationDetails(
                              'high_importance_channel', // id
                              'High Importance Notifications', // title
                              channelDescription: 'your channel description',
                              playSound: true,
                              priority: Priority.high,
                              importance: Importance.high,
                              color: Colors.green,
                              styleInformation: BigTextStyleInformation(''))),
                    );
                  } else {
                    sponsorAdded = false;
                    _loading = false;
                    Fluttertoast.showToast(
                        msg: 'Payment not completed, please try again',
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM);
                  }
                  setState(() {});
                } else {
                  sponsorAdded = false;
                  _loading = false;
                }
              }
            }, builder: (context, state) {
              return _loading
                  ? Center(
                      child: SizedBox(
                          height: 30,
                          width: 30,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  getColor(theme)))))
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 30),
                          Card(
                            color: cardBgColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  SizedBox(height: 13),
                                  Text(
                                      sponsorAdded
                                          ? 'Sponsor Created Successfully'
                                          : 'Pilihan Derma',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 20),
                                  !sponsorAdded
                                      ? Column(
                                          children: [
                                            TextField(
                                              buildCounter: (context,
                                                      {required currentLength,
                                                      required isFocused,
                                                      maxLength}) =>
                                                  Container(),
                                              maxLines: 2,
                                              maxLength: 160,
                                              maxLengthEnforcement:
                                                  MaxLengthEnforcement.enforced,
                                              style: TextStyle(
                                                  color: Colors.black),
                                              decoration: InputDecoration(
                                                fillColor: Colors.white,
                                                filled: true,
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.white)),
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    borderSide: BorderSide(
                                                        color: Colors.white)),
                                              ),
                                              onChanged: (text) {
                                                setState(() {
                                                  descriptionText = text;
                                                });
                                              },
                                            ),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text('*Maksima 160 aksara',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12)),
                                            ),
                                            SizedBox(height: 20),
                                          ],
                                        )
                                      : Container(),
                                  SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      child: ElevatedButton(
                                        child: Text(
                                          sponsorAdded ? 'Return' : "Next",
                                          textAlign: TextAlign.center,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          primary: Color(0xFF807BB2),
                                        ),
                                        onPressed: () async {
                                          FocusScope.of(context).unfocus();
                                          // print(widget.selected);
                                          // print(descriptionText);
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      TajaInfaq2(
                                                        email: widget.email,
                                                        mode: 1,
                                                        selected:
                                                            widget.selected,
                                                        username:
                                                            widget.username,
                                                        description:
                                                            descriptionText,
                                                      )));

                                          // if (sponsorAdded) {
                                          //   Navigator.push(
                                          //       context,
                                          //       MaterialPageRoute(
                                          //         builder: (context) =>
                                          //             SettingsScreen(),
                                          //       ));
                                          // } else {
                                          //   if (Platform.isIOS) {
                                          //     PurchaseParam purchaseParam;

                                          //     List<ProductDetails>
                                          //         productsDetails =
                                          //         _buildProductList();

                                          //     productsDetails
                                          //         .forEach((element) {
                                          //       print(element.id);
                                          //     });

                                          //     if (widget.selected == '3150') {
                                          //       ProductDetails productDetails =
                                          //           productsDetails.firstWhere(
                                          //               (element) =>
                                          //                   element.id ==
                                          //                   '3pakejsponsor');
                                          //       purchaseParam = PurchaseParam(
                                          //         productDetails:
                                          //             productDetails,
                                          //       );

                                          //       if (productDetails.id ==
                                          //           _kConsumableId) {
                                          //         _inAppPurchase.buyConsumable(
                                          //             purchaseParam:
                                          //                 purchaseParam,
                                          //             autoConsume:
                                          //                 _kAutoConsume);
                                          //       } else {
                                          //         _inAppPurchase
                                          //             .buyNonConsumable(
                                          //                 purchaseParam:
                                          //                     purchaseParam);
                                          //       }
                                          //     } else if (widget.selected ==
                                          //         '5150') {
                                          //       ProductDetails productDetails =
                                          //           productsDetails.firstWhere(
                                          //               (element) =>
                                          //                   element.id ==
                                          //                   '5pakejsponsor');
                                          //       purchaseParam = PurchaseParam(
                                          //         productDetails:
                                          //             productDetails,
                                          //       );

                                          //       if (productDetails.id ==
                                          //           _kConsumableId) {
                                          //         _inAppPurchase.buyConsumable(
                                          //             purchaseParam:
                                          //                 purchaseParam,
                                          //             autoConsume:
                                          //                 _kAutoConsume);
                                          //       } else {
                                          //         _inAppPurchase
                                          //             .buyNonConsumable(
                                          //                 purchaseParam:
                                          //                     purchaseParam);
                                          //       }
                                          //     } else if (widget.selected ==
                                          //         '10150') {
                                          //       ProductDetails productDetails =
                                          //           productsDetails.firstWhere(
                                          //               (element) =>
                                          //                   element.id ==
                                          //                   '10pakejsponsor');
                                          //       purchaseParam = PurchaseParam(
                                          //         productDetails:
                                          //             productDetails,
                                          //       );

                                          //       if (productDetails.id ==
                                          //           _kConsumableId) {
                                          //         _inAppPurchase.buyConsumable(
                                          //             purchaseParam:
                                          //                 purchaseParam,
                                          //             autoConsume:
                                          //                 _kAutoConsume);
                                          //       } else {
                                          //         _inAppPurchase
                                          //             .buyNonConsumable(
                                          //                 purchaseParam:
                                          //                     purchaseParam);
                                          //       }
                                          //     }
                                          //   } else {
                                          //     await PaymentRepository(
                                          //             PaymentApi())
                                          //         .createBill(
                                          //             widget.email,
                                          //             widget.username,
                                          //             widget.selected,
                                          //             descriptionText,
                                          //             1)
                                          //         .then((value) async {
                                          //       if (value != null) {
                                          //         Navigator.push(
                                          //             context,
                                          //             MaterialPageRoute(
                                          //                 builder: (context) =>
                                          //                     SubscriptionWebView(
                                          //                         mode: 1,
                                          //                         amount: value
                                          //                             .amount,
                                          //                         url: value.url
                                          //                             .toString(),
                                          //                         title:
                                          //                             'Pembayaran Tajaan'))).then(
                                          //             (value) {
                                          //           // setState(() {
                                          //           //   _loading = true;
                                          //           // });
                                          //           BlocProvider.of<
                                          //                       SponsorCubit>(
                                          //                   context)
                                          //               .fetchSponsors();
                                          //         });
                                          //       }
                                          //     });
                                          //   }
                                          // }
                                        },
                                      ))
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
            }),
          ),
        ),
      ),
    );
  }
}
