import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukim_app/business_logic/cubit/subscription/userstate_cubit.dart';
import 'package:mukim_app/data/models/sirah_category.dart';
import 'package:mukim_app/presentation/screens/sirah/Biodata_Rasulullah.dart';
import 'package:mukim_app/presentation/screens/sirah/Peristiwa_Penting.dart';
import 'package:mukim_app/presentation/screens/home/home_screen.dart';
import 'package:mukim_app/resources/Imageresources.dart';
import 'package:mukim_app/utils/componants.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Biodata_Rasulullah_details extends StatefulWidget {
  final List<SirahCategory>? categoryList;
  final String? sirahName;
  final String? sirahImage;
  final String? description;
  final int? index;

  const Biodata_Rasulullah_details(
      {Key? key,
      this.categoryList,
      this.sirahName,
      this.sirahImage,
      this.description,
      this.index})
      : super(key: key);

  @override
  _Biodata_Rasulullah_detailsState createState() =>
      _Biodata_Rasulullah_detailsState();
}

class _Biodata_Rasulullah_detailsState
    extends State<Biodata_Rasulullah_details> {
  String name = '';
  String? sirahImage, description;
  List<SirahCategory>? sirahCategory;
  int? selectedIndex;
  Map<String, dynamic>? userStateMap;
  @override
  void initState() {
    super.initState();
    selectedIndex = widget.index;
    sirahImage = widget.sirahImage;
    description = widget.description;
    sirahCategory = widget.categoryList;
    name = sirahCategory![selectedIndex!].name;
  }

  @override
  Widget build(BuildContext context) {
    userStateMap = BlocProvider.of<UserStateCubit>(context).checkUserState();
    return SafeArea(
      top: false,
      child: WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => HomeScreen()));

          return true;
        },
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
                  FutureBuilder<SharedPreferences>(
                      future: SharedPreferences.getInstance(),
                      builder: (context, snapshot) {
                        String? theme;
                        if (snapshot.hasData) {
                          theme = snapshot.data!.getString('appTheme');
                        }
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          height: 100,
                          decoration: BoxDecoration(
                            image: new DecorationImage(
                              image: AssetImage(
                                "assets/theme/${theme ?? "default"}/appbar.png",
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 50, 16, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                Biodata_Rasulullah(
                                                    screenHeight:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .height)));

                                    // Navigator.of(context).push(MaterialPageRoute(
                                    //     builder: (context) => HomeScreen()));
                                  },
                                  child: Image.asset(
                                    ImageResource.leftArrow,
                                    height: 24,
                                    width: 24,
                                  ),
                                ),
                                Text(
                                  "Sirah & Tamadun Islam",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white),
                                ),
                                Container()
                              ],
                            ),
                          ),
                        );
                      }),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, top: 16),
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 35,
                        decoration: new BoxDecoration(
                            color: Color(0xff1B1B1B),
                            borderRadius: BorderRadius.circular(8)),
                        // alignment: Alignment.center,
                        child: Center(
                            child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            icon: Image.asset(
                              ImageResource.down_arrow,
                              alignment: Alignment.centerRight,
                              height: 16,
                              width: 16,
                            ),
                            dropdownColor: Color(0xff1B1B1B),
                            onChanged: (value) {
                              setState(() {
                                name = value ?? '';
                                description = sirahCategory!
                                    .firstWhere(
                                        (element) => element.name == value)
                                    .description;
                                sirahImage = sirahCategory!
                                    .firstWhere(
                                        (element) => element.name == value)
                                    .img;
                              });
                            },
                            value: name,
                            items: sirahCategory!
                                .map<DropdownMenuItem<String>>(
                                    (e) => DropdownMenuItem(
                                        value: e.name,
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              80,
                                          child: Text(
                                            e.name,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Color(0xffFFFFFF),
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                                fontStyle: FontStyle.normal),
                                          ),
                                        )))
                                .toList(),
                          ),
                        ))),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, top: 16),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => Peristiwa_Penting()));
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(sirahImage!,
                                    width: MediaQuery.of(context).size.width,
                                    fit: BoxFit.fitWidth, frameBuilder:
                                        (context, child, frame,
                                            wasSynchronouslyLoaded) {
                                  if (frame == null) {
                                    return Shimmer.fromColors(
                                      enabled: true,
                                      child: Container(
                                          height: 165,
                                          color: Color(0xFF383838)),
                                      baseColor: Color(0xFF383838),
                                      highlightColor: Color(0xFF484848),
                                    );
                                  }

                                  return child;
                                }),
                              ),
                            ),
                          ),
                          Container(
                            //  height: 100,
                            color: Color(0xff3A343D),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 5, left: 16, right: 16, bottom: 16),
                              child: Column(
                                children: [
                                  Text(description!,
                                      style: TextStyle(
                                          color: Color(0xffFFFFFF),
                                          fontSize: 14,
                                          fontStyle: FontStyle.normal,
                                          fontWeight: FontWeight.w400)),
                                  SizedBox(height: 70)
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
      ),
    );
  }
}
