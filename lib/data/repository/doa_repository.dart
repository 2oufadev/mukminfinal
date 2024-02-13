import 'package:mukim_app/data/api/mukmin_api.dart';
import 'package:mukim_app/data/models/doa_category_model.dart';
import 'package:mukim_app/data/models/hadith_model.dart';
import 'package:mukim_app/data/models/home_screen_model.dart';
import 'package:mukim_app/resources/global.dart';

class DoaRepository {
  final MukminApi _mukminApi;

  DoaRepository(this._mukminApi);

  Future<List<HadithModel>> fetchDoa() async {
    List<dynamic> doaList = await _mukminApi.fetchDoa();

    if (doaList != null) {
      return doaList.map((e) => HadithModel.fromJson(e)).toList();
    } else {
      doaList = await _mukminApi.fetchDoa();
      return doaList.map((e) => HadithModel.fromJson(e)).toList();
    }
  }

  Future<List<ReadyHadithModel>> fetchArangedDoa(
      String category, List<int> likedImages) async {
    List<HadithModel> data = await fetchDoa();
    List<ReadyHadithModel> arrangedData = [];

    data.first.data!.forEach((element) {
      if (element.status == 'enable' &&
          element.categoryId.toString() == category) {
        List<SubImages> galleryImages = [];
        data.first.subImages!.forEach((ele) {
          if (ele.parentId == element.id) {
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

  Future<List<HomeScreenModel>> fetchDoaHomeScreen() async {
    List<HomeScreenModel> doaImages = [];
    List<DoaCategoryModel> doaCategories = await fetchArangedDoaCategories();
    List<HadithModel> doaList = await fetchDoa();

    doaCategories.forEach((doaCategory) async {
      if (doaList != null && doaList.isNotEmpty) {
        for (var doa in doaList.first.data!) {
          if (doa.status == 'enable' &&
              doa.categoryId.toString() == doaCategory.id.toString() &&
              doa.order == 1) {
            doaImages.add(HomeScreenModel(doaCategory.name!,
                Globals.images_url + doa.image!, doaCategory.id!, ''));
            break;
          } else {}
        }
      }
    });

    return doaImages;
  }

  Future<List<DoaCategoryModel>> fetchDoaCategories() async {
    List<dynamic> doaCategories = await _mukminApi.fetchDoaCategories();
    if (doaCategories != null) {
      return doaCategories.map((e) => DoaCategoryModel.fromJson(e)).toList();
    } else {
      doaCategories = await _mukminApi.fetchDoaCategories();
      return doaCategories.map((e) => DoaCategoryModel.fromJson(e)).toList();
    }
  }

  Future<List<DoaCategoryModel>> fetchArangedDoaCategories() async {
    List<DoaCategoryModel> data = await fetchDoaCategories();
    List<DoaCategoryModel> arrangedData = [];
    data.forEach((element) {
      if (element.status == 'enable') {
        arrangedData.add(element);
      }
    });
    if (arrangedData.length > 1) {
      arrangedData.sort((a, b) => a.order!.compareTo(b.order!));
    }

    return arrangedData;
  }
}
