import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukim_app/data/models/hadith_model_separate.dart';
import 'package:weather/weather.dart';

import '../../../../../../data/api/adhan_api.dart';
import '../../../../../../resources/global.dart';

part 'qiblat_state.dart';

class QiblatCubit extends Cubit<QiblatState> {
  QiblatCubit()
      : super(QiblatInitial(
            'waiting..',
            'waiting..',
            [
              'waiting..',
              'waiting..',
              'waiting..',
              'waiting..',
              'waiting..',
              'waiting..',
              'waiting..',
              'waiting..',
            ],
            0,
            'waiting..',
            Duration(seconds: 0),
            '',
            []));

  String cityName = '';
  String zone = '';

  List<DateTime> azanTimes = [];
  int newAzanIndex = 0;
  List<Weather> dayList = [];
  List<String> todaysWidgets = [];

  static QiblatCubit get(context) => BlocProvider.of(context);

  //functions
  Future<Weather?> weather() async {
    try {
      WeatherFactory wf = WeatherFactory('bea15c3ce19fb888986302695cfb1e43');
      print('cityyyyyy )))))))))))))) $cityName  ');
      dayList = await wf.fiveDayForecastByCityName(cityName);
      return await wf.currentWeatherByCityName(cityName);
    } catch (e) {
      print(e);
    }
  }

  String hoursTimesFormat(DateTime t) {
    //handle minutes

    print('timeee ******** $t');
    String mints = '00';
    if (t.minute < 10) {
      mints = '0' + t.minute.toString();
    } else {
      mints = t.minute.toString();
    }

    //hours handler
    if (t.hour < 12) {
      if (t.hour < 10) {
        return '0' + t.hour.toString() + ':' + mints + 'AM';
      } else {
        return t.hour.toString() + ':' + mints + 'AM';
      }
    } else if (t.hour > 12) {
      if ((t.hour - 12) < 10) {
        return '0' + (t.hour - 12).toString() + ':' + mints + 'PM';
      } else {
        return (t.hour - 12).toString() + ':' + mints + 'PM';
      }
    } else {
      return '00:' + mints + 'PM';
    }
  }

  Future<List<DateTime>?> prayers() async {
    print('~~~~~~~~~~~~~~~~~~~~~${zone}');
    String zoneCode = Globals.zonesCode.entries.firstWhere(
      (element) => element.key.toLowerCase() == zone.toLowerCase(),
      orElse: () {
        return MapEntry('Sepang', 'SGR01');
      },
    ).value;

    print('~~~~~~~~~$zoneCode');
    var result = await Api.fetchPrayerTimes(
      zoneCode,
    );

    if (result != null && result.isNotEmpty) {
      return result;
    }
  }

  Future<List<DateTime>?> tomorrowPrayers() async {
    String zoneCode = Globals.zonesCode.entries.firstWhere(
      (element) => element.key.toLowerCase() == zone.toLowerCase(),
      orElse: () {
        return MapEntry('Sepang', 'SGR01');
      },
    ).value;
    var result = await Api.fetchTomorrowPrayerTimes(zoneCode);

    if (result != null && result.isNotEmpty) {
      return result;
    }
  }

  int catchNextAzan(List<DateTime> azans) {
    int axanIndex = 1;

    List<Duration> durations = [];
    for (int i = 0; i < azans.length - 1; i++) {
      durations.add(azans[i].difference(azans.last));
    }
    List<Duration> durationsPlus = [];
    for (Duration d in durations) {
      if (!d.isNegative) {
        durationsPlus.add(d);
      }
    }
    Duration minDuration =
        durationsPlus.isNotEmpty ? durationsPlus[0] : Duration();
    for (int k = 0; k < durationsPlus.length; k++) {
      if (k > 0) {
        if (durationsPlus[k].compareTo(minDuration) == -1) {
          minDuration = durationsPlus[k];
        }
      }
    }

    axanIndex = durations.indexOf(minDuration) + 1;
    List<int> times = azans.map((e) => e.millisecondsSinceEpoch).toList();

    var greater = times
        .where((element) => element >= DateTime.now().millisecondsSinceEpoch)
        .toList()
      ..sort();

    if (greater != null && greater.isNotEmpty) {
      var time = greater.first;
      axanIndex = times.indexOf(time);
      axanIndex++;
    } else {
      axanIndex = times.length - 1;
    }

    return axanIndex;
  }

  String getNextAzanDuration(Duration d) {
    if (d.isNegative) {
      List<String> ls = (-d).toString().split(':');

      return "(" + ls[0] + 'h ' + ls[1] + 'm ' + ls[2].split('.')[0] + 's )';
    } else {
      List<String> ls = d.toString().split(':');

      return "(" + ls[0] + 'h ' + ls[1] + 'm ' + ls[2].split('.')[0] + 's )';
    }
  }

  String getWeatherIcon(String iconCode) {
    switch (iconCode) {
      case '01d':
        return 'assets/images/weather/colorday/Clear-Day.gif';
      case '01n':
        return 'assets/images/weather/colornight/Clear-Night.gif';
      case '02d':
      case '03d':
        return 'assets/images/weather/colorday/Mostly-Cloudy.gif';
      case '02n':
      case '03n':
        return 'assets/images/weather/colornight/Mostly-Cloudy.gif';

      case '04d':
        return 'assets/images/weather/colorday/Cloudy.gif';
      case '04n':
        return 'assets/images/weather/colornight/Cloudy.gif';
      case '9d':
        return 'assets/images/weather/colorday/Sleet.gif';
      case '9n':
        return 'assets/images/weather/colornight/Sleet.gif';
      case '10d':
        return 'assets/images/weather/colorday/Chance-Rain.gif';
      case '10n':
        return 'assets/images/weather/colornight/Chance-Rain.gif';
      case '11d':
        return 'assets/images/weather/colorday/Chance-Storms.gif';
      case '11n':
        return 'assets/images/weather/colornight/Chance-Storms.gif';
      case '13d':
        return 'assets/images/weather/colorday/Snow.gif';
      case '13n':
        return 'assets/images/weather/colornight/Snow.gif';
      case '50d':
        return 'assets/images/weather/colorday/Fog.gif';
      case '50n':
        return 'assets/images/weather/colornight/Fog.gif';

      default:
        return 'assets/images/weather/colorday/Clear-Day.gif';
    }
  }

  getData(String city, String zoneName) async {
    cityName = city;
    zone = zoneName;
    azanTimes = await prayers() ?? [];

    Weather? weat = await weather();
    String temp = weat?.temperature?.celsius?.floor().toString() ?? '--';
    String weatherIcon = weat?.weatherIcon ?? '--';

    if (azanTimes != null && azanTimes.isNotEmpty) {
      if (DateTime.now().isAfter(azanTimes[0])) {
        azanTimes[0] = azanTimes[0].add(Duration(days: 1));
      }
      if (DateTime.now().isAfter(azanTimes[1])) {
        azanTimes[1] = azanTimes[1].add(Duration(days: 1));
      }

      if (DateTime.now().isAfter(azanTimes[2])) {
        azanTimes[2] = azanTimes[2].add(Duration(days: 1));
      }

      if (DateTime.now().isAfter(azanTimes[3])) {
        azanTimes[3] = azanTimes[3].add(Duration(days: 1));
      }

      if (DateTime.now().isAfter(azanTimes[4])) {
        azanTimes[4] = azanTimes[4].add(Duration(days: 1));
      }

      if (DateTime.now().isAfter(azanTimes[5])) {
        azanTimes[5] = azanTimes[5].add(Duration(days: 1));
      }

      if (DateTime.now().isAfter(azanTimes[6])) {
        azanTimes[6] = azanTimes[6].add(Duration(days: 1));
      }
    }

    if (todaysWidgets.isEmpty && dayList != null && dayList.isNotEmpty) {
      azanTimes.forEach((element) {
        Weather closetsDateTimeToNow = dayList.reduce((a, b) =>
            a.date!.difference(element).abs() <
                    b.date!.difference(element).abs()
                ? a
                : b);

        todaysWidgets.add(getWeatherIcon(closetsDateTimeToNow.weatherIcon!));
      });
    }
    String icon = getWeatherIcon(weatherIcon);

    if (azanTimes != null &&
        catchNextAzan(azanTimes) == azanTimes.length - 1 &&
        azanTimes[catchNextAzan(azanTimes) - 1]
                .difference(azanTimes.last)
                .inSeconds <
            0) {
      azanTimes = await tomorrowPrayers() ?? [];
    }

    print('******** ${azanTimes.toSet()}  ******');

    if (azanTimes != null) {
      print('~!!!~~@@##~!~');
      List<String> azansTimesList = List.generate(
          azanTimes.length, (index) => hoursTimesFormat(azanTimes[index]));
      print(azansTimesList.toSet());

      emit(DataChanged(
          hoursTimesFormat(azanTimes.last),
          temp,
          azansTimesList,
          catchNextAzan(azanTimes) - 1,
          getNextAzanDuration(azanTimes[catchNextAzan(azanTimes) - 1]
              .difference(azanTimes.last)),
          azanTimes[catchNextAzan(azanTimes) - 1].difference(azanTimes.last),
          icon,
          todaysWidgets));
    }
  }
}
