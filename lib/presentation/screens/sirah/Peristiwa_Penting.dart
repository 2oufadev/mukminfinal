import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukim_app/business_logic/cubit/subscription/userstate_cubit.dart';
import 'package:mukim_app/resources/Imageresources.dart';
import 'package:mukim_app/utils/componants.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:mukim_app/utils/get_theme_color.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Peristiwa_Penting extends StatefulWidget {
  const Peristiwa_Penting({Key? key}) : super(key: key);

  @override
  _Peristiwa_PentingState createState() => _Peristiwa_PentingState();
}

class _Peristiwa_PentingState extends State<Peristiwa_Penting> {
  var Tag;
  String theme = 'default';
  Map<String, dynamic>? userStateMap;
  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        theme = prefs.getString('appTheme') ?? 'default';
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    Tag = arguments['tag'];
    userStateMap = BlocProvider.of<UserStateCubit>(context).checkUserState();
    return SafeArea(
      top: false,
      child: Scaffold(
          backgroundColor: Color(0xff3A343D),
          body: SlidingUpPanel(
            minHeight: 64,
            maxHeight: 265,
            // maxHeight: 265,
            color: Colors.black.withOpacity(0.5),
            panel: BlocBuilder<UserStateCubit, UserState>(
              builder: (context, state) => bottomNavBarWithOpacity(
                  context: context,
                  loggedIn: state is LoginState
                      ? state.userStateMap!['loggedIn']
                      : false),
            ),
            body: Column(
              children: [
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Image.asset(
                            ImageResource.leftArrow,
                            height: 24,
                            width: 24,
                          ),
                        ),
                        Text(
                          "Peristiwa Penting",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                        Container()
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Stack(children: [
                    Positioned(
                      top: 0,
                      right: 0,
                      left: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  "1 Ramadan",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: getColor(theme),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            Container(
                              height: 165,
                              width: MediaQuery.of(context).size.width,
                              child: Hero(
                                  tag: Tag,
                                  child: Image.asset(ImageResource.Ramadan)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ListView.separated(
                      padding: EdgeInsets.only(top: 180),
                      separatorBuilder: (context, index) => Container(),
                      itemCount: 1,
                      itemBuilder: (context, index) => Container(
                        color: Color(0xff3A343D),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, bottom: 16),
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 16, bottom: 16),
                                child: Column(
                                  children: [
                                    Text(
                                      "Peperangan Badar yang berlaku pada 17 Ramadan tahun 2 Hijrah yang merupakan peperangan pertama yang terjadi dalam Islam. Pada 29 Ramadhan tahun yang sama, Peperangan yang memaparkan jumlah bilangan dan kekuatan yang begitu berbeza di antara tentera Islam dan tentera musyirikin.",
                                      style: TextStyle(
                                          color: Color(0xffFFFFFF),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          fontStyle: FontStyle.normal),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 16, bottom: 16),
                                      child: Text(
                                        "Tentera Islam hanya berjumlah 313 orang dengan kelengkapan yang serba kekurangan sementara tentera musyikirin berjumlah 1000 orang dengan kelengkapan yang lengkap. Dalam hal ini Nabi SAW telah merancang pelbagai strategi seperti pemilihan tempat yang strategik, penyusunan tentera yang tersusun dengan pelbagai peranan di samping pengaduan dan pengharapan sepenuhnya kepada Allah SWT.",
                                        style: TextStyle(
                                            color: Color(0xffFFFFFF),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            fontStyle: FontStyle.normal),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 16, bottom: 16),
                                      child: Text(
                                        "Akhirnya umat Islam diberikan kemenangan oleh Allah SWT dengan kemenangan yang penuh gemilang.",
                                        style: TextStyle(
                                            color: Color(0xffFFFFFF),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            fontStyle: FontStyle.normal),
                                      ),
                                    ),
                                    Text(
                                      "Peperangan Badar yang berlaku pada 17 Ramadan tahun 2 Hijrah yang merupakan peperangan pertama yang terjadi dalam Islam. Pada 29 Ramadhan tahun yang sama, Peperangan yang memaparkan jumlah bilangan dan kekuatan yang begitu berbeza di antara tentera Islam dan tentera musyirikin.",
                                      style: TextStyle(
                                          color: Color(0xffFFFFFF),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          fontStyle: FontStyle.normal),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 16, bottom: 16),
                                      child: Text(
                                        "Tentera Islam hanya berjumlah 313 orang dengan kelengkapan yang serba kekurangan sementara tentera musyikirin berjumlah 1000 orang dengan kelengkapan yang lengkap. Dalam hal ini Nabi SAW telah merancang pelbagai strategi seperti pemilihan tempat yang strategik, penyusunan tentera yang tersusun dengan pelbagai peranan di samping pengaduan dan pengharapan sepenuhnya kepada Allah SWT.",
                                        style: TextStyle(
                                            color: Color(0xffFFFFFF),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            fontStyle: FontStyle.normal),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 16, bottom: 16),
                                      child: Text(
                                        "Akhirnya umat Islam diberikan kemenangan oleh Allah SWT dengan kemenangan yang penuh gemilang.",
                                        style: TextStyle(
                                            color: Color(0xffFFFFFF),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            fontStyle: FontStyle.normal),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 40,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ]),
                ),
              ],
            ),
          )),
    );
  }
}
