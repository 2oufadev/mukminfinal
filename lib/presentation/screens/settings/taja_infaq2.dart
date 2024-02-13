import 'dart:io';
import 'dart:math';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mukim_app/presentation/screens/settings/recipient_list_screen.dart';
import 'package:mukim_app/presentation/screens/settings/special_coupon.dart';
import 'package:mukim_app/presentation/screens/settings/subscription_webview.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../business_logic/cubit/subscription/userstate_cubit.dart';
import '../../../data/api/payment_api.dart';
import '../../../data/repository/firebase_data_repository.dart';
import '../../../data/repository/payment_repository.dart';
import '../../../providers/theme.dart';
import '../../../utils/componants.dart';
import '../../../utils/get_theme_color.dart';
import '../../widgets/svg_icon.dart';

class TajaInfaq2 extends StatefulWidget {
  final String email, username, selected, description;
  final int mode;
  const TajaInfaq2(
      {Key? key,
      required this.email,
      required this.username,
      required this.selected,
      required this.mode,
      required this.description})
      : super(key: key);

  @override
  _TajaInfaq2State createState() => _TajaInfaq2State();
}

const String _kConsumableId = 'consumable';

class _TajaInfaq2State extends State<TajaInfaq2> {
  Map<String, dynamic>? userStateMap;
  String selected = 'tajaan';
  String couponCode = '';
  String generatedCoupon = '';
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  List<String> _notFoundIds = <String>[];
  List<ProductDetails> _products = <ProductDetails>[];
  List<PurchaseDetails> _purchases = <PurchaseDetails>[];
  List<String> _consumables = <String>[];
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = true;
  String? _queryProductError;
  final bool _kAutoConsume = Platform.isIOS || true;

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
                            "Pilihan Cara Derma",
                            style:
                                Theme.of(context).textTheme.headline6!.copyWith(
                                      color: Colors.white,
                                    ),
                          ),
                        ),
                        ListTile(
                          leading: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: getColor(theme, isButton: true),
                              child: selected != 'tajaan'
                                  ? null
                                  : Icon(
                                      Icons.circle_rounded,
                                      color: Colors.white,
                                      size: 13,
                                    ),
                            ),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Tajaan Terbuka",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .copyWith(
                                        color: Colors.white, fontSize: 14),
                              ),
                              SizedBox(height: 3),
                              Row(
                                children: [
                                  Text(
                                    "*",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6!
                                        .copyWith(
                                            color: Colors.white, fontSize: 12),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      "Tajaan akan dibuka kepada umum",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6!
                                          .copyWith(
                                              color: Colors.white,
                                              fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onTap: () {
                            setState(() => selected = 'tajaan');
                          },
                        ),
                        ListTile(
                          leading: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: getColor(theme, isButton: true),
                              child: selected != 'coupon'
                                  ? null
                                  : Icon(
                                      Icons.circle_rounded,
                                      color: Colors.white,
                                      size: 13,
                                    ),
                            ),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Kupon Khas Penderma",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .copyWith(
                                        color: Colors.white, fontSize: 14),
                              ),
                              SizedBox(height: 3),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "*",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6!
                                        .copyWith(
                                            color: Colors.white, fontSize: 12),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      "Tajaan akan dibuka melalui kupon khas",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6!
                                          .copyWith(
                                              color: Colors.white,
                                              fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onTap: () {
                            setState(() => selected = 'coupon');
                          },
                        ),
                        SizedBox(height: 10),
                        Visibility(
                          visible: selected == 'coupon' ? true : false,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 25.0),
                            child: Column(
                              children: [
                                SizedBox(height: 5),
                                couponCode.isNotEmpty &&
                                        generatedCoupon != null &&
                                        generatedCoupon.isNotEmpty
                                    ? Text('Coupon Code',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.white))
                                    : Container(),
                                SizedBox(height: 10),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  width: MediaQuery.of(context).size.width,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: Colors.white),
                                    color: couponCode.isNotEmpty &&
                                            generatedCoupon != null &&
                                            generatedCoupon.isNotEmpty
                                        ? Colors.grey[700]
                                        : Colors.white,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: couponCode.isNotEmpty &&
                                                generatedCoupon != null &&
                                                generatedCoupon.isNotEmpty
                                            ? TextField(
                                                controller:
                                                    TextEditingController()
                                                      ..text = generatedCoupon,
                                                enabled: false,
                                                textCapitalization:
                                                    TextCapitalization
                                                        .characters,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    height: 1),
                                                textAlign: TextAlign.center,
                                                buildCounter: (context,
                                                        {required currentLength,
                                                        required isFocused,
                                                        maxLength}) =>
                                                    Container(),
                                                maxLength: 6,
                                                maxLengthEnforcement:
                                                    MaxLengthEnforcement
                                                        .enforced,
                                                maxLines: 1,
                                                decoration:
                                                    InputDecoration.collapsed(
                                                  hintText:
                                                      'Please Enter your 6 Prefix Coupon',
                                                  hintStyle: TextStyle(
                                                      fontSize: 14, height: 2),
                                                ),
                                              )
                                            : TextField(
                                                textCapitalization:
                                                    TextCapitalization
                                                        .characters,
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
                                                maxLength: 6,
                                                maxLengthEnforcement:
                                                    MaxLengthEnforcement
                                                        .enforced,
                                                maxLines: 1,
                                                decoration:
                                                    InputDecoration.collapsed(
                                                  hintText:
                                                      'Please Enter your 6 Prefix Coupon',
                                                  hintStyle: TextStyle(
                                                      fontSize: 14, height: 2),
                                                ),
                                                onChanged: (text) {
                                                  setState(() {
                                                    couponCode = text;
                                                  });
                                                },
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        SizedBox(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: getColor(theme, isButton: true),
                            ),
                            onPressed: () async {
                              if ((selected == 'coupon' &&
                                      generatedCoupon != null &&
                                      generatedCoupon.isNotEmpty) ||
                                  selected != 'coupon') {
                                if (Platform.isIOS) {
                                  PurchaseParam purchaseParam;

                                  List<ProductDetails> productsDetails =
                                      _buildProductList();

                                  productsDetails.forEach((element) {
                                    print(element.id);
                                  });

                                  if (widget.selected == '3150') {
                                    ProductDetails productDetails =
                                        productsDetails.firstWhere((element) =>
                                            element.id == '3pakejsponsor');
                                    purchaseParam = PurchaseParam(
                                      productDetails: productDetails,
                                    );

                                    if (productDetails.id == _kConsumableId) {
                                      _inAppPurchase.buyConsumable(
                                          purchaseParam: purchaseParam,
                                          autoConsume: _kAutoConsume);
                                    } else {
                                      _inAppPurchase.buyNonConsumable(
                                          purchaseParam: purchaseParam);
                                    }
                                  } else if (widget.selected == '5150') {
                                    ProductDetails productDetails =
                                        productsDetails.firstWhere((element) =>
                                            element.id == '5pakejsponsor');
                                    purchaseParam = PurchaseParam(
                                      productDetails: productDetails,
                                    );

                                    if (productDetails.id == _kConsumableId) {
                                      _inAppPurchase.buyConsumable(
                                          purchaseParam: purchaseParam,
                                          autoConsume: _kAutoConsume);
                                    } else {
                                      _inAppPurchase.buyNonConsumable(
                                          purchaseParam: purchaseParam);
                                    }
                                  } else if (widget.selected == '10150') {
                                    ProductDetails productDetails =
                                        productsDetails.firstWhere((element) =>
                                            element.id == '10pakejsponsor');
                                    purchaseParam = PurchaseParam(
                                      productDetails: productDetails,
                                    );

                                    if (productDetails.id == _kConsumableId) {
                                      _inAppPurchase.buyConsumable(
                                          purchaseParam: purchaseParam,
                                          autoConsume: _kAutoConsume);
                                    } else {
                                      _inAppPurchase.buyNonConsumable(
                                          purchaseParam: purchaseParam);
                                    }
                                  }
                                } else {
                                  await PaymentRepository(PaymentApi())
                                      .createBill(
                                    widget.email,
                                    widget.username,
                                    widget.selected,
                                    selected == 'coupon' &&
                                            generatedCoupon != null &&
                                            generatedCoupon.isNotEmpty
                                        ? widget.description +
                                            '(Special Coupon: $generatedCoupon)'
                                        : widget.description,
                                    1,
                                  )
                                      .then((value) async {
                                    if (value != null) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SubscriptionWebView(
                                                    url: value.url.toString(),
                                                    title: 'Pembayaran Tajaan',
                                                    amount: value.amount!,
                                                    mode: 1,
                                                  ))).then((value) async {
                                        if (selected == 'coupon') {
                                          final firebaseSponsorModel =
                                              await FirebaseDataRepository()
                                                  .checkSponsorCoupon(
                                                      generatedCoupon);

                                          print('********');
                                          print(firebaseSponsorModel);
                                          if (firebaseSponsorModel != null) {
                                            Future.delayed(
                                                Duration(seconds: 1),
                                                () => showDialog(
                                                    context: context,
                                                    builder:
                                                        (context) =>
                                                            AlertDialog(
                                                              backgroundColor:
                                                                  Color
                                                                      .fromARGB(
                                                                          255,
                                                                          53,
                                                                          52,
                                                                          52),
                                                              title: Column(
                                                                  children: [
                                                                    Text(
                                                                        'Terima kasih atas\nsumbangan anda',
                                                                        textAlign:
                                                                            TextAlign
                                                                                .center,
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .white,
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.bold)),
                                                                    SizedBox(
                                                                        height:
                                                                            10),
                                                                    ElevatedButton(
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        fixedSize: Size(
                                                                            150,
                                                                            30),
                                                                        alignment:
                                                                            Alignment.center,
                                                                        primary: getColor(
                                                                            theme,
                                                                            isButton:
                                                                                true),
                                                                      ),
                                                                      onPressed:
                                                                          () async {
                                                                        try {
                                                                          // await FlutterShareMe()
                                                                          //     .shareToSystem(
                                                                          //   msg:
                                                                          //       generatedCoupon,
                                                                          // );

                                                                          final DynamicLinkParameters dynamicLinkParams = DynamicLinkParameters(
                                                                              link: Uri.parse('https://mukminapps.com/$generatedCoupon'),
                                                                              uriPrefix: "https://mukminapps.page.link",
                                                                              androidParameters: const AndroidParameters(
                                                                                packageName: "com.alamintijarahresources.mukminapps",
                                                                                minimumVersion: 30,
                                                                              ),
                                                                              iosParameters: const IOSParameters(
                                                                                bundleId: "com.alamintijarahresources.mukminapps",
                                                                                appStoreId: "376771144",
                                                                                minimumVersion: "1.0.1",
                                                                              ),
                                                                              socialMetaTagParameters: SocialMetaTagParameters(title: 'MukminApp', description: 'Redeem Coupon', imageUrl: Uri.parse('https://salam.mukminapps.com/images/logo%20(7).png_1640172979.png')));

                                                                          final dynamicLink = await FirebaseDynamicLinks
                                                                              .instance
                                                                              .buildShortLink(dynamicLinkParams);
                                                                          final Uri
                                                                              shortUrl =
                                                                              dynamicLink.shortUrl;

                                                                          await Share
                                                                              .share(
                                                                            'Tajaan Percuma\nKod Code Pengaktifan :\n$generatedCoupon\nKlik di sini untuk tebus package premium anda\n${shortUrl.toString()}',
                                                                            subject:
                                                                                'Coupon Code',
                                                                          ).then(
                                                                              (value) {
                                                                            Navigator.push(context,
                                                                                MaterialPageRoute(builder: ((context) => RecipientListScreen())));
                                                                          });
                                                                        } catch (e) {
                                                                          print(
                                                                              'error: $e');
                                                                          Navigator.pop(
                                                                              context);
                                                                        }
                                                                      },
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          SvgIcon(
                                                                            svg:
                                                                                'share',
                                                                            shader:
                                                                                false,
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                10,
                                                                          ),
                                                                          Text(
                                                                              'Share Code',
                                                                              style: TextStyle(
                                                                                color: Colors.white,
                                                                                fontSize: 12,
                                                                                fontWeight: FontWeight.normal,
                                                                              ))
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ]),
                                                            )));
                                          }
                                        }
                                      });
                                    }
                                  });
                                }
                              } else {
                                if (couponCode != null &&
                                    couponCode.isNotEmpty) {
                                  setState(() {
                                    generatedCoupon = couponCode +
                                        UniqueKey()
                                            .toString()
                                            .replaceAll('[', '')
                                            .replaceAll(']', '')
                                            .replaceAll('#', '');
                                  });
                                } else {
                                  Fluttertoast.showToast(
                                      msg: 'Please enter coupon code');
                                }
                              }

                              // showDialog(
                              //     context: context,
                              //     builder: (context) => AlertDialog(
                              //           backgroundColor: Colors.grey[850],
                              //           title: Column(
                              //             children: [
                              //               Text('Pesanan Ringkas Anda',
                              //                   style: TextStyle(
                              //                       color: Colors.white)),
                              //               SizedBox(height: 20),
                              //               TextField(
                              //                 buildCounter: (context,
                              //                         {currentLength,
                              //                         isFocused,
                              //                         maxLength}) =>
                              //                     Text(
                              //                         currentLength.toString() +
                              //                             '/' +
                              //                             maxLength.toString(),
                              //                         style: TextStyle(
                              //                             color: Colors.white,
                              //                             fontSize: 12)),
                              //                 maxLines: 3,
                              //                 maxLength: 160,
                              //                 maxLengthEnforcement:
                              //                     MaxLengthEnforcement
                              //                         .truncateAfterCompositionEnds,
                              //                 style: TextStyle(
                              //                     color: Colors.black),
                              //                 decoration: InputDecoration(
                              //                   fillColor: Colors.white,
                              //                   filled: true,
                              //                   enabledBorder:
                              //                       OutlineInputBorder(
                              //                           borderRadius:
                              //                               BorderRadius
                              //                                   .circular(5),
                              //                           borderSide: BorderSide(
                              //                               color:
                              //                                   Colors.white)),
                              //                   border: OutlineInputBorder(
                              //                       borderRadius:
                              //                           BorderRadius.circular(
                              //                               5),
                              //                       borderSide: BorderSide(
                              //                           color: Colors.white)),
                              //                 ),
                              //                 onChanged: (text) {
                              //                   setState(() {
                              //                     descriptionText = text;
                              //                   });
                              //                 },
                              //               ),
                              //               SizedBox(height: 20),
                              //               SizedBox(
                              //                   height: 43,
                              //                   child: ElevatedButton(
                              //                     child: Text(
                              //                       "Teruskan",
                              //                       textAlign: TextAlign.center,
                              //                     ),
                              //                     style:
                              //                         ElevatedButton.styleFrom(
                              //                       primary: Color(0xFF807BB2),
                              //                     ),
                              //                     onPressed: () async {

                              //                     },
                              //                   ))
                              //             ],
                              //           ),
                              //         ));
                            },
                            child: Text(selected == 'coupon' &&
                                    generatedCoupon != null &&
                                    generatedCoupon.isNotEmpty
                                ? "Klik untuk sumbang"
                                : selected == 'coupon'
                                    ? "Generate Code"
                                    : 'Next'),
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
