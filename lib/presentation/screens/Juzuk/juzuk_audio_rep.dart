import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_cache/src/audio_player_utils.dart';
import 'package:mukim_app/resources/global.dart';
import 'package:sqflite/sqflite.dart';

import 'package:mukim_app/resources/constants.dart';

class JuzukAudioRep with ChangeNotifier {
  List<dynamic> data = [];
  List<String> loadedAudiosUrls = [];
  String latestPage = '';

  void onSet1(int globalInd, Color color) {
    globalInd = Globals.globalIndex;
    notifyListeners();
  }

  getPage(String juzuk) {
    String page = '1';

    switch (juzuk) {
      case "1":
        page = '1';
        return page;

      case "2":
        page = '22';
        return page;
      case "3":
        page = '42';
        return page;
      case "4":
        page = '62';
        return page;
      case "5":
        page = '82';
        return page;
      case "6":
        page = '102';
        return page;
      case "7":
        page = '122';
        return page;
      case "8":
        page = '142';
        return page;
      case "9":
        page = '162';
        return page;
      case "10":
        page = '182';
        return page;
      case "11":
        page = '202';
        return page;
      case "12":
        page = '222';
        return page;
      case "13":
        page = '242';
        return page;
      case "14":
        page = '262';
        return page;
      case "15":
        page = '282';
        return page;
      case "16":
        page = '302';
        return page;
      case "17":
        page = '322';
        return page;
      case "18":
        page = '342';
        return page;
      case "19":
        page = '362';
        return page;
      case "20":
        page = '382';
        return page;
      case "21":
        page = '402';
        return page;
      case "22":
        page = '422';
        return page;
      case "23":
        page = '442';
        return page;
      case "24":
        page = '462';
        return page;
      case "25":
        page = '482';
        return page;
      case "26":
        page = '502';
        return page;
      case "27":
        page = '522';
        return page;
      case "28":
        page = '542';
        return page;
      case "29":
        page = '562';
        return page;
      case "30":
        page = '582';
        return page;
    }
  }

  Future<String> getAyahAudioUrl(String ayah) async {
    String url;

    List data = [];
    String urll = 'https://api.quran.com/api/v4/verses/by_key/' +
        ayah.toString() +
        '?audio=' +
        Qari.qari_id.toString();

    print('urll>>>>>>>>>>> $urll');

    var resultt = await http
        .get(Uri.parse(urll), headers: {"Accept": "application/json"});

    Map<String, dynamic> aaa = jsonDecode(resultt.body);

    print(aaa);
    url = aaa['verse']['audio']['url'];
    Globals.aazz = aaa['verse']['audio']['segments'];
    // List aq = aaa['verse']['words'];
    Globals.numberOfWords = aaa.length - 1;
    await AudioConstants.database!.insert(
        'Ayah',
        {
          'ayahId': ayah.toString(),
          'value': resultt.body,
          'qari': Qari.qari_id.toString()
        },
        conflictAlgorithm: ConflictAlgorithm.ignore);

    return url;
  }

  void playPrev(
    List data,
  ) async {
    try {
      if (!AudioConstants.playingNext) {
        await AudioConstants.audioPlayer.pause();

        Globals.globalInd = Globals.globalInd - 1;

        List<Map> www = await AudioConstants.database!.rawQuery(
            'SELECT * FROM "Ayah" WHERE ayahId=? and qari=?',
            [data[Globals.globalInd]['verse_key'], Qari.qari_id.toString()]);
        if (www.isNotEmpty) {
          Map<String, dynamic> responseBody =
              jsonDecode(www.first['value'].toString());
          String url = responseBody['verse']['audio']['url'].toString();

          Globals.aazz = responseBody['verse']['audio']['segments'];
          List aq = responseBody['verse']['words'];
          Globals.numberOfWords = aq.length - 1;
          await AudioConstants.audioPlayer
              .dynamicSet(
                  url: url.toString().startsWith('//')
                      ? 'https:' + url.toString()
                      : 'https://verses.quran.com/' + url)
              .then((value) {
            AudioConstants.audioPlayer.play();
            AudioConstants.playingNext = false;
          });
        }
      }
    } catch (e) {
      print('erroooooooor $e');
    }
  }

  void playNext(
    List data,
  ) async {
    try {
      await AudioConstants.audioPlayer.pause();
      Globals.globalIndWord = 0;
      Globals.globalInd = Globals.globalInd + 1;

      List<Map> www = await AudioConstants.database!.rawQuery(
          'SELECT * FROM "Ayah" WHERE ayahId=? and qari=?',
          [data[Globals.globalInd]['verse_key'], Qari.qari_id.toString()]);
      if (www.isNotEmpty) {
        Map<String, dynamic> responseBody =
            jsonDecode(www.first['value'].toString());
        String url = responseBody['verse']['audio']['url'].toString();

        Globals.aazz = responseBody['verse']['audio']['segments'];
        List aq = responseBody['verse']['words'];
        Globals.numberOfWords = aq.length - 1;
        await AudioConstants.audioPlayer
            .dynamicSet(
                url: url.toString().startsWith('//')
                    ? 'https:' + url.toString()
                    : 'https://verses.quran.com/' + url)
            .then((value) {
          AudioConstants.audioPlayer.play();
          AudioConstants.playingNext = false;
        });
      }
    } catch (e) {
      print('erroooooooor $e');
    }
  }

  Future<void> playSelected(
    int index,
    List data,
  ) async {
    Globals.globalIndWord = 0;
    String url = '';
    List<Map> www = await AudioConstants.database!.rawQuery(
        'SELECT * FROM "Ayah" WHERE ayahId=? and qari=?',
        [data[index]['verse_key'], Qari.qari_id.toString()]);
    if (www.isNotEmpty) {
      Map<String, dynamic> responseBody =
          jsonDecode(www.first['value'].toString());
      url = responseBody['verse']['audio']['url'].toString();

      Globals.aazz = responseBody['verse']['audio']['segments'];

      List aq = responseBody['verse']['words'];
      Globals.numberOfWords = aq.length - 1;
    } else {
      await getAyahAudioUrl(data[index]['verse_key']).then((value) {
        url = value;
      });
    }

    if (AudioConstants.audioPlayer.playerState.processingState ==
        ProcessingState.idle) {
      Globals.globalInd = index;
      Globals.playingUrl = url;
      getAudio(data[index]['verse_key'].toString(), data);
    } else {
      await AudioConstants.audioPlayer.pause();

      Globals.globalInd = index;
      Globals.playingUrl = url;

      await AudioConstants.audioPlayer
          .dynamicSet(
              url: url.toString().startsWith('//')
                  ? 'https:' + url.toString()
                  : 'https://verses.quran.com/' + url)
          .then((value) {
        AudioConstants.audioPlayer.play();
        AudioConstants.playingNext = false;
        // AudioConstants.playingNext = false;
      });
    }
    try {} catch (e) {
      print('erroooooooor $e');
    }
  }

  void getAudio(String ayah, List data) async {
    Globals.globalIndWord = 0;

    try {
      var urll;
      if (Globals.playingUrl.toString().startsWith('//')) {
        urll = 'https:' + Globals.playingUrl.toString();
      } else {
        urll = 'https://verses.quran.com/' + Globals.playingUrl.toString();
      }
      await AudioConstants.audioPlayer
          .dynamicSet(url: urll)
          .then((value) async {
        AudioConstants.audioPlayer
            .play()
            .onError((error, stackTrace) => print('error $error'))
            .whenComplete(() => print('complete'));

        AudioConstants.playingNext = false;
      });
    } catch (e) {
      print('erorr5 :$e');
    }

    AudioConstants.audioPlayer.durationStream.listen((Duration? dd) {
      if (dd != null) {
        AudioConstants.duration = dd;

        notifyListeners();
      }
    });
    int inter = 1;

    AudioConstants.audioPlayer.positionStream.listen((Duration dd) {
      AudioConstants.position = dd;

      if (dd != AudioConstants.duration) {
        if (Globals.aazz.length == 1) {
          double intervalD = 0.0;
          if (Globals.aazz.first[3] is String) {
            intervalD =
                (int.parse(Globals.aazz.first[3]) / Globals.numberOfWords);
          } else {
            intervalD = (Globals.aazz.first[3] / Globals.numberOfWords);
          }

          int interval = intervalD.round();
          if (dd.inMilliseconds <= interval * inter) {
          } else {
            Globals.globalIndWord++;
            inter++;
          }
        } else {
          inter = 1;

          if (Globals.aazz.first[3] is String &&
              dd.inMilliseconds <= int.parse(Globals.aazz.first[3])) {
            Globals.globalIndWord = 0;
          } else if (Globals.aazz.first[3] is num &&
              dd.inMilliseconds <= Globals.aazz.first[3]) {
            Globals.globalIndWord = 0;
          } else if (Globals.aazz.first[3] is String &&
              dd.inMilliseconds >= int.parse(Globals.aazz.last[3])) {
            Globals.globalIndWord = int.parse(Globals.aazz.last[0]);
          } else if (Globals.aazz.first[3] is num &&
              dd.inMilliseconds >= Globals.aazz.last[3]) {
            Globals.globalIndWord = Globals.aazz.last[0];
          } else if (Globals.globalIndWord <= Globals.aazz.length - 1) {
            if (Globals.aazz.first[3] is String &&
                int.parse(Globals.aazz[Globals.globalIndWord][1]) -
                        int.parse(Globals.aazz[Globals.globalIndWord][0]) >
                    1) {
              double intervalD =
                  (int.parse(Globals.aazz[Globals.globalIndWord][3]) -
                          int.parse(Globals.aazz[Globals.globalIndWord][2]) +
                          1) /
                      (int.parse(Globals.aazz[Globals.globalIndWord][1]) -
                          int.parse(Globals.aazz[Globals.globalIndWord][0]));
              int interval = intervalD.round();
              if (dd.inMilliseconds < interval * inter) {
              } else {
                Globals.globalIndWord++;
                inter++;
              }
            } else if (Globals.aazz.first[3] is num &&
                Globals.aazz[Globals.globalIndWord][1] -
                        Globals.aazz[Globals.globalIndWord][0] >
                    1) {
              double intervalD = (Globals.aazz[Globals.globalIndWord][3] -
                      Globals.aazz[Globals.globalIndWord][2] +
                      1) /
                  (Globals.aazz[Globals.globalIndWord][1] -
                      Globals.aazz[Globals.globalIndWord][0]);
              int interval = intervalD.round();
              if (dd.inMilliseconds < interval * inter) {
              } else {
                Globals.globalIndWord++;
                inter++;
              }
            } else {
              if (Globals.aazz.first[3] is String &&
                  dd.inMilliseconds >=
                      int.parse(Globals.aazz[Globals.globalIndWord][3]) &&
                  Globals.globalIndWord != Globals.aazz.length - 1) {
                Globals.globalIndWord++;
              } else if (Globals.aazz.first[3] is num &&
                  dd.inMilliseconds >= Globals.aazz[Globals.globalIndWord][3] &&
                  Globals.globalIndWord != Globals.aazz.length - 1) {
                Globals.globalIndWord++;
              }
            }
          }
        }
      }

      notifyListeners();
    });

    AudioConstants.audioPlayer.playerStateStream.listen((state) async {
      if (state.playing) {
        AudioConstants.playing = true;
      } else {
        AudioConstants.playing = false;
        if (!AudioConstants.paused) {
          Globals.globalIndWord = 0;
        }
      }
      if (state.processingState == ProcessingState.completed &&
          !AudioConstants.playingNext) {
        AudioConstants.playingNext = true;
        await AudioConstants.audioPlayer.pause();
        if (Globals.repeat) {
          await AudioConstants.audioPlayer
              .dynamicSet(
                  url: Globals.playingUrl.toString().startsWith('//')
                      ? 'https:' + Globals.playingUrl.toString()
                      : 'https://verses.quran.com/' +
                          Globals.playingUrl.toString())
              .then((value) {
            AudioConstants.audioPlayer.play();
            AudioConstants.playingNext = false;
          });
        } else {
          if (Globals.globalInd < AudioConstants.viewinglist.length - 1) {
            Globals.globalInd = Globals.globalInd + 1;

            List<Map> www = await AudioConstants.database!.rawQuery(
                'SELECT * FROM "Ayah" WHERE ayahId=? and qari=?', [
              data[Globals.globalInd]['verse_key'],
              Qari.qari_id.toString()
            ]);
            String ur = '';
            print('www _____________$www');
            if (www.isNotEmpty) {
              Map<String, dynamic> responseBody =
                  jsonDecode(www.first['value'].toString());
              ur = responseBody['verse']['audio']['url'].toString();
              print('urrr_______________$ur');
              print(responseBody);
              Globals.aazz = responseBody['verse']['audio']['segments'];
              List aq = responseBody['verse']['words'];
              Globals.numberOfWords = aq.length - 1;
              await AudioConstants.audioPlayer
                  .dynamicSet(
                      url: ur.toString().startsWith('//')
                          ? 'https:' + ur.toString()
                          : 'https://verses.quran.com/' + ur.toString())
                  .then((value) {
                AudioConstants.audioPlayer.play();
                AudioConstants.playingNext = false;
              });
            } else {
              await getAyahAudioUrl(data[Globals.globalInd]['verse_key'])
                  .then((value) async {
                ur = value;
                print('ur ____$value');
                await AudioConstants.audioPlayer
                    .dynamicSet(
                        url: ur.toString().startsWith('//')
                            ? 'https:' + ur.toString()
                            : 'https://verses.quran.com/' + ur.toString())
                    .then((value) {
                  AudioConstants.audioPlayer.play();
                  AudioConstants.playingNext = false;
                });
              });
            }
          }
        }
      }
    });

    notifyListeners();
  }
}
