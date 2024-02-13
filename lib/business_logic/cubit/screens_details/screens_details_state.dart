part of 'screens_details_cubit.dart';

@immutable
abstract class ScreensDetailsState {}

class ScreensDetailsInitial extends ScreensDetailsState {}

class InfaqListLoaded extends ScreensDetailsState {
  final List<InfaqDetailsModel> detailsList;

  InfaqListLoaded(this.detailsList);
}

class InfaqListLoading extends ScreensDetailsState {}
