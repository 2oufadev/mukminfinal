import 'package:mukim_app/data/api/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MukminApi {
  static const BASE_URL = 'https://salam.mukminapps.com/';
  static const hadith_categories_url = BASE_URL + 'api/HadithCategory';
  static const infaq_categories_url = BASE_URL + 'api/InfaqCategory';
  static const doa_categories_url = BASE_URL + 'api/PrayCategory';
  static const hadith_url = BASE_URL + 'api/Hadith';
  static const ayat_url = BASE_URL + 'api/AlQuran';
  static const doa_url = BASE_URL + 'api/Pray';
  static const motivasi_url = BASE_URL + 'api/Motivation';
  static const subscription_url = BASE_URL + 'api/subscription';
  static const infaq_details_url = BASE_URL + 'api/Infaq';
  static const azan_url = BASE_URL + 'api/Azan';
  static const sponsors_url = 'https://salam.mukminapps.com/' + 'api/sponsor';

  Future<List<dynamic>> fetchHadithCategories() async {
    List<dynamic> list = [];
    try {
      var responseBody = await ApiClient.getData(hadith_categories_url);

      if (responseBody['status']) {
        list = responseBody['data'];
      }
    } catch (e) {
      print(e);
    }
    return list;
  }

  Future<List<dynamic>> fetchDoaCategories() async {
    List<dynamic> list = [];
    try {
      var responseBody = await ApiClient.getData(doa_categories_url);

      if (responseBody['status']) {
        list = responseBody['data'];
      }
    } catch (e) {
      print(e);
    }
    return list.isNotEmpty ? list.first : list;
  }

  Future<List<dynamic>> fetchInfaqCategories() async {
    List<dynamic> list = [];
    try {
      var responseBody = await ApiClient.getData(infaq_categories_url);

      if (responseBody['status']) {
        list = responseBody['data'];
      }
    } catch (e) {
      print(e);
    }
    return list.isNotEmpty ? list.first : list;
  }

  Future<List<dynamic>> fetchInfaqDetails() async {
    List<dynamic> list = [];
    try {
      var responseBody = await ApiClient.getData(infaq_details_url);

      if (responseBody['status']) {
        list = responseBody['data'];
      }
    } catch (e) {
      print(e);
    }
    return list.isNotEmpty ? list.first : list;
  }

  Future<List<dynamic>> fetchHadith() async {
    List<dynamic> list = [];
    try {
      var responseBody = await ApiClient.getData(hadith_url);

      if (responseBody['status']) {
        list = responseBody['data'];
      }
    } catch (e) {
      print(e);
    }
    return list;
  }

  Future<List<dynamic>> fetchAyat() async {
    List<dynamic> list = [];
    try {
      var responseBody = await ApiClient.getData(ayat_url);
      if (responseBody['status']) {
        list = responseBody['data'];
      }
    } catch (e) {
      print(e);
    }

    return list;
  }

  Future<List<dynamic>> fetchDoa() async {
    List<dynamic> list = [];
    try {
      var responseBody = await ApiClient.getData(doa_url);

      if (responseBody['status']) {
        list = responseBody['data'];
      }
    } catch (e) {
      print(e);
    }
    return list;
  }

  Future<List<dynamic>> fetchMotivasi() async {
    List<dynamic> list = [];
    try {
      var responseBody = await ApiClient.getData(motivasi_url);

      if (responseBody['status']) {
        list = responseBody['data'];
      }
    } catch (e) {
      print(e);
    }
    return list;
  }

  Future<List<dynamic>> fetchSubscriptions() async {
    List<dynamic> list = [];
    try {
      var responseBody = await ApiClient.getData(subscription_url);

      if (responseBody['status']) {
        list = responseBody['data'];
      }
    } catch (e) {
      print(e);
    }
    return list;
  }

  Future<List<dynamic>> fetchAzans() async {
    List<dynamic> list = [];
    try {
      var responseBody = await ApiClient.getData(azan_url);

      if (responseBody['status']) {
        list = responseBody['data'];
      }
    } catch (e) {
      print(e);
    }
    return list;
  }

  Future<List<dynamic>> fetchSponsors() async {
    List<dynamic> list = [];
    try {
      var responseBody = await ApiClient.getData(sponsors_url);

      if (responseBody['status']) {
        list = responseBody['data'];
      }
    } catch (e) {
      print(e);
    }
    return list;
  }

  Future<List<dynamic>> getSponsorByCode() async {
    List<dynamic> list = [];
    try {
      var responseBody = await ApiClient.getData(sponsors_url);

      if (responseBody['status']) {
        list = responseBody['data'];
      }
    } catch (e) {
      print(e);
    }
    return list;
  }

  Future<bool> checkLoginState() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String username = sharedPreferences.getString('useremail') ?? '';
    return username.isNotEmpty;
  }

  Future<bool> checkSubscriptionState() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool subscribed = sharedPreferences.getBool('subscribed') ?? false;
    return subscribed;
  }
}
