import 'package:mukim_app/data/api/adhan_api.dart';
import 'package:mukim_app/data/api/mukmin_api.dart';
import 'package:mukim_app/data/models/hadith_category_model.dart';
import 'package:mukim_app/data/models/hadith_model.dart';
import 'package:mukim_app/data/models/hadith_model_separate.dart'
    hide SubImages;
import 'package:mukim_app/data/models/home_screen_model.dart';
import 'package:mukim_app/data/models/month_prayer_model.dart';
import 'package:mukim_app/resources/constants.dart';
import 'package:mukim_app/resources/global.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HadithRepository {
  final MukminApi _mukminApi;

  HadithRepository(this._mukminApi);

  Future<List<HadithModelSeparate>> fetchHadith() async {
    List<dynamic> hadithList = await _mukminApi.fetchHadith();

    return hadithList.map((e) => HadithModelSeparate.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> fetchArangedHadith(String widgetId) async {
    Map<String, dynamic> returnedData = {};
    List<HadithModelSeparate> data = await fetchHadith();
    List<ReadyHadithModel> arrangedData = [];
    List<int> likedImages = [];
    List<Map> qqq =
        await AudioConstants.database!.rawQuery('SELECT * FROM "hadithFav" ');
    if (qqq != null && qqq.isNotEmpty) {
      qqq.forEach((element) {
        likedImages.add(element['id']);
      });
    }

    data.first.data!.forEach((element) {
      if (element.status == 'enable' &&
          element.categoryId.toString() == widgetId) {
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
    returnedData = {'arragnedList': arrangedData, 'likedList': likedImages};
    return returnedData;
  }

  Future<List<PrayerModel>> fetchMonthAzans(DateTime dateTime) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? zone = sharedPreferences.getString('district');
    List<PrayerModel> azansList = [];
    MonthPrayerModel? monthPrayer = await Api.fetchAzansTimes(zone!, dateTime);
    azansList = monthPrayer!.prayerTimes;
    return azansList;
  }

  Future<List<HadithCategoryModel>> fetchHadithCategories() async {
    List<dynamic> hadithCategories = await _mukminApi.fetchHadithCategories();

    return hadithCategories
        .map((e) => HadithCategoryModel.fromJson(e))
        .toList();
  }

  Future<List<HadithCategoryModel>> fetchArangedHadithCategories() async {
    List<HadithCategoryModel> data = await fetchHadithCategories();
    List<HadithCategoryModel> arrangedData = [];
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

  Future<List<HomeScreenModel>> fetchHadithHomeScreen() async {
    List<HomeScreenModel> hadithImages = [];
    List<HadithCategoryModel> hadithCategories =
        await fetchArangedHadithCategories();
    List<HadithModelSeparate> hadithList = await fetchHadith();

    hadithCategories.forEach((hadithCategory) async {
      if (hadithList.isNotEmpty) {
        for (var hadith in hadithList.first.data!) {
          if (hadith.status == 'enable' &&
              hadith.categoryId.toString() == hadithCategory.id.toString() &&
              hadith.order == 1) {
            hadithImages.add(HomeScreenModel(hadithCategory.name!,
                Globals.images_url + hadith.image!, hadithCategory.id!, ''));
            break;
          } else {}
        }
      }
    });

    return hadithImages;
  }
}
