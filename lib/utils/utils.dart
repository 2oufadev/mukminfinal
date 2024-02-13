import 'dart:collection';
import 'package:geocoding/geocoding.dart';
import 'package:mukim_app/calender_custom/table_calendar.dart';
import 'package:mukim_app/resources/global.dart';

class Event {
  final String title;

  const Event(this.title);

  @override
  String toString() => title;
}

final kEvents = LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  hashCode: getHashCode,
)..addAll(_kEventSource);

final _kEventSource = Map.fromIterable(List.generate(2200, (index) => index),
    key: (item) => DateTime.utc(kFirstDay.year, kFirstDay.month, item * 1),
    value: (item) =>
        List.generate(item % 4 + 1, (index) => Event('Event $item | ${0 + 1}')))
  ..addAll({
    kToday: [
      Event('Today\'s Event 1'),
      Event('Today\'s Event 2'),
    ],
  });

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

String getHijriMonthName(int month) {
  String hijriNewMonthName = '';
  if (month == 1) {
    hijriNewMonthName = 'Muharram';
  } else if (month == 2) {
    hijriNewMonthName = 'Safar';
  } else if (month == 3) {
    hijriNewMonthName = "Rabi'ulawal";
  } else if (month == 4) {
    hijriNewMonthName = "Rabi'ulakhir";
  } else if (month == 5) {
    hijriNewMonthName = 'Jamadilawwal';
  } else if (month == 6) {
    hijriNewMonthName = 'Jamadilakhir';
  } else if (month == 7) {
    hijriNewMonthName = 'Rejab';
  } else if (month == 8) {
    hijriNewMonthName = "Sya'ban";
  } else if (month == 9) {
    hijriNewMonthName = 'Ramadhan';
  } else if (month == 10) {
    hijriNewMonthName = 'Shawwal';
  } else if (month == 11) {
    hijriNewMonthName = 'Zulkaedah';
  } else if (month == 12) {
    hijriNewMonthName = 'Zulhijjah';
  }

  return hijriNewMonthName;
}

String modifyDistrictName(String city, List<Placemark> addresses) {
  String districtName;
  switch (city.toLowerCase()) {
    case 'johor':
      districtName = getCityName(addresses, Globals.johor);
      break;

    case 'kedah':
      districtName = getCityName(addresses, Globals.kedah);
      break;

    case 'kelantan':
      districtName = getCityName(addresses, Globals.kelantan);
      break;

    case 'melaka':
      districtName = getCityName(addresses, Globals.melaka);
      break;

    case 'negeri sembilan':
      districtName = getCityName(addresses, Globals.negeriSembilan);
      break;

    case 'pahang':
      districtName = getCityName(addresses, Globals.pahang);
      break;

    case 'perak':
      districtName = getCityName(addresses, Globals.perak);
      break;
    case 'perlis':
      districtName = getCityName(addresses, Globals.perlis);
      break;
    case 'pulau pinang':
      districtName = getCityName(addresses, Globals.pulauPinang);
      break;
    case 'sabah':
      districtName = getCityName(addresses, Globals.sabah);
      break;
    case 'sarawak':
      districtName = getCityName(addresses, Globals.sarawak);
      break;
    case 'selangor':
      districtName = getCityName(addresses, Globals.selangor);
      break;
    case 'terengganu':
      districtName = getCityName(addresses, Globals.terengganu);
      break;
    case 'putrajaya':
      districtName = 'Putrajaya';
      break;
    case 'Kuala Lumpur':
      districtName = 'Kuala Lumpur';
      break;
    case 'labuan':
      districtName = 'Labuan';
      break;

    default:
      districtName = '';
  }

  return districtName;
}

String getCityName(List<Placemark> addresses, List<String> cities) {
  String district = addresses.first.locality!;
  addresses.forEach((element) {
    cities.forEach((elementttt) {
      if (element.street
          .toString()
          .toLowerCase()
          .contains(elementttt.toLowerCase())) {
        district = elementttt;
      }
    });
  });

  return district;
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 10, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 26, kToday.day);
