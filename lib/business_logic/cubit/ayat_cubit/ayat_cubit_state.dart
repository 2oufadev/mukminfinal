part of 'ayat_cubit_cubit.dart';

@immutable
abstract class AyatCubitState {}

class AyatCubitInitial extends AyatCubitState {}

class AyatImagesLoading extends AyatCubitState {}

class AyatImagesLoaded extends AyatCubitState {
  final List<HomeScreenModel> ayatList;

  AyatImagesLoaded(this.ayatList);
}

class AyatListLoaded extends AyatCubitState {
  final List<ReadyHadithModel> ayatList;

  AyatListLoaded(this.ayatList);
}
