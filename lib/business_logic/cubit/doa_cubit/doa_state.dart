part of 'doa_cubit.dart';

@immutable
abstract class DoaState {}

class HomeScreenInitial extends DoaState {}

class DoaImagesLoading extends DoaState {}

class DoaImagesLoaded extends DoaState {
  final List<HomeScreenModel> doaList;

  DoaImagesLoaded(this.doaList);
}

class DoaListLoading extends DoaState {}

class DoaListLoaded extends DoaState {
  final List<ReadyHadithModel> doaList;

  DoaListLoaded(this.doaList);
}

class DoaCategoriesLoading extends DoaState {}

class DoaCategoriesLoaded extends DoaState {
  final List<DoaCategoryModel> doaCategories;
  DoaCategoriesLoaded(this.doaCategories);
}
