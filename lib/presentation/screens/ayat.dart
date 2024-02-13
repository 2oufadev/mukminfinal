import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:mukim_app/business_logic/cubit/ayat_cubit/ayat_cubit_cubit.dart';
import 'package:mukim_app/business_logic/cubit/bottom_bar/cubit.dart';
import 'package:mukim_app/business_logic/cubit/bottom_bar/states.dart';
import 'package:mukim_app/business_logic/cubit/subscription/userstate_cubit.dart';
import 'package:mukim_app/data/models/hadith_model.dart';
import 'package:mukim_app/resources/constants.dart';
import 'package:mukim_app/utils/componants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class AyatScreen extends StatefulWidget {
  final int selectedId;

  const AyatScreen({Key? key, this.selectedId = 0}) : super(key: key);
  @override
  _AyatScreenState createState() => _AyatScreenState();
}

class _AyatScreenState extends State<AyatScreen> with TickerProviderStateMixin {
  AnimationController? controller;
  bool loading = true;
  List<int> likedImages = [];
  String username = '';
  Map<String, dynamic>? userStateMap;
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light
        //color set to transperent or set your own color
        ));
    controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    userStateMap = BlocProvider.of<UserStateCubit>(context).checkUserState();

    getAyatData();
    getUsername();
  }

  getUsername() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    username = sharedPreferences.getString('username') ?? '';
    setState(() {});
  }

  List<ReadyHadithModel> ayatImages = [];

  getAyatData() async {
    List<Map> qqq =
        await AudioConstants.database!.rawQuery('SELECT * FROM "ayatFav" ');
    if (qqq != null && qqq.isNotEmpty) {
      qqq.forEach((element) {
        likedImages.add(element['id']);
      });
    }

    ayatImages =
        BlocProvider.of<AyatCubitCubit>(context).fetchAyatList(likedImages);
  }

  @override
  void dispose() {
    super.dispose();
    controller!.dispose();
    print('disposed');
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AyatCubitCubit, AyatCubitState>(
      listener: (context, state) {},
      builder: (BuildContext context, state) {
        if (state is AyatListLoaded) {
          ayatImages = state.ayatList;
          loading = false;
        }
        return BlocConsumer<MukminCubit, MukminStates>(
            listener: (context, state) {},
            builder: (context, state) {
              return OrientationBuilder(
                builder: (context, orientation) => Scaffold(
                  extendBodyBehindAppBar: true,
                  body: BlocBuilder<UserStateCubit, UserState>(
                      builder: (context, state) {
                    if (state is LoginState) {
                      userStateMap = state.userStateMap;
                    }
                    return detailsBuilderNestedLayersWithOverlay(
                        loggedIn: userStateMap != null
                            ? userStateMap!['loggedIn']
                            : false,
                        subscribed: userStateMap != null
                            ? userStateMap!['subscribed']
                            : false,
                        username: username,
                        loading: loading,
                        context: context,
                        imagesList: ayatImages,
                        widgetType: 'ayat',
                        appBarTitle: 'Ayat Quran Pilihan',
                        favColor: likedImages,
                        selectedId: widget.selectedId,
                        favFuction: (int imageId) => favImage(imageId),
                        leftPadding: 0,
                        showInfo: true,
                        type: 2);
                  }),
                ),
              );
            });
      },
    );
  }

  favImage(int imgId) async {
    if (likedImages.contains(imgId)) {
      setState(() {
        likedImages.removeWhere((element) => element == imgId);
      });
      await AudioConstants.database!
          .delete('hadithFav', where: 'id = ?', whereArgs: [imgId]);
    } else {
      setState(() {
        likedImages.add(imgId);
      });

      await AudioConstants.database!.insert(
          'ayatFav',
          {
            'id': imgId,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }
}
