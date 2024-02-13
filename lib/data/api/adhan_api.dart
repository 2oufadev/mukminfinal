import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:mukim_app/data/api/api_client.dart';
import 'package:mukim_app/data/models/month_prayer_model.dart';
import 'package:mukim_app/data/models/zone_response.dart';
import 'package:mukim_app/resources/global.dart';
import 'package:sqflite/sqflite.dart';

import '../../resources/constants.dart';

class Api {
  static const BASE_URL = 'https://api.azanpro.com/';
  static const SOLAT_BASE_URL =
      'https://www.e-solat.gov.my/index.php?r=esolatApi/takwimsolat';
  static const states_url = BASE_URL + 'zone/states.json';
  static const zone_url = BASE_URL + 'zone/zones.json';
  static const prayer_times_url = BASE_URL + 'times/today.json';
  static const tomorrow_prayer_times_url = BASE_URL + 'times/tomorrow.json';
  static const month_prayer_times_url = BASE_URL + 'times/month.json';
  static const zone_code = 'https://api.azanpro.com/zone/zones.json?state=';
  static Future<List<String>> fetchStates() async {
    List<String> states = [];

    try {
      var result = await ApiClient.getData(states_url);

      if (result['status']) {
        var json = result['data']['states'] as List;

        for (int i = 0; i < json.length; i++) {
          states.add(json[i].toString());
        }
      }
    } catch (e) {
      print(e);
    }

    return states;
  }

  static Future<ZoneModel> fetchZones() async {
    var zone = ZoneModel(results: [], states: []);

    try {
      var result = await ApiClient.getData(zone_url);

      if (result['status']) {
        zone = ZoneModel.fromJson(result['data']);
      }
    } catch (e) {
      print(e);
    }

    return zone;
  }

  static Future<List<DateTime>> fetchPrayerTimes(String zone) async {
    List<DateTime> times = [];

    try {
      List<Map> qqq = await AudioConstants.database!
          .rawQuery('SELECT * FROM "azanTimes" WHERE zoneCode=?', [zone]);
      MonthPrayerModel? jsonData;
      print('~~~~~!!!!!$zone');
      DateTime startDate = DateTime.now();
      DateTime endDate = startDate.add(Duration(days: 31));
      if (qqq.isEmpty) {
        print('~~~~~~~~~~~~~~~~~ empty');
        jsonData = await getFromServerAndSave(startDate, endDate, zone, false);
        PrayerModel prayerModel = jsonData!.prayerTimes.firstWhere((element) =>
            DateFormat('dd-MMM-yyyy').parse(element.date!).day ==
            DateTime.now().day);
        times = [
          getTimeFromString(prayerModel.imsak!),
          getTimeFromString(prayerModel.subuh!),
          getTimeFromString(prayerModel.syuruk!),
          getTimeFromString(prayerModel.syuruk!).add(Duration(minutes: 20)),
          getTimeFromString(prayerModel.zohor!),
          getTimeFromString(prayerModel.asar!),
          getTimeFromString(prayerModel.maghrib!),
          getTimeFromString(prayerModel.isyak!),
          DateTime.now(),
        ];
        return times;
      } else {
        print('existsss');
        Map<String, dynamic> responseBody =
            jsonDecode(qqq.first['data'].toString());
        print(responseBody);
        jsonData = MonthPrayerModel.fromJson(responseBody);
        int index = jsonData.prayerTimes.indexWhere((element) =>
            DateFormat('dd-MMM-yyyy').parse(element.date!).day ==
            DateTime.now().day);

        if (index != -1) {
          PrayerModel prayerModel = jsonData.prayerTimes[index];
          times = [
            getTimeFromString(prayerModel.imsak!),
            getTimeFromString(prayerModel.subuh!),
            getTimeFromString(prayerModel.syuruk!),
            getTimeFromString(prayerModel.syuruk!).add(Duration(minutes: 20)),
            getTimeFromString(prayerModel.zohor!),
            getTimeFromString(prayerModel.asar!),
            getTimeFromString(prayerModel.maghrib!),
            getTimeFromString(prayerModel.isyak!),
            DateTime.now(),
          ];
          return times;
        } else {
          print('~~~~~~~~~~~~~~~~~ empty');
          jsonData =
              await getFromServerAndSave(startDate, endDate, zone, false);
          PrayerModel prayerModel = jsonData!.prayerTimes.firstWhere(
              (element) =>
                  DateFormat('dd-MMM-yyyy').parse(element.date!).day ==
                  DateTime.now().day);
          times = [
            getTimeFromString(prayerModel.imsak!),
            getTimeFromString(prayerModel.subuh!),
            getTimeFromString(prayerModel.syuruk!),
            getTimeFromString(prayerModel.syuruk!).add(Duration(minutes: 20)),
            getTimeFromString(prayerModel.zohor!),
            getTimeFromString(prayerModel.asar!),
            getTimeFromString(prayerModel.maghrib!),
            getTimeFromString(prayerModel.isyak!),
            DateTime.now(),
          ];
          return times;
        }
      }
    } catch (e) {
      print('fetchPrayerTimes error: $e');
    }

    return times;
  }

  static Future<List<DateTime>> fetchTomorrowPrayerTimes(String zone) async {
    List<DateTime> times = [];

    try {
      List<Map> qqq = await AudioConstants.database!
          .rawQuery('SELECT * FROM "azanTimes" WHERE zoneCode=?', [zone]);
      MonthPrayerModel? jsonData;
      print('~~~~~!!!!!$zone');
      DateTime startDate = DateTime.now();
      DateTime endDate = startDate.add(Duration(days: 31));
      if (qqq.isEmpty) {
        jsonData = await getFromServerAndSave(startDate, endDate, zone, false);
        PrayerModel prayerModel = jsonData!.prayerTimes.firstWhere((element) =>
            DateFormat('dd-MMM-yyyy').parse(element.date!).day ==
            DateTime.now().add(Duration(days: 1)).day);
        times = [
          getTimeFromString(prayerModel.imsak!),
          getTimeFromString(prayerModel.subuh!),
          getTimeFromString(prayerModel.syuruk!),
          getTimeFromString(prayerModel.syuruk!).add(Duration(minutes: 20)),
          getTimeFromString(prayerModel.zohor!),
          getTimeFromString(prayerModel.asar!),
          getTimeFromString(prayerModel.maghrib!),
          getTimeFromString(prayerModel.isyak!),
          DateTime.now(),
        ];
        return times;
      } else {
        print('existsss');

        Map<String, dynamic> responseBody =
            jsonDecode(qqq.first['data'].toString());
        print(responseBody);
        jsonData = MonthPrayerModel.fromJson(responseBody);
        PrayerModel prayerModel = jsonData.prayerTimes.firstWhere((element) =>
            DateFormat('dd-MMM-yyyy').parse(element.date!).day ==
            DateTime.now().add(Duration(days: 1)).day);
        print('~~~~~~~${prayerModel}');
        print(
            '~~~~prayerModel >>>> ${prayerModel.date}~~~~ ${prayerModel.zohor}');

        times = [
          getTimeFromString(prayerModel.imsak!),
          getTimeFromString(prayerModel.subuh!),
          getTimeFromString(prayerModel.syuruk!),
          getTimeFromString(prayerModel.syuruk!).add(Duration(minutes: 20)),
          getTimeFromString(prayerModel.zohor!),
          getTimeFromString(prayerModel.asar!),
          getTimeFromString(prayerModel.maghrib!),
          getTimeFromString(prayerModel.isyak!),
          DateTime.now(),
        ];
        return times;
      }
    } catch (e) {
      print('fetchPrayerTimes error: $e');
    }

    return times;
  }

  static Future<MonthPrayerModel> fetchMonthPrayers(
      String zone, String month, String year) async {
    print('*********** $month $year');
    String zoneCode = Globals.zonesCode.entries
        .firstWhere((element) => element.key == zone,
            orElse: () => MapEntry('Sepang', 'SGR01'))
        .value;

    List<Map> qqq = await AudioConstants.database!.rawQuery(
        'SELECT * FROM "azanTimesMonthly" WHERE zoneCode=? and month=?',
        [zoneCode, month]);
    MonthPrayerModel jsonData;
    print('~~~~~!!!!!$zoneCode');
    if (qqq.isEmpty) {
      print('emptyyyyyyyyyyyyyyyyyyyy');
      DateTime firstDay = DateTime(int.parse(year), int.parse(month), 1);
      DateTime lastDay = DateTime(int.parse(year), int.parse(month) + 1, 1)
          .subtract(Duration(days: 1));
      MonthPrayerModel? jsonData =
          await getFromServerAndSave(firstDay, lastDay, zoneCode, true);

      print(jsonData!.prayerTimes.last.date);
      return jsonData;
    } else {
      print('existss-----------------');
      Map<String, dynamic> responseBody =
          jsonDecode(qqq.first['data'].toString());
      print(responseBody);
      jsonData = MonthPrayerModel.fromJson(responseBody);
      print(jsonData.prayerTimes.last.date);
    }
    return jsonData;
  }

  static Future<MonthPrayerModel?> fetchAzansTimes(
      String zone, DateTime now) async {
    DateTime endDate = now.add(Duration(days: 31));

    String zoneCode = Globals.zonesCode.entries
        .firstWhere((element) => element.key == zone,
            orElse: () => MapEntry('Sepang', 'SGR01'))
        .value;
    List<Map> qqq = await AudioConstants.database!
        .rawQuery('SELECT * FROM "azanTimes" WHERE zoneCode=?', [zoneCode]);
    MonthPrayerModel? jsonData;
    print('~~~~~!!!!!$zoneCode');
    print(qqq.toSet());
    if (qqq.isEmpty) {
      jsonData = await getFromServerAndSave(now, endDate, zoneCode, false);
      return jsonData;
    } else {
      Map<String, dynamic> responseBody =
          jsonDecode(qqq.first['data'].toString());
      print(responseBody);
      jsonData = MonthPrayerModel.fromJson(responseBody);

      DateTime lastDate =
          DateFormat('dd-MMM-yyyy').parse(jsonData.prayerTimes.last.date!);
      print(lastDate);
      if (lastDate.month != DateTime.now().month) {
        print('trueee');
        return jsonData;
      } else {
        print('elseeeeeeeeee');
        jsonData = await getFromServerAndSave(now, endDate, zoneCode, false);
        return jsonData;
      }
    }
  }

  static Future<MonthPrayerModel?> getFromServerAndSave(
      DateTime now, DateTime endDate, String zoneCode, bool monthly) async {
    var postData = {
      'datestart': now.year.toString() +
          '-' +
          now.month.toString() +
          '-' +
          now.day.toString(),
      'dateend': endDate.year.toString() +
          '-' +
          endDate.month.toString() +
          '-' +
          endDate.day.toString(),
    };

    var result = await ApiClient.postData(
            SOLAT_BASE_URL + '&period=duration&zone=' + zoneCode,
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: postData)
        .timeout(Duration(seconds: 10), onTimeout: () async {
      var data = await ApiClient.getData(
        'https://mpt-backup-api.herokuapp.com/solat/' + zoneCode,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );
      print('~~~~*******~~~');
      print(data);
      return data;
    });

    print('result @@@@@@ $result');

    print('resultttt >>>>>>>>>$result');
    if (result != null && result['status'] == true) {
      await AudioConstants.database!.insert(
          monthly ? 'azanTimesMonthly' : 'azanTimes',
          {
            'zoneCode': zoneCode,
            'data': jsonEncode(result['data']),
            if (monthly) 'month': now.month.toString()
          },
          conflictAlgorithm: ConflictAlgorithm.ignore);

      MonthPrayerModel jsonData = MonthPrayerModel.fromJson(result['data']);

      return jsonData;
    } else {
      print('Nulllllllllll');
      var data = await ApiClient.getData(
        'https://mpt-backup-api.herokuapp.com/solat/' + zoneCode,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );
      print(data);
      if (data != null && data['status'] == true) {
        await AudioConstants.database!.insert(
            monthly ? 'azanTimesMonthly' : 'azanTimes',
            {
              'zoneCode': zoneCode,
              'data': jsonEncode(
                data['data'],
              ),
              if (monthly) 'month': now.month.toString()
            },
            conflictAlgorithm: ConflictAlgorithm.ignore);

        MonthPrayerModel jsonData = MonthPrayerModel.fromJson(data['data']);
        print(jsonData.prayerTimes.last.date);
        return jsonData;
      }
    }
  }

  static Future<MonthPrayerModel> fetchNotificationsMonthPrayers(
      String zone, DateTime date) async {
    String zoneCode = Globals.zonesCode.entries
        .firstWhere(
          (element) => element.key == zone,
          orElse: () => MapEntry('Sepang', 'SGR01'),
        )
        .value;

    DateTime endDate = date.add(Duration(days: 7));

    var postData = {
      'datestart': date.year.toString() +
          '-' +
          date.month.toString() +
          '-' +
          date.day.toString(),
      'dateend': endDate.year.toString() +
          '-' +
          endDate.month.toString() +
          '-' +
          endDate.day.toString(),
    };

    var jsonPrayer;

    try {
      var result = await ApiClient.postData(
              SOLAT_BASE_URL + '&period=duration&zone=' + zoneCode,
              headers: {'Content-Type': 'application/x-www-form-urlencoded'},
              body: postData)
          .timeout(Duration(seconds: 15));

      print('resultttt >>>>>>>>>$result');

      jsonPrayer = MonthPrayerModel.fromJson(result['data']);
    } catch (e) {
      print('erorrrr ??? $e');
      var result = await ApiClient.getData(
        'https://mpt-backup-api.herokuapp.com/solat/' + zoneCode,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );
      print('~~~~~~~');
      print(result);
      jsonPrayer = MonthPrayerModel.fromJson(result['data']);
    }

    return jsonPrayer;
  }

  static DateTime getTimeFromString(String str) {
    try {
      var now = DateTime.now();
      var then = DateFormat("HH:mm").parse(str);
      var time = DateTime(now.year, now.month, now.day, then.hour, then.minute);

      return time;
      // return
    } catch (e) {
      print('getTimeFromString: $e');
      return DateTime.now();
    }
  }
}
