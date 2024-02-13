import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukim_app/business_logic/cubit/doa_cubit/doa_cubit.dart';
import 'package:mukim_app/business_logic/cubit/subscription/userstate_cubit.dart';
import 'package:mukim_app/data/models/doa_category_model.dart';
import 'package:mukim_app/data/models/ripple.dart';
import 'package:mukim_app/presentation/screens/doa/Doa_Taubat.dart';
import 'package:mukim_app/presentation/widgets/ShimmerLayouts/dua_category_shimmer.dart';
import 'package:mukim_app/resources/Imageresources.dart';
import 'package:mukim_app/utils/componants.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:mukim_app/utils/get_theme_color.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Doa_Pilihan extends StatefulWidget {
  final double screenHeight;
  const Doa_Pilihan({
    Key? key,
    required this.screenHeight,
  }) : super(key: key);
  @override
  _Doa_PilihanState createState() => _Doa_PilihanState();
}

class _Doa_PilihanState extends State<Doa_Pilihan>
    with TickerProviderStateMixin {
  AnimationController? _rippleAnimationController;
  AnimationController? scaleController;
  String theme = "default";
  Animation<double>? _rippleAnimation;
  Animation<double>? scaleAnimation;
  bool loading = true;
  double? screenHeight;
  Duration kRippleAnimationDuration = Duration(milliseconds: 300);
  Map<String, dynamic>? userStateMap;
  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        theme = prefs.getString("appTheme") ?? "default";
      });
    });

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

    name = BlocProvider.of<DoaCubit>(context).fetchDoaCategories();
    userStateMap = BlocProvider.of<UserStateCubit>(context).checkUserState();
  }

  @override
  void dispose() {
    _rippleAnimationController?.dispose();
    super.dispose();
  }

  Future<void> _goToDoa(String title, String id) async {
    await _rippleAnimationController!.forward();

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => Doa_Taubat(
                fromHome: false,
                screenHeight: widget.screenHeight,
                title: title,
                id: id),
          ),
        )
        .then((value) => _rippleAnimationController!.reverse());
  }

  List<DoaCategoryModel> name = [];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
          backgroundColor: Color(0xff3A343D),
          body:
              BlocBuilder<UserStateCubit, UserState>(builder: (context, state) {
            if (state is LoginState) {
              userStateMap = state.userStateMap;
            }
            return SlidingUpPanel(
              minHeight: 64,
              maxHeight: 265,
              color: Colors.black.withOpacity(0.5),
              panel: BlocBuilder<UserStateCubit, UserState>(
                builder: (context, state) => bottomNavBarWithOpacity(
                    context: context,
                    loggedIn: userStateMap != null
                        ? userStateMap!['loggedIn']
                        : false),
              ),
              body: Stack(children: [
                Column(
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Doa Pilihan",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Center(
                        child: Text("Kategori Doa",
                            style: TextStyle(
                              color: Color(0xffFFFFFF),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.normal,
                            )),
                      ),
                    ),
                    Expanded(
                      child: BlocBuilder<DoaCubit, DoaState>(
                          builder: (context, state) {
                        if (state is DoaCategoriesLoaded) {
                          name = state.doaCategories;
                        }
                        if (state is DoaCategoriesLoading) {
                          return DuaCategoryShimmer();
                        } else {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            // alignment: Alignment.bottomCenter,
                            padding: EdgeInsets.only(bottom: 60),
                            decoration: new BoxDecoration(
                                // color: Colors.yellow,
                                image: DecorationImage(
                                    alignment: Alignment.bottomCenter,
                                    fit: BoxFit.contain,
                                    image: AssetImage(
                                      ImageResource.background,
                                    ))),
                            child: GridView.count(
                                primary: false,
                                physics: BouncingScrollPhysics(),
                                childAspectRatio: 1 / 0.7,
                                padding: const EdgeInsets.all(8),
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                crossAxisCount: 2,
                                children: List.generate(name.length, (index) {
                                  return InkWell(
                                    onTap: () {
                                      _goToDoa(name[index].name!,
                                          name[index].id.toString());
                                    },
                                    child: Container(
                                      clipBehavior: Clip.antiAlias,
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height,
                                      decoration: new BoxDecoration(
                                          color: Color(0xff1B1B1B),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      alignment: Alignment.center,
                                      child: Text(
                                        name[index].name!,
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            fontStyle: FontStyle.normal,
                                            color: getColor(theme)),
                                      ),
                                    ),
                                  );
                                })),
                          );
                        }
                      }),
                    ),
                  ],
                ),
                AnimatedBuilder(
                  animation: _rippleAnimation!,
                  builder: (_, Widget? child) {
                    return Ripple(radius: _rippleAnimation!.value);
                  },
                ),
              ]),
            );
          })),
    );
  }
}
