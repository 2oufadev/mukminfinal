import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:mouse_parallax/mouse_parallax.dart';
import 'package:mukim_app/business_logic/cubit/subscription/userstate_cubit.dart';
import 'package:mukim_app/presentation/screens/Surah/surah.dart';
import 'package:mukim_app/presentation/widgets/juzuk_card.dart';
import 'package:mukim_app/presentation/widgets/transition.dart';
import 'package:mukim_app/resources/Imageresources.dart';
import 'package:mukim_app/resources/constants.dart';
import 'package:mukim_app/resources/global.dart';
import 'package:mukim_app/utils/componants.dart';
import 'package:rect_getter/rect_getter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'juzuk_word_tajweed.dart';

class Juzuk extends StatefulWidget {
  final List surahs;

  Juzuk({Key? key, required this.surahs}) : super(key: key);

  var title = 'Juzuk';

  @override
  _JuzukState createState() => _JuzukState();
}

class _JuzukState extends State<Juzuk> {
  bool visible = false;
  IconData ic = Icons.arrow_circle_down_rounded;
  List surahNames = [
    'Al-Fatihah (1) - Al-Baqarah (141)',
    'Al-Baqarah (142) - Al-Baqarah (252)',
    'Al-Baqarah (253) - Aali Imran (92)',
    'Aali Imran (93) - An-Nisa (23)',
    'An-Nisa (24) - An-Nisa (147)',
    'An-Nisa (148)- Al-Ma’idah (81)',
    'Al-Ma’idah (82)- Al-An’am (110)',
    'Al-An’am (111)- Al-A’raf (87)',
    'Al-A’raf (88)- Al-Anfal (40)',
    'Al-Anfal (41)- At-Taubah (92)',
    'At-Taubah (93) - Hud (5)',
    'Hud (6) - Yusuf (52)',
    'Yusuf (53) - Ibrahim (52)',
    'Al-Hijr (1) - An-Nahl (128)',
    'Al-Isra (1) - Al-Kahf (74)',
    'Al-Kahf (75) - Ta-Ha (135)',
    'Al-Anbiya (1) - Al-Haj (78)',
    'Al-Mu’minun (1) - Al-Furqan (20)',
    'Al-Furqan (21) - An-Naml (55)',
    'An-Naml (56) - Al-Ankabut (45)',
    'Al-Ankabut (46) - Al-Ahzab (30)',
    'Al-Ahzab (31) - Ya-Sin (27)',
    'Ya-Sin (28) - Az-Zumar (31)',
    'Az-Zumar (32) - Fusilat (46)',
    'Fusilat (47) - Al-Jathiyah (37)',
    'Al-Ahqaf (1) - Adz-Dzariyah (30)',
    'Adz-Dzariyah (31) - Al-Hadid (29)',
    'Al-Mujadilah (1) - At-Tahrim (12)',
    'Al-Mulk (1) - Al-Mursalat (50)',
    'An-Naba (1) - An-Nas (3)'
  ];

  final Duration animationDuration = Duration(milliseconds: 300);
  final Duration delay = Duration(milliseconds: 300);
  var rectGetterKey = RectGetter.createGlobalKey();
  Rect? rect;

  var rectGetterKeys = RectGetter.createGlobalKey();

  TextEditingController searchcontroller = new TextEditingController();

  List searchData = [];

  void _onTap() async {
    setState(() => rect = RectGetter.getRectFromKey(rectGetterKey));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(
        () {
          rect = rect!.inflate(1.3 * MediaQuery.of(context).size.longestSide);
          Globals.globalInd = 0;
          Globals.globalIndex = 0;
        },
      );
      Future.delayed(animationDuration + delay, _goToNextPage);
    });
  }

  void _goToNextPage() {
    if (widget.title == 'Surah') {
      Navigator.of(context)
          .push(FadeRouteBuilder(page: Juzuk(surahs: widget.surahs)))
          .then(
            (_) => setState(
              () {
                rect = null;
                Globals.globalInd = 0;
                Globals.globalIndex = 0;
              },
            ),
          );
    } else {
      Navigator.of(context).push(FadeRouteBuilder(page: Surah())).then(
            (_) => setState(
              () {
                rect = null;
                Globals.globalInd = 0;
                Globals.globalIndex = 0;
              },
            ),
          );
    }
  }

  void _onTapTajweed() async {
    setState(() => rect = RectGetter.getRectFromKey(rectGetterKeys));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() =>
          rect = rect!.inflate(1.3 * MediaQuery.of(context).size.longestSide));
      Future.delayed(animationDuration + delay, _goToTajweed);
    });
  }

  void _goToTajweed() {
    Navigator.of(context)
        .push(FadeRouteBuilder(
            page: JuzukWordTajweed.setJuz('1', 'Juzuk', widget.surahs)))
        .then((_) => setState(() => rect = null));
  }

  searchval(var val) {
    searchData = [];

    for (int i = 0; i < surahNames.length; i++) {
      if (surahNames[i].toLowerCase().contains(val.toLowerCase())) {
        searchData.add(surahNames[i]);
      }
    }

    setState(() {});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    searchData = [];
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return OrientationBuilder(
      builder: (context, orientation) {
        return Stack(
          children: [
            SafeArea(
              top: false,
              child: Scaffold(
                  backgroundColor: HexColor('#3A343D'),
                  extendBodyBehindAppBar: true,
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
                      body: NestedScrollView(
                          physics: NeverScrollableScrollPhysics(),
                          headerSliverBuilder: (context, isScrolled) {
                            return [
                              SliverAppBar(
                                floating: false,
                                expandedHeight: width * 0.4,
                                flexibleSpace: FlexibleSpaceBar(
                                  background: Stack(
                                    alignment: Alignment.centerRight,
                                    children: <Widget>[
                                      Container(
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: AssetImage(
                                                  ImageResource.headerFrame,
                                                ),
                                                fit: BoxFit.fill)),
                                      ),
                                      Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                30, 37, 20, 0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                RectGetter(
                                                  key: rectGetterKey,
                                                  child: GestureDetector(
                                                    onTap: _onTap,
                                                    child: Container(
                                                      width: 56,
                                                      height: 18,
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xff524D9F),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      child: const Center(
                                                        child: Text(
                                                          "Surah",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 10),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          border: Border.all(
                                                              color: Colors
                                                                  .white)),
                                                      child: CircleAvatar(
                                                        radius: 35,
                                                        backgroundImage:
                                                            AssetImage(Qari
                                                                .qari_image),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          visible = !visible;
                                                        });
                                                      },
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            Qari.qari_name
                                                                .toString(),
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 12),
                                                          ),
                                                          const SizedBox(
                                                              width: 3),
                                                          RotatedBox(
                                                            quarterTurns:
                                                                visible ? 0 : 3,
                                                            child: const Image(
                                                                image:
                                                                    AssetImage(
                                                                  ImageResource
                                                                      .drop_down,
                                                                ),
                                                                height: 18),
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                RectGetter(
                                                  key: rectGetterKeys,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      _onTapTajweed();
                                                    },
                                                    child: Container(
                                                      width: 56,
                                                      height: 18,
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xff524D9F),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      child: const Center(
                                                        child: Text(
                                                          "Tajweed",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 10),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 1.56),
                                        ],
                                      ),
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.black45,
                                          ),
                                          height: 35,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 30),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.search,
                                                color: Colors.white,
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 15, 0, 0),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    84,
                                                child: TextField(
                                                  onChanged: (val) {
                                                    searchval(val);
                                                  },
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12),
                                                  decoration:
                                                      const InputDecoration(
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors
                                                              .transparent),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors
                                                              .transparent),
                                                    ),
                                                    hintText: 'Cari Juzuk',
                                                    hintStyle: TextStyle(
                                                        color: Colors.white),
                                                    fillColor: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                backgroundColor: Colors.transparent,
                                leading: Icon(null),
                              )
                            ];
                          },
                          body: MediaQuery.removePadding(
                              context: context,
                              removeTop: true,
                              child: ParallaxStack(layers: [
                                Column(
                                  children: [
                                    Visibility(
                                        visible: visible,
                                        child: Container(
                                          color: Colors.black,
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 10, 10, 10),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              const Text(
                                                'Pilih Qari / Pembaca',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15),
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  qariCards(
                                                      'Abdul Basit',
                                                      context,
                                                      ImageResource.abdulbasit),
                                                  qariCards(
                                                      'Mishary Rashid Alfasay',
                                                      context,
                                                      ImageResource.mishari),
                                                  qariCards(
                                                      'Abu Bakr Al-Shatri',
                                                      context,
                                                      ImageResource.shatri),
                                                ],
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  qariCards(
                                                      'Hani Ar Rifai',
                                                      context,
                                                      ImageResource.refai),
                                                  qariCards(
                                                      'Abdul Rahman Al-Sudais',
                                                      context,
                                                      ImageResource.sudais),
                                                  qariCards(
                                                      'Siddiq El-Minshawi',
                                                      context,
                                                      ImageResource.minshawi),
                                                ],
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  qariCards(
                                                      'Mahmoud Al-Hussary',
                                                      context,
                                                      ImageResource.husary),
                                                  qariCards(
                                                      'Saud Al-Shuraim',
                                                      context,
                                                      ImageResource.shuraim),
                                                  qariCards(
                                                      'Mohamed Tablawi',
                                                      context,
                                                      ImageResource.tablawi),
                                                ],
                                              ),
                                            ],
                                          ),
                                        )),
                                    SizedBox(height: 15),
                                    searchData.toString() == '[]'
                                        ? Expanded(
                                            child: ListView.builder(
                                              padding:
                                                  EdgeInsets.only(bottom: 65),
                                              itemCount: surahNames.length,
                                              shrinkWrap: true,
                                              scrollDirection: Axis.vertical,
                                              itemBuilder: (context, index) {
                                                return JuzukCard(
                                                  index: index,
                                                  data: surahNames[index]
                                                      .toString(),
                                                  surahs: widget.surahs,
                                                  showQari: () {
                                                    setState(() {
                                                      visible = true;
                                                    });
                                                  },
                                                );
                                              },
                                            ),
                                          )
                                        : Expanded(
                                            child: ListView.builder(
                                              padding:
                                                  EdgeInsets.only(bottom: 65),
                                              itemCount: searchData.length,
                                              shrinkWrap: true,
                                              scrollDirection: Axis.vertical,
                                              itemBuilder: (context, index) {
                                                return JuzukCard(
                                                  index: index,
                                                  data: surahNames[index]
                                                      .toString(),
                                                  surahs: widget.surahs,
                                                  showQari: () {
                                                    setState(() {
                                                      visible = true;
                                                    });
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                  ],
                                ),
                              ]))))),
            ),
            _ripple()
          ],
        );
      },
    );
  }

  Widget qariCards(var qariname, context, var imgdata) {
    return GestureDetector(
      onTap: () {
        setState(() {
          AudioConstants.paused = false;
          AudioConstants.duration = Duration();
          AudioConstants.position = Duration();
          AudioConstants.playing = false;
          AudioConstants.playingNext = false;
          Globals.globalInd = 0;
          Globals.globalIndex = 0;
          Qari.qari_name = qariname;
          Qari.qari_image = imgdata;
          visible = false;
          if (qariname == 'Abdul Basit') {
            Qari.qari_id = 1;
          }
          if (qariname == 'Abdul Rahman Al-Sudais') {
            Qari.qari_id = 3;
          }
          if (qariname == 'Abu Bakr Al-Shatri') {
            Qari.qari_id = 4;
          }
          if (qariname == 'Hani Ar Rifai') {
            Qari.qari_id = 5;
          }
          if (qariname == 'Sheikh Mishary Rashid Alfasay') {
            Qari.qari_id = 7;
          }
          if (qariname == 'Mohamed Siddiq El-Minshawi') {
            Qari.qari_id = 8;
          }
          print(Qari.qari_id.toString());
        });
      },
      child: Container(
        padding: EdgeInsets.all(10),
        width: (MediaQuery.of(context).size.width / 3) - 10,
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(imgdata),
              minRadius: 24,
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              qariname,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _ripple() {
    if (rect == null) {
      return Container();
    }
    return AnimatedPositioned(
      duration: animationDuration,
      left: rect!.left,
      right: MediaQuery.of(context).size.width - rect!.right,
      top: rect!.top,
      bottom: MediaQuery.of(context).size.height - rect!.bottom,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xff524D9F),
        ),
      ),
    );
  }
}
