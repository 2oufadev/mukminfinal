import 'package:mukim_app/data/api/mukmin_api.dart';
import 'package:mukim_app/data/models/sponsor_model.dart';

class SponsorsRepository {
  final MukminApi _mukminApi;

  SponsorsRepository(this._mukminApi);

  Future<List<SponsorModel>> fetchSponsors() async {
    List<SponsorModel> sponsList = [];

    try {
      List<dynamic> sponsorsList = await _mukminApi.fetchSponsors();

      Map<String, dynamic> data = sponsorsList.first;
      List<SponsorModel> dataList =
          data.values.map((e) => SponsorModel.fromJson(e)).toList();
      dataList.forEach((element) {
        print(element.toJson());
        print('@@@@@@');
        if (element.status == 'active' || element.status == 'full'
            // && element.remaining != 0
            ) {
          sponsList.add(element);
        }
      });

      if (sponsList.length > 1) {
        sponsList.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
      }
    } catch (e) {}

    return sponsList;
  }

  Future<SponsorModel?> getSponsorByCode(String coupon) async {
    SponsorModel? sponsorModel;

    try {
      List<dynamic> sponsorsList = await _mukminApi.getSponsorByCode();

      Map<String, dynamic> data = sponsorsList.first;
      List<SponsorModel> dataList =
          data.values.map((e) => SponsorModel.fromJson(e)).toList();
      dataList.forEach((element) {
        print(element.toJson());
        print('@@@@@@');
        if (element.coupon == coupon) {
          sponsorModel = element;
        }
      });
    } catch (e) {}

    return sponsorModel;
  }
}
