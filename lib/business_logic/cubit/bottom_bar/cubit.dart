import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukim_app/business_logic/cubit/bottom_bar/states.dart';
import 'package:mukim_app/data/models/mukmin.dart';
import 'package:mukim_app/resources/Imageresources.dart';

class MukminCubit extends Cubit<MukminStates> {
  MukminCubit() : super(MukminInitialState());

  static MukminCubit getCubitObj(context) {
    return BlocProvider.of(context);
  }

  List<String> bottomIcons = [
    ImageResource.Utama,
    ImageResource.Qiblat,
    ImageResource.Quran,
    ImageResource.Hadith,
    ImageResource.Doa,
    ImageResource.Artikel,
    ImageResource.Sumbangan,
    ImageResource.Masjid,
    ImageResource.Kalendar,
    ImageResource.Zikir,
    ImageResource.Restoran,
    ImageResource.Sirah,
    ImageResource.Restoran,
    ImageResource.Tetapan,
  ];
  List<String> lables = [
    'Utama',
    'Kiblat',
    'Quran',
    'Hadith',
    'Doa',
    'Artikel',
    'Sumbangan',
    'Masjid/Surau',
    'Kalendar',
    'Zikir',
    'Restoran Halal',
    'Sirah',
    'Motivasi',
    'Sirah',
    'Restoran Halal',
    'Tetapan',
  ];

  String gridIcon = 'assets/images/gridicons_grid.png';
  bool isTwo = false;

  void changeGrid() {
    isTwo = !isTwo;

    gridIcon = isTwo
        ? 'assets/images/bx_bxs-grid-alt.png'
        : 'assets/images/gridicons_grid.png';
    emit(MukminGridChangeState());
  }

  int imageIndex = 0;
  int subImageIndex = 0;
  CrossFadeState crossFadeState = CrossFadeState.showFirst;

  void changeImage(int index) {
    imageIndex = index;
    crossFadeState = crossFadeState == CrossFadeState.showSecond
        ? CrossFadeState.showFirst
        : CrossFadeState.showSecond;
    // print(imageIndex);
    emit(MukminImageChangeState());
  }

  void changeSubImage(int index) {
    subImageIndex = index;
    crossFadeState = crossFadeState == CrossFadeState.showSecond
        ? CrossFadeState.showFirst
        : CrossFadeState.showSecond;
    print(subImageIndex);
    emit(MukminImageChangeState());
  }

  List<HadithModel> taubat = [
    HadithModel(
      image: ImageResource.Doa_taubat1,
      title: '',
    ),
    HadithModel(
      image: ImageResource.Doa_taubat2,
      title: '',
    ),
    HadithModel(
      image: ImageResource.Doa_taubat3,
      title: '',
    ),
  ];

  int hadithItemIndex = 0;

  Color favColor = Colors.white;
  void changeFavorite() {
    favColor = favColor == Colors.white ? Colors.red : Colors.white;
    emit(MukminFavoriteChangeState());
  }

  Color favColor_outlined = Colors.white;
  void changeFavoriteOutlined({bool imageLoved = false}) {
    //when Api used.. use imageLoved
    favColor_outlined =
        favColor_outlined == Colors.white ? Colors.red : Colors.white;
    emit(MukminFavoriteChangeState());
  }

  Color menuColor = Color(0xff1A1317);

  void menucolorChange() {
    menuColor = Colors.black;
    emit(MukminMenuColorChangeState());
  }
}
