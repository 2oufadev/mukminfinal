import 'package:mukim_app/business_logic/cubit/bottom_bar/cubit.dart';
import 'package:mukim_app/business_logic/cubit/bottom_bar/states.dart';
import 'package:mukim_app/business_logic/cubit/hadith_cubit/hadith_cubit_cubit.dart';
import 'package:mukim_app/business_logic/cubit/subscription/userstate_cubit.dart';
import 'package:mukim_app/data/models/hadith_category_model.dart';
import 'package:mukim_app/presentation/widgets/ShimmerLayouts/hadith_category_shimmer.dart';
import 'package:mukim_app/providers/theme.dart';
import 'package:mukim_app/resources/global.dart';
import 'package:mukim_app/utils/get_theme_color.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:mukim_app/presentation/screens/hadith/hadeth_detail_screens.dart';
import 'package:mukim_app/utils/componants.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class HadithCategoriesScreen extends StatefulWidget {
  @override
  _HadithCategoriesScreenState createState() => _HadithCategoriesScreenState();
}

class _HadithCategoriesScreenState extends State<HadithCategoriesScreen> {
  bool loading = true;
  Map<String, dynamic>? userStateMap;
  List<HadithCategoryModel> hadithCategoryList = [];
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      //color set to transperent or set your own color
    ));
    userStateMap = BlocProvider.of<UserStateCubit>(context).checkUserState();
    hadithCategoryList =
        BlocProvider.of<HadithCubitCubit>(context).fetchHadithCategories();
  }

  @override
  Widget build(BuildContext context) {
    String theme = Provider.of<ThemeNotifier>(context).appTheme;

    return BlocConsumer<MukminCubit, MukminStates>(
      listener: (context, state) {},
      builder: (BuildContext context, state) {
        MukminCubit cubit = MukminCubit.getCubitObj(context);
        double width = MediaQuery.of(context).size.width;

        return SafeArea(
          top: false,
          child: Scaffold(
            backgroundColor: HexColor('#3A343D'),
            extendBodyBehindAppBar: true,
            body: BlocBuilder<UserStateCubit, UserState>(
                builder: (context, state) {
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
                body: OrientationBuilder(builder: (context, orientation) {
                  return CustomScrollView(
                    physics: BouncingScrollPhysics(),
                    slivers: <Widget>[
                      SliverAppBar(
                        floating: false,
                        expandedHeight: width * 0.267,
                        bottom: PreferredSize(
                          // Add this code
                          preferredSize: Size.fromHeight(30.0), // Add this code
                          child: Text(''), // Add this code
                        ),
                        backgroundColor: HexColor('#3A343D'),
                        flexibleSpace: FlexibleSpaceBar(
                          background: Stack(
                            alignment: Alignment.centerRight,
                            children: <Widget>[
                              FutureBuilder<SharedPreferences>(
                                  future: SharedPreferences.getInstance(),
                                  builder: (context, snapshot) {
                                    String? theme;
                                    if (snapshot.hasData) {
                                      theme =
                                          snapshot.data!.getString('appTheme');
                                    }
                                    return Container(
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: AssetImage(
                                                "assets/theme/${theme ?? "default"}/appbar.png",
                                              ),
                                              fit: BoxFit.cover)),
                                    );
                                  }),
                              Padding(
                                padding: const EdgeInsets.only(top: 35.0),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left:
                                            orientation == Orientation.portrait
                                                ? width * 0.32
                                                : width * 0.4,
                                        top: 2.0,
                                      ),
                                      child: Text(
                                        "Hadith Pilihan",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Spacer(),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        leading: Icon(
                          null,
                        ),
                      ),
                      BlocBuilder<HadithCubitCubit, HadithCubitState>(
                          builder: (context, state) {
                        if (state is HadithCategoriesLoading) {
                          return HadithCategoryShimmer();
                        }
                        if (state is HadithCategoriesLoaded) {
                          hadithCategoryList = state.hadithCategories;
                        }

                        return SliverPadding(
                          padding: EdgeInsets.all(15.0),
                          sliver: SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:
                                  orientation == Orientation.portrait ? 3 : 5,
                              mainAxisSpacing: 20.0,
                              crossAxisSpacing: 5.0,
                              childAspectRatio: 1 / 1.3,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                                return InkWell(
                                  onTap: () {
                                    cubit.hadithItemIndex =
                                        hadithCategoryList[index].id!;
                                    navigateTo(
                                        context: context,
                                        leftToRightTransasion: true,
                                        screen: HadithDetailScreen(
                                          hadithCategoryList[index]
                                              .id
                                              .toString(),
                                          hadithCategoryList[index].name!,
                                        )).then((value) => setState(() {}));
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                        ),
                                        child: Image.network(
                                            Globals.images_url +
                                                hadithCategoryList[index]
                                                    .image!,
                                            fit: BoxFit.cover,
                                            height: (width - 40) / 3,
                                            width: (width - 40) / 3,
                                            frameBuilder: (context, child,
                                                frame, wasSynchronouslyLoaded) {
                                          if (frame == null) {
                                            return Shimmer.fromColors(
                                              enabled: true,
                                              child: Container(
                                                  height: (width - 40) / 3,
                                                  width: (width - 40) / 3,
                                                  color: Color(0xFF383838)),
                                              baseColor: Color(0xFF383838),
                                              highlightColor: Color(0xFF484848),
                                            );
                                          }

                                          return child;
                                        }),
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      Text(
                                        hadithCategoryList[index].name!.trim(),
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: getColor(theme),
                                          fontSize: 15.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              childCount: hadithCategoryList != null &&
                                      hadithCategoryList.isNotEmpty
                                  ? hadithCategoryList.length
                                  : 0,
                            ),
                          ),
                        );
                      }),
                      SliverToBoxAdapter(
                        child: SizedBox(height: 50),
                      )
                    ],
                  );
                }),
              );
            }),
          ),
        );
      },
    );
  }
}
