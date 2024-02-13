part of 'hadith_cubit.dart';

@immutable
abstract class HadithState {}

class HadithInitial extends HadithState {}

class InfaqCategoriesLoaded extends HadithState {
  final List<DoaCategoryModel> infaqCategories;
  InfaqCategoriesLoaded(this.infaqCategories);
}

class AzansListLoaded extends HadithState {
  final List<AzanModel> azansList;

  AzansListLoaded(this.azansList);
}
