import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:mukim_app/business_logic/cubit/subscription/userstate_cubit.dart';
import 'package:mukim_app/data/models/calendar_event_module.dart';
import 'package:mukim_app/calender_custom/table_calendar.dart';
import 'package:mukim_app/carousel_custom/carousel_slider.dart';
import 'package:mukim_app/presentation/screens/artikel/Artikel_Pilihan_details.dart';
import 'package:mukim_app/presentation/screens/calendar.dart';
import 'package:mukim_app/utils/componants.dart';
import 'package:mukim_app/utils/utils.dart';
import 'package:mukim_app/utils/get_theme_color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:xml/xml.dart';

enum CalendarViews { dates, months, year }

class Takwim_Hijri extends StatefulWidget {
  const Takwim_Hijri({Key? key}) : super(key: key);

  @override
  _Takwim_HijriState createState() => _Takwim_HijriState();
}

class _Takwim_HijriState extends State<Takwim_Hijri>
    with SingleTickerProviderStateMixin {
  String theme = 'default';
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  final headerText = DateFormat('dd MMM yyyy').format(DateTime.now());
  final selectedText = DateFormat.yMd().format(DateTime.now());

  var current = DateFormat('dd MMM yyyy').format(DateTime.now());
  var newHijCal =
      HijriCalendar.fromDate(DateTime.now()).toFormat('dd MMMM yyyy');

  var hijriCal = "";

  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;

  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  final pageAnimationDuration = const Duration(seconds: 1);
  final pageAnimationCurve = Curves.linearToEaseOut;
  final formatAnimationDuration = const Duration(seconds: 1);
  final formatAnimationCurve = Curves.linear;
  final dayHitTestBehavior = HitTestBehavior.opaque;
  final CarouselController _controller = CarouselController();
  DateTime? _currentDateTime;
  DateTime? _selectedDateTime;
  List<Calendar> _sequentialDates = [];
  int? midYear;
  CalendarViews _currentView = CalendarViews.dates;
  String calender = DateFormat('dd MMM yyyy').format(DateTime.now());
  var selectedDate = "";
  final Shader linearGradient = LinearGradient(
    colors: <Color>[
      Color(0xffEC008C),
      Color(0xffFC6767),
    ],
  ).createShader(
    Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
  );
  Map<String, dynamic>? userStateMap;
  List<CalendarEvent> eventsList = [];
  List<CalendarEvent> showingEventsList = [];
  bool loading = true;
  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        theme = prefs.getString('appTheme') ?? 'default';
      });
    });
    _selectedDay = _focusedDay;
    modifyDat();
    if (newHijCal.contains('Jumada Al-Thani')) {
      hijriCal = newHijCal.replaceAll('Jumada Al-Thani', 'Jamadilakhir');
    } else if (newHijCal.contains('Rajab')) {
      hijriCal = newHijCal.replaceAll('Rajab', 'Rejab');
    } else if (newHijCal.contains("Sha'aban")) {
      hijriCal = newHijCal.replaceAll("Sha'aban", "Sya'ban");
    } else if (newHijCal.contains('Ramadan')) {
      hijriCal = newHijCal.replaceAll('Ramadan', 'Ramadhan');
    } else if (newHijCal.contains("Dhu Al-Qi'dah")) {
      hijriCal = newHijCal.replaceAll("Dhu Al-Qi'dah", 'Zulkaedah');
    } else if (newHijCal.contains('Dhu Al-Hijjah')) {
      hijriCal = newHijCal.replaceAll('Dhu Al-Hijjah', 'Zulhijjah');
    } else if (newHijCal.contains("Rabi' Al-Awwal")) {
      hijriCal = newHijCal.replaceAll("Rabi' Al-Awwal", "Rabi'ulawal");
    } else if (newHijCal.contains("Rabi' Al-Thani")) {
      hijriCal = newHijCal.replaceAll("Rabi' Al-Thani", "Rabi'ulakhir");
    } else {
      hijriCal = newHijCal;
    }
    final date = DateTime.now();
    _currentDateTime = DateTime(date.year, date.month);
    _selectedDateTime = DateTime(date.year, date.month, date.day);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() => _getCalendar());
    });
    selectedDate = DateFormat('dd MMM yyyy').format(DateTime.now());

    getEvents();
    super.initState();
  }

  modifyDat() async {
    try {
      http.Response response = await http.get(
        Uri.parse('http://hijrah.mfrapps.com/api/hijrah-api.php'),
      );
      XmlDocument xmlDocument = XmlDocument.parse(response.body);
      // print('~~~~~~~~~~~!!!~~~~~~');
      // print(xmlDocument
      //     .getElement('date')!
      //     .getElement('hijrah')!
      //     .getElement('day')!
      //     .text);
    } catch (e) {
      print(e);
    }
    // _focusedDay
  }

  getEvents() async {
    try {
      String url = 'https://salam.mukminapps.com/api/Hijri';
      var result = await http
          .get(Uri.parse(url), headers: {"Accept": "application/json"});
      List responseBody = jsonDecode(result.body);
      responseBody.first.forEach((element) {
        if (element['status'] == 'enable') {
          String date = HijriCalendar.fromDate(DateTime.parse(element['date']))
              .toFormat('dd MMMM yyyy');
          String modifiedDate = '';

          if (date.contains('Jumada Al-Thani')) {
            modifiedDate = date.replaceAll('Jumada Al-Thani', 'Jamadilakhir');
          } else if (date.contains('Rajab')) {
            modifiedDate = date.replaceAll('Rajab', 'Rejab');
          } else if (date.contains("Sha'aban")) {
            modifiedDate = date.replaceAll("Sha'aban", "Sya'ban");
          } else if (date.contains('Ramadan')) {
            modifiedDate = date.replaceAll('Ramadan', 'Ramadhan');
          } else if (date.contains("Dhu Al-Qi'dah")) {
            modifiedDate = date.replaceAll("Dhu Al-Qi'dah", 'Zulkaedah');
          } else if (date.contains('Dhu Al-Hijjah')) {
            modifiedDate = date.replaceAll('Dhu Al-Hijjah', 'Zulhijjah');
          } else if (date.contains("Rabi' Al-Awwal")) {
            modifiedDate = date.replaceAll("Rabi' Al-Awwal", "Rabi'ulawal");
          } else if (date.contains("Rabi' Al-Thani")) {
            modifiedDate = date.replaceAll("Rabi' Al-Thani", "Rabi'ulakhir");
          } else if (date.contains('Jumada Al-Awwal')) {
            modifiedDate = date.replaceAll('Jumada Al-Awwal', 'Jamadilawwal');
          } else {
            modifiedDate = date;
          }

          eventsList.add(CalendarEvent(
            element['title'],
            'https://salam.mukminapps.com/images/' + element['image'],
            element['date'],
            modifiedDate,
            element['description'],
          ));

          if (DateTime.parse(element['date']).month == _focusedDay.month &&
              DateTime.parse(element['date']).year == _focusedDay.year) {
            showingEventsList.add(CalendarEvent(
              element['title'],
              'https://salam.mukminapps.com/images/' + element['image'],
              element['date'],
              modifiedDate,
              element['description'],
            ));
          }
        }
      });

      if (showingEventsList.length > 1) {
        showingEventsList.sort((a, b) => a.date.compareTo(b.date));
      }

      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      print(e);
    }
  }

  getChangedMonthEvents() async {
    setState(() {
      loading = true;
    });
    showingEventsList.clear();

    for (CalendarEvent event in eventsList) {
      if (DateTime.parse(event.date).month == _focusedDay.month &&
          DateTime.parse(event.date).year == _focusedDay.year) {
        showingEventsList.add(event);
        print('PPPPP____${event.title} ${event.date}');
      }
    }

    setState(() {
      loading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<String> hero = ['Event', 'Ramadan', 'Sayawal', 'Syaaban'];

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    newHijCal = HijriCalendar.fromDate(selectedDay).toFormat('dd MMMM yyyy');
    if (newHijCal.contains('Jumada Al-Thani')) {
      hijriCal = newHijCal.replaceAll('Jumada Al-Thani', 'Jamadilakhir');
    } else if (newHijCal.contains('Rajab')) {
      hijriCal = newHijCal.replaceAll('Rajab', 'Rejab');
    } else if (newHijCal.contains("Sha'aban")) {
      hijriCal = newHijCal.replaceAll("Sha'aban", "Sya'ban");
    } else if (newHijCal.contains('Ramadan')) {
      hijriCal = newHijCal.replaceAll('Ramadan', 'Ramadhan');
    } else if (newHijCal.contains("Dhu Al-Qi'dah")) {
      hijriCal = newHijCal.replaceAll("Dhu Al-Qi'dah", 'Zulkaedah');
    } else if (newHijCal.contains('Dhu Al-Hijjah')) {
      hijriCal = newHijCal.replaceAll('Dhu Al-Hijjah', 'Zulhijjah');
    } else if (newHijCal.contains("Rabi' Al-Awwal")) {
      hijriCal = newHijCal.replaceAll("Rabi' Al-Awwal", "Rabi'ulawal");
    } else if (newHijCal.contains("Rabi' Al-Thani")) {
      hijriCal = newHijCal.replaceAll("Rabi' Al-Thani", "Rabi'ulakhir");
    } else if (newHijCal.contains('Jumada Al-Awwal')) {
      hijriCal = newHijCal.replaceAll('Jumada Al-Awwal', 'Jamadilawwal');
    } else {
      hijriCal = newHijCal;
    }
    setState(() {
      _selectedDay = selectedDay;
      if (_selectedDay != null) {
        current = DateFormat('dd MMM yyyy').format(selectedDay);
      }
      _focusedDay = focusedDay;
      _rangeStart = null; // Important to clean those
      _rangeEnd = null;
      _rangeSelectionMode = RangeSelectionMode.toggledOff;
    });
  }

  int _currentIndex = 0;
  Tween<Offset> _offset = Tween(begin: Offset(1, 0), end: Offset(0, 1));
  @override
  Widget build(BuildContext context) {
    userStateMap = BlocProvider.of<UserStateCubit>(context).checkUserState();
    return SafeArea(
      top: false,
      child: Scaffold(
          backgroundColor: Color(0xff3A343D),
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
            body: Column(children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 100,
                decoration: BoxDecoration(
                    image: new DecorationImage(
                        image: AssetImage(
                          "assets/theme/${theme ?? "default"}/appbar.png",
                        ),
                        fit: BoxFit.cover)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 50, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Takwim Hijri",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      toolbarHeight: 350,
                      leading: Container(),
                      backgroundColor: Colors.transparent,
                      flexibleSpace: Padding(
                        padding: const EdgeInsets.only(
                            left: 10.0, right: 10.0, top: 10.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: new BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(20)),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(9.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        setState(
                                            () => _focusedDay = DateTime.now());
                                      },
                                      child: Icon(
                                        Icons.date_range,
                                        color: getColor(theme),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Text(hijriCal,
                                          style: TextStyle(
                                              color: Color(0xffFFFFFF),
                                              fontSize: 18,
                                              fontStyle: FontStyle.normal,
                                              fontWeight: FontWeight.w700)),
                                    ),
                                    Spacer(),
                                    Text(
                                      current.toString(),
                                      style: TextStyle(
                                        color: getColor(theme),
                                        fontSize: 12,
                                        fontStyle: FontStyle.normal,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              TableCalendar<Event>(
                                daysOfWeekVisible: true,
                                rowHeight: 50,
                                daysOfWeekHeight: 25,
                                daysOfWeekStyle: DaysOfWeekStyle(
                                  weekdayStyle: TextStyle(
                                      color: Color(0xffFFFFFF),
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.normal,
                                      fontSize: 17),
                                  weekendStyle: TextStyle(
                                      color: Color(0xffFFFFFF),
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.normal,
                                      fontSize: 17),
                                  dowTextFormatter: (date, locale) =>
                                      DateFormat.E(locale).format(date)[0],
                                ),
                                locale: 'ms_MS',
                                headerVisible: false,
                                firstDay: kFirstDay,
                                lastDay: kLastDay,
                                focusedDay: _focusedDay,
                                selectedDayPredicate: (day) =>
                                    isSameDay(_selectedDay!, day),
                                rangeStartDay: _rangeStart,
                                rangeEndDay: _rangeEnd,
                                calendarFormat: _calendarFormat,
                                rangeSelectionMode: _rangeSelectionMode,
                                startingDayOfWeek: StartingDayOfWeek.monday,
                                calendarStyle: CalendarStyle(
                                  markerDecoration: new BoxDecoration(
                                      color: getColor(theme),
                                      shape: BoxShape.rectangle),
                                  weekendTextStyle:
                                      TextStyle(color: Colors.white),
                                  selectedDecoration: new BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        begin: Alignment.topRight,
                                        end: Alignment.bottomLeft,
                                        colors: [
                                          Color(0xffEC008C),
                                          Color(0xffFC6767),
                                        ],
                                      )),
                                  defaultTextStyle:
                                      TextStyle(color: Colors.white),
                                  outsideDaysVisible: false,
                                ),
                                onDaySelected: _onDaySelected,
                                onPageChanged: (focusedDay) {
                                  _focusedDay = focusedDay;
                                  _selectedDay = DateTime(focusedDay.year,
                                      focusedDay.month, _selectedDay!.day);

                                  _onDaySelected(_selectedDay!, _focusedDay);

                                  getChangedMonthEvents();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 20)),
                    SliverList(
                        delegate: SliverChildListDelegate(List.generate(
                            loading ? 4 : showingEventsList.length,
                            (index) => Container(
                                  padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                                  child: Column(children: [
                                    index == 0
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                left: 5.0,
                                                right: 5.0,
                                                bottom: 5),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.dark_mode_outlined,
                                                  color: getColor(theme),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10),
                                                  child: Text(
                                                    "Tarikh & Peristiwa Penting",
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xffFFFFFF),
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FontStyle.normal),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Container(),
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    Artikel_Pilihan_details(
                                                      showingEventsList[index]
                                                          .calendar,
                                                      showingEventsList[index]
                                                          .description,
                                                      showingEventsList[index]
                                                          .img,
                                                      true,
                                                    )));
                                      },
                                      child: Row(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child: Hero(
                                              tag: loading
                                                  ? 'coin$index'
                                                  : 'coin${showingEventsList[index].img}',
                                              child: loading
                                                  ? Shimmer.fromColors(
                                                      enabled: true,
                                                      child: Container(
                                                        height: 60,
                                                        width: 60,
                                                        decoration:
                                                            new BoxDecoration(
                                                                color: Color(
                                                                    0xFF383838)),
                                                      ),
                                                      baseColor:
                                                          Color(0xFF383838),
                                                      highlightColor:
                                                          Color(0xFF484848),
                                                    )
                                                  : Image.network(
                                                      showingEventsList[index]
                                                          .img,
                                                      width: 60,
                                                      height: 60,
                                                      fit: BoxFit.cover,
                                                      frameBuilder: (context,
                                                          child,
                                                          frame,
                                                          wasSynchronouslyLoaded) {
                                                      if (frame == null) {
                                                        return Shimmer
                                                            .fromColors(
                                                          enabled: true,
                                                          child: Container(
                                                              height: 60,
                                                              width: 60,
                                                              color: Color(
                                                                  0xFF383838)),
                                                          baseColor:
                                                              Color(0xFF383838),
                                                          highlightColor:
                                                              Color(0xFF484848),
                                                        );
                                                      }

                                                      return child;
                                                    }),
                                            ),
                                          ),
                                          Expanded(
                                            child: ListTile(
                                                title: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5, bottom: 5),
                                                  child: loading
                                                      ? Shimmer.fromColors(
                                                          enabled: true,
                                                          child: Container(
                                                              height: 12,
                                                              width: 100,
                                                              color: Color(
                                                                  0xFF383838)),
                                                          baseColor:
                                                              Color(0xFF383838),
                                                          highlightColor:
                                                              Color(0xFF484848),
                                                        )
                                                      : Text(
                                                          showingEventsList[
                                                                  index]
                                                              .calendar,
                                                          style: TextStyle(
                                                              color: getColor(
                                                                  theme),
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .normal),
                                                        ),
                                                ),
                                                subtitle: loading
                                                    ? Shimmer.fromColors(
                                                        enabled: true,
                                                        child: Container(
                                                            height: 35,
                                                            width: 200,
                                                            color: Color(
                                                                0xFF383838)),
                                                        baseColor:
                                                            Color(0xFF383838),
                                                        highlightColor:
                                                            Color(0xFF484848),
                                                      )
                                                    : Text(
                                                        showingEventsList[index]
                                                            .description,
                                                        maxLines: 3,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xffFFFFFF),
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontStyle:
                                                              FontStyle.normal,
                                                        ),
                                                      )),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5, bottom: 5),
                                      child: Container(
                                        height: 1,
                                        color: Color(0xff787878),
                                      ),
                                    ),
                                  ]),
                                )))),
                    SliverToBoxAdapter(child: SizedBox(height: 50)),
                  ],
                ),
              ),
            ]),
          )),
    );
  }

  void _getCalendar() {
    _sequentialDates = CustomCalendar().getMonthCalendar(
      _currentDateTime!.month,
      _currentDateTime!.year,
      startWeekDay: StartWeekDay.monday,
    );
  }
}
