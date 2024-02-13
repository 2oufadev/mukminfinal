import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:mukim_app/business_logic/cubit/subscription/userstate_cubit.dart';
import 'package:mukim_app/data/models/bookmarks_model.dart';
import 'package:mukim_app/data/models/word_bookmark_model.dart';
import 'package:mukim_app/presentation/screens/Surah/surah.dart';
import 'package:mukim_app/presentation/widgets/bookmarks_card.dart';
import 'package:mukim_app/presentation/widgets/transition.dart';
import 'package:mukim_app/resources/constants.dart';
import 'package:mukim_app/resources/global.dart';
import 'package:mukim_app/utils/app_localization.dart';
import 'package:mukim_app/utils/componants.dart';
import 'package:mukim_app/providers/theme.dart';
import 'package:provider/provider.dart';
import 'package:rect_getter/rect_getter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:mukim_app/utils/get_theme_color.dart';
import 'Juzuk/juzuk.dart';
import 'package:just_audio/just_audio.dart';

class BookMarks extends StatefulWidget {
  final List? surahs;
  final List? surahsUrdu;
  const BookMarks({Key? key, this.surahs, this.surahsUrdu}) : super(key: key);

  @override
  _BookMarksState createState() => _BookMarksState();
}

class _BookMarksState extends State<BookMarks> {
  final Duration animationDuration = Duration(milliseconds: 300);
  final Duration delay = Duration(milliseconds: 300);
  var rectGetterKeyJuzuk = RectGetter.createGlobalKey();
  var rectGetterKeySurah = RectGetter.createGlobalKey();
  MainAxisAlignment deleteAlignment = MainAxisAlignment.start;
  var rectGetterKeys = RectGetter.createGlobalKey();
  bool loadingRecent = true;
  bool loadingBookmarks = true;
  bool loadingWordsBookmarks = true;
  Rect? rect;
  List surahs = [];
  List<BookmarksModel> recentList = [];
  List<BookmarksModel> bookmarksList = [];
  List<WordsBookmarksModel> wordsBookmarksList = [];

  Map<String, dynamic>? userStateMap;

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

      setState(() {
        loadingWordsBookmarks = false;
      });
    } catch (e) {
      setState(() {
        loadingWordsBookmarks = false;
      });
      print('--------$e');
    }
  }

  getRecent() async {
    try {
      List<Map> qqq =
          await AudioConstants.database!.rawQuery('SELECT * FROM "recent"');
      if (qqq.isNotEmpty) {
        qqq.forEach((element) {
          recentList.add(BookmarksModel(element['surahName'],
              element['surahId'], element['page'], element['juz']));
          print(element);
        });
      }
      setState(() {
        loadingRecent = false;
      });
    } catch (e) {
      setState(() {
        loadingRecent = false;
      });
    }
  }

  deleteFromRecentDatabase(int id) async {
    try {
      await AudioConstants.database!
          .delete('recent', where: 'surahId = ?', whereArgs: [id]);
    } catch (e) {
      print(e);
    }
  }

  deleteFromWordsBookmarksDatabase(String verseKey, int position) async {
    try {
      await AudioConstants.database!.delete('wordsbookmarks',
          where: 'verse_key = ? AND position = ?',
          whereArgs: [verseKey, position]);
    } catch (e) {
      print(e);
    }
  }

  deleteFromBookmarksDatabase(int id) async {
    try {
      await AudioConstants.database!
          .delete('bookmarks', where: 'surahId = ?', whereArgs: [id]);
    } catch (e) {
      print(e);
    }
  }

  getBookmarks() async {
    try {
      List<Map> qqq =
          await AudioConstants.database!.rawQuery('SELECT * FROM "bookmarks"');
      if (qqq.isNotEmpty) {
        qqq.forEach((element) {
          bookmarksList.add(BookmarksModel(element['surahName'],
              element['surahId'], element['page'], element['juz']));
        });
      }
      setState(() {
        loadingBookmarks = false;
      });
    } catch (e) {
      setState(() {
        loadingBookmarks = false;
      });
      print('--------$e');
    }
  }

  _onTapSurah() async {
    setState(
      () {
        rect = RectGetter.getRectFromKey(rectGetterKeySurah);
        Globals.globalInd = 0;
        Globals.globalIndex = 0;
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() =>
          rect = rect!.inflate(1.3 * MediaQuery.of(context).size.longestSide));
      Future.delayed(animationDuration + delay, _goToNextPage('Juzuk'));
      Globals.globalInd = 0;
      Globals.globalIndex = 0;
    });
  }

  _onTapJuzuk() async {
    setState(
      () {
        rect = RectGetter.getRectFromKey(rectGetterKeyJuzuk);
        Globals.globalInd = 0;
        Globals.globalIndex = 0;
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() =>
          rect = rect!.inflate(1.3 * MediaQuery.of(context).size.longestSide));
      Future.delayed(animationDuration + delay, _goToNextPage('Surah'));
      Globals.globalInd = 0;
      Globals.globalIndex = 0;
    });
  }

  _goToNextPage(String title) {
    if (title == 'Surah') {
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
    getRecent();
    getBookmarks();
    getWordsBookmarks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    String? theme = Provider.of<ThemeNotifier>(context).appTheme;
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
                  body: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: Column(children: [
                        Container(
                          height: width * 0.330,
                          child: Stack(
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
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  height: width * 0.2,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            RectGetter(
                                              key: rectGetterKeySurah,
                                              child: GestureDetector(
                                                onTap: _onTapSurah,
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
                                                      "Surah",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                                child: Text(
                                              "Bookmark",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                color: Colors.white,
                                              ),
                                            )),
                                            RectGetter(
                                              key: rectGetterKeyJuzuk,
                                              child: GestureDetector(
                                                onTap: _onTapJuzuk,
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
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.black45,
                          ),
                          height: 35,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                width: MediaQuery.of(context).size.width - 84,
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .translate('recent_pages'),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.2,
                          child: ListView.builder(
                            padding: EdgeInsets.only(
                              bottom: 15,
                            ),
                            itemCount: recentList.length,
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) {
                              return Dismissible(
                                key: ObjectKey(recentList[index]),
                                onUpdate: (details) {
                                  if (details.direction ==
                                      DismissDirection.startToEnd) {
                                    print('left to right');
                                    setState(() {
                                      deleteAlignment = MainAxisAlignment.start;
                                    });
                                  } else if (details.direction ==
                                      DismissDirection.endToStart) {
                                    setState(() {
                                      deleteAlignment = MainAxisAlignment.end;
                                    });
                                  }
                                },
                                onDismissed: (direction) {
                                  deleteFromRecentDatabase(
                                      recentList[index].surahId);
                                  setState(() {
                                    recentList.removeAt(index);
                                  });
                                },
                                background: Container(
                                    child: Row(
                                      mainAxisAlignment: deleteAlignment,
                                      children: [
                                        SizedBox(width: 15),
                                        Text('Delete from bookmarks?',
                                            style:
                                                TextStyle(color: Colors.white)),
                                        SizedBox(width: 15),
                                      ],
                                    ),
                                    color: Colors.red),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      right: 15, left: 15),
                                  child: BookmarksCard(
                                    page: recentList[index].page,
                                    juz: recentList[index].juz,
                                    surahName: recentList[index].surahName,
                                    bookmark: false,
                                    surahId: recentList[index].surahId,
                                    surahs: widget.surahs!,
                                    surahUrdu: widget.surahsUrdu![
                                        recentList[index].surahId - 1],
                                    moveScroll: false,
                                    verse: '',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.black45,
                          ),
                          height: 35,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                width: MediaQuery.of(context).size.width - 84,
                                child: Text(
                                  'Perkataan Bookmark',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.2,
                          child: ListView.builder(
                            padding: EdgeInsets.only(
                              bottom: 15,
                            ),
                            itemCount: wordsBookmarksList.length,
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) {
                              return Dismissible(
                                key: ObjectKey(wordsBookmarksList[index]),
                                onUpdate: (details) {
                                  if (details.direction ==
                                      DismissDirection.startToEnd) {
                                    print('left to right');
                                    setState(() {
                                      deleteAlignment = MainAxisAlignment.start;
                                    });
                                  } else if (details.direction ==
                                      DismissDirection.endToStart) {
                                    setState(() {
                                      deleteAlignment = MainAxisAlignment.end;
                                    });
                                  }
                                },
                                onDismissed: (direction) {
                                  deleteFromWordsBookmarksDatabase(
                                      wordsBookmarksList[index].verseKey,
                                      wordsBookmarksList[index].position);

                                  setState(() {
                                    wordsBookmarksList.removeAt(index);
                                  });
                                },
                                background: Container(
                                    child: Row(
                                      mainAxisAlignment: deleteAlignment,
                                      children: [
                                        SizedBox(width: 15),
                                        Text('Delete from bookmarks?',
                                            style:
                                                TextStyle(color: Colors.white)),
                                        SizedBox(width: 15),
                                      ],
                                    ),
                                    color: Colors.red),
                                child: Padding(
                                    padding: const EdgeInsets.only(
                                        right: 15, left: 15),
                                    child: BookmarksCard(
                                      page: wordsBookmarksList[index].page,
                                      juz: wordsBookmarksList[index].juz,
                                      surahName:
                                          wordsBookmarksList[index].surahName,
                                      bookmark: true,
                                      surahId:
                                          wordsBookmarksList[index].surahId,
                                      surahs: widget.surahs!,
                                      surahUrdu: widget.surahsUrdu![
                                          wordsBookmarksList[index].surahId -
                                              1],
                                      moveScroll: true,
                                      verse: wordsBookmarksList[index].verseKey,
                                    )),
                              );
                            },
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          decoration: const BoxDecoration(
                            color: Colors.black45,
                          ),
                          height: 35,
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            AppLocalizations.of(context)!
                                .translate('page_bookmarks'),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.25,
                          width: MediaQuery.of(context).size.width,
                          child: ListView.builder(
                            padding: EdgeInsets.only(
                                bottom: 45, right: 15, left: 15),
                            itemCount: bookmarksList.length,
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) {
                              return Dismissible(
                                key: ObjectKey(bookmarksList[index]),
                                onDismissed: (direction) {
                                  deleteFromBookmarksDatabase(
                                      bookmarksList[index].surahId);
                                  setState(() {
                                    bookmarksList.removeAt(index);
                                  });
                                },
                                onUpdate: (details) {
                                  print(details.direction);
                                  if (details.direction ==
                                      DismissDirection.startToEnd) {
                                    print('left to right');
                                    setState(() {
                                      deleteAlignment = MainAxisAlignment.start;
                                    });
                                  } else if (details.direction ==
                                      DismissDirection.endToStart) {
                                    setState(() {
                                      deleteAlignment = MainAxisAlignment.end;
                                    });
                                  }
                                },
                                background: Container(
                                    child: Row(
                                      mainAxisAlignment: deleteAlignment,
                                      children: [
                                        SizedBox(width: 15),
                                        Text('Delete from bookmarks?',
                                            style:
                                                TextStyle(color: Colors.white)),
                                        SizedBox(width: 15),
                                      ],
                                    ),
                                    color: Colors.red),
                                child: BookmarksCard(
                                    page: bookmarksList[index].page,
                                    juz: bookmarksList[index].juz,
                                    surahName: bookmarksList[index].surahName,
                                    bookmark: true,
                                    surahId: bookmarksList[index].surahId,
                                    surahs: widget.surahs!,
                                    surahUrdu: widget.surahsUrdu![
                                        bookmarksList[index].surahId - 1],
                                    moveScroll: false,
                                    verse: ''),
                              );
                            },
                          ),
                        )
                      ])),
                ))
          ],
        );
      }),
    );
  }
}
