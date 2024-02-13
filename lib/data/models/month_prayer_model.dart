class MonthPrayerModel {
  List<PrayerModel> prayerTimes;

  MonthPrayerModel(this.prayerTimes);

  factory MonthPrayerModel.fromJson(json) {
    return MonthPrayerModel(
      (json['prayerTime'] as List).map((e) => PrayerModel.fromJson(e)).toList(),
    );
  }
}

class PrayerModel {
  String? date;
  int? dateStamp;
  String? imsak;
  String? subuh;
  String? syuruk;
  String? zohor;
  String? asar;
  String? maghrib;
  String? isyak;

  PrayerModel(
    this.date,
    this.imsak,
    this.subuh,
    this.syuruk,
    this.zohor,
    this.asar,
    this.maghrib,
    this.isyak,
  );

  factory PrayerModel.fromJson(json) {
    String imsak = json['imsak'];
    String fajr = json['fajr'];
    String syuruk = json['syuruk'];
    String dhuhr = json['dhuhr'];
    String asr = json['asr'];
    String maghrib = json['maghrib'];
    String isha = json['isha'];
    return PrayerModel(
      json['date'],
      imsak.toString().substring(0, imsak.length - 3),
      fajr.toString().substring(0, fajr.length - 3),
      syuruk.toString().substring(0, syuruk.length - 3),
      dhuhr.toString().substring(0, dhuhr.length - 3),
      asr.toString().substring(0, asr.length - 3),
      maghrib.toString().substring(0, maghrib.length - 3),
      isha.toString().substring(0, isha.length - 3),
    );
  }
}
