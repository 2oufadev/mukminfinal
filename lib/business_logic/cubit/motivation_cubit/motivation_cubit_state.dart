part of 'motivation_cubit_cubit.dart';

@immutable
abstract class MotivationCubitState {}

class MotivationCubitInitial extends MotivationCubitState {}

class MotivasiImagesLoading extends MotivationCubitState {}

class MotivasiImagesLoaded extends MotivationCubitState {
  final List<HomeScreenModel> motivasiList;

  MotivasiImagesLoaded(this.motivasiList);
}

class MotivasiListLoading extends MotivationCubitState {}

class MotivasiListLoaded extends MotivationCubitState {
  final List<Data> motivList;

  MotivasiListLoaded(this.motivList);
}
