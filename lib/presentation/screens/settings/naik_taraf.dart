import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
import 'package:mukim_app/business_logic/cubit/sponsor/sponsor_cubit.dart';
import 'package:mukim_app/business_logic/cubit/subscription/userstate_cubit.dart';
import 'package:mukim_app/data/api/payment_api.dart';
import 'package:mukim_app/data/models/sponsor_model.dart';
import 'package:mukim_app/data/repository/payment_repository.dart';
import 'package:mukim_app/presentation/screens/settings/settings_screen.dart';
import 'package:mukim_app/presentation/screens/settings/subscription_webview.dart';
import 'package:mukim_app/utils/app_localization.dart';
import 'package:mukim_app/utils/componants.dart';
import 'package:mukim_app/providers/theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'dart:convert';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

import 'package:http/http.dart' as http;

import '../../../business_logic/consumable_store.dart';

class NaikTarafScreen extends StatefulWidget {
  const NaikTarafScreen({Key? key}) : super(key: key);

  @override
  _NaikTarafScreenState createState() => _NaikTarafScreenState();
}

const String _3pakejsponsor = '3pakejsponsor';
const String _5pakejsponsor = '5pakejsponsor';
const String _10pakejsponsor = '10pakejsponsor';
const String _sumbangan1 = 'sumbangan1';
const String _sumbangan10 = 'sumbangan10';
const String _sumbangan100 = 'sumbangan100';
const String _bulananSubscription = 'bulanan';
const String _tahunanSubscription = 'tahunan';
const String _kConsumableId = 'consumable';
List<String> _kProductIds = Platform.isAndroid
    ? <String>[
        _3pakejsponsor,
        _5pakejsponsor,
        _10pakejsponsor,
        _sumbangan1,
        _sumbangan10,
        _sumbangan100,
        _bulananSubscription,
        _tahunanSubscription,
      ]
    : <String>[
        _bulananSubscription,
        _tahunanSubscription,
      ];

class _NaikTarafScreenState extends State<NaikTarafScreen> {
  String selected = "250";
  int selectedSponsor = 0;
  Map<String, dynamic>? userStateMap;
  List<SponsorModel>? sponsorsList;
  int sponsorGroupValue = 0;
  late SharedPreferences sharedPreferences;
  String username = '';
  String email = '';
  String customerId = '';
  String subscriptionDescription = "Bulanan (RM1.00)";
  List<BrowserEvent> _events = [];
  bool loadingRedeem = false;
  bool showSponsorList = true;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<String> _notFoundIds = <String>[];
  List<ProductDetails> _products = <ProductDetails>[];
  List<PurchaseDetails> _purchases = <PurchaseDetails>[];
  List<String> _consumables = <String>[];
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = true;
  String? _queryProductError;
  final bool _kAutoConsume = Platform.isIOS || true;

  @override
  void initState() {
    super.initState();
    userStateMap = BlocProvider.of<UserStateCubit>(context).checkUserState();
    sponsorsList = BlocProvider.of<SponsorCubit>(context).fetchSponsors();
    initSharedPref();
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription =
        purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription?.cancel();
    }, onError: (Object error) {
      // handle error here.
    });
    initStoreInfo();
  }

  @override
  void dispose() {
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatformAddition.setDelegate(null);
    }
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      setState(() {
        _isAvailable = isAvailable;
        _products = <ProductDetails>[];
        _purchases = <PurchaseDetails>[];
        _notFoundIds = <String>[];
        _consumables = <String>[];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    }

    final ProductDetailsResponse productDetailResponse =
        await _inAppPurchase.queryProductDetails(_kProductIds.toSet());
    if (productDetailResponse.error != null) {
      setState(() {
        _queryProductError = productDetailResponse.error!.message;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = <PurchaseDetails>[];
        _notFoundIds = productDetailResponse.notFoundIDs;
        _consumables = <String>[];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {
        _queryProductError = null;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = <PurchaseDetails>[];
        _notFoundIds = productDetailResponse.notFoundIDs;
        _consumables = <String>[];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    final List<String> consumables = await ConsumableStore.load();
    setState(() {
      _isAvailable = isAvailable;
      _products = productDetailResponse.productDetails;
      _notFoundIds = productDetailResponse.notFoundIDs;
      _consumables = consumables;
      _purchasePending = false;
      _loading = false;
    });
  }

  List<ProductDetails> _buildProductList() {
    if (!_isAvailable) {
      print('~~~~~~~~~~~ is Not Available');
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

    print('~~~~~~~~~~~ is Available ${productList.toSet()}');

    return productList;
  }

  Future<void> consume(String id) async {
    await ConsumableStore.consume(id);
    final List<String> consumables = await ConsumableStore.load();
    setState(() {
      _consumables = consumables;
    });
  }

  void showPendingUI() {
    setState(() {
      _purchasePending = true;
    });
  }

  Future<void> deliverProduct(PurchaseDetails purchaseDetails) async {
    DateTime endDate = DateTime.now();
    if (selected == '250') {
      endDate = DateTime.now().add(Duration(days: 30));
    } else if (selected == '1150') {
      endDate = DateTime.now().add(Duration(days: 365));
    } else {
      endDate = DateTime.now().add(Duration(days: 1095));
    }

    var postData = {
      'email': email,
      'paid': true,
      'paid_amount': selected,
      'package_type':
          selected == '250' ? 'Bulanan (RM1.00)' : 'Tahunan (RM10.00)',
      'payment_status': 'Success',
      'status': 'active',
      'date1': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'date2': DateFormat('yyyy-MM-dd').format(endDate)
    };
    var response = await http.post(
        Uri.parse(
            'https://salam.mukminapps.com/api/subscription/payment/notify_url'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(postData),
        encoding: Encoding.getByName("utf-8"));

    print('@@@@@@@@##### ${response.body}');

    if (response.statusCode == 200 &&
        !response.body.toLowerCase().contains('error')) {
      FlutterLocalNotificationsPlugin().show(
        Random().nextInt(pow(2, 31).toInt()),
        'Congratulations!',
        'Your subscription have Success and Expires at ${DateFormat("dd/MM/yyyy").format(endDate)} based on Subscription',
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
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => SettingsScreen(
                    checkSubscription: true,
                  )));
    }

    // IMPORTANT!! Always verify purchase details before delivering the product.
    //  var response = await ApiClient.postData('https://salam.mukminapps.com/api/subscription/payment/notify_url',
    //     headers: <String, String>{'authorization': 'Basic ' + base64Encode(utf8.encode('$Api_Key'))},
    //     body: parameters);
  }

  void handleError(IAPError error) {
    Fluttertoast.showToast(msg: error.message);
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.
    return Future<bool>.value(true);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // handle invalid purchase here if  _verifyPurchase` failed.

    Fluttertoast.showToast(msg: purchaseDetails.error!.message);
  }

  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          final bool valid = await _verifyPurchase(purchaseDetails);
          if (valid && purchaseDetails.status == PurchaseStatus.purchased) {
            deliverProduct(purchaseDetails);
          }
          if (valid) {
          } else {
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        }
        if (Platform.isAndroid) {
          if (!_kAutoConsume && purchaseDetails.productID == _kConsumableId) {
            final InAppPurchaseAndroidPlatformAddition androidAddition =
                _inAppPurchase.getPlatformAddition<
                    InAppPurchaseAndroidPlatformAddition>();
            await androidAddition.consumePurchase(purchaseDetails);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<void> confirmPriceChange(BuildContext context) async {
    // if (Platform.isAndroid) {
    //   final InAppPurchaseAndroidPlatformAddition androidAddition =
    //       _inAppPurchase
    //           .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
    //   final BillingResultWrapper priceChangeConfirmationResult =
    //       await androidAddition.launchPriceChangeConfirmationFlow(
    //     sku: 'purchaseId',
    //   );
    //   if (priceChangeConfirmationResult.responseCode == BillingResponse.ok) {
    //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    //       content: Text('Price change accepted'),
    //     ));
    //   } else {
    //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //       content: Text(
    //         priceChangeConfirmationResult.debugMessage ??
    //             'Price change failed with code ${priceChangeConfirmationResult.responseCode}',
    //       ),
    //     ));
    //   }
    // }
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iapStoreKitPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iapStoreKitPlatformAddition.showPriceConsentIfNeeded();
    }
  }

  initSharedPref() async {
    sharedPreferences = await SharedPreferences.getInstance();
    email = sharedPreferences.getString('useremail') ?? '';
    username =
        sharedPreferences.getString('username') ?? email.split('@').first;
    customerId = sharedPreferences.get('userid') != null
        ? sharedPreferences.get('userid').toString()
        : '';
  }

  @override
  Widget build(BuildContext context) {
    var cardBgColor = Colors.black87;
    String theme = Provider.of<ThemeNotifier>(context).appTheme;

    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Color.fromRGBO(50, 49, 49, 1),
        appBar: AppBar(
          leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.chevron_left,
              size: 30,
            ),
          ),
          title: Text('Naik Taraf (Premium)'),
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
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  BlocBuilder<SponsorCubit, SponsorState>(
                      builder: (context, state) {
                    if (state is SponsorsLoaded) {
                      sponsorsList = state.sponsorsList;
                      if (sponsorsList != null && sponsorsList!.isNotEmpty) {
                        if (selectedSponsor == 0) {
                          selectedSponsor = sponsorsList!.first.id!;
                        }
                      } else {
                        showSponsorList = false;
                      }
                    }
                    return !Platform.isIOS && showSponsorList
                        ? SizedBox(
                            width: double.infinity,
                            child: Card(
                              color: cardBgColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(18),
                                    child: Text(
                                      "Baki pakej premium percuma untuk anda!",
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6!
                                          .copyWith(
                                            color: Colors.white,
                                          ),
                                    ),
                                  ),
                                  state is SponsorsLoaded &&
                                          sponsorsList != null &&
                                          sponsorsList!.isNotEmpty
                                      ? ListTile(
                                          leading: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: CircleAvatar(
                                              radius: 10,
                                              backgroundColor:
                                                  Color(0xFF807BB2),
                                              child: selectedSponsor == 0 ||
                                                      selectedSponsor ==
                                                          sponsorsList!.first.id
                                                  ? Icon(
                                                      Icons.circle_rounded,
                                                      color: Colors.white,
                                                      size: 13,
                                                    )
                                                  : null,
                                            ),
                                          ),
                                          title: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  sponsorsList!.first.remaining
                                                              .toString() +
                                                          " " +
                                                          sponsorsList!
                                                              .first.package!
                                                              .substring(2)
                                                              .trim()
                                                              .split('|')
                                                              .first ??
                                                      'Null',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text(
                                                  sponsorsList!.first.name ??
                                                      'Null',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                  )),
                                            ],
                                          ),
                                          onTap: () {
                                            setState(() {
                                              selectedSponsor =
                                                  sponsorsList!.first.id!;
                                              print(
                                                  'selectedSponsor :> $selectedSponsor');
                                            });
                                          },
                                        )
                                      : state is SponsorsLoading
                                          ? Container(
                                              height: 40,
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width: 30,
                                                  ),
                                                  Shimmer.fromColors(
                                                    enabled: true,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Color(0xFF383838),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                      height: 20,
                                                      width: 20,
                                                    ),
                                                    baseColor:
                                                        Color(0xFF383838),
                                                    highlightColor:
                                                        Color(0xFF484848),
                                                  ),
                                                  SizedBox(
                                                    width: 20,
                                                  ),
                                                  Shimmer.fromColors(
                                                    enabled: true,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Color(0xFF383838),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5)),
                                                      height: 40,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              2,
                                                    ),
                                                    baseColor:
                                                        Color(0xFF383838),
                                                    highlightColor:
                                                        Color(0xFF484848),
                                                  )
                                                ],
                                              ),
                                            )
                                          : Container(),
                                  state is SponsorsLoaded &&
                                          sponsorsList != null &&
                                          sponsorsList!.isNotEmpty &&
                                          sponsorsList!.length > 1
                                      ? ListTile(
                                          leading: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: CircleAvatar(
                                              radius: 10,
                                              backgroundColor:
                                                  Color(0xFF807BB2),
                                              child: selectedSponsor ==
                                                      sponsorsList![1].id
                                                  ? Icon(
                                                      Icons.circle_rounded,
                                                      color: Colors.white,
                                                      size: 13,
                                                    )
                                                  : null,
                                            ),
                                          ),
                                          title: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  sponsorsList![1]
                                                              .remaining
                                                              .toString() +
                                                          " " +
                                                          sponsorsList![1]
                                                              .package!
                                                              .substring(2)
                                                              .trim()
                                                              .split('|')
                                                              .first ??
                                                      'Null',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text(
                                                  sponsorsList![1].name ??
                                                      'Null',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                  )),
                                            ],
                                          ),
                                          onTap: () {
                                            setState(() {
                                              selectedSponsor =
                                                  sponsorsList![1].id!;
                                              print(
                                                  'selectedSponsor :> $selectedSponsor');
                                            });
                                          },
                                        )
                                      : state is SponsorsLoading
                                          ? Column(
                                              children: [
                                                SizedBox(height: 10),
                                                Container(
                                                  height: 40,
                                                  child: Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 30,
                                                      ),
                                                      Shimmer.fromColors(
                                                        enabled: true,
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              color: Color(
                                                                  0xFF383838),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                          height: 20,
                                                          width: 20,
                                                        ),
                                                        baseColor:
                                                            Color(0xFF383838),
                                                        highlightColor:
                                                            Color(0xFF484848),
                                                      ),
                                                      SizedBox(
                                                        width: 20,
                                                      ),
                                                      Shimmer.fromColors(
                                                        enabled: true,
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              color: Color(
                                                                  0xFF383838),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5)),
                                                          height: 40,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              2,
                                                        ),
                                                        baseColor:
                                                            Color(0xFF383838),
                                                        highlightColor:
                                                            Color(0xFF484848),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Container(),
                                  SizedBox(height: 30),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: _events.map((e) {
                                      if (e is RedirectEvent) {
                                        return Text('redirect: ${e.url}');
                                      }
                                      if (e is CloseEvent) {
                                        return Text('closed');
                                      }

                                      return Text('Unknown event: $e');
                                    }).toList(),
                                  ),
                                  SizedBox(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: Color(0xFF807BB2),
                                      ),
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder:
                                                (context) =>
                                                    StatefulBuilder(builder:
                                                        (context, setState) {
                                                      return AlertDialog(
                                                        backgroundColor:
                                                            Colors.grey[850],
                                                        title: Column(
                                                          children: [
                                                            Text(
                                                                'Pesanan Ringkas Penaja',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white)),
                                                            SizedBox(height: 3),
                                                            Text(
                                                                selectedSponsor ==
                                                                        0
                                                                    ? sponsorsList!
                                                                            .first
                                                                            .name ??
                                                                        'Null'
                                                                    : sponsorsList!
                                                                            .firstWhere((element) =>
                                                                                element.id ==
                                                                                selectedSponsor)
                                                                            .name ??
                                                                        'Null',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    color: Colors
                                                                        .white70,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal)),
                                                            SizedBox(height: 5),
                                                            Container(
                                                              width: double
                                                                  .infinity,
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(5),
                                                              constraints:
                                                                  BoxConstraints(
                                                                      minHeight:
                                                                          50),
                                                              decoration:
                                                                  BoxDecoration(
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                      color: Colors
                                                                              .grey[
                                                                          700]),
                                                              child: Text(
                                                                  selectedSponsor ==
                                                                          0
                                                                      ? sponsorsList!
                                                                              .first
                                                                              .notes ??
                                                                          'Empty Note'
                                                                      : sponsorsList!
                                                                              .firstWhere((element) =>
                                                                                  element.id ==
                                                                                  selectedSponsor)
                                                                              .notes ??
                                                                          'Empty Note',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          14)),
                                                            ),
                                                            SizedBox(
                                                                height: 20),
                                                            SizedBox(
                                                                height: 43,
                                                                width: 200,
                                                                child:
                                                                    ElevatedButton(
                                                                  child: loadingRedeem
                                                                      ? Container(
                                                                          height: 15,
                                                                          width: 15,
                                                                          child: CircularProgressIndicator(
                                                                            color:
                                                                                Colors.white,
                                                                            strokeWidth:
                                                                                1,
                                                                          ))
                                                                      : Text(
                                                                          AppLocalizations.of(context)!
                                                                              .translate('click_to_unlock_premium'),
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                        ),
                                                                  style: ElevatedButton
                                                                      .styleFrom(
                                                                    primary: Color(
                                                                        0xFF807BB2),
                                                                  ),
                                                                  onPressed:
                                                                      () async {
                                                                    setState(
                                                                        () {
                                                                      loadingRedeem =
                                                                          true;
                                                                    });

                                                                    DateTime
                                                                        afterYear =
                                                                        DateTime.now().add(Duration(
                                                                            days:
                                                                                365));

                                                                    var postData =
                                                                        {
                                                                      'customer_id':
                                                                          customerId,
                                                                      'package': sponsorsList!
                                                                          .firstWhere((element) =>
                                                                              element.id ==
                                                                              selectedSponsor)
                                                                          .package,
                                                                      'sponsor_id': sponsorsList!
                                                                          .firstWhere((element) =>
                                                                              element.id ==
                                                                              selectedSponsor)
                                                                          .id,
                                                                      'payment_status':
                                                                          'Sponsored',
                                                                      'status':
                                                                          'active',
                                                                      'date1': DateFormat(
                                                                              'yyyy-MM-dd')
                                                                          .format(
                                                                              DateTime.now()),
                                                                      'date2': DateFormat(
                                                                              'yyyy-MM-dd')
                                                                          .format(
                                                                              afterYear)
                                                                    };
                                                                    var response = await http.post(
                                                                        Uri.parse(
                                                                            'https://salam.mukminapps.com/api/subscription/add'),
                                                                        headers: {
                                                                          'Content-Type':
                                                                              'application/json'
                                                                        },
                                                                        body: json.encode(
                                                                            postData),
                                                                        encoding:
                                                                            Encoding.getByName("utf-8"));

                                                                    print(
                                                                        response);

                                                                    if (response
                                                                            .statusCode ==
                                                                        200) {
                                                                      // int sponsorId = sponsorsList
                                                                      //     .firstWhere((element) =>
                                                                      //         element.id ==
                                                                      //         selectedSponsor)
                                                                      //     .id;
                                                                      // var response = await http.post(
                                                                      //     Uri.parse(
                                                                      //         'https://salam.mukminapps.com/api/sponsor/$sponsorId/redeem'),
                                                                      //     headers: {
                                                                      //       'Content-Type':
                                                                      //           'application/json'
                                                                      //     },
                                                                      //     body:
                                                                      //         json.encode({}),
                                                                      //     encoding:
                                                                      //         Encoding.getByName("utf-8"));

                                                                      Future.delayed(
                                                                          Duration(
                                                                              seconds: 2),
                                                                          () {
                                                                        FlutterLocalNotificationsPlugin()
                                                                            .show(
                                                                          Random()
                                                                              .nextInt(pow(2, 31).toInt()),
                                                                          'Congratulations!',
                                                                          'Your subscription have Success and Expires at ${DateFormat("dd/MM/yyyy").format(afterYear)} based on Sponsor',
                                                                          NotificationDetails(
                                                                              android: AndroidNotificationDetails(
                                                                                  'high_importance_channel', // id
                                                                                  'High Importance Notifications', // title
                                                                                  channelDescription: 'your channel description',
                                                                                  playSound: false,
                                                                                  color: Colors.green,
                                                                                  styleInformation: BigTextStyleInformation(''))),
                                                                        );
                                                                      });
                                                                      Navigator.pushReplacement(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) => SettingsScreen(
                                                                                    checkSubscription: true,
                                                                                  )));
                                                                    } else {
                                                                      print(
                                                                          'elssssseeee');
                                                                    }

                                                                    setState(
                                                                        () {
                                                                      loadingRedeem =
                                                                          false;
                                                                    });
                                                                  },
                                                                ))
                                                          ],
                                                        ),
                                                      );
                                                    }));
                                      },
                                      child: Text(
                                        AppLocalizations.of(context)!.translate(
                                            'click_to_unlock_premium'),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    height: 43,
                                  ),
                                  SizedBox(height: 18)
                                ],
                              ),
                            ),
                          )
                        : Container();
                  }),
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      color: cardBgColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(18),
                            child: Text(
                              "Naik taraf ke 'Premium'",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                Table(
                                  border: TableBorder(
                                      verticalInside: BorderSide(
                                    style: BorderStyle.solid,
                                    color: cardBgColor,
                                  )),
                                  columnWidths: {
                                    0: FractionColumnWidth(0.5),
                                    1: FractionColumnWidth(0.25),
                                    2: FractionColumnWidth(0.25)
                                  },
                                  children: [
                                    TableRow(children: [
                                      Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(8))),
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.all(12),
                                        child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text('Fungsi',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: cardBgColor))),
                                      ),
                                      Container(
                                        height: 40,
                                        color: Colors.white,
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12.0, horizontal: 8),
                                        child: Center(
                                            child: Text('Percuma',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: cardBgColor))),
                                      ),
                                      Container(
                                          height: 40,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.only(
                                                  topRight:
                                                      Radius.circular(8))),
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12.0, horizontal: 8),
                                          child: Text('Premium',
                                              style: TextStyle(
                                                  color: cardBgColor,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold)))
                                    ]),
                                  ],
                                ),
                                Table(
                                  border: TableBorder.all(color: Colors.white),
                                  columnWidths: {
                                    0: FractionColumnWidth(0.5),
                                    1: FractionColumnWidth(0.25),
                                    2: FractionColumnWidth(0.25)
                                  },
                                  children: [
                                    TableRow(children: [
                                      Container(
                                        height: 40,
                                        padding: const EdgeInsets.all(12.0),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text('Tukar Tema',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12)),
                                        ),
                                      ),
                                      Container(
                                        height: 40,
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                          child: Icon(Icons.cancel_presentation,
                                              color: Colors.red),
                                        ),
                                      ),
                                      Container(
                                          height: 40,
                                          padding: const EdgeInsets.all(8.0),
                                          child: Center(
                                            child: Icon(Icons.check_box,
                                                color: Colors.green),
                                          )),
                                    ]),
                                    TableRow(children: [
                                      Container(
                                        height: 40,
                                        padding: const EdgeInsets.all(12.0),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text('Tetapan Azan',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12)),
                                        ),
                                      ),
                                      Container(
                                        height: 40,
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                          child: Icon(Icons.cancel_presentation,
                                              color: Colors.red),
                                        ),
                                      ),
                                      Container(
                                          height: 40,
                                          padding: const EdgeInsets.all(8.0),
                                          child: Center(
                                            child: Icon(Icons.check_box,
                                                color: Colors.green),
                                          )),
                                    ]),
                                    TableRow(children: [
                                      Container(
                                        height: 40,
                                        padding: const EdgeInsets.all(12.0),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text('Tukar design Wallpaper',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12)),
                                        ),
                                      ),
                                      Container(
                                        height: 40,
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                          child: Icon(Icons.cancel_presentation,
                                              color: Colors.red),
                                        ),
                                      ),
                                      Container(
                                          height: 40,
                                          padding: const EdgeInsets.all(8.0),
                                          child: Center(
                                            child: Icon(Icons.check_box,
                                                color: Colors.green),
                                          )),
                                    ]),
                                    TableRow(children: [
                                      Container(
                                        height: 40,
                                        padding: const EdgeInsets.all(12.0),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text('Tukar Design Kiblat',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12)),
                                        ),
                                      ),
                                      Container(
                                        height: 40,
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                          child: Icon(Icons.cancel_presentation,
                                              color: Colors.red),
                                        ),
                                      ),
                                      Container(
                                          height: 40,
                                          padding: const EdgeInsets.all(8.0),
                                          child: Center(
                                            child: Icon(Icons.check_box,
                                                color: Colors.green),
                                          )),
                                    ]),
                                    TableRow(children: [
                                      Container(
                                        height: 40,
                                        padding: const EdgeInsets.all(12.0),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text('Tukar Design Tasbih',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12)),
                                        ),
                                      ),
                                      Container(
                                        height: 40,
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                          child: Icon(Icons.cancel_presentation,
                                              color: Colors.red),
                                        ),
                                      ),
                                      Container(
                                          height: 40,
                                          padding: const EdgeInsets.all(8.0),
                                          child: Center(
                                            child: Icon(Icons.check_box,
                                                color: Colors.green),
                                          )),
                                    ]),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 18)
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      color: cardBgColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(18),
                            child: Text(
                              "Pilih pakej",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                          ListTile(
                            leading: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: Color(0xFF807BB2),
                                child: selected != '250'
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
                                  "Bulanan (RM1.00)",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6!
                                      .copyWith(
                                          color: Colors.white, fontSize: 16),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  "30 days subscription to premium features",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6!
                                      .copyWith(
                                          color: Colors.white70, fontSize: 12),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  "Auto-Renewable Subscription",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6!
                                      .copyWith(
                                          color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                            onTap: () {
                              subscriptionDescription = "Bulanan (RM1.00)";
                              setState(() => selected = '250');
                            },
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          ListTile(
                            leading: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: Color(0xFF807BB2),
                                child: selected != '1150'
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
                                  "Tahunan (RM10.00)",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6!
                                      .copyWith(
                                          color: Colors.white, fontSize: 16),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  "365 days subscription to premium features",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6!
                                      .copyWith(
                                          color: Colors.white70, fontSize: 12),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  "Auto-Renewable Subscription",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6!
                                      .copyWith(
                                          color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                            onTap: () {
                              subscriptionDescription = "Tahunan (RM10.00)";
                              setState(() => selected = '1150');
                            },
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          !Platform.isIOS
                              ? ListTile(
                                  leading: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: CircleAvatar(
                                      radius: 10,
                                      backgroundColor: Color(0xFF807BB2),
                                      child: selected != '2650'
                                          ? null
                                          : Icon(
                                              Icons.circle_rounded,
                                              color: Colors.white,
                                              size: 13,
                                            ),
                                    ),
                                  ),
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "3 Tahun (RM25.00)",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6!
                                            .copyWith(
                                                color: Colors.white,
                                                fontSize: 16),
                                      ),
                                      SizedBox(height: 3),
                                      Text(
                                        "3 years subscription to premium features",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6!
                                            .copyWith(
                                                color: Colors.white70,
                                                fontSize: 12),
                                      ),
                                      SizedBox(height: 3),
                                      Text(
                                        "Auto-Renewable Subscription",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6!
                                            .copyWith(
                                                color: Colors.white70,
                                                fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    subscriptionDescription =
                                        "3 Tahun (RM25.00)";
                                    setState(() => selected = '2650');
                                  },
                                )
                              : SizedBox(),
                          SizedBox(height: 10),
                          if (!Platform.isIOS)
                            Text(
                              '*Tambah RM1.50 caj perkhidmatan FPX Billplz',
                              style:
                                  TextStyle(fontSize: 10, color: Colors.white),
                            ),
                          SizedBox(height: 10),
                          SizedBox(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xFF807BB2),
                              ),
                              onPressed: () async {
                                if (Platform.isIOS) {
                                  PurchaseParam purchaseParam;

                                  List<ProductDetails> productsDetails =
                                      _buildProductList();

                                  productsDetails.forEach((element) {
                                    print('------${element.id}');
                                  });

                                  if (selected == '250') {
                                    ProductDetails productDetails =
                                        productsDetails.firstWhere((element) =>
                                            element.id == 'bulanan');
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
                                  } else {
                                    ProductDetails productDetails =
                                        productsDetails.firstWhere((element) =>
                                            element.id == 'tahunan');
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
                                    email,
                                    username,
                                    selected,
                                    subscriptionDescription,
                                    0,
                                  )
                                      .then((value) async {
                                    if (value != null) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SubscriptionWebView(
                                                      url: value.url.toString(),
                                                      amount: value.amount!,
                                                      mode: 2,
                                                      title:
                                                          'Pembayaran Langganan')));
                                    }
                                  });
                                }
                              },
                              child: Text("Bayar"),
                            ),
                            width: 150,
                            height: 43,
                          ),
                          SizedBox(height: 18)
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 135)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
