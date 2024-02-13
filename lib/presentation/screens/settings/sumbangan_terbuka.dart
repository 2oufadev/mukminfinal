import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mukim_app/business_logic/cubit/subscription/userstate_cubit.dart';
import 'package:mukim_app/data/api/payment_api.dart';
import 'package:mukim_app/data/repository/payment_repository.dart';
import 'package:mukim_app/presentation/screens/settings/subscription_webview.dart';
import 'package:mukim_app/presentation/screens/settings/taja_infaq.dart';
import 'package:mukim_app/utils/componants.dart';
import 'package:mukim_app/providers/theme.dart';
import 'package:mukim_app/utils/get_theme_color.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

import '../../../business_logic/consumable_store.dart';

class SumbanganTerbukaScreen extends StatefulWidget {
  const SumbanganTerbukaScreen({Key? key}) : super(key: key);

  @override
  _SumbanganTerbukaScreenState createState() => _SumbanganTerbukaScreenState();
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
const List<String> _kProductIds = <String>[
  _3pakejsponsor,
  _5pakejsponsor,
  _10pakejsponsor,
  _sumbangan1,
  _sumbangan10,
  _sumbangan100,
  _bulananSubscription,
  _tahunanSubscription,
];

class _SumbanganTerbukaScreenState extends State<SumbanganTerbukaScreen> {
  String selected = "3150";
  String selected2 = "250";
  String descriptionText = '';
  Map<String, dynamic>? userStateMap;

  SharedPreferences? sharedPreferences;
  String username = '';
  String email = '';
  String subscriptionDescription = "3 pakej premium | RM30.00";
  String subscriptionDescription2 = "RM1.00";

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
    // TODO: implement initState
    super.initState();
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
          if (valid) {
            deliverProduct(purchaseDetails);
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
    // if (Platform.isIOS) {
    //   final InAppPurchaseStoreKitPlatformAddition iapStoreKitPlatformAddition =
    //       _inAppPurchase
    //           .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
    //   await iapStoreKitPlatformAddition.showPriceConsentIfNeeded();
    // }
  }

  initSharedPref() async {
    sharedPreferences = await SharedPreferences.getInstance();
    email = sharedPreferences!.getString('useremail') ?? '';
    username =
        sharedPreferences!.getString('username') ?? email.split('@').first;
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
          title: Text('Sumbangan'),
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
                            "Taja(Infaq)",
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
                              child: selected != '3150'
                                  ? null
                                  : Icon(
                                      Icons.circle_rounded,
                                      color: Colors.white,
                                      size: 13,
                                    ),
                            ),
                          ),
                          title: Text(
                            "3 pakej premium | RM30.00",
                            style: Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(color: Colors.white, fontSize: 16),
                          ),
                          onTap: () {
                            setState(() => selected = '3150');
                            subscriptionDescription =
                                "3 pakej premium | RM30.00";
                          },
                        ),
                        ListTile(
                          leading: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: getColor(theme, isButton: true),
                              child: selected != '5150'
                                  ? null
                                  : Icon(
                                      Icons.circle_rounded,
                                      color: Colors.white,
                                      size: 13,
                                    ),
                            ),
                          ),
                          title: Text(
                            "5 pakej premium | RM50.00",
                            style: Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(color: Colors.white, fontSize: 16),
                          ),
                          onTap: () {
                            setState(() => selected = '5150');
                            subscriptionDescription =
                                "5 pakej premium | RM50.00";
                          },
                        ),
                        ListTile(
                          leading: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: getColor(theme, isButton: true),
                              child: selected != '10150'
                                  ? null
                                  : Icon(
                                      Icons.circle_rounded,
                                      color: Colors.white,
                                      size: 13,
                                    ),
                            ),
                          ),
                          title: Text(
                            "10 pakej premium | RM100.00",
                            style: Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(color: Colors.white, fontSize: 16),
                          ),
                          onTap: () {
                            setState(() => selected = '10150');
                            subscriptionDescription =
                                "10 pakej premium | RM100.00";
                          },
                        ),
                        SizedBox(height: 30),
                        SizedBox(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: getColor(theme, isButton: true),
                            ),
                            onPressed: () async {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => TajaInfaq(
                                            email: email,
                                            mode: 1,
                                            selected: selected,
                                            username: username,
                                          )));
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
                              //                       if (Platform.isIOS) {
                              //                         PurchaseParam
                              //                             purchaseParam;

                              //                         List<ProductDetails>
                              //                             productsDetails =
                              //                             _buildProductList();

                              //                         productsDetails
                              //                             .forEach((element) {
                              //                           print(element.id);
                              //                         });

                              //                         if (selected == '3150') {
                              //                           ProductDetails
                              //                               productDetails =
                              //                               productsDetails
                              //                                   .firstWhere(
                              //                                       (element) =>
                              //                                           element
                              //                                               .id ==
                              //                                           '3pakejsponsor');
                              //                           purchaseParam =
                              //                               PurchaseParam(
                              //                             productDetails:
                              //                                 productDetails,
                              //                           );

                              //                           if (productDetails.id ==
                              //                               _kConsumableId) {
                              //                             _inAppPurchase.buyConsumable(
                              //                                 purchaseParam:
                              //                                     purchaseParam,
                              //                                 autoConsume:
                              //                                     _kAutoConsume);
                              //                           } else {
                              //                             _inAppPurchase
                              //                                 .buyNonConsumable(
                              //                                     purchaseParam:
                              //                                         purchaseParam);
                              //                           }
                              //                         } else if (selected ==
                              //                             '5150') {
                              //                           ProductDetails
                              //                               productDetails =
                              //                               productsDetails
                              //                                   .firstWhere(
                              //                                       (element) =>
                              //                                           element
                              //                                               .id ==
                              //                                           '5pakejsponsor');
                              //                           purchaseParam =
                              //                               PurchaseParam(
                              //                             productDetails:
                              //                                 productDetails,
                              //                           );

                              //                           if (productDetails.id ==
                              //                               _kConsumableId) {
                              //                             _inAppPurchase.buyConsumable(
                              //                                 purchaseParam:
                              //                                     purchaseParam,
                              //                                 autoConsume:
                              //                                     _kAutoConsume);
                              //                           } else {
                              //                             _inAppPurchase
                              //                                 .buyNonConsumable(
                              //                                     purchaseParam:
                              //                                         purchaseParam);
                              //                           }
                              //                         } else if (selected ==
                              //                             '10150') {
                              //                           ProductDetails
                              //                               productDetails =
                              //                               productsDetails
                              //                                   .firstWhere(
                              //                                       (element) =>
                              //                                           element
                              //                                               .id ==
                              //                                           '10pakejsponsor');
                              //                           purchaseParam =
                              //                               PurchaseParam(
                              //                             productDetails:
                              //                                 productDetails,
                              //                           );

                              //                           if (productDetails.id ==
                              //                               _kConsumableId) {
                              //                             _inAppPurchase.buyConsumable(
                              //                                 purchaseParam:
                              //                                     purchaseParam,
                              //                                 autoConsume:
                              //                                     _kAutoConsume);
                              //                           } else {
                              //                             _inAppPurchase
                              //                                 .buyNonConsumable(
                              //                                     purchaseParam:
                              //                                         purchaseParam);
                              //                           }
                              //                         }
                              //                       } else {
                              //                         await PaymentRepository(
                              //                                 PaymentApi())
                              //                             .createBill(
                              //                                 email,
                              //                                 username,
                              //                                 selected,
                              //                                 descriptionText,
                              //                                 1)
                              //                             .then((value) async {
                              //                           if (value != null) {
                              //                             Navigator.push(
                              //                                 context,
                              //                                 MaterialPageRoute(
                              //                                     builder: (context) => SubscriptionWebView(
                              //                                         url: value
                              //                                             .url
                              //                                             .toString(),
                              //                                         title:
                              //                                             'Pembayaran Tajaan')));
                              //                           }
                              //                         });
                              //                       }
                              //                     },
                              //                   ))
                              //             ],
                              //           ),
                              //         ));
                            },
                            child: Text("Teruskan"),
                          ),
                          width: 150,
                          height: 43,
                        ),
                        SizedBox(height: 18),
                      ],
                    ),
                  ),
                  Card(
                    color: cardBgColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 18),
                        Padding(
                          padding: const EdgeInsets.all(18),
                          child: Text(
                            "Sumbangan kos operasi",
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
                              child: selected2 != '250'
                                  ? null
                                  : Icon(
                                      Icons.circle_rounded,
                                      color: Colors.white,
                                      size: 13,
                                    ),
                            ),
                          ),
                          title: Text(
                            "RM1.00",
                            style: Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(color: Colors.white, fontSize: 16),
                          ),
                          onTap: () {
                            setState(() => selected2 = '250');
                            subscriptionDescription2 = "RM1.00";
                          },
                        ),
                        ListTile(
                          leading: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: getColor(theme, isButton: true),
                              child: selected2 != '1150'
                                  ? null
                                  : Icon(
                                      Icons.circle_rounded,
                                      color: Colors.white,
                                      size: 13,
                                    ),
                            ),
                          ),
                          title: Text(
                            "RM10.00",
                            style: Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(color: Colors.white, fontSize: 16),
                          ),
                          onTap: () {
                            setState(() => selected2 = '1150');
                            subscriptionDescription2 = "RM10.00";
                          },
                        ),
                        ListTile(
                          leading: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: getColor(theme, isButton: true),
                              child: selected2 != '10150'
                                  ? null
                                  : Icon(
                                      Icons.circle_rounded,
                                      color: Colors.white,
                                      size: 13,
                                    ),
                            ),
                          ),
                          title: Text(
                            "RM100.00",
                            style: Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(color: Colors.white, fontSize: 16),
                          ),
                          onTap: () {
                            setState(() => selected2 = '10150');
                            subscriptionDescription2 = "RM100.00";
                          },
                        ),
                        SizedBox(height: 30),
                        SizedBox(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: getColor(theme, isButton: true),
                            ),
                            onPressed: () async {
                              if (!Platform.isIOS) {
                                await PaymentRepository(PaymentApi())
                                    .createBill(email, username, selected2,
                                        subscriptionDescription2, 2)
                                    .then((value) async {
                                  if (value != null) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SubscriptionWebView(
                                                    url: value.url.toString(),
                                                    amount: value.amount!,
                                                    mode: 3,
                                                    title:
                                                        'Pembayaran Sumbangan')));
                                  }
                                });
                              } else {
                                PurchaseParam purchaseParam;

                                List<ProductDetails> productsDetails =
                                    _buildProductList();

                                productsDetails.forEach((element) {
                                  print(element.id);
                                });

                                if (selected2 == '250') {
                                  ProductDetails productDetails =
                                      productsDetails.firstWhere((element) =>
                                          element.id == 'sumbangan1');
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
                                } else if (selected2 == '1150') {
                                  ProductDetails productDetails =
                                      productsDetails.firstWhere((element) =>
                                          element.id == 'sumbangan10');
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
                                } else if (selected2 == '10150') {
                                  ProductDetails productDetails =
                                      productsDetails.firstWhere((element) =>
                                          element.id == 'sumbangan100');
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
                              }
                            },
                            child: Text("Bayar"),
                          ),
                          width: 150,
                          height: 43,
                        ),
                        SizedBox(height: 18),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 150,
                  )
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
