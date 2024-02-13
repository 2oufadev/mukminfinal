import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:location/location.dart';
import 'package:mouse_parallax/mouse_parallax.dart';
import 'package:mukim_app/business_logic/cubit/bottom_bar/cubit.dart';
import 'package:mukim_app/business_logic/cubit/subscription/userstate_cubit.dart';
import 'package:mukim_app/data/models/hadith_model.dart';
import 'package:mukim_app/presentation/screens/artikel/Artikel_Pilihan.dart';
import 'package:mukim_app/presentation/screens/settings/naik_taraf.dart';
import 'package:mukim_app/presentation/screens/sirah/Biodata_Rasulullah.dart';
import 'package:mukim_app/presentation/screens/doa/Doa_Pilihan.dart';
import 'package:mukim_app/presentation/screens/MasjidBerhampiran.dart';
import 'package:mukim_app/presentation/screens/Restoran_Halal.dart';
import 'package:mukim_app/presentation/screens/infaq/Senarai_Infaq.dart';
import 'package:mukim_app/presentation/screens/Surah/surah.dart';
import 'package:mukim_app/presentation/screens/Takwim_Hijri.dart';
import 'package:mukim_app/presentation/screens/hadith/hadith_categories_screen.dart';
import 'package:mukim_app/presentation/screens/ayat.dart';
import 'package:mukim_app/presentation/screens/home/home_screen.dart';
import 'package:mukim_app/presentation/screens/motivasi.dart';
import 'package:http/http.dart' as http;
import 'package:mukim_app/presentation/screens/qiblat/google_earth.dart';
import 'package:mukim_app/presentation/screens/qiblat/main_screen.dart';
import 'package:mukim_app/presentation/screens/settings/settings_screen.dart';
import 'package:mukim_app/presentation/screens/zikir/homeScreen.dart';
import 'package:mukim_app/presentation/screens/zikir/homeScreen2.dart';
import 'package:mukim_app/presentation/screens/zikir/homeScreen3.dart';
import 'package:mukim_app/presentation/screens/zikir/homeScreen5.dart';
import 'package:mukim_app/providers/theme.dart';
import 'package:mukim_app/resources/constants.dart';
import 'package:mukim_app/resources/global.dart';
import 'package:mukim_app/utils/app_localization.dart';
import 'package:mukim_app/utils/get_theme_color.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<dynamic> navigateTo({
  required BuildContext context,
  required Widget screen,
  bool leftToRightTransasion = false,
}) {
  if (!leftToRightTransasion)
    return Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => screen,
        ));
  else
    return Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.leftToRight,
            duration: Duration(milliseconds: 300),
            child: screen));
}

Future<dynamic> navigateAndfinish({
  required BuildContext context,
  required Widget screen,
  bool rightToLeftTransasion = false,
}) {
  if (!rightToLeftTransasion)
    return Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => screen),
      (route) => false,
    );
  else
    return Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft,
            duration: Duration(milliseconds: 300),
            child: screen));
}

Widget imageBottomRow(
    {required BuildContext context,
    required String sharedImage,
    required Function(int aa) favFuction,
    required List<int> favColor,
    required String link,
    required String info,
    required String description,
    required String description2,
    required int imageId,
    required String reference,
    required bool showInfo,
    int? type}) {
  String theme = Provider.of<ThemeNotifier>(context).appTheme;

  return Container(
    width: double.infinity,
    padding: EdgeInsets.only(right: 15),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 1,
          child: Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                onPressed: () => favFuction(imageId),
                icon: Icon(
                  Icons.favorite_outline,
                  color: favColor.contains(imageId) ? Colors.red : Colors.white,
                  size: 30,
                ),
              ),
              Text(
                'Suka',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: InkWell(
            onTap: () async {
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return Center(
                        child: Container(
                            height: 30,
                            width: 30,
                            child: CircularProgressIndicator(
                                color: getColor(theme))));
                  });

              try {
                http.Response response = await http.get(Uri.parse(sharedImage));

                final DynamicLinkParameters dynamicLinkParams =
                    DynamicLinkParameters(
                        link: Uri.parse('https://mukminapps.com/$description2'),
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
                        socialMetaTagParameters: SocialMetaTagParameters(
                          title: '',
                          description: '',
                        ));

                final dynamicLink = await FirebaseDynamicLinks.instance
                    .buildShortLink(dynamicLinkParams);
                final Uri shortUrl = dynamicLink.shortUrl;

                await Share.shareXFiles(
                  [
                    XFile.fromData(
                      response.bodyBytes,
                      mimeType: 'image/png',
                    )
                  ],
                  text: description + ' ${shortUrl.toString()}',
                  subject: 'Share Image',
                );
                Navigator.pop(context);

                Navigator.pop(context);
              } catch (e) {
                print('error: $e');
                Navigator.pop(context);
              }
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment:
                  showInfo ? MainAxisAlignment.center : MainAxisAlignment.end,
              children: [
                Image.asset(
                  'assets/images/share.png',
                  height: 25.0,
                  fit: BoxFit.contain,
                ),
                SizedBox(
                  width: 15.0,
                ),
                Text(
                  'Kongsi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        showInfo
            ? Expanded(
                flex: 1,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              String details = '';
                              String title = '';
                              if (info != null && info.isNotEmpty) {
                                List<String> descList = info.split('\r');
                                if (descList.length > 1) {
                                  title = descList.first;
                                  details = info.replaceFirst(title, '');
                                } else {
                                  details = descList.first;
                                }

                                print('title :>>>>> $title');
                                print('details :>>>> $details');
                                print('description :>>>> $description');
                              }

                              return AlertDialog(
                                titlePadding:
                                    EdgeInsets.only(top: 20, right: 10),
                                scrollable: true,
                                title: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 25),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        child: Text(
                                          type != null && type == 3
                                              ? 'Sumber Motivasi'
                                              : type != null && type == 2
                                                  ? 'Sumber Ayat'
                                                  : 'Sumber Hadith',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      alignment: Alignment.center,
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      icon: Image.asset(
                                        'assets/images/ei_close-o.png',
                                        height: 25.0,
                                        width: 25,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  ],
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      details,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 11.0,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        if (link != null && link.isNotEmpty) {
                                          try {
                                            await launchUrlString(
                                                link.toString());
                                          } catch (e) {
                                            'Could not launch $link';
                                          }
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: HexColor('#524D9F'),
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 7, horizontal: 7),
                                        margin: EdgeInsets.symmetric(
                                            vertical: 15, horizontal: 10),
                                        height: 39.0,
                                        width: double.infinity,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              'assets/images/share.png',
                                              height: 25.0,
                                              fit: BoxFit.cover,
                                            ),
                                            SizedBox(
                                              width: 10.0,
                                            ),
                                            Text(
                                              'Pergi ke pautan sumber',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14.0,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                backgroundColor: HexColor('#3A343D'),
                              );
                            });
                      },
                      icon: Image.asset(
                        'assets/images/more.png',
                        height: 25.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Text(
                      'Info Lanjut',
                      style: TextStyle(
                          fontSize: 12,
                          color: showInfo ? Colors.white : Colors.transparent),
                    ),
                  ],
                ),
              )
            : Container(),
      ],
    ),
  );
}

Widget detailsBuilderNestedLayersWithOverlay({
  required BuildContext context,
  required List<ReadyHadithModel> imagesList,
  required String appBarTitle,
  IconData? leadingIcon,
  VoidCallback? leadingFun,
  bool showFavorite = false,
  bool twoDGrid = true,
  bool loading = false,
  int? selectedId,
  int? type,
  String? widgetType,
  String? category,
  String? categoryId,
  required bool loggedIn,
  required bool subscribed,
  required Function(int) favFuction,
  required List<int> favColor,
  required double leftPadding,
  required bool showInfo,
  required String username,
}) {
  MukminCubit cubit = MukminCubit.getCubitObj(context);
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;

  print('~~~~~~~~~~~~!!!!!!!!!!!!!!!!!! $selectedId');

  if (selectedId != 0 && imagesList != null && imagesList.isNotEmpty) {
    int selectedIndex =
        imagesList.indexWhere((element) => element.id == selectedId);
    if (selectedIndex != 0 && cubit.imageIndex == 0 && selectedIndex != -1) {
      cubit.changeImage(selectedIndex);
      print('!@!@!@!@');
      print(selectedIndex);
    }
  }

  String descriptionData = '';
  if (imagesList != null && imagesList.isNotEmpty) {
    if (widgetType != null && widgetType == 'hadith') {
      descriptionData =
          'Hadith-${category!.replaceAll(' ', '-')}-$categoryId-${imagesList[cubit.imageIndex].id}';
    } else if (widgetType != null && widgetType == 'ayat') {
      descriptionData = 'Ayat-${imagesList[cubit.imageIndex].id}';
    } else if (widgetType != null && widgetType == 'doa') {
      descriptionData =
          'Doa-${category!.replaceAll(' ', '-')}-$categoryId-${imagesList[cubit.imageIndex].id}';
    }
  }

  return OrientationBuilder(
    builder: (context, orientation) =>
        BlocBuilder<UserStateCubit, UserState>(builder: (context, state) {
      return SlidingUpPanel(
        minHeight: 64,
        maxHeight: 265,
        color: Colors.black.withOpacity(0.5),
        panel: bottomNavBarWithOpacity(
            context: context,
            loggedIn:
                state is LoginState ? state.userStateMap!['loggedIn'] : false),
        body: OrientationBuilder(
          builder: (context, orientation) => Stack(
            children: [
              NestedScrollView(
                physics: NeverScrollableScrollPhysics(),
                headerSliverBuilder: (context, isScolled) {
                  return [
                    SliverAppBar(
                      floating: true,
                      expandedHeight: width * 0.267,
                      backgroundColor: HexColor('#3A343D'),
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          alignment: Alignment.centerRight,
                          children: <Widget>[
                            Consumer<ThemeNotifier>(
                                builder: (context, data, child) {
                              return Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                      "assets/theme/${data.appTheme ?? "default"}/appbar.png",
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            }),
                            Positioned(
                              top: width * 0.167,
                              width: width,
                              child: Row(
                                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    onPressed: leadingFun,
                                    icon: Icon(
                                      leadingIcon,
                                      size: 20.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        left: leftPadding,
                                        top: 2,
                                      ),
                                      child: Center(
                                        child: Text(
                                          "$appBarTitle",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    alignment: Alignment.bottomRight,
                                    padding: EdgeInsets.only(
                                        bottom: 11.0, right: 10),
                                    onPressed: () {
                                      cubit.changeGrid();
                                    },
                                    icon: Image.asset(
                                      cubit.gridIcon,
                                      height: 23.0,
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      leading: Icon(null),
                    ),
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          Container(
                            color: HexColor('#3A343D'),
                            child: Container(
                              height: orientation == Orientation.portrait
                                  ? height * 0.5
                                  : width,
                              width: width,
                              child: loading
                                  ? Shimmer.fromColors(
                                      enabled: true,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: Color(0xFF383838)),
                                        clipBehavior: Clip.antiAlias,
                                        height: height * 0.5,
                                        width: width,
                                      ),
                                      baseColor: Color(0xFF383838),
                                      highlightColor: Color(0xFF484848),
                                    )
                                  : AnimatedCrossFade(
                                      firstChild: imagesList != null &&
                                              imagesList.isNotEmpty
                                          ? Image.network(
                                              imagesList[cubit.imageIndex]
                                                              .galleryImages !=
                                                          null &&
                                                      imagesList[cubit.imageIndex]
                                                          .galleryImages!
                                                          .isNotEmpty
                                                  ? Globals.images_url +
                                                      imagesList[cubit.imageIndex]
                                                          .galleryImages![cubit
                                                              .subImageIndex]
                                                          .image!
                                                  : imagesList != null &&
                                                          imagesList
                                                              .isNotEmpty &&
                                                          imagesList[cubit.imageIndex]
                                                                  .image !=
                                                              null
                                                      ? Globals.images_url +
                                                          imagesList[cubit
                                                                  .imageIndex]
                                                              .image!
                                                      : '',
                                              fit: BoxFit.cover,
                                              height: height * 0.5,
                                              width: width, frameBuilder:
                                                  (context, child, frame,
                                                      wasSynchronouslyLoaded) {
                                              if (frame == null) {
                                                return Shimmer.fromColors(
                                                  enabled: true,
                                                  child: Container(
                                                      height: height * 0.5,
                                                      width: width,
                                                      color: Color(0xFF383838)),
                                                  baseColor: Color(0xFF383838),
                                                  highlightColor:
                                                      Color(0xFF484848),
                                                );
                                              }

                                              return child;
                                            }
                                              // width: width,
                                              )
                                          : Container(),
                                      secondChild: imagesList != null &&
                                              imagesList.isNotEmpty
                                          ? Image.network(
                                              imagesList[cubit.imageIndex]
                                                              .galleryImages !=
                                                          null &&
                                                      imagesList[cubit.imageIndex]
                                                          .galleryImages!
                                                          .isNotEmpty
                                                  ? Globals.images_url +
                                                      imagesList[cubit.imageIndex]
                                                          .galleryImages![cubit
                                                              .subImageIndex]
                                                          .image!
                                                  : imagesList != null &&
                                                          imagesList
                                                              .isNotEmpty &&
                                                          imagesList[cubit.imageIndex]
                                                                  .image !=
                                                              null
                                                      ? Globals.images_url +
                                                          imagesList[cubit
                                                                  .imageIndex]
                                                              .image!
                                                      : '',
                                              fit: BoxFit.cover,
                                              height: height * 0.5,
                                              width: width, frameBuilder:
                                                  (context, child, frame,
                                                      wasSynchronouslyLoaded) {
                                              if (frame == null) {
                                                return Shimmer.fromColors(
                                                  enabled: true,
                                                  child: Container(
                                                      height: height * 0.5,
                                                      width: width,
                                                      color: Color(0xFF383838)),
                                                  baseColor: Color(0xFF383838),
                                                  highlightColor:
                                                      Color(0xFF484848),
                                                );
                                              }

                                              return child;
                                            })
                                          : Container(),
                                      crossFadeState: cubit.crossFadeState,
                                      firstCurve: Curves.bounceInOut,
                                      secondCurve: Curves.easeInBack,
                                      duration: Duration(milliseconds: 500),
                                    ),
                            ),
                          ),
                          Container(
                            width: width,
                            color: HexColor('#171518'),
                            child: imageBottomRow(
                                context: context,
                                type: type != null ? type : 1,
                                info: loading
                                    ? ''
                                    : imagesList != null &&
                                            imagesList.isNotEmpty &&
                                            imagesList[cubit.imageIndex]
                                                    .description !=
                                                null
                                        ? imagesList[cubit.imageIndex]
                                            .description!
                                        : '',
                                sharedImage: loading
                                    ? ''
                                    : imagesList != null &&
                                            imagesList.isNotEmpty &&
                                            imagesList[cubit.imageIndex]
                                                    .galleryImages !=
                                                null &&
                                            imagesList[cubit.imageIndex]
                                                .galleryImages!
                                                .isNotEmpty
                                        ? Globals.images_url +
                                            imagesList[cubit.imageIndex]
                                                .galleryImages![
                                                    cubit.subImageIndex]
                                                .image!
                                        : imagesList != null &&
                                                imagesList.isNotEmpty &&
                                                imagesList[cubit.imageIndex].image !=
                                                    null
                                            ? Globals.images_url +
                                                imagesList[cubit.imageIndex]
                                                    .image!
                                            : '',
                                reference: loading
                                    ? ''
                                    : imagesList != null &&
                                            imagesList.isNotEmpty &&
                                            imagesList[cubit.imageIndex]
                                                    .galleryImages !=
                                                null &&
                                            imagesList[cubit.imageIndex]
                                                .galleryImages!
                                                .isNotEmpty
                                        ? imagesList[cubit.imageIndex]
                                            .galleryImages![cubit.subImageIndex]
                                            .reference!
                                        : '',
                                link: loading
                                    ? ''
                                    : imagesList != null &&
                                            imagesList.isNotEmpty &&
                                            imagesList[cubit.imageIndex].urlLink !=
                                                null
                                        ? imagesList[cubit.imageIndex].urlLink!
                                        : '',
                                description: subscribed
                                    ? 'Infografik ini dikongsi oleh $username (Premium) dari MukminApps.Terokai Applikasi PERCUMA TANPA IKLAN di '
                                    // imagesList[cubit.imageIndex]
                                    //     .description
                                    : 'Terokai Pelbagai Infografik, Arah Kiblat, Bacaan Al Quran, Hadith, Motivasi dan lain-lain dalam Applikasi PERCUMA TANPA IKLAN di ',
                                description2: descriptionData,
                                favColor: favColor,
                                favFuction: favFuction,
                                imageId: loading
                                    ? 0
                                    : imagesList != null &&
                                            imagesList.isNotEmpty &&
                                            imagesList[cubit.imageIndex]
                                                    .galleryImages !=
                                                null &&
                                            imagesList[cubit.imageIndex]
                                                .galleryImages!
                                                .isNotEmpty
                                        ? imagesList[cubit.imageIndex]
                                            .galleryImages![cubit.subImageIndex]
                                            .id!
                                        : imagesList != null && imagesList.isNotEmpty
                                            ? imagesList[cubit.imageIndex].id!
                                            : 0,
                                showInfo: showInfo),
                          ),
                        ],
                      ),
                    ),
                    imagesList != null &&
                            imagesList.isNotEmpty &&
                            imagesList[cubit.imageIndex].galleryImages !=
                                null &&
                            imagesList[cubit.imageIndex]
                                .galleryImages!
                                .isNotEmpty
                        ? SliverPersistentHeader(
                            pinned: true,
                            delegate: PersistentHeader(
                              height: width * 0.3,
                              widget: Container(
                                  color: HexColor('#3A343D'),
                                  height: width * 0.3,
                                  child: ListView.builder(
                                      itemCount: loading
                                          ? 5
                                          : imagesList[cubit.imageIndex]
                                                          .galleryImages !=
                                                      null &&
                                                  imagesList[cubit.imageIndex]
                                                      .galleryImages!
                                                      .isNotEmpty
                                              ? imagesList[cubit.imageIndex]
                                                  .galleryImages!
                                                  .length
                                              : 0,
                                      scrollDirection: Axis.horizontal,
                                      padding: EdgeInsets.only(
                                          left: 5, top: 10, bottom: 10),
                                      itemBuilder: (context, index) {
                                        return loading
                                            ? Shimmer.fromColors(
                                                enabled: true,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      color: Color(0xFF383838)),
                                                  clipBehavior: Clip.antiAlias,
                                                  margin:
                                                      EdgeInsets.only(right: 5),
                                                  height: width * 3,
                                                  width: width * 0.22,
                                                ),
                                                baseColor: Color(0xFF383838),
                                                highlightColor:
                                                    Color(0xFF484848),
                                              )
                                            : InkWell(
                                                onTap: () {
                                                  if (subscribed ||
                                                      index == 0) {
                                                    cubit.changeSubImage(index);
                                                  } else {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                NaikTarafScreen()));
                                                  }
                                                },
                                                child: Container(
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      border:
                                                          cubit.subImageIndex ==
                                                                  index
                                                              ? Border.all(
                                                                  width: 2,
                                                                  color: Colors
                                                                      .amber,
                                                                )
                                                              : null),
                                                  margin:
                                                      EdgeInsets.only(right: 5),
                                                  height: width * 3,
                                                  width: width * 0.22,
                                                  child: Stack(
                                                    children: [
                                                      Positioned.fill(
                                                        child: imagesList !=
                                                                    null &&
                                                                imagesList[cubit
                                                                            .imageIndex]
                                                                        .galleryImages !=
                                                                    null
                                                            ? Image.network(
                                                                Globals.images_url +
                                                                    imagesList[cubit
                                                                            .imageIndex]
                                                                        .galleryImages![
                                                                            index]
                                                                        .image!,
                                                                fit:
                                                                    BoxFit.fill,
                                                                // width: width,
                                                                frameBuilder:
                                                                    (context,
                                                                        child,
                                                                        frame,
                                                                        wasSynchronouslyLoaded) {
                                                                if (frame ==
                                                                    null) {
                                                                  return Shimmer
                                                                      .fromColors(
                                                                    enabled:
                                                                        true,
                                                                    child: Container(
                                                                        height: height *
                                                                            0.3,
                                                                        width: width *
                                                                            0.3,
                                                                        color: Color(
                                                                            0xFF383838)),
                                                                    baseColor:
                                                                        Color(
                                                                            0xFF383838),
                                                                    highlightColor:
                                                                        Color(
                                                                            0xFF484848),
                                                                  );
                                                                }

                                                                return child;
                                                              })
                                                            : Container(),
                                                      ),
                                                      !subscribed && index != 0
                                                          ? Positioned(
                                                              bottom: 5,
                                                              right: 5,
                                                              child: Icon(
                                                                  Icons.lock,
                                                                  color: Colors
                                                                      .amber))
                                                          : Container()
                                                    ],
                                                  ),
                                                ),
                                              );
                                      })),
                            ),
                          )
                        : SliverToBoxAdapter(),
                  ];
                },
                body: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  removeBottom: true,
                  child: ParallaxStack(
                    layers: [
                      ListView(
                        children: [
                          Container(
                            height: height,
                            padding: EdgeInsets.only(bottom: 65),
                            color: HexColor('#3A343D'),
                            child: GridView.count(
                              physics: BouncingScrollPhysics(),
                              shrinkWrap: true,
                              crossAxisCount: cubit.isTwo ? 2 : 3,
                              mainAxisSpacing: 10.0,
                              crossAxisSpacing: 10.0,
                              childAspectRatio: 1 / 1,
                              padding: EdgeInsets.only(top: 5),
                              children: List.generate(
                                loading
                                    ? 4
                                    : imagesList != null
                                        ? imagesList.length
                                        : 0,
                                (index) => Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: InkWell(
                                    child: loading
                                        ? Shimmer.fromColors(
                                            enabled: true,
                                            child: Container(
                                                height: height * 0.3,
                                                width: width * 0.3,
                                                color: Color(0xFF383838)),
                                            baseColor: Color(0xFF383838),
                                            highlightColor: Color(0xFF484848),
                                          )
                                        : Image.network(
                                            Globals.images_url +
                                                imagesList[index].image!,
                                            fit: BoxFit.fitWidth, frameBuilder:
                                                (context, child, frame,
                                                    wasSynchronouslyLoaded) {
                                            if (frame == null) {
                                              return Shimmer.fromColors(
                                                enabled: true,
                                                child: Container(
                                                    height: height * 0.3,
                                                    width: width * 0.3,
                                                    color: Color(0xFF383838)),
                                                baseColor: Color(0xFF383838),
                                                highlightColor:
                                                    Color(0xFF484848),
                                              );
                                            }

                                            return child;
                                          }),
                                    onTap: () {
                                      cubit.subImageIndex = 0;
                                      cubit.changeImage(index);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }),
  );
}

class PersistentHeader extends SliverPersistentHeaderDelegate {
  final Widget? widget;
  final double? height;

  PersistentHeader({this.widget, this.height});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      width: double.infinity,
      height: height,
      child: Card(
        margin: EdgeInsets.all(0),
        color: Colors.white,
        elevation: 5.0,
        child: Center(child: widget),
      ),
    );
  }

  @override
  double get maxExtent => height!;

  @override
  double get minExtent => height!;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

Widget bottomNavItemBuilder({
  required String iconPath,
  required String label,
  required BuildContext context,
  required bool loggedIn,
  Widget? targetScreen,
}) {
  return Expanded(
    flex: 1,
    child: InkWell(
      key: ValueKey(label),
      onTap: () {
        MukminCubit cubit = MukminCubit.getCubitObj(context);
        cubit.imageIndex = 0;
        cubit.subImageIndex = 0;
        cubit.hadithItemIndex = 0;
        if (AudioConstants.playing) {
          AudioConstants.audioPlayer.stop();
          Globals.globalIndWord = 0;
          AudioConstants.duration = Duration();
          AudioConstants.position = Duration();
          AudioConstants.playing = false;
        }
        if (label == 'Kiblat') {
          getCity().then((value) {
            navigateTo(
              context: context,
              screen: Kibat2(
                    cityName: value.city,
                    zone: value.district,
                  ) ??
                  HomeScreen(),
            );
          });
          // checkLocation().then((value) {
          //   if (value) {
          //     getEarth().then((value) {
          //       //value=false;

          //       print('setEarth---------------------  ${value.toString()}');

          //       if (value.toString() == 'null') {
          //         navigateTo(
          //           context: context,
          //           screen: GoogleEarth() ?? HomeScreen(),
          //         );
          //       } else {
          //         if (value) {
          //           navigateTo(
          //             context: context,
          //             screen: GoogleEarth() ?? HomeScreen(),
          //           );
          //         } else {
          //           getCity().then((value) {
          //             navigateTo(
          //               context: context,
          //               screen: Kibat2(
          //                     cityName: value.city,
          //                     zone: value.district,
          //                   ) ??
          //                   HomeScreen(),
          //             );
          //           });
          //         }
          //       }
          //     });
          //   } else {
          //     checkLocationPermission().then((value) {
          //       if (value == true) {
          //         getEarth().then((value) {
          //           //value=false;

          //           print('setEarth---------------------  ${value.toString()}');

          //           if (value.toString() == 'null') {
          //             navigateTo(
          //               context: context,
          //               screen: GoogleEarth() ?? HomeScreen(),
          //             );
          //           } else {
          //             if (!value) {
          //               navigateTo(
          //                 context: context,
          //                 screen: GoogleEarth() ?? HomeScreen(),
          //               );
          //             } else {
          //               getCity().then((value) {
          //                 navigateTo(
          //                   context: context,
          //                   screen: Kibat2(
          //                         cityName: value.city,
          //                         zone: value.district,
          //                       ) ??
          //                       HomeScreen(),
          //                 );
          //               });
          //             }
          //           }
          //         });
          //       } else {
          //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          //           content: Text('Please Enable Access Location'),
          //         ));
          //       }
          //     });
          //   }
          // });
        } else {
          navigateTo(
            context: context,
            screen: targetScreen ?? HomeScreen(),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Column(
          children: [
            Image.asset(iconPath,
                height: 30.0,
                // width: 22.0,
                color: null,
                fit: BoxFit.fitHeight),
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 10.0,
                ),
              ),
            ),
            SizedBox(
              height: 9,
            ),
          ],
        ),
      ),
    ),
  );
}

Future<bool> checkLocationPermission() async {
  Location location = new Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      return false;
    }
  }

  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      return false;
    }
  }
  return true;
}

Future<bool?> getEarth() async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  return sp.getBool('earth');
}

Future<bool> checkLocation() async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  return sp.getDouble('latitude') != null;
}

Future<CityEntity> getCity() async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  String? city = sp.getString('city');
  String? district = sp.getString('district');
  return CityEntity(city ?? '', district ?? '');
}

Widget bottomNavBarWithOpacity(
    {required BuildContext context, required bool loggedIn}) {
  bool isEarth = true;

  getEarth().then((value) {
    isEarth = value ?? true;
  });

  return OrientationBuilder(builder: (context, orientation) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 2.0,
          sigmaY: 2.0,
        ),
        child: Container(
          padding: const EdgeInsets.only(
            top: 10,
            // bottom: 20.0,
            right: 0.0,
            left: 0.0,
          ),
          height: 265,
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(8.0),
                topLeft: Radius.circular(8.0),
              )),
          child: Consumer<ThemeNotifier>(builder: (context, notifier, child) {
            String theme = notifier.appTheme;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    bottomNavItemBuilder(
                        iconPath:
                            'assets/theme/${theme ?? 'default'}/Utama.png',
                        label: 'Utama',
                        context: context,
                        targetScreen: HomeScreen(),
                        loggedIn: loggedIn),
                    bottomNavItemBuilder(
                        iconPath:
                            'assets/theme/${theme ?? 'default'}/Qiblat.png',
                        label: 'Kiblat',
                        context: context,
                        targetScreen: GoogleEarth(),
                        loggedIn: loggedIn),
                    bottomNavItemBuilder(
                        iconPath:
                            'assets/theme/${theme ?? 'default'}/Quran.png',
                        label: 'Quran',
                        context: context,
                        targetScreen: Surah(),
                        loggedIn: loggedIn),
                    bottomNavItemBuilder(
                        iconPath:
                            'assets/theme/${theme ?? 'default'}/Hadith.png',
                        label: 'Hadith',
                        context: context,
                        targetScreen: HadithCategoriesScreen(),
                        loggedIn: loggedIn),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    bottomNavItemBuilder(
                        iconPath: 'assets/theme/${theme ?? 'default'}/Doa.png',
                        label: "Doa",
                        context: context,
                        targetScreen: Doa_Pilihan(
                            screenHeight: MediaQuery.of(context).size.height),
                        loggedIn: loggedIn),
                    bottomNavItemBuilder(
                        iconPath:
                            'assets/theme/${theme ?? 'default'}/Sirah.png',
                        label: AppLocalizations.of(context)!.translate('ayat'),
                        context: context,
                        targetScreen: AyatScreen(),
                        loggedIn: loggedIn),
                    bottomNavItemBuilder(
                        iconPath:
                            'assets/theme/${theme ?? 'default'}/Motivasi.png',
                        label: 'Motivasi',
                        context: context,
                        targetScreen: MotivasiScreen(),
                        loggedIn: loggedIn),
                    bottomNavItemBuilder(
                        iconPath:
                            'assets/theme/${theme ?? 'default'}/Artikel.png',
                        label: 'Artikel',
                        context: context,
                        targetScreen: Artikel_Pilihan(),
                        loggedIn: loggedIn),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    bottomNavItemBuilder(
                        iconPath:
                            'assets/theme/${theme ?? 'default'}/Zikir.png',
                        label: 'Zikir',
                        context: context,
                        targetScreen: Globals.selectedValue == "Design 1"
                            ? HomeScreen5()
                            : Globals.selectedValue == "Design 3"
                                ? HomeScreen3()
                                : Globals.selectedValue == "Design 2"
                                    ? HomeScreen2()
                                    : Zikir(),
                        loggedIn: loggedIn),
                    bottomNavItemBuilder(
                        iconPath:
                            'assets/theme/${theme ?? 'default'}/Sirah.png',
                        label: 'Sirah',
                        context: context,
                        targetScreen: Biodata_Rasulullah(
                          screenHeight: MediaQuery.of(context).size.height,
                        ),
                        loggedIn: loggedIn),
                    bottomNavItemBuilder(
                        iconPath:
                            'assets/theme/${theme ?? 'default'}/Kalendar.png',
                        label: 'Kalendar',
                        context: context,
                        targetScreen: Takwim_Hijri(),
                        loggedIn: loggedIn),
                    bottomNavItemBuilder(
                        iconPath:
                            'assets/theme/${theme ?? 'default'}/Masjid.png',
                        label: 'Masjid/Surau',
                        context: context,
                        targetScreen: MasjidBerhampiran(),
                        loggedIn: loggedIn),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    bottomNavItemBuilder(
                        iconPath:
                            'assets/theme/${theme ?? 'default'}/Restoran.png',
                        label: 'Restoran Halal',
                        context: context,
                        targetScreen: Restoran_Halal(),
                        loggedIn: loggedIn),
                    bottomNavItemBuilder(
                        iconPath:
                            'assets/theme/${theme ?? 'default'}/Sumbangan.png',
                        label: 'Sumbangan',
                        context: context,
                        targetScreen: Senarai_Infaq(),
                        loggedIn: loggedIn),
                    bottomNavItemBuilder(
                        iconPath:
                            'assets/theme/${theme ?? 'default'}/Tetapan.png',
                        label: 'Tetapan',
                        context: context,
                        targetScreen: SettingsScreen(),
                        loggedIn: loggedIn),
                    Spacer(),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  });
}

class CityEntity {
  String city, district;
  CityEntity(this.city, this.district);
}
