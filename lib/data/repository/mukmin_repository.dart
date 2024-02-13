import 'package:intl/intl.dart';
import 'package:mukim_app/data/api/mukmin_api.dart';
import 'package:mukim_app/data/models/azan_model.dart';
import 'package:mukim_app/data/models/doa_category_model.dart';
import 'package:mukim_app/data/models/infaq_details_module.dart';
import 'package:mukim_app/data/models/subscription_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MukminRepository {
  final MukminApi _mukminApi;
  MukminRepository(this._mukminApi);

  Future<List<DoaCategoryModel>> fetchInfaqCategories() async {
    List<dynamic> infaqCategories = await _mukminApi.fetchInfaqCategories();

    return infaqCategories.map((e) => DoaCategoryModel.fromJson(e)).toList();
  }

  Future<List<DoaCategoryModel>> fetchArangedInfaqCategories() async {
    List<DoaCategoryModel> data = await fetchInfaqCategories();
    List<DoaCategoryModel> arrangedData = [];
    data.forEach((element) {
      if (element.status == 'enable') {
        arrangedData.add(element);
      }
    });

    if (arrangedData.length > 1) {
      arrangedData.sort((a, b) => a.order!.compareTo(b.order!));
    }

    arrangedData.insert(
        0, DoaCategoryModel(name: 'Pilih Kategori', order: 0, id: 0));

    arrangedData.add(DoaCategoryModel(name: 'Semua', order: 1000, id: 1000));

    return arrangedData;
  }

  Future<List<InfaqDetailsModel>> fetchInfaq() async {
    List<dynamic> infaqList = await _mukminApi.fetchInfaqDetails();

    return infaqList.map((e) => InfaqDetailsModel.fromJson(e)).toList();
  }

  Future<List<InfaqDetailsModel>> fetchArrangedInfaq(
      String category, bool filter) async {
    List<InfaqDetailsModel> data = await fetchInfaq();
    List<InfaqDetailsModel> dataNew = [];
    if (filter) {
      data.forEach((element) {
        if (element.status == 'enable' &&
            element.categoryId == int.parse(category)) {
          dataNew.add(element);
        }
      });
    } else {
      data.forEach((element) {
        if (element.status == 'enable') {
          dataNew.add(element);
        }
      });
    }

    if (dataNew.length > 1) {
      dataNew.sort((a, b) => a.order!.compareTo(b.order!));
    }
    return dataNew;
  }

  Future<List<SubscriptionModel>> fetchSubscriptions() async {
    List<dynamic> subscriptionsList = await _mukminApi.fetchSubscriptions();
    List<dynamic> listt = subscriptionsList.first;

    print('~~~~length~~~${listt.length}');
    return listt.map((e) => SubscriptionModel.fromJson(e)).toList();
  }

  Future<List<AzanModel>> fetchAzans() async {
    List<dynamic> azanList = await _mukminApi.fetchAzans();
    return azanList.map((e) => AzanModel.fromJson(e)).toList();
  }

  Future<bool> checkLoginState() async {
    bool loginState = await _mukminApi.checkLoginState();

    return loginState;
  }

  Future<bool> checkSubscriptionState() async {
    bool subscribed = await _mukminApi.checkSubscriptionState();
    return subscribed;
  }

  Future<Map<String, dynamic>> checkUserState() async {
    Map<String, dynamic> map;

    bool loggedIn = await checkLoginState();
    bool subscribed = await checkSubscriptionState();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Duration? daysLeft;

    if (subscribed) {
      String endDate = sharedPreferences.getString('subscriptionEndDate') ?? '';

      daysLeft =
          DateFormat('yyyy-MM-dd').parse(endDate).difference(DateTime.now());
    }

    map = {
      'loggedIn': loggedIn,
      'subscribed': subscribed,
      'package': daysLeft != null ? daysLeft.inDays.toString() + ' Hari' : ''
    };

    return map;
  }

  Future<Map<String, dynamic>> checkUserFirstState() async {
    Map<String, dynamic> map;

    bool loggedIn = await checkLoginState();

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String email = sharedPreferences.getString('useremail') ?? '';
    Duration daysLeft;
    SubscriptionModel? subscriptionModel;
    print('userEmail >>>>>> $email');

    List<SubscriptionModel?> subscriptionsList = await fetchSubscriptions();
    if (subscriptionsList.indexWhere((element) =>
            element!.email.toString() == email &&
            element.package!.isNotEmpty &&
            element.period != null &&
            element.period!.contains('@') &&
            DateTime.now().isBefore(DateFormat('yyyy-MM-dd')
                .parse(element.period!.split('@')[1]))) !=
        -1) {
      subscriptionModel = subscriptionsList.lastWhere((element) =>
          element!.email.toString() == email &&
          element.package!.isNotEmpty &&
          element.period != null &&
          element.period!.contains('@') &&
          DateTime.now().isBefore(
              DateFormat('yyyy-MM-dd').parse(element.period!.split('@')[1])));
    }

    if (subscriptionModel != null && subscriptionModel.period != "@") {
      sharedPreferences.setString(
          'subscriptionEndDate', subscriptionModel.period!.split('@')[1]);
      sharedPreferences.setBool('subscribed', true);
    }

    daysLeft = subscriptionModel != null && subscriptionModel.period != "@"
        ? DateFormat('yyyy-MM-dd')
            .parse((subscriptionModel.period!.split('@')[1]))
            .difference(DateTime.now())
        : Duration();

    map = {
      'loggedIn': loggedIn,
      'subscribed': subscriptionModel != null,
      'package':
          subscriptionModel != null ? daysLeft.inDays.toString() + ' Hari' : ''
    };

    return map;
  }
}
