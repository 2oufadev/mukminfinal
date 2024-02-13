import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:mukim_app/business_logic/cubit/subscription/userstate_cubit.dart';
import 'package:mukim_app/presentation/screens/qiblat/main_screen.dart';
import 'package:mukim_app/presentation/screens/settings/naik_taraf.dart';
import 'package:mukim_app/presentation/widgets/qiblat/compass_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CmpassTheme extends StatefulWidget {
  final String oldCity, oldDistrict;

  const CmpassTheme(
      {Key? key, required this.oldCity, required this.oldDistrict})
      : super(key: key);

  @override
  _CmpassThemeState createState() => _CmpassThemeState();
}

class _CmpassThemeState extends State<CmpassTheme> {
  int design = 0;
  bool subscribed = false;
  late SharedPreferences sharedPreferences;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initShared();
  }

  initShared() async {
    sharedPreferences = await SharedPreferences.getInstance();
    design = sharedPreferences.getInt('compassDesign') ?? 0;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: HexColor('3A343D'),
      appBar: PreferredSize(
        child: Container(
          decoration: BoxDecoration(),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
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
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    'Tukar Tema Kompas',
                    style: Theme.of(context)
                        .textTheme
                        .headline6!
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => Kibat2(
                          cityName: widget.oldCity,
                          zone: widget.oldDistrict,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0, left: 20),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        preferredSize: Size.fromHeight(
          width * 0.267,
        ),
      ),
      body: BlocBuilder<UserStateCubit, UserState>(builder: (context, state) {
        if (state is LoginState) {
          subscribed = state.userStateMap!['subscribed'];
        }
        return Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () {
                    if (design != 0 && design != 1) {
                      design = 1;
                      sharedPreferences.setInt('compassDesign', 1);
                      setState(() {});
                    }
                  },
                  child: Container(
                    width: height / 5,
                    height: height / 5,
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 2,
                            color: design == 1 || design == 0
                                ? Colors.yellow
                                : HexColor('1b1b1b')),
                        borderRadius: BorderRadius.circular(5),
                        color: HexColor('1b1b1b')),
                    child: Center(
                      child: Transform.scale(
                          alignment: Alignment.center,
                          scale: (height / 5) / (width / 1.7),
                          child: Compass1(
                              design: 1, scaled: (height / 5) / (width / 1.7))),
                    ),
                  ),
                ),
                Stack(
                  children: [
                    InkWell(
                      onTap: () {
                        if (subscribed) {
                          design = 2;
                          sharedPreferences.setInt('compassDesign', 2);
                          setState(() {});
                        } else {
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (context) => NaikTarafScreen()))
                              .then((value) {
                            setState(() {});
                          });
                        }
                      },
                      child: Container(
                        width: height / 5,
                        height: height / 5,
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 2,
                                color: design == 2
                                    ? Colors.yellow
                                    : HexColor('1b1b1b')),
                            borderRadius: BorderRadius.circular(5),
                            color: HexColor('1b1b1b')),
                        child: Center(
                          child: Transform.scale(
                              scale: (height / 5) / (width / 1.7),
                              child: Compass1(
                                  design: 2,
                                  scaled: (height / 5) / (width / 1.7))),
                        ),
                      ),
                    ),
                    subscribed
                        ? Container()
                        : Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: subscribed
                                    ? Colors.transparent
                                    : Colors.black26),
                            height: height / 5,
                            width: height / 5,
                            child:
                                Icon(Icons.lock, color: Colors.white, size: 40),
                          )
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Stack(
                  children: [
                    InkWell(
                      onTap: () {
                        if (subscribed) {
                          design = 3;
                          sharedPreferences.setInt('compassDesign', 3);
                          setState(() {});
                        } else {
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (context) => NaikTarafScreen()))
                              .then((value) {
                            setState(() {});
                          });
                        }
                      },
                      child: Container(
                        width: height / 5,
                        height: height / 5,
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 2,
                                color: design == 3
                                    ? Colors.yellow
                                    : HexColor('1b1b1b')),
                            borderRadius: BorderRadius.circular(5),
                            color: HexColor('1b1b1b')),
                        child: Center(
                          child: Transform.scale(
                              scale: (height / 5) / (width / 1.7),
                              child: Compass1(
                                design: 3,
                                scaled: (height / 5) / (width / 1.7),
                              )),
                        ),
                      ),
                    ),
                    subscribed
                        ? Container()
                        : Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.black26),
                            height: height / 5,
                            width: height / 5,
                            child:
                                Icon(Icons.lock, color: Colors.white, size: 40),
                          )
                  ],
                ),
                Container(
                  width: height / 5,
                  height: height / 5,
                ),
              ],
            )
          ],
        );
      }),
    );
  }
}
