import 'dart:convert';
import 'package:just_audio/just_audio.dart';

import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

class Qari {
  static var qari_id = 2;
  static var qari_name = 'Abdul Basit';
  static var qari_image = 'assets/images/abdulbasit.jpg';
}

class AudioConstants {
  static AudioPlayer audioPlayer = AudioPlayer();
  static bool paused = false;
  static Duration duration = Duration();
  static Duration position = Duration();
  static bool playing = false;
  static bool playingNext = false;
  static List viewinglist = [];
  static Database? database;
  static ProcessingState processingState = ProcessingState.idle;
}

getSurah() async {
  try {
    String url = 'https://quranicaudio.com/api/surahs';
    var result =
        await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    var responseBody = jsonDecode(result.body);
    return responseBody;
  } catch (e) {
    return e;
  }
}

class Strings {}
