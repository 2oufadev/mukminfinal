import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mukim_app/business_logic/cubit/subscription/userstate_cubit.dart';
import 'package:mukim_app/presentation/screens/Juzuk/juzuk.dart';
import 'package:mukim_app/presentation/screens/Juzuk/juzuk_audio.dart';
import 'package:mukim_app/presentation/screens/Juzuk/juzuk_audio_rep.dart';
import 'package:mukim_app/presentation/screens/Juzuk/juzuk_word_tajweed.dart';
import 'package:mukim_app/presentation/widgets/ShimmerLayouts/quran_shimmer.dart';
import 'package:mukim_app/presentation/widgets/tajweed_cards.dart';
import 'package:mukim_app/presentation/widgets/transition.dart';
import 'package:mukim_app/providers/theme.dart';
import 'package:mukim_app/resources/Imageresources.dart';
import 'package:mukim_app/resources/constants.dart';
import 'package:mukim_app/resources/global.dart';
import 'package:mukim_app/utils/get_theme_color.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rect_getter/rect_getter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:mukim_app/utils/componants.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class JuzukTajweed extends StatefulWidget {
  JuzukTajweed({Key? key}) : super(key: key);
  var juzNum = "1";
  var surahs;

  JuzukTajweed.set(var juzNum, var surahs) {
    this.juzNum = juzNum;
    this.surahs = surahs;
  }

  @override
  _JuzukTajweedState createState() => _JuzukTajweedState();
}

class _JuzukTajweedState extends State<JuzukTajweed> {
  final Duration animationDuration = Duration(milliseconds: 300);
  final Duration delay = Duration(milliseconds: 300);
  Timer? timer;
  String theme = 'default';

  var rectGetterKey = RectGetter.createGlobalKey();
  Rect? rect;
  ScrollController scrollController = ScrollController();
  int page = 1;
  int more = 0;
  var rectGetterKeys = RectGetter.createGlobalKey();
  bool initProv = true;
  ItemScrollController? ayatScrollController;
  ItemPositionsListener? itemPosLis;
  var juzname = "بِسْمِ اللَّهِ";
  int surahId = 0;
  bool loading = true;
  bool showMore = false;
  bool qariVisible = false;
  void _onTap() async {
    setState(() => rect = RectGetter.getRectFromKey(rectGetterKey));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() =>
          rect = rect!.inflate(1.3 * MediaQuery.of(context).size.longestSide));
      Future.delayed(animationDuration + delay, _goToNextPage);
    });
  }

  void _goToNextPage() {
    Navigator.of(context)
        .push(FadeRouteBuilder(
            page: JuzukWordTajweed.setJuz(
                widget.juzNum.toString(), 'JuzukTajweed', widget.surahs)))
        .then((_) => setState(() => rect = null));
  }

  @override
  void initState() {
    // TODO: implement didChangeDependencies
    super.initState();
    getJuz();

    getJuzukTajweedData(widget.juzNum);

    ayatScrollController = ItemScrollController();
    itemPosLis = ItemPositionsListener.create();
    itemPosLis!.itemPositions.addListener(() {
      if (AudioConstants.viewinglist.isNotEmpty &&
          itemPosLis!.itemPositions.value.isNotEmpty) {
        int pos = itemPosLis!.itemPositions.value.first.index;

        String s = AudioConstants.viewinglist[pos]['verse_key']
            .toString()
            .split(':')
            .first;
        if (s != surahId.toString()) {
          surahId = int.parse(AudioConstants.viewinglist[pos]['verse_key']
              .toString()
              .split(':')
              .first);
          setState(() {});
        }

        setState(() {});
      }
    });
  }

  getJuz() {
    switch (widget.juzNum.toString()) {
      case "1":
        juzname = "بِسْمِ اللَّهِ";
        page = 1;
        break;
      case "2":
        juzname = "سَيَقُولُ";
        page = 22;
        break;
      case "3":
        juzname = "تِلْكَ الرُّسُلُ";
        page = 42;
        break;
      case "4":
        juzname = "لَنْ تَنَالُوا";
        page = 62;
        break;
      case "5":
        juzname = "وَالْمُحْصَنَاتُ";
        page = 82;
        break;
      case "6":
        juzname = "لَا يُحِبُّ اللَّهُ	";
        page = 102;
        break;
      case "7":
        juzname = "وَإِذَا سَمِعُوا	";
        page = 122;
        break;
      case "8":
        juzname = "وَلَوْ أَنَّنَا	";
        page = 142;
        break;
      case "9":
        juzname = "قَالَ الْمَلَأُ	";
        page = 162;
        break;
      case "10":
        juzname = "وَاعْلَمُوا	";
        page = 182;
        break;
      case "11":
        juzname = "يَعْتَذِرُونَ	";
        page = 202;
        break;
      case "12":
        juzname = "وَمَا مِنْ دَابَّةٍ	";
        page = 222;
        break;
      case "13":
        juzname = "وَمَا أُبَرِّئُ	";
        page = 242;
        break;
      case "14":
        juzname = "رُبَمَا	";
        page = 262;
        break;
      case "15":
        juzname = "سُبْحَانَ الَّذِي	";
        page = 282;
        break;
      case "16":
        juzname = "قَالَ أَلَمْ	";
        page = 302;
        break;
      case "17":
        juzname = "اقْتَرَبَ";
        page = 322;
        break;
      case "18":
        juzname = "قَدْ أَفْلَحَ	";
        page = 342;
        break;
      case "19":
        juzname = "وَقَالَ الَّذِينَ	";
        page = 362;
        break;
      case "20":
        juzname = "أَمَّنْ خَلَقَ	";
        page = 382;
        break;
      case "21":
        juzname = "اتْلُ مَا أُوحِيَ	";
        page = 402;
        break;
      case "22":
        juzname = "وَمَنْ يَقْنُتْ	";
        page = 422;
        break;
      case "23":
        juzname = "وَمَا لِيَ	";
        page = 442;
        break;
      case "24":
        juzname = "فَمَنْ أَظْلَمُ	";
        page = 462;
        break;
      case "25":
        juzname = "إِلَيْهِ يُرَدُّ	";
        page = 482;
        break;
      case "26":
        juzname = "حم";
        page = 502;
        break;
      case "27":
        juzname = "قَالَ فَمَا خَطْبُكُمْ	";
        page = 522;
        break;
      case "28":
        juzname = "قَدْ سَمِعَ اللَّهُ	";
        page = 542;
        break;
      case "29":
        juzname = "تَبَارَكَ الَّذِي	";
        page = 562;
        break;
      case "30":
        juzname = "عَمَّ يَتَسَاءَلُونَ	";
        page = 582;
        break;
    }
  }

  int ind = 1;
  int len = 1;

  getJuzukTajweedData(var juzN) async {
    try {
      AudioConstants.viewinglist.clear();

      List<Map> qqq = await AudioConstants.database!
          .rawQuery('SELECT * FROM "Page" WHERE pageId=?', [page.toString()]);
      if (qqq.isNotEmpty) {
        Map<String, dynamic> responseBody =
            jsonDecode(qqq.first['value'].toString());
        AudioConstants.viewinglist.addAll(responseBody['verses']);
      } else {
        String url = 'https://api.quran.com/api/v4/verses/by_page/' +
            page.toString() +
            '?language=malay&words=true&translations=39&word_fields=text_uthmani,text_indopak,text_imlaei,code_v1&page=1';

        var result = await http
            .get(Uri.parse(url), headers: {"Accept": "application/json"});

        Map<String, dynamic> responseBody = jsonDecode(result.body);

        AudioConstants.viewinglist.addAll(responseBody['verses']);
        await AudioConstants.database!.insert('Page', {
          'pageId': page.toString(),
          'value': result.body,
        });

        setState(() {
          loading = false;
        });
      }

      AudioConstants.viewinglist.forEach((element) async {
        List<Map> qqq = await AudioConstants.database!.rawQuery(
            'SELECT * FROM "Ayah" WHERE ayahId=? and qari=?',
            [element['verse_key'].toString(), Qari.qari_id.toString()]);
        if (qqq.isEmpty) {
          String urll = 'https://api.quran.com/api/v4/verses/by_key/' +
              element['verse_key'].toString() +
              '?words=true&audio=' +
              Qari.qari_id.toString();

          var resultt = await http
              .get(Uri.parse(urll), headers: {"Accept": "application/json"});
          Map<String, dynamic> aaa = jsonDecode(resultt.body);
          await AudioConstants.database!.insert(
              'Ayah',
              {
                'ayahId': aaa['verse']['verse_key'],
                'value': resultt.body,
                'qari': Qari.qari_id.toString()
              },
              conflictAlgorithm: ConflictAlgorithm.ignore);
        }
      });

      if (loading) {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      if (loading) {
        setState(() {
          loading = false;
        });
      }
      print(e);
      return e;
    }
  }

  getMoreJuzukTajweedData() async {
    try {
      setState(() {
        showMore = true;
      });

      more++;
      List<Map> www = await AudioConstants.database!.rawQuery(
          'SELECT * FROM "Page" WHERE pageId=? ', [(page + more).toString()]);
      if (www.isNotEmpty) {
        Map<String, dynamic> responseBody =
            jsonDecode(www.first['value'].toString());
        AudioConstants.viewinglist.addAll(responseBody['verses']);
      } else {
        String url = 'https://api.quran.com/api/v4/verses/by_page/' +
            (page + more).toString() +
            '?language=malay&words=true&translations=39&word_fields=text_uthmani,text_imlaei,text_indopak,code_v1&page=1&per_page=50';
        var result = await http
            .get(Uri.parse(url), headers: {"Accept": "application/json"});

        Map<String, dynamic> responseBody = jsonDecode(result.body);

        AudioConstants.viewinglist.addAll(responseBody['verses']);
        await AudioConstants.database!.insert('Page', {
          'pageId': (page + more).toString(),
          'value': result.body,
        });

        setState(() {
          showMore = false;
        });
      }

      AudioConstants.viewinglist.forEach((element) async {
        List<Map> qqq = await AudioConstants.database!.rawQuery(
            'SELECT * FROM "Ayah" WHERE ayahId=? and qari=?',
            [element['verse_key'].toString(), Qari.qari_id.toString()]);
        if (qqq.isEmpty) {
          String urll = 'https://api.quran.com/api/v4/verses/by_key/' +
              element['verse_key'].toString() +
              '?words=true&audio=' +
              Qari.qari_id.toString();

          var resultt = await http
              .get(Uri.parse(urll), headers: {"Accept": "application/json"});
          Map<String, dynamic> aaa = jsonDecode(resultt.body);
          await AudioConstants.database!.insert(
              'Ayah',
              {
                'ayahId': aaa['verse']['verse_key'],
                'value': resultt.body,
                'qari': Qari.qari_id.toString()
              },
              conflictAlgorithm: ConflictAlgorithm.ignore);
        }
      });

      setState(() {
        showMore = false;
      });
    } catch (e) {
      setState(() {
        showMore = false;
      });

      print(e);
      more--;
      return e;
    }
  }

  @override
  Widget build(BuildContext context) {
    theme = Provider.of<ThemeNotifier>(context).appTheme;

    if (mounted && (Globals.autoScroll)) {
      if (ayatScrollController!.isAttached &&
          AudioConstants.viewinglist.isNotEmpty &&
          Globals.globalInd != 0) {
        if (Globals.globalInd > AudioConstants.viewinglist.length - 1) {
        } else {
          ayatScrollController!.scrollTo(
              index: Globals.globalInd, duration: Duration(seconds: 1));
        }
      }
    }

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
              body: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(
                  color: Color(0xff3a343d),
                ),
                child:
                    Consumer<JuzukAudioRep>(builder: (context, model, child) {
                  return Column(
                    children: [
                      Container(
                        height: 119,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                          image: AssetImage(
                              "assets/theme/${theme ?? "default"}/appbar.png"),
                          fit: BoxFit.fill,
                        )),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.fromLTRB(0, 15, 30, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      IconButton(
                                        onPressed: () async {
                                          AudioConstants.audioPlayer.stop();
                                          Globals.globalIndWord = 0;
                                          AudioConstants.duration = Duration();
                                          AudioConstants.position = Duration();
                                          AudioConstants.playing = false;

                                          Navigator.push(
                                              context,
                                              PageTransition(
                                                  type: PageTransitionType
                                                      .leftToRightWithFade,
                                                  child: Juzuk(
                                                      surahs: widget.surahs)));
                                        },
                                        icon: const Icon(
                                          Icons.arrow_back_ios,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          qariVisible = !qariVisible;
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.white)),
                                          child: CircleAvatar(
                                            radius: 35,
                                            backgroundImage:
                                                AssetImage(Qari.qari_image),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            qariVisible = !qariVisible;
                                          });
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 90,
                                              child: Text(
                                                Qari.qari_name.toString(),
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                overflow: TextOverflow.visible,
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 10),
                                              ),
                                            ),
                                            RotatedBox(
                                              quarterTurns: qariVisible ? 0 : 3,
                                              child: Image(
                                                image: AssetImage(
                                                    ImageResource.drop_down),
                                                height: 16,
                                                width: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Stack(
                                          children: [
                                            Positioned(
                                              top: 70,
                                              left: 12,
                                              child: Text(
                                                surahId != 0 &&
                                                        widget.surahs != null &&
                                                        widget.surahs.isNotEmpty
                                                    ? widget.surahs[surahId - 1]
                                                        ['name']['simple']
                                                    : ''.toString(),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              surahId != 0
                                                  ? Globals
                                                      .surahUrdu[surahId - 1]
                                                      .toString()
                                                  : '',
                                              style: const TextStyle(
                                                fontSize: 80,
                                                color: Colors.white,
                                                fontFamily: 'Quran',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
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
                                                  BorderRadius.circular(5),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                "Tajweed",
                                                style: TextStyle(
                                                    color: Colors.white,
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
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                          visible: qariVisible,
                          child: Container(
                            color: Colors.black,
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const Text(
                                  'Pilih Qari / Pembaca',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    qariCards('Abdul Basit', context,
                                        ImageResource.abdulbasit),
                                    qariCards('Mishary Rashid Alfasay', context,
                                        ImageResource.mishari),
                                    qariCards('Abu Bakr Al-Shatri', context,
                                        ImageResource.shatri),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    qariCards('Hani Ar Rifai', context,
                                        ImageResource.refai),
                                    qariCards('Abdul Rahman Al-Sudais', context,
                                        ImageResource.sudais),
                                    qariCards('Siddiq El-Minshawi', context,
                                        ImageResource.minshawi),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    qariCards('Mahmoud Al-Hussary', context,
                                        ImageResource.husary),
                                    qariCards('Saud Al-Shuraim', context,
                                        ImageResource.shuraim),
                                    qariCards('Mohamed Tablawi', context,
                                        ImageResource.tablawi),
                                  ],
                                ),
                              ],
                            ),
                          )),
                      Expanded(
                          child: NotificationListener<ScrollNotification>(
                              onNotification: (ScrollNotification scrollNotif) {
                                if (scrollNotif.metrics.maxScrollExtent ==
                                    scrollNotif.metrics.pixels) {
                                  if (!showMore) {
                                    showMore = true;

                                    getMoreJuzukTajweedData();
                                  }
                                }
                                return true;
                              },
                              child: loading
                                  ? QuranShimmer()
                                  : ScrollablePositionedList.builder(
                                      itemCount:
                                          AudioConstants.viewinglist.length,
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      itemPositionsListener: itemPosLis,
                                      itemScrollController:
                                          ayatScrollController,
                                      itemBuilder: (context, index) {
                                        if (index ==
                                                AudioConstants
                                                        .viewinglist.length -
                                                    1 &&
                                            showMore) {
                                          return Column(children: [
                                            juzuk_tajweed_card(
                                                index,
                                                AudioConstants.viewinglist,
                                                context,
                                                widget.juzNum, [], () {
                                              setState(() {});
                                            }, juzname),
                                            Container(
                                                padding: EdgeInsets.all(15),
                                                width: 50,
                                                height: 50,
                                                child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            getColor(theme))))
                                          ]);
                                        } else {
                                          return juzuk_tajweed_card(
                                              index,
                                              AudioConstants.viewinglist,
                                              context,
                                              widget.juzNum, [], () {
                                            setState(() {});
                                          }, juzname);
                                        }
                                      }))),
                      Container(
                        height: 10,
                        color: Colors.black,
                      ),
                      JuzukAudio(onTapBack: () {
                        if (Globals.globalInd >= 1) {
                          if (AudioConstants
                                  .audioPlayer.playerState.processingState !=
                              ProcessingState.idle) {
                            model.playPrev(
                              AudioConstants.viewinglist,
                            );
                          }
                        }
                      }, onTapNext: () {
                        if (AudioConstants
                                .audioPlayer.playerState.processingState !=
                            ProcessingState.idle) {
                          model.playNext(
                            AudioConstants.viewinglist,
                          );
                        }
                      }, onTapPlay: () async {
                        if (AudioConstants.audioPlayer.playerState.playing) {
                          AudioConstants.paused = true;
                          AudioConstants.audioPlayer.pause();
                        } else if (AudioConstants
                                .audioPlayer.playerState.processingState ==
                            ProcessingState.idle) {
                          model.onSet1(Globals.globalInd, Globals.color1);

                          List<Map> www = await AudioConstants.database!.rawQuery(
                              'SELECT * FROM "Ayah" WHERE ayahId=? and qari=?',
                              [
                                AudioConstants.viewinglist[Globals.globalInd]
                                        ['verse_key']
                                    .toString(),
                                Qari.qari_id.toString()
                              ]);
                          if (www.isNotEmpty) {
                            Map<String, dynamic> responseBody =
                                jsonDecode(www.first['value'].toString());
                            String url = responseBody['verse']['audio']['url']
                                .toString();
                            Globals.aazz =
                                responseBody['verse']['audio']['segments'];
                            Globals.globalIndWord = 0;
                            Globals.playingUrl = url;
                            model.getAudio(
                                AudioConstants.viewinglist[Globals.globalInd]
                                        ['verse_key']
                                    .toString(),
                                AudioConstants.viewinglist);
                            AudioConstants.paused = false;
                          } else {}
                        } else {
                          if (AudioConstants
                                  .audioPlayer.playerState.processingState ==
                              ProcessingState.completed) {
                            if (Globals.globalInd <
                                AudioConstants.viewinglist.length - 1) {
                              Globals.globalInd = Globals.globalInd + 1;

                              List<Map> www = await AudioConstants.database!
                                  .rawQuery(
                                      'SELECT * FROM "Ayah" WHERE ayahId=? and qari=?',
                                      [
                                    AudioConstants
                                        .viewinglist[Globals.globalInd]
                                            ['verse_key']
                                        .toString(),
                                    Qari.qari_id.toString()
                                  ]);
                              if (www.isNotEmpty) {
                                Map<String, dynamic> responseBody =
                                    jsonDecode(www.first['value'].toString());
                                String url = responseBody['verse']['audio']
                                        ['url']
                                    .toString();
                                Globals.aazz =
                                    responseBody['verse']['audio']['segments'];
                                Globals.globalIndWord = 0;
                                Globals.playingUrl = url;
                                model.getAudio(
                                    AudioConstants
                                        .viewinglist[Globals.globalInd]
                                            ['verse_key']
                                        .toString(),
                                    AudioConstants.viewinglist);
                                AudioConstants.paused = false;
                              }
                            }
                          } else {
                            AudioConstants.audioPlayer.play();
                          }
                        }
                      }),
                      SizedBox(height: 60)
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
        _ripple(),
      ],
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
          qariVisible = false;
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
