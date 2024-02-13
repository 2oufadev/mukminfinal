// import 'package:carousel_slider/carousel_options.dart';
// import 'package:carousel_slider/carousel_slider.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukim_app/business_logic/cubit/subscription/userstate_cubit.dart';
import 'package:mukim_app/data/models/article_category.dart';
import 'package:mukim_app/data/models/article_module.dart';
import 'package:mukim_app/presentation/screens/Solat.dart';
import 'package:mukim_app/presentation/screens/artikel/Artikel_Pilihan_details.dart';
import 'package:mukim_app/resources/Imageresources.dart';
import 'package:mukim_app/utils/get_theme_color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mukim_app/utils/componants.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
// import 'package:stacked_card_carousel/stacked_card_carousel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Artikel_Pilihan extends StatefulWidget {
  @override
  _Artikel_PilihanState createState() => _Artikel_PilihanState();
}

class _Artikel_PilihanState extends State<Artikel_Pilihan> {
  bool loading = true;
  bool loading2 = true;
  String theme = "default";
  List<ArticleCategory> articleList = [];
  List<ArticleModule> articles = [];
  Map<String, dynamic>? userStateMap;
  int _currentIndex = 0;
  int index = 0;
  double itemWidth = 60.0;
  int itemCount = 5;
  int selected = 50;
  double height = 170;
  FixedExtentScrollController _scrollController =
      FixedExtentScrollController(initialItem: 1);
  final GlobalKey<_Artikel_PilihanState> rendererKey1 = new GlobalKey();
  final PageController _pageController = PageController();
  ScrollController listViewController = ScrollController();
  CarouselController carouselController = CarouselController();
  @override
  initState() {
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        theme = prefs.getString("appTheme") ?? "default";
      });
    });
    super.initState();
    // WidgetsBinding.instance!.addPostFrameCallback((_) {
    //   imgList.forEach((imageUrl) {
    //     precacheImage(NetworkImage(imageUrl), context);
    //   });
    // });
    carouselController.onReady.then((value) {
      Future.delayed(Duration(milliseconds: 500), () {
        carouselController.animateToPage(2,
            duration: Duration(milliseconds: 1000), curve: Curves.easeInOut);
      });

      Future.delayed(Duration(milliseconds: 2500), () {
        carouselController.animateToPage(0,
            duration: Duration(milliseconds: 1000), curve: Curves.easeInOut);
      });
    });
    Future.delayed(Duration(milliseconds: 500), () {
      listViewController.animateTo(listViewController.position.maxScrollExtent,
          duration: Duration(milliseconds: 1000), curve: Curves.easeInOut);
    });

    Future.delayed(Duration(milliseconds: 2500), () {
      listViewController.animateTo(listViewController.position.minScrollExtent,
          duration: Duration(milliseconds: 1000), curve: Curves.easeInOut);
    });
    getArticleCategories();
  }

  getArticleCategories() async {
    try {
      String url = 'https://salam.mukminapps.com/api/ArticleCategory';
      var result = await http
          .get(Uri.parse(url), headers: {"Accept": "application/json"});
      List responseBody = jsonDecode(result.body);
      responseBody.forEach((element) {
        if (element['status'] == 'enable') {
          articleList.add(ArticleCategory(
              element['name'].toString(),
              element['title'],
              element['description'],
              'https://salam.mukminapps.com/images/' + element['image'],
              element['id'],
              element['order']));
        }
      });

      if (articleList.length > 1) {
        articleList.sort((a, b) => a.order.compareTo(b.order));
      }

      setState(() {
        loading = false;
      });
      getArticles();
    } catch (e) {
      setState(() {
        loading = false;
        loading2 = false;
      });
      print(e);
    }
  }

  getArticles() async {
    setState(() {
      loading2 = true;
    });
    articles.clear();
    try {
      String url = 'https://salam.mukminapps.com/api/Article';
      var result = await http
          .get(Uri.parse(url), headers: {"Accept": "application/json"});
      List responseBody = jsonDecode(result.body);
      responseBody.first.forEach((element) {
        if (element['favorite'] == 'yes') {
          articles.add(ArticleModule(
              element['name'].toString(),
              element['description'],
              'https://salam.mukminapps.com/images/' + element['image'],
              element['order']));
        }
      });

      if (articles.length > 1) {
        articles.sort((a, b) => a.order.compareTo(b.order));
      }

      setState(() {
        loading2 = false;
      });
    } catch (e) {
      setState(() {
        loading2 = false;
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    userStateMap = BlocProvider.of<UserStateCubit>(context).checkUserState();
    return SafeArea(
      top: false,
      child: Scaffold(
          backgroundColor: Color(0xff3A343D),
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
              body: Column(children: [
                Stack(children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 285,
                    decoration: new BoxDecoration(
                        image: new DecorationImage(
                      image: AssetImage(ImageResource.Header),
                      fit: BoxFit.cover,
                    )),
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 50, 16, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.only(left: 10),
                          ),
                          Text(
                            "Artikel Pilihan",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                          Container(
                            height: 24,
                            width: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 150, left: 16, right: 16),
                    child: Container(
                      width: double.infinity,
                      height: height,
                      child: CarouselSlider(
                        carouselController: carouselController,
                        options: CarouselOptions(
                          height: height,
                          initialPage: 0,
                          enlargeCenterPage: true,
                          enableInfiniteScroll: false,
                          onPageChanged: (i, reason) {
                            setState(() {
                              _currentIndex = i;
                            });
                            // Future.delayed(Duration(milliseconds: 500), () {
                            //   listViewController.animateTo(
                            //       listViewController.position.maxScrollExtent,
                            //       duration: Duration(milliseconds: 500),
                            //       curve: Curves.easeInOut);
                            // });

                            // Future.delayed(Duration(milliseconds: 1500), () {
                            //   listViewController.animateTo(
                            //       listViewController.position.minScrollExtent,
                            //       duration: Duration(milliseconds: 500),
                            //       curve: Curves.easeInOut);
                            // });
                          },
                        ),
                        items: List.generate(
                            loading ? 3 : articleList.length,
                            (i) => ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: loading
                                      ? Shimmer.fromColors(
                                          enabled: true,
                                          child: Container(
                                            clipBehavior: Clip.antiAlias,
                                            decoration: new BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: Color(0xFF383838)),
                                            height: height,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                          ),
                                          baseColor: Color(0xFF383838),
                                          highlightColor: Color(0xFF484848),
                                        )
                                      : Container(
                                          clipBehavior: Clip.antiAlias,
                                          decoration: new BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          height: height,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          // color: Colors.yellow,
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          Solat(
                                                              articleList[i].id,
                                                              articleList[i]
                                                                  .name,
                                                              articleList)));
                                            },
                                            child: Image.network(
                                                articleList[i].image,
                                                fit: BoxFit.cover,
                                                frameBuilder: (context,
                                                    child,
                                                    frame,
                                                    wasSynchronouslyLoaded) {
                                              if (frame == null) {
                                                return Shimmer.fromColors(
                                                  enabled: true,
                                                  child: Container(
                                                      height: 165,
                                                      color: Color(0xFF383838)),
                                                  baseColor: Color(0xFF383838),
                                                  highlightColor:
                                                      Color(0xFF484848),
                                                );
                                              }

                                              return child;
                                            }),
                                          ),
                                        ),
                                )),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 350),
                      alignment: Alignment.bottomCenter,
                      child: loading
                          ? Shimmer.fromColors(
                              enabled: true,
                              child: Container(
                                  height: 20,
                                  width: 50,
                                  color: Color(0xFF383838)),
                              baseColor: Color(0xFF383838),
                              highlightColor: Color(0xFF484848),
                            )
                          : Text(
                              articleList[_currentIndex].name,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  color: getColor(theme),
                                  fontSize: 20,
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ]),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        leading: Container(),
                        expandedHeight: 180,
                        backgroundColor: Colors.transparent,
                        flexibleSpace: Padding(
                          padding: const EdgeInsets.all(16),
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
                              : Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 180,
                                  decoration: new BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Color(0xff1B1B1B)),
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: SingleChildScrollView(
                                      primary: true,
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            width: double.infinity,
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Container(
                                                    height: 25,
                                                    child: InkWell(
                                                      onTap: () {
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder: (context) => Solat(
                                                                    articleList[
                                                                            _currentIndex]
                                                                        .id,
                                                                    articleList[
                                                                            _currentIndex]
                                                                        .name,
                                                                    articleList)));
                                                        // navigateTo(
                                                        //     context: context,
                                                        //     screen: ArtikelDetails(
                                                        //         articleList[_currentIndex].name,
                                                        //         articleList[_currentIndex].description,
                                                        //         articleList[_currentIndex].image));
                                                      },
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.all(5),
                                                        decoration:
                                                            BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            3),
                                                                border:
                                                                    Border.all(
                                                                  color: Color(
                                                                      0xFF379C9E),
                                                                )),
                                                        child: Text(
                                                          'Baca Artikel',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12,
                                                            fontStyle: FontStyle
                                                                .normal,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ]),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  articleList[_currentIndex]
                                                      .title,
                                                  style: TextStyle(
                                                      color: getColor(theme),
                                                      fontSize: 15,
                                                      fontStyle:
                                                          FontStyle.normal,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8),
                                            child: Text(
                                              articleList[_currentIndex]
                                                  .description,
                                              style: TextStyle(
                                                  color: Color(0xffFFFFFF),
                                                  fontSize: 12,
                                                  height: 1.4,
                                                  fontStyle: FontStyle.normal,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      SliverToBoxAdapter(
                          child: ListView.builder(
                              padding: EdgeInsets.only(bottom: 55),
                              itemCount: loading2 ? 3 : articles.length,
                              shrinkWrap: true,
                              primary: false,
                              controller: listViewController,
                              itemBuilder: (context, index) => Container(
                                  color: Color(0xff3A343D),
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Column(children: [
                                        index == 0
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.all(15),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                      ImageResource.line,
                                                      height: 24,
                                                      width: 24,
                                                      color: getColor(theme),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10),
                                                      child: Text(
                                                        "Artikel menarik hari ini",
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xffFFFFFF),
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontStyle: FontStyle
                                                                .normal),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : Container(),
                                        InkWell(
                                          onTap: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Artikel_Pilihan_details(
                                                            articles[index]
                                                                .name,
                                                            articles[index]
                                                                .description,
                                                            articles[index]
                                                                .image,
                                                            false)));

                                            // Navigator.of(context).push(
                                            //   PageRouteBuilder(
                                            //       transitionDuration:
                                            //           Duration(milliseconds: 2000),
                                            //       pageBuilder: (BuildContext context,
                                            //           Animation<double> animation,
                                            //           Animation<double> scondaryAnimation) {
                                            //         return Artikel_Pilihan_details();
                                            //       },
                                            //       transitionsBuilder: (BuildContext context,
                                            //           Animation<double> animation,
                                            //           Animation<double> scondaryAnimation,
                                            //           Widget child) {
                                            //         return Align(
                                            //           child: FadeTransition(
                                            //             opacity: animation,
                                            //             child: child,
                                            //           ),
                                            //         );
                                            //       }),
                                            // );
                                          },
                                          child: Row(
                                            children: [
                                              Container(
                                                clipBehavior: Clip.antiAlias,
                                                decoration: new BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8)),
                                                child: Hero(
                                                  tag: loading2
                                                      ? 'coin$index'
                                                      : 'coin${articles[index].image}',
                                                  child: loading2
                                                      ? Shimmer.fromColors(
                                                          enabled: true,
                                                          child: Container(
                                                            height: 60,
                                                            width: 60,
                                                            decoration:
                                                                new BoxDecoration(
                                                                    color: Color(
                                                                        0xFF383838)),
                                                          ),
                                                          baseColor:
                                                              Color(0xFF383838),
                                                          highlightColor:
                                                              Color(0xFF484848),
                                                        )
                                                      : Image.network(
                                                          articles[index].image,
                                                          width: 60,
                                                          height: 60,
                                                          fit: BoxFit.cover,
                                                          frameBuilder: (context,
                                                              child,
                                                              frame,
                                                              wasSynchronouslyLoaded) {
                                                          if (frame == null) {
                                                            return Shimmer
                                                                .fromColors(
                                                              enabled: true,
                                                              child: Container(
                                                                  height: 60,
                                                                  width: 60,
                                                                  color: Color(
                                                                      0xFF383838)),
                                                              baseColor: Color(
                                                                  0xFF383838),
                                                              highlightColor:
                                                                  Color(
                                                                      0xFF484848),
                                                            );
                                                          }

                                                          return child;
                                                        }),
                                                ),
                                              ),
                                              Expanded(
                                                child: ListTile(
                                                    title: loading2
                                                        ? Shimmer.fromColors(
                                                            enabled: true,
                                                            child: Container(
                                                              height: 12,
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.6,
                                                              decoration: new BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                  color: Color(
                                                                      0xFF383838)),
                                                            ),
                                                            baseColor: Color(
                                                                0xFF383838),
                                                            highlightColor:
                                                                Color(
                                                                    0xFF484848),
                                                          )
                                                        : Text(
                                                            articles[index]
                                                                .name,
                                                            style: TextStyle(
                                                                color: getColor(
                                                                    theme),
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .normal),
                                                          ),
                                                    subtitle: loading2
                                                        ? Shimmer.fromColors(
                                                            enabled: true,
                                                            child: Container(
                                                              height: 40,
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.7,
                                                              decoration: new BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                  color: Color(
                                                                      0xFF383838)),
                                                            ),
                                                            baseColor: Color(
                                                                0xFF383838),
                                                            highlightColor:
                                                                Color(
                                                                    0xFF484848),
                                                          )
                                                        : Text(
                                                            articles[index]
                                                                .description,
                                                            maxLines: 3,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              color: Color(
                                                                  0xffFFFFFF),
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .normal,
                                                            ),
                                                          )),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 15, bottom: 15),
                                          child: Container(
                                            height: 1,
                                            color: Color(0xff787878),
                                          ),
                                        ),
                                      ])))))
                    ],
                  ),
                )
              ]))),
    );
  }
}
