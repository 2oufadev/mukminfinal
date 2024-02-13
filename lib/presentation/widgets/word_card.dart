import 'package:flutter/material.dart';
import 'package:mukim_app/providers/theme.dart';
import 'package:mukim_app/resources/constants.dart';
import 'package:mukim_app/resources/global.dart';
import 'package:mukim_app/utils/get_theme_color.dart';
import 'package:provider/provider.dart';

import 'package:just_audio/just_audio.dart';
import 'package:just_audio_cache/src/audio_player_utils.dart';

class WordCard extends StatefulWidget {
  final data;
  final audioList;
  const WordCard({Key? key, this.data, this.audioList}) : super(key: key);

  @override
  _WordCardState createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> {
  List<String> audioList = [];
  Map tajweedList = {};
  List<ColorEntity> colorsList = [
    ColorEntity('hamza wasl', Colors.blue[300]!),
    ColorEntity('laam shamsiyah', Colors.pink[300]!),
    ColorEntity('madda permissible', Colors.orange[300]!),
    ColorEntity('madda normal', Colors.red[300]!),
    ColorEntity('madda necessary', Colors.deepPurple[300]!),
    ColorEntity('ghunnah', Colors.teal[400]!),
    ColorEntity('qalaqah', Colors.indigo[300]!),
    ColorEntity('ikhafa', Colors.greenAccent),
    ColorEntity('idgham wo ghunnah', Colors.blueGrey),
    ColorEntity('idgham ghunnah', Colors.blueGrey),
    ColorEntity('madda obligator', Colors.yellow),
    ColorEntity('ikhafa shafawi', Colors.brown[400]!),
    ColorEntity('silent', Colors.cyan),
  ];
  @override
  void initState() {
    // TODO: implement initState
    Globals.globalInd = 0;
    Globals.globalIndex = 0;
    AudioConstants.audioPlayer = AudioPlayer();
    AudioConstants.duration = Duration();
    AudioConstants.playing = false;
    AudioConstants.position = Duration();
    getAudioLinks();
    super.initState();
  }

  getAudioLinks() async {
    List aaa =
        widget.data['text_uthmani_tajweed'].toString().split('</tajweed>');
    //split(RegExp('<.*?>'));
    aaa.forEach((element) {
      if (element.toString().contains('<tajweed class=ham_wasl>')) {
        List bb = element.toString().split('<tajweed class=ham_wasl>');
        tajweedList.addAll({bb.last: 'hamza wasl'});
      } else if (element
          .toString()
          .contains('<tajweed class=laam_shamsiyah>')) {
        List bb = element.toString().split('<tajweed class=laam_shamsiyah>');
        tajweedList.addAll({bb.last: 'laam shamsiyah'});
      } else if (element
          .toString()
          .contains('<tajweed class=madda_permissible>')) {
        List bb = element.toString().split('<tajweed class=madda_permissible>');
        tajweedList.addAll({bb.last: 'madda permissible'});
      } else if (element.toString().contains('<tajweed class=madda_normal>')) {
        List bb = element.toString().split('<tajweed class=madda_normal>');
        tajweedList.addAll({bb.last: 'madda normal'});
      } else if (element
          .toString()
          .contains('<tajweed class=madda_necessary>')) {
        List bb = element.toString().split('<tajweed class=madda_necessary>');
        tajweedList.addAll({bb.last: 'madda necessary'});
      } else if (element.toString().contains('<tajweed class=ghunnah>')) {
        List bb = element.toString().split('<tajweed class=ghunnah>');
        tajweedList.addAll({bb.last: 'ghunnah'});
      } else if (element.toString().contains('<tajweed class=qalaqah>')) {
        List bb = element.toString().split('<tajweed class=qalaqah>');
        tajweedList.addAll({bb.last: 'qalaqah'});
      } else if (element.toString().contains('<tajweed class=ikhafa>')) {
        List bb = element.toString().split('<tajweed class=ikhafa>');
        tajweedList.addAll({bb.last: 'ikhafa'});
      } else if (element
          .toString()
          .contains('<tajweed class=idgham_wo_ghunnah>')) {
        List bb = element.toString().split('<tajweed class=idgham_wo_ghunnah>');
        tajweedList.addAll({bb.last: 'idgham wo ghunnah'});
      } else if (element
          .toString()
          .contains('<tajweed class=idgham_ghunnah>')) {
        List bb = element.toString().split('<tajweed class=idgham_ghunnah>');
        tajweedList.addAll({bb.last: 'idgham ghunnah'});
      } else if (element
          .toString()
          .contains('<tajweed class=madda_obligator>')) {
        List bb = element.toString().split('<tajweed class=madda_obligator>');
        tajweedList.addAll({bb.last: 'madda obligator'});
      } else if (element
          .toString()
          .contains('<tajweed class=ikhafa_shafawi>')) {
        List bb = element.toString().split('<tajweed class=ikhafa_shafawi>');
        tajweedList.addAll({bb.last: 'ikhafa shafawi'});
      } else if (element.toString().contains('<tajweed class=slnt>')) {
        List bb = element.toString().split('<tajweed class=slnt>');
        tajweedList.addAll({bb.last: 'silent'});
      }
    });
    for (var abc in widget.audioList) {
      if (abc['audio_url'] != null) {
        audioList.add('https://verses.quran.com/' + abc['audio_url']);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.data['words'].length - 1,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          List<tajweedEntity> abc = [];
          tajweedList.forEach((key, value) {
            if (widget.data['words'][index]['text'].toString().contains(key)) {
              abc.add(tajweedEntity(value, key));
            }
          });
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
            child: Column(
              children: [
                Container(
                  child: Row(
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            height: 50,
                          ),
                          InkWell(
                            onTap: () {
                              if (AudioConstants.processingState !=
                                      ProcessingState.idle &&
                                  Globals.wordVerseKey ==
                                      widget.data['verse_key'] &&
                                  Globals.wordIndex == index &&
                                  Globals.wordPlaying) {
                                AudioConstants.audioPlayer.pause();
                                Globals.wordPlaying = false;
                                setState(() {});
                              } else {
                                Globals.wordIndex = index;
                                Globals.wordVerseKey = widget.data['verse_key'];
                                Globals.wordPlaying = true;
                                setState(() {});
                                playAudio();
                              }
                            },
                            child: SizedBox(
                              width: 50,
                              child: Icon(
                                  AudioConstants.processingState !=
                                              ProcessingState.idle &&
                                          Globals.wordVerseKey ==
                                              widget.data['verse_key'] &&
                                          Globals.wordIndex == index &&
                                          Globals.wordPlaying == true
                                      ? Icons.pause_circle_filled_outlined
                                      : Icons.play_circle_fill_outlined,
                                  color: Colors.white,
                                  size: 21),
                            ),
                          ),
                        ],
                      ),
                      Consumer<ThemeNotifier>(builder: (context, val, child) {
                        return Container(
                          width: MediaQuery.of(context).size.width - 100,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: widget.data['words'][index]
                                                ['transliteration']['text']
                                            .toString() !=
                                        'null'
                                    ? Text(
                                        widget.data['words'][index]['text']
                                            .toString()
                                            .trim(),
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize: 30,
                                          color: Globals.wordVerseKey ==
                                                      widget
                                                          .data['verse_key'] &&
                                                  Globals.wordIndex == index
                                              ? getColor(val.appTheme)
                                              : Colors.white,
                                          fontFamily: 'KFGQPC',
                                        ),
                                      )
                                    : null,
                              ),
                              // Align(
                              //   alignment: Alignment.bottomLeft,
                              //   child: widget.data['words'][index]
                              //                   ['transliteration']['text']
                              //               .toString() !=
                              //           'null'
                              //       ? Text(
                              //           widget.data['words'][index]
                              //                   ['transliteration']['text']
                              //               .toString(),
                              //           style: TextStyle(
                              //             fontSize: 15,
                              //             color: getColor(val.appTheme),
                              //           ),
                              //         )
                              //       : null,
                              // ),
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: abc.isNotEmpty
                                    ? Column(
                                        children: [
                                          ...List.generate(
                                              abc.length,
                                              (index) => Container(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          abc[index]
                                                              .tajweedType
                                                              .toString(),
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            color: colorsList
                                                                .firstWhere((element) =>
                                                                    element
                                                                        .hokm ==
                                                                    abc[index]
                                                                        .tajweedType
                                                                        .toString())
                                                                .color,
                                                          ),
                                                        ),
                                                        Text(
                                                          abc[index]
                                                              .tajweedWord
                                                              .toString(),
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            color: colorsList
                                                                .firstWhere((element) =>
                                                                    element
                                                                        .hokm ==
                                                                    abc[index]
                                                                        .tajweedType
                                                                        .toString())
                                                                .color,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ))
                                        ],
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  width: MediaQuery.of(context).size.width - 50,
                  height: 0.5,
                  decoration: const BoxDecoration(
                    color: Color(0xff929292),
                  ),
                ),
              ],
            ),
          );
        });
  }

  TextSpan splitWord(String word) {
    List<TextSpan> textSpan = [];
    List<String> namesSplit = word.split("");

    for (var i = 0; i < namesSplit.length; i++) {
      textSpan.add(TextSpan(text: namesSplit[i]));
    }

    return TextSpan(children: textSpan);
  }

  void playAudio() async {
    try {
      await AudioConstants.audioPlayer
          .dynamicSet(url: audioList[Globals.wordIndex])
          .onError((error, stackTrace) {
        print('!!!!!!$error');
      }).then((value) async {
        AudioConstants.audioPlayer
            .play()
            .onError((error, stackTrace) => print('error $error'))
            .whenComplete(() => print('complete'));

        AudioConstants.playingNext = false;
      });
    } catch (e) {
      print('erorr5 :$e');
    }

    AudioConstants.audioPlayer.playerStateStream.listen((state) async {
      setState(() {
        AudioConstants.processingState = state.processingState;
      });

      if (state.playing) {
        AudioConstants.playing = true;
      } else {
        AudioConstants.playing = false;
        if (!AudioConstants.paused) {}
      }
      if (state.processingState == ProcessingState.completed &&
          !AudioConstants.playingNext) {
        await AudioConstants.audioPlayer.pause();
        setState(() {
          Globals.wordPlaying = false;
        });
      }
    });
  }
}

class tajweedEntity {
  final String tajweedType;
  final String tajweedWord;
  tajweedEntity(this.tajweedType, this.tajweedWord);
}

class ColorEntity {
  final String hokm;
  final Color color;

  ColorEntity(this.hokm, this.color);
}
