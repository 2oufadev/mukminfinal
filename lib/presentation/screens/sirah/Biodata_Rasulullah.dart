import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukim_app/business_logic/cubit/subscription/userstate_cubit.dart';
import 'package:mukim_app/data/models/ripple.dart';
import 'package:mukim_app/data/models/sirah_category.dart';
import 'package:mukim_app/presentation/screens/sirah/Biodata_Rasulullah_details.dart';
import 'package:mukim_app/presentation/widgets/ShimmerLayouts/sirah_category_shimmer.dart';
import 'package:mukim_app/resources/Imageresources.dart';
import 'package:mukim_app/utils/componants.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mukim_app/utils/get_theme_color.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Biodata_Rasulullah extends StatefulWidget {
  final double screenHeight;
  const Biodata_Rasulullah({
    Key? key,
    required this.screenHeight,
  }) : super(key: key);

  @override
  _Biodata_RasulullahState createState() => _Biodata_RasulullahState();
}

class _Biodata_RasulullahState extends State<Biodata_Rasulullah>
    with TickerProviderStateMixin {
  AnimationController? _rippleAnimationController;
  AnimationController? scaleController;

  Animation<double>? _rippleAnimation;
  Animation<double>? scaleAnimation;
  String theme = "default";
  double? screenHeight;
  Duration kRippleAnimationDuration = Duration(milliseconds: 300);
  final _controller = ScrollController();
  List<SirahCategory> name = [];
  double get maxHeight => 200 + MediaQuery.of(context).padding.top;
  bool loading = true;
  double get minHeight => kToolbarHeight + MediaQuery.of(context).padding.top;
  Map<String, dynamic>? userStateMap;
  bool isEmpty = false;
  bool changeLayout = false;
  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        theme = prefs.getString("appTheme") ?? "default";
      });
    });
    super.initState();

    _rippleAnimationController = AnimationController(
      vsync: this,
      duration: kRippleAnimationDuration,
    );

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: widget.screenHeight,
    ).animate(CurvedAnimation(
      parent: _rippleAnimationController!,
      curve: Curves.easeIn,
    ));

    getSirahNames();
  }

  getSirahNames() async {
    try {
      String url = 'https://salam.mukminapps.com/api/Sirah';
      var result = await http
          .get(Uri.parse(url), headers: {"Accept": "application/json"});
      List responseBody = jsonDecode(result.body);
      responseBody.forEach((element) {
        if (element['status'] == 'enable') {
          name.add(SirahCategory(
              element['id'].toString(),
              element['name'],
              element['order'],
              'https://salam.mukminapps.com/images/' + element['image'],
              element['description']));
        }
      });

      if (name.length > 1) {
        name.sort((a, b) => a.order.compareTo(b.order));
      }

      setState(() {
        loading = false;
      });
      return responseBody;
    } catch (e) {
      setState(() {
        loading = false;
      });
      print(e);
      return e;
    }
  }

  @override
  void dispose() {
    _rippleAnimationController!.dispose();
    super.dispose();
  }

  Future<void> _goToDoa(String sirahName, String sirahImage, String description,
      int index) async {
    await _rippleAnimationController!.forward();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Biodata_Rasulullah_details(
            categoryList: name,
            sirahName: sirahName,
            sirahImage: sirahImage,
            description: description,
            index: index),
      ),
    );
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

              body: Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 285,
                    decoration: new BoxDecoration(
                        image: new DecorationImage(
                      image: AssetImage(ImageResource.BiodataMain),
                      fit: BoxFit.cover,
                    )),
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 50, 16, 0),
                      child: Container(
                        alignment: Alignment.center,
                        height: 50,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(width: 20),
                            Container(
                              width: 25,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    changeLayout = !changeLayout;
                                  });
                                },
                                child: changeLayout
                                    ? Image.asset(
                                        'assets/images/bx_bxs-grid-alt.png',
                                        height: 23.0,
                                        fit: BoxFit.cover,
                                      )
                                    : Icon(
                                        Icons.menu,
                                        size: 23.0,
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                "Sirah & Tamadun Islam",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontStyle: FontStyle.normal,
                                    fontSize: 20,
                                    height: 1,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              ),
                            ),
                            SizedBox(width: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 175, bottom: 65),
                      child: changeLayout
                          ? GridView.count(
                              crossAxisCount: 2,
                              childAspectRatio:
                                  MediaQuery.of(context).size.width / 200,
                              children: loading
                                  ? List.generate(
                                      10, (index) => SirahCategoryShimmer())
                                  : List.generate(
                                      name.length,
                                      (index) => Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16,
                                                right: 16,
                                                top: 8,
                                                bottom: 8),
                                            child: GestureDetector(
                                              onTap: () {
                                                _goToDoa(
                                                    name[index].name,
                                                    name[index].img,
                                                    name[index].description,
                                                    index);
                                              },
                                              child: Container(
                                                width: 343,
                                                decoration: new BoxDecoration(
                                                    color: Color(0xff1B1B1B),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8)),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  name[index].name,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: getColor(theme),
                                                      fontSize: 15,
                                                      fontStyle:
                                                          FontStyle.normal,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                            ),
                                          )))
                          : ListView.builder(
                              itemCount: name.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    _goToDoa(name[index].name, name[index].img,
                                        name[index].description, index);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        bottom: 10, left: 10, right: 10),
                                    width: 343,
                                    padding: const EdgeInsets.all(10),
                                    decoration: new BoxDecoration(
                                        color: Color(0xff1B1B1B),
                                        borderRadius: BorderRadius.circular(8)),
                                    alignment: Alignment.center,
                                    child: Text(
                                      name[index].name,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: getColor(theme),
                                          fontSize: 15,
                                          fontStyle: FontStyle.normal,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                );
                              })),
                  AnimatedBuilder(
                    animation: _rippleAnimation!,
                    builder: (_, Widget? child) {
                      return Ripple(radius: _rippleAnimation!.value);
                    },
                  ),
                ],
              ),
            )),
      ),
    );
  }
}

class Header extends StatelessWidget {
  final double maxHeight;
  final double minHeight;

  const Header({Key? key, required this.maxHeight, required this.minHeight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final expandRatio = _calculateExpandRatio(constraints);
        final animation = AlwaysStoppedAnimation(expandRatio);

        return Stack(
          fit: StackFit.expand,
          children: [
            _buildImage(),
            _buildGradient(animation),
            _buildTitle(animation),
          ],
        );
      },
    );
  }

  double _calculateExpandRatio(BoxConstraints constraints) {
    var expandRatio =
        (constraints.maxHeight - minHeight) / (maxHeight - minHeight);
    if (expandRatio > 1.0) expandRatio = 1.0;
    if (expandRatio < 0.0) expandRatio = 0.0;
    return expandRatio;
  }

  Align _buildTitle(Animation<double> animation) {
    return Align(
      alignment: Alignment.center,
      // AlignmentTween(begin: Alignment.topCenter, end: Alignment.topLeft)
      //     .evaluate(animation),
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.only(right: 12, left: 12),
            alignment: Alignment.center,
            child: Text(
              "Sirah & Tamadun Islam",
              style: TextStyle(
                fontSize: Tween<double>(begin: 18, end: 22).evaluate(animation),
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container _buildGradient(Animation<double> animation) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.black87,
            // ColorTween
            // (begin: Colors.black87, end: Colors.black38)
            //     .evaluate(animation)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Image _buildImage() {
    return Image.asset(
      ImageResource.BiodataMain,
      fit: BoxFit.cover,
    );
  }
}
