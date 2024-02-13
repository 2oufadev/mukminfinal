import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mukim_app/business_logic/cubit/subscription/userstate_cubit.dart';
import 'package:mukim_app/data/models/infaq_details_module.dart';
import 'package:mukim_app/resources/Imageresources.dart';
import 'package:mukim_app/resources/global.dart';
import 'package:mukim_app/utils/componants.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mukim_app/utils/get_theme_color.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Senarai_Infaq_Details extends StatefulWidget {
  final InfaqDetailsModel data;

  Senarai_Infaq_Details(this.data);
  @override
  _Senarai_Infaq_DetailsState createState() => _Senarai_Infaq_DetailsState();
}

class _Senarai_Infaq_DetailsState extends State<Senarai_Infaq_Details> {
  String theme = "default";
  Map<String, dynamic>? userStateMap;
  void _launchURL(String _url) async {
    if (!await launch(_url)) throw 'Could not launch $_url';
  }

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
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Image.asset(
                            ImageResource.leftArrow,
                            width: 24,
                            height: 24,
                          ),
                        ),
                        Text(
                          "Senarai Infaq",
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
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Center(
                    child: Text(
                      widget.data.organizationName!,
                      style: TextStyle(
                          color: Color(0xffFFFFFF),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${widget.data.bankName} " +
                              widget.data.maybankNo.toString(),
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(color: Color(0xffFFFFFF)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: GestureDetector(
                            onTap: () {
                              FlutterClipboard.copy(
                                  widget.data.maybankNo.toString());
                              Fluttertoast.showToast(
                                  msg: "Copied",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.white,
                                  textColor: Colors.black,
                                  fontSize: 12.0);
                            },
                            child: Image.asset(
                              ImageResource.copy,
                              height: 24,
                              width: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          "Kami membuat pemeriksaan berkala dengan pihak Polis Diraja Malaysia untuk memastikan nombor akaun sumbangan adalah sahih dan benar.",
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                              color: Color(0xff929292),
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          height: 1,
                          color: Color(0xff787878),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        right: 0,
                        left: 0,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 12, left: 16, right: 16, bottom: 12),
                          child: Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: new BoxDecoration(
                                borderRadius: BorderRadius.circular(8)),
                            child: Image.network(
                                Globals.images_url + widget.data.image!,
                                fit: BoxFit.cover, frameBuilder: (context,
                                    child, frame, wasSynchronouslyLoaded) {
                              if (frame == null) {
                                return Shimmer.fromColors(
                                  enabled: true,
                                  child: Container(
                                      height: 165, color: Color(0xFF383838)),
                                  baseColor: Color(0xFF383838),
                                  highlightColor: Color(0xFF484848),
                                );
                              }

                              return child;
                            }),
                          ),
                        ),
                      ),
                      ListView.separated(
                        // scrollDirection: Axis.vertical,
                        // shrinkWrap: true,
                        padding: EdgeInsets.only(top: 180),
                        separatorBuilder: (context, index) => Container(),
                        itemCount: 1,
                        itemBuilder: (context, index) => Container(
                          //  height: 100,
                          color: Color(0xff3A343D),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 5, left: 16, right: 16, bottom: 16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Pengenalan",
                                      style: TextStyle(
                                          color: getColor(theme),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          fontStyle: FontStyle.normal),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  child: Text(
                                    widget.data.introduction!,
                                    style: TextStyle(
                                        color: Color(0xffFFFFFF),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        fontStyle: FontStyle.normal),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Latar Belakang",
                                      style: TextStyle(
                                          color: getColor(theme),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          fontStyle: FontStyle.normal),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  child: Text(
                                    widget.data.background!,
                                    style: TextStyle(
                                        color: Color(0xffFFFFFF),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        fontStyle: FontStyle.normal),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Pautan Laman Web",
                                      style: TextStyle(
                                          color: getColor(theme),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          fontStyle: FontStyle.normal),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  child: Column(
                                    children: [
                                      ...List.generate(
                                          widget.data.websiteLink!.length,
                                          (index) => Row(
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: InkWell(
                                                      onTap: () {
                                                        _launchURL(widget
                                                                .data
                                                                .websiteLink![
                                                                    index]
                                                                .startsWith(
                                                                    "https://")
                                                            ? widget.data
                                                                    .websiteLink![
                                                                index]
                                                            : "https://" +
                                                                widget.data
                                                                        .websiteLink![
                                                                    index]);
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4.0),
                                                        child: Text(
                                                          "${index + 1}. " +
                                                              widget.data
                                                                      .websiteLink![
                                                                  index],
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xffF2C94C),
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .normal),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )),
                                      SizedBox(
                                        height: 50,
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
