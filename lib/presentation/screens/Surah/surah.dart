import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:mouse_parallax/mouse_parallax.dart';
import 'package:mukim_app/business_logic/cubit/subscription/userstate_cubit.dart';
import 'package:mukim_app/presentation/screens/bookmarks.dart';
import 'package:mukim_app/presentation/widgets/ShimmerLayouts/surah_shimmer.dart';
import 'package:mukim_app/presentation/widgets/surah_card.dart';
import 'package:mukim_app/presentation/widgets/transition.dart';
import 'package:mukim_app/resources/Imageresources.dart';
import 'package:mukim_app/resources/constants.dart';
import 'package:mukim_app/resources/global.dart';
import 'package:mukim_app/utils/componants.dart';
import 'package:mukim_app/providers/theme.dart';
import 'package:mukim_app/utils/get_theme_color.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rect_getter/rect_getter.dart';
import '../Juzuk/juzuk.dart';
import '../Juzuk/juzuk_word_tajweed.dart';
import 'package:http/http.dart' as http;

class Surah extends StatefulWidget {
  Surah({Key? key}) : super(key: key);

  var title = 'Surah';

  @override
  _SurahState createState() => _SurahState();
}

class _SurahState extends State<Surah> {
  bool visible = false;
  final Duration animationDuration = Duration(milliseconds: 300);
  final Duration delay = Duration(milliseconds: 300);
  var rectGetterKey = RectGetter.createGlobalKey();
  var rectGetterKeys = RectGetter.createGlobalKey();
  bool loading = true;
  Rect? rect;
  TextEditingController search = TextEditingController();
  Map<String, dynamic>? userStateMap;

  void _onTap() async {
    setState(
      () {
        rect = RectGetter.getRectFromKey(rectGetterKey);
        Globals.globalInd = 0;
        Globals.globalIndex = 0;
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() =>
          rect = rect!.inflate(1.3 * MediaQuery.of(context).size.longestSide));
      Future.delayed(animationDuration + delay, _goToNextPage);
      Globals.globalInd = 0;
      Globals.globalIndex = 0;
    });
  }

  void _goToNextPage() {
    if (widget.title == 'Surah') {
      Navigator.of(context)
          .push(FadeRouteBuilder(page: Juzuk(surahs: surahs)))
          .then(
            (_) => setState(
              () {
                rect = null;
                Globals.globalInd = 0;
                Globals.globalIndex = 0;
                AudioConstants.audioPlayer = AudioPlayer();
                AudioConstants.duration = Duration();
                AudioConstants.playing = false;
                AudioConstants.position = Duration();
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
                AudioConstants.audioPlayer = AudioPlayer();
                AudioConstants.duration = Duration();
                AudioConstants.playing = false;
                AudioConstants.position = Duration();
              },
            ),
          );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getSurah();
    super.initState();
  }

  void _onTapBookmarks() async {
    setState(() => rect = RectGetter.getRectFromKey(rectGetterKeys));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() =>
          rect = rect!.inflate(1.3 * MediaQuery.of(context).size.longestSide));
      Future.delayed(animationDuration + delay, _goToBookmarks);
    });
  }

  void _goToBookmarks() {
    Navigator.of(context)
        .push(FadeRouteBuilder(
            page: BookMarks(surahs: surahs, surahsUrdu: surahUrdu)))
        .then((_) => setState(() => rect = null));
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
            page: JuzukWordTajweed.setJuz('1', 'Surah', surahs)))
        .then((_) => setState(() => rect = null));
  }

  getSurah() async {
    try {
      List<Map> qqq =
          await AudioConstants.database!.rawQuery('SELECT * FROM "Surahs"');
      if (qqq.isEmpty) {
        String url = 'https://quranicaudio.com/api/surahs';
        var result = await http
            .get(Uri.parse(url), headers: {"Accept": "application/json"});
        surahs = jsonDecode(result.body);
        await AudioConstants.database!.insert('Surahs', {'value': result.body});
      } else {
        surahs = jsonDecode(qqq.first['value'].toString());
      }
      setState(() {
        loading = false;
      });
      // getDownloadedSurahs();
    } catch (e) {
      setState(() {
        loading = false;
      });
      print('--------$e');
    }
  }

  List surahs = [];
  List searchData = [];

  var data = [];

  searchval(var val) {
    searchData.clear();

    surahs
        .where((element) => element['name']['simple']
            .toString()
            .toLowerCase()
            .contains(val.toString().toLowerCase()))
        .forEach((element) {
      searchData.add(element);
    });

    setState(() {});
  }

  List surahUrdu = [
    '!',
    '"',
    '#',
    '\$',
    '%',
    '&',
    '\'',
    '(',
    ')',
    '*',
    '+',
    ',',
    '-',
    '.',
    '/',
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    ':',
    ';',
    '<',
    '=',
    '>',
    '?',
    '@',
    'a',
    'A',
    'b',
    'B',
    'c',
    'C',
    'd',
    'D',
    'E',
    'e',
    'F',
    'f',
    'g',
    'G',
    'H',
    'h',
    'I',
    'i',
    'J',
    'j',
    'K',
    'k',
    'l',
    'L',
    'M',
    'm',
    'n',
    'N',
    'O',
    'o',
    'p',
    'P',
    'Q',
    'q',
    'R',
    'r',
    's',
    'S',
    't',
    'T',
    'u',
    'U',
    'v',
    'V',
    'W',
    'w',
    'x',
    'X',
    'y',
    'Y',
    'Z',
    'z',
    '[',
    '\'',
    ']',
    '^',
    '_',
    '`',
    '{',
    '|',
    '}',
    '~',
    '¡',
    '¢',
    '£',
    '¤',
    '¥',
    '¦',
    '§',
    '¨',
    '©',
    'ª',
    '«',
    '¬',
    '®',
    '¯',
    '°',
    '±',
    '²',
    '³',
    '´',
    'µ'
  ];

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    String theme = Provider.of<ThemeNotifier>(context).appTheme;
    userStateMap = BlocProvider.of<UserStateCubit>(context).checkUserState();
    return SafeArea(
      top: false,
      child: OrientationBuilder(builder: (context, orientation) {
        return Stack(
          children: [
            Scaffold(
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
                        headerSliverBuilder: (context, isScolled) {
                          return [
                            SliverAppBar(
                              floating: false,
                              expandedHeight: width * 0.4,
                              // bottom: PreferredSize(
                              //   preferredSize: Size.fromHeight(30.0),
                              //   child: Text(''),
                              // ),
                              flexibleSpace: FlexibleSpaceBar(
                                background: Stack(
                                  alignment: Alignment.centerRight,
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                            "assets/theme/${theme ?? "default"}/appbar.png",
                                          ),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                    //         Container(
                                    // height: 154,
                                    // decoration: const BoxDecoration(
                                    //     image: DecorationImage(
                                    //   image: AssetImage('assets/headerFrame.png'),
                                    //   fit: BoxFit.fill,
                                    // ))),
                                    // Padding(
                                    //   padding: const EdgeInsets.only(top: 35.0),
                                    //   child: Row(
                                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //     children: [

                                    //     ],
                                    //   ),
                                    // ),
                                    Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              30, 37, 20, 0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              RectGetter(
                                                key: rectGetterKey,
                                                child: GestureDetector(
                                                  onTap: _onTap,
                                                  child: Container(
                                                    width: 56,
                                                    height: 18,
                                                    decoration: BoxDecoration(
                                                      color: getColor(
                                                        theme,
                                                        isButton: true,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                    child: const Center(
                                                      child: Text(
                                                        "Juzuk",
                                                        style: TextStyle(
                                                            color: Colors.white,
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
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                            color:
                                                                Colors.white)),
                                                    child: CircleAvatar(
                                                      radius: 35,
                                                      backgroundImage:
                                                          AssetImage(
                                                              Qari.qari_image),
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
                                                          style:
                                                              const TextStyle(
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
                                                          child: Image(
                                                            image: AssetImage(
                                                                ImageResource
                                                                    .drop_down),
                                                            height: 16,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  RectGetter(
                                                    key: rectGetterKeys,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        _onTapTajweed();
                                                      },
                                                      child: Container(
                                                        width: 64,
                                                        height: 18,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: getColor(
                                                            theme,
                                                            isButton: true,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                        ),
                                                        child: const Center(
                                                          child: Text(
                                                            "Tajweed",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 10),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  RectGetter(
                                                    key: RectGetter
                                                        .createGlobalKey(),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        _onTapBookmarks();
                                                      },
                                                      child: Container(
                                                        width: 64,
                                                        height: 18,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: getColor(
                                                            theme,
                                                            isButton: true,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                        ),
                                                        child: const Center(
                                                          child: Text(
                                                            "Bookmarks",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 10),
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
                                                        color:
                                                            Colors.transparent),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color:
                                                            Colors.transparent),
                                                  ),
                                                  hintText: 'Cari Surah',
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
                            child: ParallaxStack(
                              layers: [
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
                                    loading
                                        ? SurahShimmer()
                                        : searchData.isEmpty
                                            ? Expanded(
                                                child: ListView.builder(
                                                  itemCount: surahs.length,
                                                  shrinkWrap: true,
                                                  padding: EdgeInsets.only(
                                                      bottom: 65),
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return SurahCard(
                                                      data: surahs[index],
                                                      urduName:
                                                          surahUrdu[index],
                                                      surahs: surahs,
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
                                                  padding: EdgeInsets.only(
                                                      bottom: 65),
                                                  itemCount: searchData.length,
                                                  shrinkWrap: true,
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return SurahCard(
                                                      data: searchData[index],
                                                      urduName: surahUrdu[surahs
                                                          .indexOf(searchData[
                                                              index])],
                                                      surahs: surahs,
                                                      showQari: () {
                                                        setState(() {
                                                          visible = true;
                                                        });
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                    SizedBox(height: 50)
                                  ],
                                )
                              ],
                            ))))),
            _ripple()
          ],
        );
      }),
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
            Qari.qari_id = 2;
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

          if (qariname == 'Mahmoud Al-Hussary') {
            Qari.qari_id = 6;
          }

          if (qariname == 'Mishary Rashid Alfasay') {
            Qari.qari_id = 7;
          }
          if (qariname == 'Siddiq El-Minshawi') {
            Qari.qari_id = 8;
          }

          if (qariname == 'Saud Al-Shuraim') {
            Qari.qari_id = 10;
          }

          if (qariname == 'Mohamed Tablawi') {
            Qari.qari_id = 11;
          }
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
