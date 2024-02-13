import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukim_app/business_logic/cubit/subscription/userstate_cubit.dart';
import 'package:mukim_app/data/api/adhan_api.dart';
import 'package:mukim_app/data/models/month_prayer_model.dart';
import 'package:mukim_app/presentation/screens/MasjidBerhampiran.dart';
import 'package:mukim_app/presentation/screens/qiblat/kiblat_kaba.dart';
import 'package:mukim_app/presentation/screens/qiblat/search.dart';
import 'package:mukim_app/presentation/screens/qiblat/simple_google_earth.dart';
import 'package:mukim_app/presentation/screens/zikir/homeScreen.dart';
import 'package:mukim_app/resources/Imageresources.dart';
import 'package:mukim_app/utils/utils.dart';
import 'package:mukim_app/utils/video_player_360.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:mukim_app/utils/componants.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:weather/weather.dart';
import 'package:weather_icons/weather_icons.dart';

import 'compasses_choises.dart';

class TakwimSolat extends StatefulWidget {
  final String cityName;
  final String? zone;

  const TakwimSolat({required this.cityName, this.zone});

  @override
  _TakwimSolatState createState() => _TakwimSolatState();
}

class _TakwimSolatState extends State<TakwimSolat> {
  List<String> azans = ['Imsak', 'Subuh', 'Zohor', 'Asar', 'Maghrib', 'Isyak'];
  List<String> solats = [
    'Tarikh',
    'Imsak',
    'Subuh',
    'Syuruk',
    'Zohor',
    'Asar',
    'Maghrib',
    'Isyak'
  ];

  List<IconData> icons = [
    WeatherIcons.night_alt_cloudy_high,
    WeatherIcons.sunrise,
    WeatherIcons.day_cloudy,
    WeatherIcons.cloud,
    WeatherIcons.sunset,
    WeatherIcons.night_clear
  ];
  bool amFlag = false;
  var _today = HijriCalendar.now();
  String hijriNewMonthName = '';
  WeatherFactory wf = WeatherFactory('856822fd8e22db5e1ba48c0e7d69844a');
  Weather? x;
  int compassDesign = 0;

  DateTime anyDay(int hYear, int hMonth, int hDay) {
    return HijriCalendar().hijriToGregorian(hYear, hMonth, hDay);
  }

  Future<List<DateTime>> prayers(int hYear, int hMonth, int hDay) async {
    return [];
  }

  String hours(DateTime t) {
    if (t.hour <= 12) {
      amFlag = true;
      return t.hour.toString();
    } else if (t.hour > 12) {
      amFlag = false;
      return (t.hour - 12).toString();
    } else {
      return '00';
    }
  }

  @override
  void initState() {
    super.initState();
    initShared();
    if (_today.longMonthName.contains('Jumada Al-Thani')) {
      hijriNewMonthName =
          _today.longMonthName.replaceAll('Jumada Al-Thani', 'Jamadilakhir');
    } else if (_today.longMonthName.contains('Rajab')) {
      hijriNewMonthName = _today.longMonthName.replaceAll('Rajab', 'Rejab');
    } else if (_today.longMonthName.contains("Sha'aban")) {
      hijriNewMonthName =
          _today.longMonthName.replaceAll("Sha'aban", "Sya'ban");
    } else if (_today.longMonthName.contains('Ramadan')) {
      hijriNewMonthName =
          _today.longMonthName.replaceAll('Ramadan', 'Ramadhan');
    } else if (_today.longMonthName.contains("Dhu Al-Qi'dah")) {
      hijriNewMonthName =
          _today.longMonthName.replaceAll("Dhu Al-Qi'dah", 'Zulkaedah');
    } else if (_today.longMonthName.contains('Dhu Al-Hijjah')) {
      hijriNewMonthName =
          _today.longMonthName.replaceAll('Dhu Al-Hijjah', 'Zulhijjah');
    } else if (_today.longMonthName.contains("Rabi' Al-Awwal")) {
      hijriNewMonthName =
          _today.longMonthName.replaceAll("Rabi' Al-Awwal", "Rabi'ulawal");
    } else if (_today.longMonthName.contains("Rabi' Al-Thani")) {
      hijriNewMonthName =
          _today.longMonthName.replaceAll("Rabi' Al-Thani", "Rabi'ulakhir");
    } else {
      hijriNewMonthName = _today.longMonthName;
    }
    try {
      prayers(1432, 1, 1).then((value) => null).onError((error, stackTrace) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                    content: Text(
                        "${error.toString().contains(RegExp('city not found')) ? 'not valid city name' : 'some thing goes wrong check internet connection'}"),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("ok")),
                    ]));
      });
    } catch (e) {}
  }

  initShared() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    compassDesign = prefs.getInt('compassDesign') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: HexColor('3A343D'),
        body: DefaultTabController(
          length: 2,
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  backgroundColor: HexColor('3A343D'),
                  expandedHeight: width * 0.267,
                  floating: true,
                  pinned: false,
                  snap: true,
                  leading: Container(),
                  actionsIconTheme: IconThemeData(opacity: 0.01),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      alignment: Alignment.centerRight,
                      children: <Widget>[
                        FutureBuilder<SharedPreferences>(
                          future: SharedPreferences.getInstance(),
                          builder: (context, snapshot) {
                            String? theme;
                            if (snapshot.hasData) {
                              theme = snapshot.data!.getString('appTheme');
                            }
                            return Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                    "assets/theme/${theme ?? "default"}/appbar.png",
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                        Positioned(
                          left: 0,
                          bottom: 20,
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: InkWell(
                                  onTap: () => Navigator.pop(context),
                                  child: Image.asset(
                                    ImageResource.leftArrow,
                                    height: 24,
                                    width: 24,
                                  ),
                                ),
                              ),
                              Text(
                                "Takwin Solat",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: GestureDetector(
                                  onTap: () {},
                                  child: Icon(
                                    Icons.settings_outlined,
                                    size: 24,
                                    color: Colors.transparent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
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
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //the city name upp the screen
                    Center(
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => SearchScreen(
                                oldCity: widget.cityName,
                                oldZone: widget.zone,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/main_screen_icons/city_arr.png',
                                width: 25,
                                height: 25,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Container(
                                //width: 200,
                                child: Text(
                                  ' ${widget.zone}',
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    //Higri Takwim
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: HexColor('1b1b1b'),
                        ),
                        height: 35,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            InkWell(
                              onTap: decreaseMonth,
                              child: Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                    DateFormat('LLL yyyy').format(
                                        _today.hijriToGregorian(_today.hYear,
                                            _today.hMonth, _today.hDay)),
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.white)),
                                Text(
                                    '($hijriNewMonthName' +
                                        ' ' +
                                        '${_today.hYear}' +
                                        ' H)',
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.white)),
                              ],
                            ),
                            InkWell(
                              onTap: increaseMonth,
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    //month Solat name heading
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: Row(
                            children: [
                              SizedBox(width: 8),
                              ...List.generate(
                                  solats.length,
                                  (index) => Expanded(
                                        flex: 1,
                                        child: Text(
                                          solats[index],
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 11),
                                        ),
                                      )),
                              SizedBox(width: 8),
                            ],
                          ),
                        ),
                        FutureBuilder<MonthPrayerModel>(
                          future: Api.fetchMonthPrayers(
                            widget.zone!,
                            _today
                                .hijriToGregorian(
                                    _today.hYear, _today.hMonth, _today.hDay)
                                .month
                                .toString(),
                            _today
                                .hijriToGregorian(
                                    _today.hYear, _today.hMonth, _today.hDay)
                                .year
                                .toString(),
                          ),
                          builder: (context, snapshot) {
                            if (!(snapshot.hasData) && snapshot.data == null) {
                              return ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: 30,
                                itemBuilder: (context, index) {
                                  return prayerTile(
                                    (index + 1).toString(),
                                    'waiting',
                                    'waiting',
                                    'waiting',
                                    'waiting',
                                    'waiting',
                                    'waiting',
                                    'waiting',
                                    (index % 2) == 0,
                                  );
                                },
                              );
                            } else {
                              var month = snapshot.data;
                              var prayers = month!.prayerTimes;

                              return ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: month.prayerTimes.length,
                                itemBuilder: (context, index) {
                                  var prayer = prayers[index];
                                  String date = prayer.date!;

                                  return prayerTile(
                                    date.toString().substring(0, 2),
                                    prayer.imsak!.split('(').first,
                                    prayer.subuh!.split('(').first,
                                    prayer.syuruk!.split('(').first,
                                    prayer.zohor!.split('(').first,
                                    prayer.asar!.split('(').first,
                                    prayer.maghrib!.split('(').first,
                                    prayer.isyak!.split('(').first,
                                    (index % 2) == 0,
                                  );
                                },
                              );
                            }
                          },
                        )
                      ],
                    ),

                    //the 6 options under the screen
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      child: Container(
                        height: 160,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 16,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context)
                                        .pushReplacement(MaterialPageRoute(
                                            builder: (context) => TakwimSolat(
                                                  cityName: widget.cityName,
                                                )));
                                  },
                                  child: Container(
                                    width: (width - 50) / 2,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                      color: HexColor('524D9F'),
                                      gradient: LinearGradient(
                                          begin: Alignment.centerRight,
                                          end: Alignment.centerLeft,
                                          colors: [
                                            HexColor('FC6767'),
                                            HexColor('EC008C'),
                                          ]),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Icon(
                                          Icons.calendar_today,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text('Takwim Solat',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w400))
                                      ],
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    navigateTo(
                                        context: context,
                                        screen: MasjidBerhampiran());
                                  },
                                  child: Container(
                                    width: (width - 50) / 2,
                                    height: 32,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
                                        color: HexColor('524D9F')),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Image.asset(
                                          'assets/images/main_screen_icons/masjid_icon.png',
                                          width: 16,
                                          height: 16,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text('Masjid Berhampiran',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w400))
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    navigateTo(
                                        context: context, screen: Zikir());
                                  },
                                  child: Container(
                                    width: (width - 50) / 2,
                                    height: 32,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
                                        color: HexColor('524D9F')),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Image.asset(
                                          'assets/images/main_screen_icons/zikir_icon.png',
                                          width: 16,
                                          height: 16,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text('Zikir',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w400))
                                      ],
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) => SearchScreen(
                                          oldCity: widget.cityName,
                                          oldZone: widget.zone,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: (width - 50) / 2,
                                    height: 32,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
                                        color: HexColor('524D9F')),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Image.asset(
                                          'assets/images/main_screen_icons/tukas_lukasi.png',
                                          width: 16,
                                          height: 16,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text('Tukar Lokasi',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w400))
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) => TrianglesLine(
                                            oldCity: widget.cityName,
                                            oldDistrict: widget.zone!),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: (width - 50) / 2,
                                    height: 32,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
                                        color: HexColor('524D9F')),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Icon(
                                          Icons.view_in_ar,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text('Augmented Reality',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w400))
                                      ],
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    await showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                                insetPadding:
                                                    EdgeInsets.all(10),
                                                elevation: 203,
                                                title: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    SizedBox(
                                                      width: 30,
                                                    ),
                                                    Text(
                                                      'Premium',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: Colors.white,
                                                          fontSize: 18),
                                                    ),
                                                    InkWell(
                                                      child: Icon(
                                                        Icons
                                                            .highlight_remove_outlined,
                                                        color: Colors.white,
                                                      ),
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    )
                                                  ],
                                                ),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8)),
                                                backgroundColor:
                                                    HexColor('3A343D'),
                                                content: Text(
                                                  'Fungsi ini adalah untuk pengguna akaun Premium sahaja. Sila\nnaiktaraf ke akan Premium untuk menggunakan fungsi ini.',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                                actions: [
                                                  Center(
                                                    child: InkWell(
                                                        onTap: () {
                                                          //write your premium here
                                                          Navigator.of(context)
                                                              .pop();
                                                          Navigator.of(context)
                                                              .pushReplacement(
                                                                  MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          CmpassTheme(
                                                                            oldCity:
                                                                                widget.cityName,
                                                                            oldDistrict:
                                                                                widget.zone!,
                                                                          )));
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(12.0),
                                                          child: Container(
                                                            height: 32,
                                                            width: 168,
                                                            decoration: BoxDecoration(
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            5)),
                                                                color: HexColor(
                                                                    '524D9F')),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Image.asset(
                                                                  './assets/images/main_screen_icons/external_link_icon.png',
                                                                  height: 16,
                                                                  width: 16,
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text(
                                                                  "Naik taraf akaun",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          10),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        )),
                                                  ),
                                                ]));
                                  },
                                  child: Container(
                                    width: (width - 50) / 2,
                                    height: 32,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
                                        color: HexColor('524D9F')),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Image.asset(
                                          'assets/images/main_screen_icons/compass_icon.png',
                                          width: 16,
                                          height: 16,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text('Design Kiblat (Premium)',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w400))
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SimpleGoogleEarth()),
                                    );
                                  },
                                  child: Container(
                                    width: (width - 50) / 2,
                                    height: 32,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
                                        color: HexColor('524D9F')),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Icon(
                                          Icons.public,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text('3D Earth Globes',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w400))
                                      ],
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    await VideoPlayer360.playVideoURL(
                                        "https://salam.mukminapps.com/images/makkah360.jpg",
                                        showPlaceholder: true,
                                        context: context);
                                  },
                                  child: Container(
                                    width: (width - 50) / 2,
                                    height: 32,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
                                        color: HexColor('524D9F')),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Image.asset(
                                          ImageResource.kaaba360,
                                          color: Colors.white,
                                          height: 16,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text('Kaaba 360˚',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w400))
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 100)
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void increaseMonth() {
    _today.hMonth += 1;

    var date =
        _today.hijriToGregorian(_today.hYear, _today.hMonth, _today.hDay);

    setState(() {});

    int hMonth;
    if (_today.hMonth > 12) {
      hMonth = _today.hMonth - 12;
    } else if (_today.hMonth < 1) {
      hMonth = _today.hMonth + 12;
    } else {
      hMonth = _today.hMonth;
    }

    if (hMonth == 1) {
      hijriNewMonthName = 'Muharram';
    } else if (hMonth == 2) {
      hijriNewMonthName = 'Safar';
    } else if (hMonth == 3) {
      hijriNewMonthName = "Rabi'ulawal";
    } else if (hMonth == 4) {
      hijriNewMonthName = "Rabi'ulakhir";
    } else if (hMonth == 5) {
      hijriNewMonthName = 'Jamadilawwal';
    } else if (hMonth == 6) {
      hijriNewMonthName = 'Jamadilakhir';
    } else if (hMonth == 7) {
      hijriNewMonthName = 'Rejab';
    } else if (hMonth == 8) {
      hijriNewMonthName = "Sya'ban";
    } else if (hMonth == 9) {
      hijriNewMonthName = 'Ramadhan';
    } else if (hMonth == 10) {
      hijriNewMonthName = 'Shawwal';
    } else if (hMonth == 11) {
      hijriNewMonthName = 'Zulkaedah';
    } else if (hMonth == 12) {
      hijriNewMonthName = 'Zulhijjah';
    } else {
      hijriNewMonthName = _today.longMonthName;
    }
    setState(() {});
  }

  void decreaseMonth() {
    _today.hMonth -= 1;
    var date =
        _today.hijriToGregorian(_today.hYear, _today.hMonth, _today.hDay);

    int hMonth;
    if (_today.hMonth > 12) {
      hMonth = _today.hMonth - 12;
    } else if (_today.hMonth < 1) {
      hMonth = _today.hMonth + 12;
    } else {
      hMonth = _today.hMonth;
    }
    hijriNewMonthName = getHijriMonthName(hMonth);

    setState(() {});
  }

  Widget prayerTile(
    String date,
    String imsak,
    String subuh,
    String syuruk,
    String zohor,
    String asar,
    String maghrib,
    String isyak,
    bool gray,
  ) {
    var style = TextStyle(fontSize: 11, color: Colors.white);
    DateTime now = DateTime.now();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          color: now.day == int.parse(date)
              ? HexColor('1B1B1B')
              : gray
                  ? Color(0xFF2E2B30)
                  : Colors.transparent,
          gradient: (now.day == int.parse(date))
              ? LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [HexColor("EC008C"), HexColor('FC6767')])
              : null),
      child: Row(
        children: [
          SizedBox(width: 8),
          Expanded(
              flex: 1,
              child: Text(date, style: style, textAlign: TextAlign.center)),
          Expanded(
              flex: 1,
              child: Text(imsak, style: style, textAlign: TextAlign.center)),
          Expanded(
              flex: 1,
              child: Text(subuh, style: style, textAlign: TextAlign.center)),
          Expanded(
              flex: 1,
              child: Text(syuruk, style: style, textAlign: TextAlign.center)),
          Expanded(
              flex: 1,
              child: Text(zohor, style: style, textAlign: TextAlign.center)),
          Expanded(
              flex: 1,
              child: Text(asar, style: style, textAlign: TextAlign.center)),
          Expanded(
              flex: 1,
              child: Text(maghrib, style: style, textAlign: TextAlign.center)),
          Expanded(
              flex: 1,
              child: Text(isyak, style: style, textAlign: TextAlign.center)),
          SizedBox(width: 8),
        ],
      ),
    );
  }
}
