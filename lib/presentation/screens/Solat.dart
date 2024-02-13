import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukim_app/business_logic/cubit/subscription/userstate_cubit.dart';
import 'package:mukim_app/data/models/article_category.dart';
import 'package:mukim_app/data/models/article_module.dart';
import 'package:mukim_app/presentation/screens/artikel/Artikel_Pilihan_details.dart';
import 'package:mukim_app/resources/Imageresources.dart';
import 'package:mukim_app/utils/componants.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:mukim_app/utils/get_theme_color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Solat extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  final List<ArticleCategory> categoryList;
  Solat(this.categoryId, this.categoryName, this.categoryList);
  @override
  _SolatState createState() => _SolatState();
}

class _SolatState extends State<Solat> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  String theme = 'default';
  bool loading = true;
  List<ArticleModule> articles = [];
  String categoryName = '';
  int? categoryId;
  Map<String, dynamic>? userStateMap;
  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        theme = prefs.getString("appTheme") ?? "default";
      });
    });
    categoryName = widget.categoryName;
    categoryId = widget.categoryId;
    getArticles();
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
  }

  List<String> image = [
    ImageResource.solat1,
    ImageResource.solat2,
    ImageResource.solat3,
    ImageResource.solat4,
    ImageResource.solat1,
    ImageResource.solat2,
    ImageResource.solat3,
    ImageResource.solat4,
    ImageResource.solat4
  ];
  List<String> titles = [
    'Sedekah murahkan rezeki, hindar bala',
    'Puasa bukan sekadar lapar dahaga',
    'Duit raya beri motivasi, didik amalan memberi',
    'Usah lalai, hanyut kemewahan dunia',
    'Sedekah murahkan rezeki, hindar bala',
    'Puasa bukan sekadar lapar dahaga',
    'Duit raya beri motivasi, didik amalan memberi',
    'Usah lalai, hanyut kemewahan dunia',
    'Usah lalai, hanyut kemewahan dunia'
  ];
  List<String> subtitles = [
    'Sedekah menjadi antara amalan yang paling berat dilakukan, khususnya manusia yang tidak suka berkongsi harta dengan orang lain....',
    'Sedekah menjadi antara amalan yang paling berat dilakukan, khususnya manusia yang tidak suka berkongsi harta dengan orang lain....',
    'Sedekah menjadi antara amalan yang paling berat dilakukan, khususnya manusia yang tidak suka berkongsi harta dengan orang lain....',
    'Sedekah menjadi antara amalan yang paling berat dilakukan, khususnya manusia yang tidak suka berkongsi harta dengan orang lain....',
    'Sedekah menjadi antara amalan yang paling berat dilakukan, khususnya manusia yang tidak suka berkongsi harta dengan orang lain....',
    'Sedekah menjadi antara amalan yang paling berat dilakukan, khususnya manusia yang tidak suka berkongsi harta dengan orang lain....',
    'Sedekah menjadi antara amalan yang paling berat dilakukan, khususnya manusia yang tidak suka berkongsi harta dengan orang lain....',
    'Sedekah menjadi antara amalan yang paling berat dilakukan, khususnya manusia yang tidak suka berkongsi harta dengan orang lain....',
    'Sedekah menjadi antara amalan yang paling berat dilakukan, khususnya manusia yang tidak suka berkongsi harta dengan orang lain....',
  ];

  getArticles() async {
    setState(() {
      loading = true;
    });
    articles.clear();
    try {
      String url = 'https://salam.mukminapps.com/api/Article';
      var result = await http
          .get(Uri.parse(url), headers: {"Accept": "application/json"});
      List responseBody = jsonDecode(result.body);
      responseBody.first.forEach((element) {
        if (element['category_id'] == categoryId) {
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
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
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
            body: Column(
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                      image: new DecorationImage(
                          image: AssetImage(
                            "assets/theme/${theme ?? "default"}/appbar.png",
                          ),
                          fit: BoxFit.cover)),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, top: 50),
                    child: Container(
                        height: 35,
                        decoration: new BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8)),
                        // alignment: Alignment.center,
                        child: Center(
                            child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(categoryName,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    )),
                                SizedBox(width: 5),
                                Container(
                                  child: Image.asset(
                                    ImageResource.drop_down,
                                    height: 12,
                                    width: 12,
                                  ),
                                )
                              ],
                            ),
                            DropdownButton<String>(
                              icon: Container(),
                              underline: Container(),
                              dropdownColor: Color(0xff1B1B1B),
                              onChanged: (value) {
                                setState(() {
                                  categoryName = value ?? '';
                                  categoryId = widget.categoryList
                                      .firstWhere(
                                          (element) => element.name == value)
                                      .id;
                                });
                                getArticles();
                              },
                              value: categoryName,
                              borderRadius: BorderRadius.circular(8),
                              isDense: true,
                              selectedItemBuilder: (BuildContext context) {
                                return widget.categoryList.map<Widget>((item) {
                                  return Text(item.name,
                                      style:
                                          TextStyle(color: Colors.transparent));
                                }).toList();
                              },
                              alignment: Alignment.center,
                              isExpanded: false,
                              items: widget.categoryList
                                  .map<DropdownMenuItem<String>>(
                                      (e) => DropdownMenuItem(
                                          value: e.name,
                                          child: Container(
                                            width: 250,
                                            child: Text(
                                              e.name,
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white),
                                            ),
                                          )))
                                  .toList(),
                            ),
                          ],
                        ))),
                  ),
                ),
                Expanded(
                    child: LiveList(
                        itemCount: loading ? 10 : articles.length,
                        itemBuilder: (context, index, animation) {
                          return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: Offset(0, 0.3),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                                    child: Column(children: [
                                      Row(
                                        children: [
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
                                            },
                                            child: Hero(
                                              tag: loading
                                                  ? 'coin$index'
                                                  : 'coin${articles[index].image}',
                                              child: loading
                                                  ? Shimmer.fromColors(
                                                      enabled: true,
                                                      child: Container(
                                                          height: 60,
                                                          width: 60,
                                                          color: Color(
                                                              0xFF383838)),
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
                                                          baseColor:
                                                              Color(0xFF383838),
                                                          highlightColor:
                                                              Color(0xFF484848),
                                                        );
                                                      }

                                                      return child;
                                                    }),
                                            ),
                                          ),
                                          Expanded(
                                            child: ListTile(
                                              title: loading
                                                  ? Shimmer.fromColors(
                                                      enabled: true,
                                                      child: Container(
                                                          height: 12,
                                                          width: 300,
                                                          color: Color(
                                                              0xFF383838)),
                                                      baseColor:
                                                          Color(0xFF383838),
                                                      highlightColor:
                                                          Color(0xFF484848),
                                                    )
                                                  : Text(
                                                      articles[index].name,
                                                      style: TextStyle(
                                                          color:
                                                              getColor(theme),
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontStyle:
                                                              FontStyle.normal),
                                                    ),
                                              subtitle: loading
                                                  ? Shimmer.fromColors(
                                                      enabled: true,
                                                      child: Container(
                                                          height: 30,
                                                          width: 350,
                                                          color: Color(
                                                              0xFF383838)),
                                                      baseColor:
                                                          Color(0xFF383838),
                                                      highlightColor:
                                                          Color(0xFF484848),
                                                    )
                                                  : Text(
                                                      articles[index]
                                                          .description,
                                                      maxLines: 3,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xffFFFFFF),
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontStyle:
                                                            FontStyle.normal,
                                                      ),
                                                    ),
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
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 15, bottom: 15),
                                        child: Container(
                                          height: 1,
                                          color: Color(0xff787878),
                                        ),
                                      ),
                                    ]),
                                  )));
                        }))
              ],
            ),
          )),
    );
  }
}
