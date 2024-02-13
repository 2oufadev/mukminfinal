part of 'hadith_cubit_cubit.dart';

@immutable
abstract class HadithCubitState {}

class HadithCubitInitial extends HadithCubitState {}

class HadithImagesLoading extends HadithCubitState {}

class HadithImagesLoaded extends HadithCubitState {
  final List<HomeScreenModel> hadithList;

  HadithImagesLoaded(this.hadithList);
}

class HadithListLoading extends HadithCubitState {}

class HadithListLoaded extends HadithCubitState {
  final List<ReadyHadithModel> hadithList;
  final List<int> likedList;

  HadithListLoaded(this.hadithList, this.likedList);
}

class HadithCategoriesLoading extends HadithCubitState {}

class OneDayHadithListLoaded extends HadithCubitState {
  final List<OneDayHadithModel> oneDayHadithList;

  OneDayHadithListLoaded(this.oneDayHadithList);
}

class HadithCategoriesLoaded extends HadithCubitState {
  final List<HadithCategoryModel> hadithCategories;
  HadithCategoriesLoaded(this.hadithCategories);
}

class ChanginNotificationAudio extends HadithCubitState {}

class NotificationAudioChanged extends HadithCubitState {}
