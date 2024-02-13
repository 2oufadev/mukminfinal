import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukim_app/business_logic/cubit/subscription/userstate_cubit.dart';
import 'package:mukim_app/presentation/screens/Surah/surah_tajweed.dart';
import 'package:mukim_app/presentation/widgets/word_card.dart';
import 'package:mukim_app/resources/global.dart';
import 'package:mukim_app/utils/componants.dart';
import 'package:mukim_app/providers/theme.dart';
import 'package:page_transition/page_transition.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:mukim_app/utils/get_theme_color.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SurahWordTajweed extends StatefulWidget {
  SurahWordTajweed({Key? key}) : super(key: key);

  var chapnum = '1';
  var urduName;
  var engName;
  var surahs;

  SurahWordTajweed.setChap(
    var chapnum,
    var urduName,
    var engName,
    var surahs,
  ) {
    this.chapnum = chapnum;
    this.urduName = urduName;
    this.engName = engName;
    this.surahs = surahs;
  }

  @override
  _SurahWordTajweedState createState() => _SurahWordTajweedState();
}

class _SurahWordTajweedState extends State<SurahWordTajweed> {
  int ind = 1;
  int len = 1;
  Map<String, dynamic>? userStateMap;
  getWordsTajweedBySurah(var chapnum) async {
    try {
      String url = 'https://api.quran.com/api/v4/verses/by_chapter/' +
          chapnum +
          '?language=ms&words=true&per_page=1000&word_fields=text_uthmani,text_imlaei,text_indopak&fields=text_uthmani_tajweed&page=' +
          ind.toString();
      var result = await http
          .get(Uri.parse(url), headers: {"Accept": "application/json"});
      var responseBody = jsonDecode(result.body);
      return responseBody;
    } catch (e) {
      return e;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    Globals.wordIndex = 0;
    Globals.wordVerseKey = '1:1';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String theme = Provider.of<ThemeNotifier>(context).appTheme;
    userStateMap = BlocProvider.of<UserStateCubit>(context).checkUserState();
    return SafeArea(
      top: false,
      child: Scaffold(
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
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: Color(0xff3a343d),
            ),
            child: Column(
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          "assets/theme/${theme ?? "default"}/appbar.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(30, 40, 30, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 3 - 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          PageTransition(
                                              type: PageTransitionType
                                                  .leftToRightWithFade,
                                              child: SurahTajweed.set(
                                                  widget.chapnum,
                                                  widget.urduName,
                                                  widget.engName,
                                                  widget.surahs,
                                                  null,
                                                  null)));
                                    },
                                    icon: const Icon(
                                      Icons.arrow_back_ios,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 3 - 20,
                              child: const Center(
                                child: Text(
                                  "Tajweed",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 3 - 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder(
                    future: getWordsTajweedBySurah(widget.chapnum),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      try {
                        var snap = snapshot.data;
                        len = snap['pagination']['total_pages'];

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                              child: CircularProgressIndicator(
                            color: getColor(theme),
                          ));
                        }
                        if (snapshot.hasError) {
                          return const SnackBar(
                            content: Text('No Internet Connection'),
                          );
                        }

                        return ListView.builder(
                            itemCount: snap['verses'].length,
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) {
                              return WordCard(
                                  data: snap['verses'][index],
                                  audioList: snap['verses'][index]['words']);
                            });
                      } catch (e) {
                        return Center(
                            child: CircularProgressIndicator(
                          color: getColor(theme),
                        ));
                      }
                    },
                  ),
                ),
                Container(
                  height: 10,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
