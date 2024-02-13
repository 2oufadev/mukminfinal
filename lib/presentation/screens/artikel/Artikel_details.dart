import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukim_app/business_logic/cubit/subscription/userstate_cubit.dart';
import 'package:mukim_app/resources/Imageresources.dart';
import 'package:mukim_app/utils/componants.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:mukim_app/utils/get_theme_color.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ArtikelDetails extends StatefulWidget {
  final String name, description, img;

  ArtikelDetails(
    this.name,
    this.description,
    this.img,
  );
  @override
  _ArtikelDetailsState createState() => _ArtikelDetailsState();
}

class _ArtikelDetailsState extends State<ArtikelDetails> {
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
                          widget.name,
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
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Container(
                          decoration: new BoxDecoration(
                              borderRadius: BorderRadius.circular(5)),
                          height: 170,
                          width: MediaQuery.of(context).size.width,
                          // color: Colors.yellow,
                          child: InkWell(
                            child: Image.network(widget.img, fit: BoxFit.cover,
                                frameBuilder: (context, child, frame,
                                    wasSynchronouslyLoaded) {
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
                      SizedBox(height: 30),
                      Text(
                        'Description',
                        style: TextStyle(
                            color: getColor(theme),
                            fontSize: 18,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 20),
                      Container(
                          padding: EdgeInsets.all(15),
                          decoration: new BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Color(0xff1B1B1B)),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Text(widget.description,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16)),
                              ],
                            ),
                          ))
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }
}
