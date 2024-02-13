import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukim_app/business_logic/cubit/bottom_bar/cubit.dart';
import 'package:mukim_app/business_logic/cubit/bottom_bar/states.dart';
import 'package:mukim_app/business_logic/cubit/doa_cubit/doa_cubit.dart';
import 'package:mukim_app/business_logic/cubit/subscription/userstate_cubit.dart';
import 'package:mukim_app/data/models/hadith_model.dart';
import 'package:mukim_app/presentation/screens/doa/Doa_Pilihan.dart';
import 'package:mukim_app/resources/constants.dart';
import 'package:mukim_app/utils/componants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class Doa_Taubat extends StatefulWidget {
  final String title, id;
  final bool fromHome;
  final int selectedId;

  const Doa_Taubat({
    Key? key,
    required double screenHeight,
    required this.title,
    required this.id,
    required this.fromHome,
    this.selectedId = 0,
  }) : super(key: key);
  @override
  _Doa_TaubatState createState() => _Doa_TaubatState();
}

class _Doa_TaubatState extends State<Doa_Taubat> {
  bool isSelected = false;
  bool isSelected1 = false;
  bool isSelected2 = false;
  bool loading = true;
  List<ReadyHadithModel> doaList = [];
  String username = '';
  List<int> likedImages = [];
  Map<String, dynamic>? userStateMap;

  @override
  void initState() {
    super.initState();

    getDuas();
    getUsername();
  }

  getDuas() async {
    List<Map> qqq =
        await AudioConstants.database!.rawQuery('SELECT * FROM "doaFav" ');
    if (qqq != null && qqq.isNotEmpty) {
      qqq.forEach((element) {
        likedImages.add(element['id']);
      });
    }
    userStateMap = BlocProvider.of<UserStateCubit>(context).checkUserState();

    doaList =
        BlocProvider.of<DoaCubit>(context).fetchDoaList(widget.id, likedImages);
  }

  getUsername() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    username = sharedPreferences.getString('username') ?? '';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MukminCubit, MukminStates>(
      listener: (context, state) {},
      builder: (BuildContext context, state) {
        MukminCubit cubit = MukminCubit.getCubitObj(context);

        return OrientationBuilder(
          builder: (context, orientation) => Scaffold(
            extendBodyBehindAppBar: true,
            body: BlocBuilder<UserStateCubit, UserState>(
                builder: (context, state) {
              if (state is LoginState) {
                userStateMap = state.userStateMap;
              }
              return BlocBuilder<DoaCubit, DoaState>(builder: (context, state) {
                if (state is DoaListLoaded) {
                  doaList = state.doaList;
                }

                return detailsBuilderNestedLayersWithOverlay(
                  loading: state is DoaListLoading ? true : false,
                  loggedIn:
                      userStateMap != null ? userStateMap!['loggedIn'] : false,
                  subscribed: userStateMap != null
                      ? userStateMap!['subscribed']
                      : false,
                  context: context,
                  username: username,
                  imagesList: doaList,
                  appBarTitle: widget.title,
                  leadingIcon: Icons.arrow_back,
                  widgetType: 'doa',
                  category: widget.title,
                  categoryId: widget.id,
                  selectedId: widget.selectedId,
                  leadingFun: () {
                    if (state is DoaListLoaded) {
                      cubit.subImageIndex = 0;
                      cubit.imageIndex = 0;
                      if (widget.fromHome) {
                        Navigator.pop(context);
                      } else {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Doa_Pilihan(
                                screenHeight:
                                    MediaQuery.of(context).size.height)));
                      }
                    }
                  },
                  favColor: likedImages,
                  favFuction: state is DoaListLoaded
                      ? (int imageId) => favImage(imageId)
                      : (int imageId) {},
                  leftPadding: 0,
                  showInfo: false,
                );
              });
            }),
          ),
        );
      },
    );
  }

  favImage(int imgId) async {
    if (likedImages.contains(imgId)) {
      setState(() {
        likedImages.removeWhere((element) => element == imgId);
      });
      await AudioConstants.database!
          .delete('doaFav', where: 'id = ?', whereArgs: [imgId]);
    } else {
      setState(() {
        likedImages.add(imgId);
      });
      await AudioConstants.database!.insert(
          'doaFav',
          {
            'id': imgId,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }
}
