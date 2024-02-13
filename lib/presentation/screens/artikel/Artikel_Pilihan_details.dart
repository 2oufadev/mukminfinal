import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukim_app/business_logic/cubit/subscription/userstate_cubit.dart';
import 'package:mukim_app/resources/Imageresources.dart';
import 'package:mukim_app/utils/componants.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:mukim_app/utils/get_theme_color.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Artikel_Pilihan_details extends StatefulWidget {
  final String name, description, img;
  final bool takwim;

  Artikel_Pilihan_details(this.name, this.description, this.img, this.takwim);
  @override
  _Artikel_Pilihan_detailsState createState() =>
      _Artikel_Pilihan_detailsState();
}

class _Artikel_Pilihan_detailsState extends State<Artikel_Pilihan_details> {
  String theme = "default";
  Map<String, dynamic>? userStateMap;
  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        theme = prefs.getString("appTheme") ?? "default";
      });
    });
    super.initState();
  }

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
                          widget.takwim != null && widget.takwim
                              ? "Peristiwa Penting"
                              : "Artikel Pilihan",
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
                  flex: 1,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width - 32,
                                    child: Text(
                                      widget.name.isNotEmpty
                                          ? widget.name
                                          : "Sedekah murahkan rezeki, hindar bala",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: getColor(theme)),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              Hero(
                                tag: 'coin${widget.img}',
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  width: MediaQuery.of(context).size.width,
                                  child: widget.img.isNotEmpty
                                      ? Image.network(
                                          widget.img,
                                          fit: BoxFit.fitWidth,
                                        )
                                      : Image.asset(
                                          ImageResource.coins,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          //  height: 100,
                          color: Color(0xff3A343D),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, bottom: 16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  child: Text(
                                    widget.description.isNotEmpty
                                        ? widget.description
                                        : "Namun, orang beriman yang memahami konsep sedekah itu akan meyakini ia amalan terpuji, yang bukan hanya mampu menyucikan diri dan harta, bahkan pahalanya berkekalan hingga ke hari pembalasan.",

                                    // textAlign: TextAlign.justify,
                                    style: TextStyle(
                                        color: Color(0xffFFFFFF),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        fontStyle: FontStyle.normal),
                                  ),
                                ),
                                widget.description.isNotEmpty
                                    ? Container()
                                    : Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10, bottom: 10),
                                        child: Text(
                                          "Namun, orang beriman yang memahami konsep sedekah itu akan meyakini ia amalan terpuji, yang bukan hanya mampu menyucikan diri dan harta, bahkan pahalanya berkekalan hingga ke hari pembalasan.",
                                          // textAlign: TextAlign.justify,
                                          style: TextStyle(
                                              color: Color(0xffFFFFFF),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              fontStyle: FontStyle.normal),
                                        ),
                                      ),
                                widget.description.isNotEmpty
                                    ? Container()
                                    : Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10, bottom: 10),
                                        child: Text(
                                          "Pada umumnya, bersedekah ialah amalan sunat yang banyak disebut dalam Islam. Ia pemberian ikhlas yang sebenarnya menandakan tahap keimanan seseorang, selain bukti ketaatan kepada Allah SWT.",
                                          // textAlign: TextAlign.justify,
                                          style: TextStyle(
                                              color: Color(0xffFFFFFF),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              fontStyle: FontStyle.normal),
                                        ),
                                      ),
                                widget.description.isNotEmpty
                                    ? Container()
                                    : Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10, bottom: 10),
                                        child: Text(
                                          "Amalan sedekah tidak terhad kepada orang berharta, sebaliknya orang Islam yang tidak memiliki harta pun boleh bersedekah berdasarkan kemampuannya, asalkan lahir daripada hati yang ikhlas.",
                                          // textAlign: TextAlign.justify,
                                          style: TextStyle(
                                              color: Color(0xffFFFFFF),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              fontStyle: FontStyle.normal),
                                        ),
                                      ),
                                widget.description.isNotEmpty
                                    ? Container()
                                    : Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10, bottom: 10),
                                        child: Text(
                                          "Sedekah juga tidak terhad kepada pemberian wang ringgit atau harta benda, sebaliknya merangkumi hal seperti mengajar ilmu baik dan memberi pertolongan.",
                                          // textAlign: TextAlign.justify,
                                          style: TextStyle(
                                              color: Color(0xffFFFFFF),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              fontStyle: FontStyle.normal),
                                        ),
                                      ),
                                widget.description.isNotEmpty
                                    ? Container()
                                    : Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10, bottom: 10),
                                        child: Text(
                                          "Malah, senyum juga disifatkan sebagai sedekah apatah lagi jika ia membabitkan pembangunan ekonomi umat Islam seperti membayar zakat, berwakaf dan infak (memberi sumbangan wang serta harta).",
                                          // textAlign: TextAlign.justify,
                                          style: TextStyle(
                                              color: Color(0xffFFFFFF),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              fontStyle: FontStyle.normal),
                                        ),
                                      ),
                                widget.description.isNotEmpty
                                    ? Container()
                                    : Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Text(
                                          "Abu Dzarr berkata, bahawa Rasulullah SAW bersabda:",
                                          // textAlign: TextAlign.justify,
                                          style: TextStyle(
                                              color: Color(0xffFFFFFF),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              fontStyle: FontStyle.normal),
                                        ),
                                      ),
                                widget.description.isNotEmpty
                                    ? Container()
                                    : Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: Text(
                                          "“Senyummu kepada saudaramu ialah sedekah bagimu; kamu memerintah kepada kebaikan dan melarang kemungkaran ialah sedekah; kamu memberi petunjuk kepada seseorang sesat di jalan ialah sedekah; kamu melihat kepada seseorang yang tidak dapat melihat dan menolongnya sedekah bagimu; kamu menghilangkan batu, duri dan tulang di jalan ialah sedekah bagimu dan kamu memasukkan air daripada timbamu ke timba saudaramu sedekah bagimu.” (HR Tirmizi)",
                                          // textAlign: TextAlign.justify,
                                          style: TextStyle(
                                              color: Color(0xffFFFFFF),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              fontStyle: FontStyle.normal),
                                        ),
                                      ),
                                SizedBox(
                                  height: 60,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
