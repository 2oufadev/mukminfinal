import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mukim_app/data/models/sponsor_model.dart';
import 'package:mukim_app/data/repository/sponsors_repository.dart';

part 'sponsor_state.dart';

class SponsorCubit extends Cubit<SponsorState> {
  final SponsorsRepository sponsorsRepository;
  List<SponsorModel> sponsorsList = [];
  SponsorModel? sponsorModel;
  SponsorCubit(this.sponsorsRepository) : super(SponsorInitial());

  List<SponsorModel> fetchSponsors() {
    emit(SponsorsLoading());

    sponsorsRepository.fetchSponsors().then((sponsorsList) {
      int count = 0;

      List<SponsorModel> dataList = [];
      sponsorsList.forEach((element) {
        print(element.toJson());
        if (count < 2 &&
            element.remaining != null &&
            element.remaining != 0 &&
            element.status != 'full') {
          count++;
          dataList.add(element);
        }
      });
      dataList.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
      this.sponsorsList = dataList;
      emit(SponsorsLoaded(dataList));
    });

    return this.sponsorsList;
  }

  SponsorModel getSponsorByCode(String code) {
    print(code);
    emit(GetSponsorLoading());

    sponsorsRepository.getSponsorByCode(code).then((sponsor) {
      this.sponsorModel = sponsor;
      if (sponsor != null &&
          sponsor.remaining != 0 &&
          sponsor.status != 'full') {
        print('~~~~~~~~~~~~~~~~~~~~~~~');
        print(sponsor.toJson());
        emit(GetSponsorLoaded(sponsor));
      } else if (sponsor != null &&
          (sponsor.remaining == 0 || sponsor.status == 'full')) {
        emit(GetSponsorError('Sponsor has no free slots available'));
      } else if (sponsor == null) {
        emit(GetSponsorError('Sponsor doesnt exist'));
      } else {
        emit(GetSponsorError('Sponsor not available'));
      }
    });

    return this.sponsorModel!;
  }
}
