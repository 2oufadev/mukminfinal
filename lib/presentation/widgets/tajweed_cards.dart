import 'package:flutter/material.dart';
import 'package:mukim_app/data/models/word_bookmark_model.dart';
import 'package:mukim_app/presentation/screens/Juzuk/juzuk_audio_rep.dart';
import 'package:mukim_app/providers/theme.dart';
import 'package:mukim_app/utils/get_theme_color.dart';

import 'converters.dart';

import 'package:provider/provider.dart';

Widget surah_tajweed_card(
    var globalIndex,
    var data,
    context,
    var chapnum,
    List<WordsBookmarksModel> wordsBookmarksList,
    Function setState,
    String surahName) {
  var bgcolor;
  if (globalIndex % 2 == 0) {
    bgcolor = const Color(0xff3a343d);
  } else {
    bgcolor = Colors.black38;
  }

  return Container(
    color: bgcolor,
    padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
    child: Column(
      children: [
        Row(
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(5),
                        topRight: Radius.circular(5)),
                    color: Color(0xff524D9F),
                  ),
                  width: 34,
                  height: 20,
                  child: Center(
                    child: Text(
                      data[globalIndex]['verse_key'].toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Consumer<JuzukAudioRep>(builder: (context, model, child) {
                  return InkWell(
                    onTap: () async {
                      model.playSelected(
                        globalIndex,
                        data,
                      );
                    },
                    child: const Icon(
                      Icons.play_circle_outline_outlined,
                      size: 30,
                      color: Colors.white,
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(
              width: 21,
            ),
            Expanded(
              flex: 1,
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child:

                          // the arabic verse we have to change

                          Consumer<JuzukAudioRep>(
                              builder: (context, model, child) {
                        return RichText(
                          text: getArabic(data, globalIndex, context,
                              wordsBookmarksList, setState, surahName),
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                        );
                      }),

                      //
                    ),
                    SizedBox(height: 5),
                    Consumer<ThemeNotifier>(builder: (context, value, child) {
                      return Text(
                        geteng(data, globalIndex).trim(),
                        style: TextStyle(
                          color: getColor(value.appTheme),
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.left,
                      );
                    }),
                    SizedBox(height: 5),
                    Text(
                      data[globalIndex]['translations'][0]['text'].trim(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    ),
  );
}

Widget juzuk_tajweed_card(
    var globalIndex,
    var data,
    context,
    var juzNum,
    List<WordsBookmarksModel> wordsBookmarksList,
    Function setState,
    String surahName) {
  var bgcolor;

  if (globalIndex % 2 == 0) {
    bgcolor = const Color(0xff3a343d);
  } else {
    bgcolor = Colors.black38;
  }
  return Consumer<ThemeNotifier>(
    builder: (context, value, child) {
      return Container(
        color: bgcolor,
        padding: const EdgeInsets.fromLTRB(0, 10, 20, 10),
        child: Column(
          children: [
            Row(
              children: [
                Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(5),
                            topRight: Radius.circular(5)),
                        color: Color(0xff524D9F),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 5),
                      height: 20,
                      child: Center(
                        child: Text(
                          data[globalIndex]['verse_key'].toString(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Consumer<JuzukAudioRep>(builder: (context, model, child) {
                      return InkWell(
                        onTap: () async {
                          model.playSelected(
                            globalIndex,
                            data,
                          );
                        },
                        child: Icon(
                          Icons.play_circle_outline_outlined,
                          size: 30,
                          color: Colors.white,
                        ),
                      );
                    })
                  ],
                ),
                const SizedBox(
                  width: 35,
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                          alignment: Alignment.centerRight,
                          child: Consumer<JuzukAudioRep>(
                              builder: (context, model, child) {
                            return RichText(
                              text: getArabic(data, globalIndex, context,
                                  wordsBookmarksList, setState, surahName),
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.right,
                            );
                          })),
                      SizedBox(height: 5),
                      Text(
                        geteng(data, globalIndex).trim(),
                        style: TextStyle(
                            color: getColor(value.appTheme), fontSize: 12),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 5),
                      Text(
                        data[globalIndex]['translations'][0]['text']
                            .trim()
                            .trim(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      );
    },
  );
}
