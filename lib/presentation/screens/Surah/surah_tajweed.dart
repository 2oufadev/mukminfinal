import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mukim_app/business_logic/cubit/subscription/userstate_cubit.dart';
import 'package:mukim_app/data/models/word_bookmark_model.dart';
import 'package:mukim_app/presentation/screens/Juzuk/juzuk_audio.dart';
import 'package:mukim_app/presentation/screens/Juzuk/juzuk_audio_rep.dart';
import 'package:mukim_app/presentation/screens/Surah/surah.dart';
import 'package:mukim_app/presentation/screens/Surah/surah_word_tajweed.dart';
import 'package:mukim_app/presentation/widgets/ShimmerLayouts/quran_shimmer.dart';
import 'package:mukim_app/presentation/widgets/tajweed_cards.dart';
import 'package:mukim_app/presentation/widgets/transition.dart';
import 'package:mukim_app/providers/theme.dart';
import 'package:mukim_app/resources/Imageresources.dart';
import 'package:mukim_app/resources/constants.dart';
import 'package:mukim_app/resources/global.dart';
import 'package:mukim_app/utils/get_theme_color.dart';
import 'package:mukim_app/utils/componants.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rect_getter/rect_getter.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SurahTajweed extends StatefulWidget {
  SurahTajweed({Key? key}) : super(key: key);

  var chapnum, urduname, engName, surahs, moveScroll, verse;

  SurahTajweed.set(var chapnum, var urduname, var engName, var surahs,
      var moveScroll, var verse) {
    this.chapnum = chapnum;
    this.urduname = urduname;
    this.engName = engName;
    this.surahs = surahs;
    this.moveScroll = moveScroll;
    this.verse = verse;
  }

  @override
  _SurahTajweedState createState() => _SurahTajweedState();

  static _SurahTajweedState? of(BuildContext context) =>
      context.findAncestorStateOfType<_SurahTajweedState>();
}

class _SurahTajweedState extends State<SurahTajweed> {
  Map<String, dynamic>? userStateMap;
  List<WordsBookmarksModel> wordsBookmarksList = [];

  String theme = 'default';
  int pos = 0;
  final Duration animationDuration = const Duration(milliseconds: 300);
  final Duration delay = const Duration(milliseconds: 300);
  var rectGetterKey = RectGetter.createGlobalKey();
  ItemScrollController? ayatScrollController;
  ItemPositionsListener? itemPosLis;
  Rect? rect;
  int more = 0;
  var rectGetterKeys = RectGetter.createGlobalKey();
  bool nextSurah = false;
  int page = 1;
  int surahId = 0;
  bool initProv = true;
  bool showMore = false;
  bool showingmore = false;
  bool loading = true;
  int suraInt = 1;
  int numberOfPages = 1;
  int currentNumberOfPage = 1;
  bool qariVisible = false;
  set string(String value) => () {
        ayatScrollController!
            .scrollTo(index: int.parse(value), duration: Duration(seconds: 1));
      };

  getWordsBookmarks() async {
    try {
      List<Map> qqq = await AudioConstants.database!
          .rawQuery('SELECT * FROM "wordsbookmarks"');
      if (qqq.isNotEmpty) {
        qqq.forEach((element) {
          wordsBookmarksList.add(WordsBookmarksModel(
              element['verse_key'],
              element['position'],
              element['surahName'],
              element['surahId'],
              element['page'],
              element['juz']));
        });
      }
      setState(() {});
    } catch (e) {
      setState(() {});
      print('--------$e');
    }
  }

  void _onTapBookmark(String surahName, int surahId, int page, int juz) async {
    await AudioConstants.database!
        .insert(
            'bookmarks',
            {
              'surahId': surahId,
              'surahName': surahName,
              'page': page,
              'juz': juz
            },
            conflictAlgorithm: ConflictAlgorithm.ignore)
        .then((value) {
      Fluttertoast.showToast(
          msg: "Added to bookmarks",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 12.0);
    });
  }

  void _onTap() async {
    setState(
      () {
        rect = RectGetter.getRectFromKey(rectGetterKey);
        Globals.globalInd = 0;
        Globals.globalIndex = 0;
      },
    );
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
    Navigator.of(context)
        .push(FadeRouteBuilder(
            page: SurahWordTajweed.setChap(widget.chapnum, widget.urduname,
                widget.engName, widget.surahs)))
        .then((_) => setState(() => rect = null));
  }

  @override
  void initState() {
    // TODO: implement didChangeDependencies
    super.initState();
    userStateMap = BlocProvider.of<UserStateCubit>(context).checkUserState();
    ayatScrollController = ItemScrollController();
    surahId = int.parse(widget.chapnum);
    suraInt = int.parse(widget.chapnum);
    itemPosLis = ItemPositionsListener.create();
    getWordsBookmarks();
    itemPosLis!.itemPositions.addListener(() {
      if (AudioConstants.viewinglist.isNotEmpty &&
          itemPosLis!.itemPositions.value.isNotEmpty) {
        pos = itemPosLis!.itemPositions.value.first.index;

        if (int.parse(AudioConstants.viewinglist[pos]['verse_key']
                .toString()
                .split(':')
                .first) !=
            surahId) {
          surahId = int.parse(AudioConstants.viewinglist[pos]['verse_key']
              .toString()
              .split(':')
              .first);
        }

        setState(() {});
      }
    });

    getSurahTajweedData(widget.chapnum);
    Future.delayed(Duration(seconds: 2), () {
      if (ayatScrollController!.isAttached &&
          widget.moveScroll != null &&
          widget.moveScroll) {
        ayatScrollController!.scrollTo(
            index: AudioConstants.viewinglist
                .indexWhere((element) => element['verse_key'] == widget.verse),
            duration: Duration(seconds: 1));
      } else if (widget.moveScroll != null && widget.moveScroll) {
        Future.delayed(Duration(seconds: 1), () {
          if (ayatScrollController!.isAttached &&
              widget.moveScroll != null &&
              widget.moveScroll) {
            ayatScrollController!.scrollTo(
                index: AudioConstants.viewinglist.indexWhere(
                    (element) => element['verse_key'] == widget.verse),
                duration: Duration(seconds: 1));
          }
        });
      }
    });
  }

  int ind = 1;
  int len = 1;
  bool visible = false;
  String? surahName;

  Future getSurahTajweedData(var chapnum) async {
    AudioConstants.viewinglist.clear();
    print(chapnum);
    print(currentNumberOfPage);
    List<Map> qqq = await AudioConstants.database!.rawQuery(
        'SELECT * FROM "Surah" WHERE surahId=? and page=?',
        [chapnum.toString(), currentNumberOfPage.toString()]);
    if (qqq.isNotEmpty) {
      print('~~~~~~~~~~~~~~~~~~ first page not empty');
      Map<String, dynamic> responseBody =
          jsonDecode(qqq.first['value'].toString());
      AudioConstants.viewinglist.addAll(responseBody['verses']);
      List aaa = responseBody['verses'];

      numberOfPages = responseBody['pagination']['total_pages'];
      if (numberOfPages != 1) {
        currentNumberOfPage++;
      }
    } else {
      print('~~~~~~~~~~~~~~~~~~ first page empty');

      String url = 'https://api.quran.com/api/v4/verses/by_chapter/' +
          chapnum.toString() +
          '?language=malay&words=true&translations=39&word_fields=text_uthmani,text_indopak,text_imlaei,code_v1&page=1&per_page=50';
      var result = await http
          .get(Uri.parse(url), headers: {"Accept": "application/json"});

      Map<String, dynamic> responseBody = jsonDecode(result.body);
      List aaa = responseBody['verses'];
      AudioConstants.viewinglist.addAll(aaa);
      numberOfPages = responseBody['pagination']['total_pages'];
      await AudioConstants.database!.insert('Surah',
          {'surahId': suraInt.toString(), 'value': result.body, 'page': '1'});

      await AudioConstants.database!.insert(
          'recent',
          {
            'surahId':
                int.parse(aaa.first['verse_key'].toString().split(':').first),
            'surahName': widget.engName,
            'page': aaa.first['page_number'],
            'juz': aaa.first['juz_number']
          },
          conflictAlgorithm: ConflictAlgorithm.ignore);
      if (responseBody['pagination']['total_pages'] != 1) {
        print('+++++++++++++++++++++++');
        currentNumberOfPage++;
      }

      // box.put(chapnum.toString(), AudioConstants.viewinglist);

      setState(() {
        loading = false;
      });
    }

    AudioConstants.viewinglist.forEach((element) async {
      List<Map> qqq = await AudioConstants.database!.rawQuery(
          'SELECT * FROM "Ayah" WHERE ayahId=? and qari=?',
          [element['verse_key'].toString(), Qari.qari_id.toString()]);
      if (qqq.isEmpty) {
        print('~~~~~~~${element}');
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
              // aaa['audio_files'][0]['url'],
              'qari': Qari.qari_id.toString()
            },
            conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    });

    setState(() {
      loading = false;
    });

    try {} catch (e) {
      print('-----$e');
      return e;
    }

    if (loading) {
      setState(() {
        loading = false;
      });
    }
  }

  getMoreJuzukTajweedData() async {
    setState(() {
      showMore = true;
    });
    print('moooooooore');
    print(currentNumberOfPage);
    if (currentNumberOfPage != 1) {
      List<Map> www = await AudioConstants.database!.rawQuery(
          'SELECT * FROM "Surah" WHERE surahId=? and page=?',
          [(suraInt + more).toString(), currentNumberOfPage.toString()]);

      if (www.isNotEmpty) {
        print('not not not empty');
        Map<String, dynamic> responseBody =
            jsonDecode(www.first['value'].toString());
        AudioConstants.viewinglist.addAll(responseBody['verses']);
        numberOfPages = responseBody['pagination']['total_pages'];
        if (numberOfPages != 1 && numberOfPages > currentNumberOfPage) {
          currentNumberOfPage++;
        } else {
          currentNumberOfPage = 1;
        }
      } else {
        print('-------- empty');
        String url = 'https://api.quran.com/api/v4/verses/by_chapter/' +
            (suraInt + more).toString() +
            '?language=malay&words=true&translations=39&word_fields=text_uthmani,text_indopak,text_imlaei,code_v1&page=${currentNumberOfPage.toString()}&per_page=50';
        var result = await http
            .get(Uri.parse(url), headers: {"Accept": "application/json"});

        Map<String, dynamic> responseBody = jsonDecode(result.body);

        AudioConstants.viewinglist.addAll(responseBody['verses']);
        numberOfPages = responseBody['pagination']['total_pages'];
        await AudioConstants.database!.insert('Surah', {
          'surahId': (suraInt + more).toString(),
          'value': result.body,
          'page': currentNumberOfPage.toString()
        });

        if (numberOfPages != 1 && numberOfPages > currentNumberOfPage) {
          currentNumberOfPage++;
        } else {
          currentNumberOfPage = 1;
        }

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
                // aaa['audio_files'][0]['url'],
                'qari': Qari.qari_id.toString()
              },
              conflictAlgorithm: ConflictAlgorithm.ignore);
        }
      });
    } else {
      more++;
      List<Map> www = await AudioConstants.database!.rawQuery(
          'SELECT * FROM "Surah" WHERE surahId=? and page=?',
          [(suraInt + more).toString(), currentNumberOfPage.toString()]);
      if (www.isNotEmpty) {
        Map<String, dynamic> responseBody =
            jsonDecode(www.first['value'].toString());
        AudioConstants.viewinglist.addAll(responseBody['verses']);
        numberOfPages = responseBody['pagination']['total_pages'];
        if (numberOfPages != 1 && numberOfPages > currentNumberOfPage) {
          currentNumberOfPage++;
        } else {
          currentNumberOfPage = 1;
        }
      } else {
        String url = 'https://api.quran.com/api/v4/verses/by_chapter/' +
            (suraInt + more).toString() +
            '?language=malay&words=true&translations=39&word_fields=text_uthmani,text_indopak,text_imlaei,code_v1&page=${currentNumberOfPage.toString()}&per_page=50';
        var result = await http
            .get(Uri.parse(url), headers: {"Accept": "application/json"});

        Map<String, dynamic> responseBody = jsonDecode(result.body);

        AudioConstants.viewinglist.addAll(responseBody['verses']);
        numberOfPages = responseBody['pagination']['total_pages'];
        await AudioConstants.database!.insert('Surah', {
          'surahId': (suraInt + more).toString(),
          'value': result.body,
          'page': currentNumberOfPage.toString()
        });

        if (numberOfPages != 1 && numberOfPages > currentNumberOfPage) {
          currentNumberOfPage++;
        } else {
          currentNumberOfPage = 1;
        }

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
                // aaa['audio_files'][0]['url'],
                'qari': Qari.qari_id.toString()
              },
              conflictAlgorithm: ConflictAlgorithm.ignore);
        }
      });

      try {} catch (e) {
        setState(() {
          showMore = false;
        });

        print(e);
        more--;
        return e;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    theme = Provider.of<ThemeNotifier>(context).appTheme;

    if (mounted && Globals.autoScroll) {
      if (ayatScrollController!.isAttached &&
          AudioConstants.viewinglist.isNotEmpty &&
          Globals.globalInd != 0) {
        ayatScrollController!
            .scrollTo(index: Globals.globalInd, duration: Duration(seconds: 1));
      }
    }
    return SafeArea(
      top: false,
      child: Stack(
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
                      Column(
                        children: [
                          Container(
                            padding: EdgeInsets.only(top: 20),
                            height: 139,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                              image: AssetImage(
                                  "assets/theme/${theme ?? "default"}/appbar.png"),
                              fit: BoxFit.fill,
                            )),
                            child: Column(
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 10, 10, 0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        child: IconButton(
                                          onPressed: () async {
                                            AudioConstants.audioPlayer.stop();
                                            AudioConstants.duration =
                                                Duration();
                                            AudioConstants.position =
                                                Duration();
                                            AudioConstants.playing = false;
                                            Globals.globalIndWord = 0;
                                            Navigator.push(
                                                context,
                                                PageTransition(
                                                    type: PageTransitionType
                                                        .leftToRightWithFade,
                                                    child: Surah()));
                                          },
                                          icon: const Icon(
                                            Icons.arrow_back_ios,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              qariVisible = !qariVisible;
                                              if (visible) {
                                                visible = !visible;
                                              }
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
                                                if (visible) {
                                                  visible = !visible;
                                                }
                                              });
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: 80,
                                                  child: Text(
                                                    Qari.qari_name.toString(),
                                                    textAlign: TextAlign.center,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.visible,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 10),
                                                  ),
                                                ),
                                                RotatedBox(
                                                  quarterTurns:
                                                      qariVisible ? 0 : 3,
                                                  child: Image(
                                                    image: AssetImage(
                                                        ImageResource
                                                            .drop_down),
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
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              visible = !visible;
                                              if (qariVisible) {
                                                qariVisible = !qariVisible;
                                              }
                                            });
                                          },
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                height: 60,
                                                child: Text(
                                                  surahId != 0
                                                      ? Globals.surahUrdu[
                                                              surahId - 1]
                                                          .toString()
                                                      : widget.urduname
                                                          .toString(),
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 80,
                                                    height: 1,
                                                    color: Colors.white,
                                                    fontFamily: 'Quran',
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    surahId != 0 &&
                                                            widget.surahs !=
                                                                null &&
                                                            widget.surahs
                                                                .isNotEmpty
                                                        ? widget.surahs[
                                                                surahId - 1]
                                                            ['name']['simple']
                                                        : widget.engName
                                                            .toString(),
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 3,
                                                  ),
                                                  RotatedBox(
                                                    quarterTurns:
                                                        visible ? 0 : 3,
                                                    child: const Image(
                                                      image: AssetImage(
                                                          ImageResource
                                                              .drop_down),
                                                      height: 18,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          RectGetter(
                                            key: rectGetterKey,
                                            child: GestureDetector(
                                              onTap: _onTap,
                                              child: Container(
                                                width: 100,
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
                                          SizedBox(height: 10),
                                          GestureDetector(
                                            onTap: () {
                                              _onTapBookmark(
                                                  widget.surahs[int.parse(AudioConstants
                                                              .viewinglist[pos]
                                                                  ['verse_key']
                                                              .toString()
                                                              .split(':')
                                                              .first) -
                                                          1]['name']['simple']
                                                      .toString(),
                                                  int.parse(AudioConstants
                                                      .viewinglist[pos]
                                                          ['verse_key']
                                                      .toString()
                                                      .split(':')
                                                      .first),
                                                  AudioConstants.viewinglist[pos]
                                                      ['page_number'],
                                                  AudioConstants.viewinglist[pos]
                                                      ['juz_number']);
                                            },
                                            child: Container(
                                              width: 100,
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
                                                  "Add To Bookmark",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: visible,
                            child: Container(
                                color: Colors.black,
                                padding:
                                    const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                height: 250,
                                width: MediaQuery.of(context).size.width,
                                child: ListView.builder(
                                  itemCount: widget.surahs.length,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (context, index) {
                                    return surahCard2(widget.surahs[index],
                                        context, Globals.surahUrdu[index]);
                                  },
                                )),
                          ),
                          Visibility(
                              visible: qariVisible,
                              child: Container(
                                color: Colors.black,
                                padding:
                                    const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    const Text(
                                      'Pilih Qari / Pembaca',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15),
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        qariCards('Abdul Basit', context,
                                            ImageResource.abdulbasit),
                                        qariCards('Mishary Rashid Alfasay',
                                            context, ImageResource.mishari),
                                        qariCards('Abu Bakr Al-Shatri', context,
                                            ImageResource.shatri),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        qariCards('Hani Ar Rifai', context,
                                            ImageResource.refai),
                                        qariCards('Abdul Rahman Al-Sudais',
                                            context, ImageResource.sudais),
                                        qariCards('Siddiq El-Minshawi', context,
                                            ImageResource.minshawi),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                        ],
                      ),
                      Expanded(
                          child: NotificationListener<ScrollNotification>(
                              onNotification: (ScrollNotification scrollNotif) {
                                if (scrollNotif.metrics.maxScrollExtent ==
                                    scrollNotif.metrics.pixels) {
                                  if (!showingmore) {
                                    showingmore = true;
                                    String latestSurah = AudioConstants
                                        .viewinglist.last['verse_key']
                                        .toString()
                                        .split(':')
                                        .first;
                                    getMoreJuzukTajweedData();

                                    Future.delayed(Duration(seconds: 2), () {
                                      showingmore = false;
                                    });
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
                                            surah_tajweed_card(
                                                index,
                                                AudioConstants.viewinglist,
                                                context,
                                                widget.chapnum,
                                                wordsBookmarksList, () {
                                              setState(() {});
                                            }, widget.engName),
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
                                          return surah_tajweed_card(
                                              index,
                                              AudioConstants.viewinglist,
                                              context,
                                              widget.chapnum,
                                              wordsBookmarksList, () {
                                            setState(() {});
                                          }, widget.engName);
                                        }
                                      },
                                    ))),
                      Container(
                        height: 10,
                        color: Colors.black,
                      ),
                      JuzukAudio(onTapBack: () {
                        // _onSelected(Globals.globalInd, Globals.color1);
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
                        // _onSelected(Globals.globalInd, Globals.color1);
                        if (AudioConstants.audioPlayer.playerState.playing) {
                          AudioConstants.audioPlayer.pause();
                          AudioConstants.paused = true;
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
                            print('not emptyyyy ~~~~~~~~~~');
                            Map<String, dynamic> responseBody =
                                jsonDecode(www.first['value'].toString());
                            String url = responseBody['verse']['audio']['url']
                                .toString();

                            print(' url >>>>>>> ${url}');
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
                                print(
                                    '~!~!~!~!~! ${AudioConstants.viewinglist[Globals.globalInd]['verse_key']}');
                                model.getAudio(
                                    AudioConstants
                                        .viewinglist[Globals.globalInd]
                                            ['verse_key']
                                        .toString(),
                                    AudioConstants.viewinglist);
                                AudioConstants.paused = false;
                              } else {}
                            } else {}
                          } else {
                            AudioConstants.audioPlayer.play();
                          }
                        }
                      }),
                      SizedBox(height: 60)
                      // SurahAudio(
                      //   // onTapBack: () {
                      //   //   if (Globals.globalInd >= 1) {
                      //   //     if (AudioConstants
                      //   //             .audioPlayer.playerState.processingState !=
                      //   //         ProcessingState.idle) {
                      //   //       model.playPrev(box, AudioConstants.viewinglist, widget.chapnum);
                      //   //     }
                      //   //   }
                      //   // },
                      //   // onTapNext: () {
                      //   //   if (AudioConstants
                      //   //           .audioPlayer.playerState.processingState !=
                      //   //       ProcessingState.idle) {
                      //   //     model.playNext(box, AudioConstants.viewinglist, widget.chapnum);
                      //   //   }
                      //   // },
                      //   // onTapPlay: () {
                      //   //   if (AudioConstants.playing) {
                      //   //     AudioConstants.audioPlayer.pause();
                      //   //     AudioConstants.paused = true;
                      //   //   } else if (AudioConstants
                      //   //           .audioPlayer.playerState.processingState ==
                      //   //       ProcessingState.idle) {
                      //   //     model.onSet(Globals.globalInd, Globals.color1);
                      //   //     List aaa = box.get(widget.chapnum.toString() + 'urls');
                      //   //     if (aaa != null) {
                      //   //       String verse = AudioConstants.viewinglist[Globals.globalInd]
                      //   //               ['verse_key']
                      //   //           .toString();
                      //   //       String url = aaa.firstWhere((element) =>
                      //   //           element['verse_key'] == verse)['url'];
                      //   //       model.getAudio(url, box, widget.chapnum);
                      //   //       AudioConstants.paused = false;
                      //   //     }
                      //   //   } else {
                      //   //     AudioConstants.audioPlayer.play();
                      //   //   }
                      //   // },
                      // ),
                      ,
                      SizedBox(height: 30)
                    ],
                  );
                }),
              ),
            ),
          ),
          _ripple()
        ],
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
          color: getColor(theme, isButton: true),
        ),
      ),
    );
  }

  Widget surahCard2(var data, context, var urduName) {
    return GestureDetector(
      onTap: () {
        Globals.globalInd = 0;
        Globals.globalIndex = 0;
        print('~~~ data >>>> ${data}');
        AudioConstants.paused = false;
        AudioConstants.duration = Duration();
        AudioConstants.position = Duration();
        AudioConstants.playing = false;
        AudioConstants.playingNext = false;
        AudioConstants.audioPlayer.stop();
        JuzukAudioRep().onSet1(Globals.globalInd, Globals.color1);

        visible = false;
        setState(() {});

        SurahTajweed.set(data['id'].toString(), urduName,
            data['name']['simple'].trim(), widget.surahs, null, null);
        getSurahTajweedData(data['id'].toString()).then((value) async {
          List<Map> www = await AudioConstants.database!
              .rawQuery('SELECT * FROM "Ayah" WHERE ayahId=? and qari=?', [
            AudioConstants.viewinglist[Globals.globalInd]['verse_key']
                .toString(),
            Qari.qari_id.toString()
          ]);
          if (www.isNotEmpty) {
            Map<String, dynamic> responseBody =
                jsonDecode(www.first['value'].toString());
            String url = responseBody['verse']['audio']['url'].toString();
            Globals.aazz = responseBody['verse']['audio']['segments'];
            Globals.globalIndWord = 0;
            Globals.playingUrl = url;
            JuzukAudioRep().getAudio(
                AudioConstants.viewinglist[Globals.globalInd]['verse_key']
                    .toString(),
                AudioConstants.viewinglist);
          } else {}
        });
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 30,
                  child: Text(
                    data['id'].toString(),
                    style:
                        const TextStyle(color: Color(0xff929292), fontSize: 12),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            data['name']['simple'].trim(),
                            style: TextStyle(
                              color: getColor(theme),
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Text(
                          data['revelation']['place'] +
                              '. ' +
                              data['ayat'].toString() +
                              'Ayat',
                          style: const TextStyle(
                              color: Color(0xff929292), fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: Text(
                    urduName,
                    style: TextStyle(
                      color: getColor(theme),
                      fontSize: 50,
                      fontFamily: 'Quran',
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width - 50,
              height: 0.5,
              decoration: const BoxDecoration(
                color: Color(0xff929292),
              ),
            ),
          ],
        ),
      ),
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
}
