part of 'sponsor_cubit.dart';

@immutable
abstract class SponsorState {}

class SponsorInitial extends SponsorState {}

class SponsorsLoading extends SponsorState {}

class GetSponsorLoading extends SponsorState {}

class GetSponsorError extends SponsorState {
  final String error;

  GetSponsorError(this.error);
}

class SponsorsLoaded extends SponsorState {
  final List<SponsorModel> sponsorsList;

  SponsorsLoaded(this.sponsorsList);
}

class GetSponsorLoaded extends SponsorState {
  final SponsorModel sponsorModel;

  GetSponsorLoaded(this.sponsorModel);
}
