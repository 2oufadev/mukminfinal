import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:mukim_app/business_logic/cubit/bottom_bar/cubit.dart';
import 'package:mukim_app/business_logic/cubit/bottom_bar/states.dart';
import 'package:mukim_app/business_logic/cubit/hadith_cubit/hadith_cubit_cubit.dart';
import 'package:mukim_app/business_logic/cubit/subscription/userstate_cubit.dart';
import 'package:mukim_app/data/models/hadith_model.dart';
import 'package:mukim_app/resources/constants.dart';
import 'package:mukim_app/utils/componants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class HadithDetailScreen extends StatefulWidget {
  final String categoryId;
  final String title;

  final int selectedId;

  HadithDetailScreen(this.categoryId, this.title, {this.selectedId = 0});
  @override
  _HadithDetailScreenState createState() => _HadithDetailScreenState();
}

class _HadithDetailScreenState extends State<HadithDetailScreen>
    with TickerProviderStateMixin {
  List<ReadyHadithModel>? hadithImages;
  bool loading = true;
  Map<String, dynamic>? userStateMap;
  String username = '';
  List<int> likedImages = [];
  int selectedId = 0;
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light));
    userStateMap = BlocProvider.of<UserStateCubit>(context).checkUserState();
    selectedId = widget.selectedId;
    getHadithData();
    getUsername();
  }

  getUsername() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    username = sharedPreferences.getString('username') ?? '';
    setState(() {});
  }

  getHadithData() async {
    hadithImages = BlocProvider.of<HadithCubitCubit>(context).fetchHadithList(
      widget.categoryId,
    );
  }

  @override
  Widget build(BuildContext context) {
    print('%%%%% ${selectedId}');
    return BlocBuilder<UserStateCubit, UserState>(builder: (context, state) {
      if (state is LoginState) {
        userStateMap = state.userStateMap;
      }
      return Container(
        child: BlocConsumer<HadithCubitCubit, HadithCubitState>(
          listener: (context, state) {},
          builder: (BuildContext context, state) {
            if (state is HadithListLoaded) {
              hadithImages = state.hadithList;
              likedImages = state.likedList;
              loading = false;
            }

            return BlocBuilder<MukminCubit, MukminStates>(
                builder: (context, state) {
              return OrientationBuilder(
                builder: (context, orientation) => Scaffold(
                    extendBodyBehindAppBar: true,
                    body: detailsBuilderNestedLayersWithOverlay(
                      loggedIn: userStateMap != null
                          ? userStateMap!['loggedIn']
                          : false,
                      username: username,
                      selectedId: selectedId,
                      widgetType: 'hadith',
                      category: widget.title,
                      categoryId: widget.categoryId,
                      subscribed: userStateMap != null
                          ? userStateMap!['subscribed']
                          : false,
                      loading: loading,
                      context: context,
                      imagesList: hadithImages ?? [],
                      appBarTitle: widget.title,
                      favColor: likedImages,
                      favFuction: (int imageId) => favImage(imageId),
                      leftPadding: 0,
                      showInfo: true,
                    )),
              );
            });
          },
        ),
      );
    });
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
          'hadithFav',
          {
            'id': imgId,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }
}
