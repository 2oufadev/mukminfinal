import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mukim_app/data/models/word_bookmark_model.dart';
import 'package:mukim_app/providers/theme.dart';
import 'package:mukim_app/resources/constants.dart';
import 'package:mukim_app/resources/global.dart';
import 'package:provider/provider.dart';
import 'package:mukim_app/utils/get_theme_color.dart';
import 'package:sqflite/sqflite.dart';

String geteng(var snap, var index) {
  var str = "";
  for (int i = 0; i < snap[index]['words'].length; i++) {
    str = str +
        " " +
        snap[index]['words'][i]['transliteration']['text']
            .toString()
            .replaceAll('null', '');
  }
  return str.toString();
}

String getengtrans(var snap, var index) {
  var str = "";
  for (int i = 0; i < snap[index]['words'].length; i++) {
    str = str +
        " " +
        snap[index]['words'][i]['translation']['text']
            .toString()
            .replaceAll('null', '');
  }
  return str.toString();
}

// the function that is giving the arabic translation
TextSpan getArabic(
    var snap,
    var index,
    context,
    List<WordsBookmarksModel> wordsBookmarksList,
    Function setState,
    String surahName) {
  String theme = Provider.of<ThemeNotifier>(context).appTheme;

  List<TextSpan> spanList = [];
  for (int i = 0; snap.isNotEmpty && i < snap[index]['words'].length; i++) {
    if (snap[index]['words'][i]['char_type_name'] == 'end') {
      spanList.add(TextSpan(
        text: ' ' +
            "\u{FD3F}" +
            snap[index]['words'][i]['text_uthmani']
                .toString()
                .replaceAll('null', '') +
            "\u{FD3E}",
        style: TextStyle(
          fontSize: 20,
          fontFamily: 'KFGQPC',
          color: Colors.white,
        ),
      ));
    } else {
      spanList.add(TextSpan(
        recognizer: LongPressGestureRecognizer()
          ..onLongPress = (() async {
            if (wordsBookmarksList.indexWhere((element) =>
                    element.verseKey == snap[index]['verse_key'] &&
                    element.position == snap[index]['words'][i]['position']) !=
                -1) {
              try {
                await AudioConstants.database!.delete('wordsbookmarks',
                    where: 'verse_key = ? AND position = ?',
                    whereArgs: [
                      snap[index]['verse_key'],
                      snap[index]['words'][i]['position']
                    ]).then((value) {
                  wordsBookmarksList.removeWhere((element) =>
                      element.verseKey == snap[index]['verse_key'] &&
                      element.position == snap[index]['words'][i]['position']);
                  setState();
                  Fluttertoast.showToast(
                      msg: "Removed from bookmarks",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.white,
                      textColor: Colors.black,
                      fontSize: 12.0);
                });
              } catch (e) {
                print(e);
              }
            } else {
              print(snap[index]);
              await AudioConstants.database!
                  .insert(
                      'wordsbookmarks',
                      {
                        'verse_key': snap[index]['verse_key'],
                        'position': snap[index]['words'][i]['position'],
                        'surahName': surahName,
                        'surahId': snap[index]['verse_key'].split(':').first,
                        'page': snap[index]['page_number'],
                        'juz': snap[index]['juz_number']
                      },
                      conflictAlgorithm: ConflictAlgorithm.ignore)
                  .then((value) {
                wordsBookmarksList.add(WordsBookmarksModel(
                    snap[index]['verse_key'],
                    snap[index]['words'][i]['position'],
                    surahName,
                    int.parse(snap[index]['verse_key'].split(':').first),
                    snap[index]['page_number'],
                    snap[index]['juz_number']));
                setState();
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
          }),
        text: " " +
            snap[index]['words'][i]['text_uthmani']
                .toString()
                .replaceAll('null', ''),
        style: TextStyle(
          fontSize: 30,
          fontFamily: 'KFGQPC2',
          backgroundColor: wordsBookmarksList.indexWhere((element) =>
                      element.verseKey == snap[index]['verse_key'] &&
                      element.position ==
                          snap[index]['words'][i]['position']) !=
                  -1
              ? Colors.green
              : Colors.transparent,
          color: Globals.globalInd == index && i == Globals.globalIndWord
              ? getColor(theme)
              : Colors.white,
        ),
      ));
    }
  }
  TextSpan aaa = TextSpan(
    children: spanList,
  );

  return aaa;
}
