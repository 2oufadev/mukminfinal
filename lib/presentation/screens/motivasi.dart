import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:mouse_parallax/mouse_parallax.dart';
import 'package:mukim_app/business_logic/cubit/bottom_bar/cubit.dart';
import 'package:mukim_app/business_logic/cubit/bottom_bar/states.dart';
import 'package:mukim_app/business_logic/cubit/motivation_cubit/motivation_cubit_cubit.dart';
import 'package:mukim_app/business_logic/cubit/subscription/userstate_cubit.dart';
import 'package:mukim_app/data/models/hadith_model.dart';
import 'package:mukim_app/presentation/screens/home/home_screen.dart';
import 'package:mukim_app/presentation/widgets/ShimmerLayouts/motivation_shimmer.dart';
import 'package:mukim_app/resources/Imageresources.dart';
import 'package:mukim_app/resources/constants.dart';
import 'package:mukim_app/resources/global.dart';
import 'package:mukim_app/utils/componants.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sqflite/sqflite.dart';

class MotivasiScreen extends StatefulWidget {
  final int? id;

  const MotivasiScreen({Key? key, this.id}) : super(key: key);
  @override
  _MotivasiScreenState createState() => _MotivasiScreenState();
}

class _MotivasiScreenState extends State<MotivasiScreen>
    with SingleTickerProviderStateMixin {
  // AnimationController controller;
  bool loading = true;
  int prevId = 0;
  Map<String, dynamic>? userStateMap;
  String username = '';
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light));
    if (widget.id != null) {
      prevId = widget.id!;
    }
    getMotivasiData();
  }

  favImage(int imgId) async {
    if (likedImages.contains(imgId)) {
      setState(() {
        likedImages.removeWhere((element) => element == imgId);
      });
      await AudioConstants.database!
          .delete('motivFav', where: 'id = ?', whereArgs: [imgId]);
    } else {
      setState(() {
        likedImages.add(imgId);
      });
      await AudioConstants.database!.insert(
          'motivFav',
          {
            'id': imgId,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  getMotivasiData() async {
    List<Map> qqq =
        await AudioConstants.database!.rawQuery('SELECT * FROM "motivFav" ');
    if (qqq != null && qqq.isNotEmpty) {
      qqq.forEach((element) {
        likedImages.add(element['id']);
      });
    }

    motivasiImages = BlocProvider.of<MotivationCubitCubit>(context)
        .fetchMotivasiList(likedImages);
  }

  List<Data> motivasiImages = [];
  List<int> likedImages = [];
  bool subscribed = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userStateMap = BlocProvider.of<UserStateCubit>(context).checkUserState();
    return BlocConsumer<MukminCubit, MukminStates>(
      listener: (context, state) {},
      builder: (BuildContext context, state) {
        MukminCubit cubit = MukminCubit.getCubitObj(context);
        double width = MediaQuery.of(context).size.width;
        double height = MediaQuery.of(context).size.height;

        return OrientationBuilder(builder: (context, orientation) {
          return SafeArea(
            top: false,
            child: Scaffold(
              backgroundColor: HexColor('#3A343D'),
              extendBodyBehindAppBar: true,
              body: SlidingUpPanel(
                minHeight: 64,
                maxHeight: 265,
                color: Colors.black.withOpacity(0.5),
                panel: BlocBuilder<UserStateCubit, UserState>(
                    builder: (context, state) {
                  subscribed = state is LoginState
                      ? state.userStateMap!['subscribed']
                      : false;
                  return bottomNavBarWithOpacity(
                      context: context,
                      loggedIn: state is LoginState
                          ? state.userStateMap!['loggedIn']
                          : false);
                }),
                body: NestedScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  headerSliverBuilder: (context, isScolled) {
                    return [
                      SliverAppBar(
                        floating: false,
                        expandedHeight: width * 0.267,
                        // bottom: PreferredSize(
                        //   preferredSize: Size.fromHeight(30.0),
                        //   child: Text(''),
                        // ),
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
                                      username = snapshot.data!
                                              .getString('username') ??
                                          '';
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
                                  }),
                              Padding(
                                padding: const EdgeInsets.only(top: 35.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: InkWell(
                                        onTap: () => navigateAndfinish(
                                          context: context,
                                          screen: HomeScreen(),
                                        ),
                                        child: Image.asset(
                                          ImageResource.leftArrow,
                                          height: 24,
                                          width: 24,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: width * 0.06,
                                        top: 5.0,
                                      ),
                                      child: Text(
                                        "Motivasi & Inspirasi",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      alignment: Alignment.bottomRight,
                                      padding: EdgeInsets.only(
                                          bottom: 11.0, right: 10),
                                      onPressed: () {
                                        cubit.changeGrid();
                                        print(cubit.isTwo);
                                      },
                                      icon: Image.asset(
                                        cubit.gridIcon,
                                        height: 23.0,
                                        fit: BoxFit.fitHeight,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        backgroundColor: Colors.transparent,
                        leading: Icon(null),
                      ),
                    ];
                  },
                  body: MediaQuery.removePadding(
                    context: context,

                    removeTop: true,

                    // padding: EdgeInsets.zero,
                    child:
                        BlocBuilder<MotivationCubitCubit, MotivationCubitState>(
                            builder: (context, state) {
                      if (state is MotivasiListLoaded) {
                        motivasiImages = state.motivList;
                      }
                      return state is MotivasiListLoading
                          ? MotivationShimmer()
                          : motivasiImages == null || motivasiImages.isEmpty
                              ? Container()
                              : ParallaxStack(
                                  layers: [
                                    ListView(
                                      children: [
                                        Container(
                                          color: HexColor('#3A343D'),
                                          child: Container(
                                            height: orientation ==
                                                    Orientation.portrait
                                                ? height * 0.5
                                                : width, //image covers all screen
                                            width: width,
                                            child: AnimatedCrossFade(
                                              firstChild: Image.network(
                                                  prevId != 0
                                                      ? Globals.images_url +
                                                          motivasiImages[motivasiImages
                                                                  .indexWhere((element) =>
                                                                      element
                                                                          .id ==
                                                                      widget
                                                                          .id)]
                                                              .image!
                                                      : Globals.images_url +
                                                          motivasiImages[cubit
                                                                  .imageIndex]
                                                              .image!,
                                                  fit: BoxFit.cover,
                                                  height: height * 0.5,
                                                  width: width,
                                                  frameBuilder: (context,
                                                      child,
                                                      frame,
                                                      wasSynchronouslyLoaded) {
                                                if (frame == null) {
                                                  return Shimmer.fromColors(
                                                    enabled: true,
                                                    child: Container(
                                                        height: height * 0.5,
                                                        width: width,
                                                        color:
                                                            Color(0xFF383838)),
                                                    baseColor:
                                                        Color(0xFF383838),
                                                    highlightColor:
                                                        Color(0xFF484848),
                                                  );
                                                }

                                                return child;
                                              }
                                                  // width: width,
                                                  ),
                                              secondChild: Image.network(
                                                  Globals.images_url +
                                                      motivasiImages[
                                                              cubit.imageIndex]
                                                          .image!,
                                                  fit: BoxFit.cover,
                                                  height: height * 0.5,
                                                  width: width,
                                                  frameBuilder: (context,
                                                      child,
                                                      frame,
                                                      wasSynchronouslyLoaded) {
                                                if (frame == null) {
                                                  return Shimmer.fromColors(
                                                    enabled: true,
                                                    child: Container(
                                                        height: height * 0.5,
                                                        width: width,
                                                        color:
                                                            Color(0xFF383838)),
                                                    baseColor:
                                                        Color(0xFF383838),
                                                    highlightColor:
                                                        Color(0xFF484848),
                                                  );
                                                }

                                                return child;
                                              }),
                                              crossFadeState:
                                                  cubit.crossFadeState,
                                              firstCurve: Curves.bounceInOut,
                                              secondCurve: Curves.easeInBack,
                                              duration:
                                                  Duration(milliseconds: 500),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          color: HexColor('#171518'),
                                          child: imageBottomRow(
                                            context: context,
                                            info: motivasiImages != null &&
                                                    motivasiImages.isNotEmpty &&
                                                    motivasiImages[cubit
                                                                .imageIndex]
                                                            .description !=
                                                        null
                                                ? motivasiImages[
                                                        cubit.imageIndex]
                                                    .description!
                                                : '',
                                            sharedImage: Globals.images_url +
                                                motivasiImages[cubit.imageIndex]
                                                    .image!,
                                            link:
                                                motivasiImages[cubit.imageIndex]
                                                    .urlLink!,
                                            description: subscribed
                                                ? 'Infografik ini dikongsi oleh $username (Premium) dari MukminApps.Terokai Applikasi PERCUMA TANPA IKLAN di '
                                                : 'Terokai Pelbagai Infografik, Arah Kiblat, Bacaan Al Quran, Hadith, Motivasi dan lain-lain dalam Applikasi PERCUMA TANPA IKLAN di ',
                                            description2:
                                                'Motivasi-${motivasiImages[cubit.imageIndex].id}',
                                            reference: '',
                                            favColor: likedImages,
                                            type: 3,
                                            showInfo: true,
                                            favFuction: (int aa) =>
                                                favImage(aa),
                                            imageId:
                                                motivasiImages[cubit.imageIndex]
                                                    .id!,
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(
                                              top: 10, bottom: 60),
                                          color: HexColor('#3A343D'),
                                          child: GridView.count(
                                            physics: BouncingScrollPhysics(),
                                            shrinkWrap: true,
                                            crossAxisCount: cubit.isTwo ? 2 : 3,
                                            mainAxisSpacing: 10.0,
                                            crossAxisSpacing: 10.0,
                                            childAspectRatio: 1 / 1,
                                            children: List.generate(
                                              motivasiImages.length,
                                              (index) => Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                clipBehavior: Clip.antiAlias,
                                                child: InkWell(
                                                  child: Image.network(
                                                      Globals.images_url +
                                                          motivasiImages[index]
                                                              .image!,
                                                      fit: BoxFit.cover,
                                                      frameBuilder: (context,
                                                          child,
                                                          frame,
                                                          wasSynchronouslyLoaded) {
                                                    if (frame == null) {
                                                      return Shimmer.fromColors(
                                                        enabled: true,
                                                        child: Container(
                                                            color: Color(
                                                                0xFF383838)),
                                                        baseColor:
                                                            Color(0xFF383838),
                                                        highlightColor:
                                                            Color(0xFF484848),
                                                      );
                                                    }

                                                    return child;
                                                  }),
                                                  onTap: () {
                                                    prevId = 0;
                                                    cubit.changeImage(index);
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    /*   ListView(
                              physics: BouncingScrollPhysics(),
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: height * 0.61),
                                  child: Container(
                                    color: HexColor('#3A343D'),
                                    child: ScaleTransition(
                                      scale: CurvedAnimation(
                                        parent: controller,
                                        curve: Curves.bounceInOut,
                                      ),
                                      child: GridView.count(
                                        physics: BouncingScrollPhysics(),
                                        shrinkWrap: true,
                                        crossAxisCount: cubit.isTwo ? 2 : 3,
                                        mainAxisSpacing: 10.0,
                                        crossAxisSpacing: 10.0,
                                        childAspectRatio: 1 / 1,
                                        children: List.generate(
                                          ayatImages.length,
                                          (index) => InkWell(
                                            child: Image.asset(
                                              '${ayatImages[index]}',
                                              fit: BoxFit.fitWidth,
                                            ),
                                            onTap: () {
                                              cubit.changeImage(index);
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),*/
                                  ],
                                );
                    }),
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }
}
