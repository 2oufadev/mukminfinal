import 'package:mukim_app/data/api/mukmin_api.dart';
import 'package:mukim_app/data/models/hadith_model.dart';
import 'package:mukim_app/data/models/home_screen_model.dart';
import 'package:mukim_app/resources/global.dart';

class MotivationRepository {
  final MukminApi _mukminApi;

  MotivationRepository(this._mukminApi);

  Future<List<Data>> fetchMotivasi() async {
    List<dynamic> motivasiList = await _mukminApi.fetchMotivasi();
    if (motivasiList != null) {
      return motivasiList.map((e) => Data.fromJson(e)).toList();
    } else {
      motivasiList = await _mukminApi.fetchMotivasi();
      return motivasiList != null
          ? motivasiList.map((e) => Data.fromJson(e)).toList()
          : [];
    }
  }

  Future<List<Data>> fetchArangedMotivasi(List<int> likedImages) async {
    List<Data> data = await fetchMotivasi();
    List<Data> arrangedData = [];

    data.forEach((element) {
      if (element.status == 'enable') {
        arrangedData.add(element);
      }
    });

    if (arrangedData.length > 1) {
      arrangedData.sort((a, b) => a.order!.compareTo(b.order!));
      arrangedData.sort((a, b) {
        int liked = -1;

        return liked;
      });
    }

    return arrangedData;
  }

  Future<List<HomeScreenModel>> fetchMotivasiHomeScreen() async {
    List<HomeScreenModel> motivasiImages = [];
    List<Data> enabledMotivasi = [];
    List<Data> motivasi = await fetchMotivasi();
    motivasi.forEach((element) {
      if (element.status == 'enable') {
        enabledMotivasi.add(element);
      }
    });

    if (enabledMotivasi.length > 1) {
      enabledMotivasi.sort((a, b) => a.order!.compareTo(b.order!));
    }
    for (int i = 0; i < enabledMotivasi.length && i < 5; i++) {
      motivasiImages.add(HomeScreenModel(
          'Motivasi',
          Globals.images_url + enabledMotivasi[i].image!,
          enabledMotivasi[i].categoryId ?? 1,
          ''));
    }

    return motivasiImages;
  }
}
