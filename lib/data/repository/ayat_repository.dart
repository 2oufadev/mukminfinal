import 'package:mukim_app/data/api/mukmin_api.dart';
import 'package:mukim_app/data/models/hadith_model.dart';
import 'package:mukim_app/data/models/home_screen_model.dart';
import 'package:mukim_app/resources/global.dart';

class AyatRepository {
  final MukminApi _mukminApi;

  AyatRepository(this._mukminApi);

  Future<List<HomeScreenModel>> fetchAyatHomeScreen() async {
    List<HomeScreenModel> ayatImages = [];
    List<Data> enabledAyat = [];
    List<HadithModel> ayat = await fetchAyat();
    if (ayat != null && ayat.isNotEmpty) {
      ayat.first.data!.forEach((element) {
        if (element.status == 'enable') {
          enabledAyat.add(element);
        }
      });

      if (enabledAyat.length > 1) {
        enabledAyat.sort((a, b) => a.order!.compareTo(b.order!));
      }
      for (int i = 0; i < enabledAyat.length && i < 5; i++) {
        ayatImages.add(HomeScreenModel(
            'Ayat',
            Globals.images_url + enabledAyat[i].image!,
            enabledAyat[i].categoryId ?? 0,
            ''));
      }
    }

    return ayatImages;
  }

  Future<List<HadithModel>> fetchAyat() async {
    List<dynamic> ayatList = await _mukminApi.fetchAyat();
    if (ayatList != null) {
      return ayatList.map((e) => HadithModel.fromJson(e)).toList();
    } else {
      ayatList = await _mukminApi.fetchAyat();
      return ayatList.map((e) => HadithModel.fromJson(e)).toList();
    }
  }

  Future<List<ReadyHadithModel>> fetchArangedAyat(List<int> likedImages) async {
    List<HadithModel> data = await fetchAyat();
    List<ReadyHadithModel> arrangedData = [];

    data.first.data!.forEach((element) {
      if (element.status == 'enable' && element.status != null) {
        List<SubImages> galleryImages = [];
        data.first.subImages!.forEach((ele) {
          if (ele.parentId == element.id && ele.order != null) {
            galleryImages.add(SubImages(
                id: ele.id,
                image: ele.image,
                order: ele.order,
                reference: ele.reference != null
                    ? 'https://salam.mukminapps.com/' + ele.reference!
                    : ''));
          }
        });
        if (galleryImages.length > 1) {
          galleryImages.sort((a, b) => a.order!.compareTo(b.order!));
          galleryImages.sort((a, b) {
            if (likedImages.contains(b.id)) {
              return 1;
            }
            return -1;
          });
        }
        arrangedData.add(ReadyHadithModel(
          id: element.id,
          image: element.image,
          description: element.description,
          urlLink: element.urlLink,
          galleryImages: galleryImages,
          order: element.order,
        ));
      }
    });

    if (arrangedData.length > 1) {
      arrangedData.sort((a, b) => a.order!.compareTo(b.order!));
      arrangedData.sort((a, b) {
        int liked = -1;
        if (b.galleryImages!.isNotEmpty) {
          b.galleryImages!.forEach((element) {
            if (likedImages.contains(element.id)) {
              liked = 1;
              return;
            }
          });
        } else {
          if (likedImages.contains(b.id)) {
            liked = 1;
            return liked;
          }
        }
        return liked;
      });
    }

    return arrangedData;
  }
}
