import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukim_app/business_logic/cubit/hadith/hadith_cubit.dart';
import 'package:mukim_app/business_logic/cubit/screens_details/screens_details_cubit.dart';
import 'package:mukim_app/business_logic/cubit/subscription/userstate_cubit.dart';
import 'package:mukim_app/data/models/doa_category_model.dart';
import 'package:mukim_app/data/models/infaq_details_module.dart';
import 'package:mukim_app/presentation/screens/infaq/Senarai_Infaq_Details.dart';
import 'package:mukim_app/resources/Imageresources.dart';
import 'package:mukim_app/utils/componants.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:mukim_app/utils/get_theme_color.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Senarai_Infaq extends StatefulWidget {
  @override
  _Senarai_InfaqState createState() => _Senarai_InfaqState();
}

class _Senarai_InfaqState extends State<Senarai_Infaq> {
  List<DoaCategoryModel> infaqCategoryList = [];
  List<InfaqDetailsModel> infaqDetailsList = [];
  bool loading = false;
  String selectedCategoryName = '';
  String theme = "default";
  Map<String, dynamic>? userStateMap;
  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        theme = prefs.getString("appTheme") ?? "default";
      });
    });
    super.initState();
  }

  List<InfaqDetailsModel> searchData = [];

  searchval(var val) {
    searchData.clear();

    print('------');
    print(val);
    infaqDetailsList
        .where((element) => element.organizationName
            .toString()
            .toLowerCase()
            .contains(val.toString().toLowerCase()))
        .forEach((element) {
      searchData.add(element);
    });

    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    infaqCategoryList =
        BlocProvider.of<HadithCubit>(context).fetchInfaqCategories();
    userStateMap = BlocProvider.of<UserStateCubit>(context).checkUserState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
          backgroundColor: Color(0xff3A343D),
          body: SlidingUpPanel(
            minHeight: 64,
            maxHeight: 265,
            color: Colors.black.withOpacity(0.5),
            panel: BlocBuilder<UserStateCubit, UserState>(
              builder: (context, state) => bottomNavBarWithOpacity(
                  context: context,
                  loggedIn: state is LoginState
                      ? state.userStateMap!['loggedIn']
                      : false),
            ),
            body: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 100,
                  decoration: BoxDecoration(
                      image: new DecorationImage(
                          image: AssetImage(
                            "assets/theme/${theme ?? "default"}/appbar.png",
                          ),
                          fit: BoxFit.cover)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 50, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(),
                        Text(
                          "Senarai Infaq",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                        Container()
                      ],
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  color: Color(0xff000000),
                  child: TextFormField(
                    onChanged: (text) {
                      searchval(text);
                    },
                    cursorColor: Colors.white,
                    style: TextStyle(fontSize: 18, color: Colors.white),
                    decoration: new InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                        hintText: "Carian",
                        hintStyle: TextStyle(
                            color: Color(0xffDADADA),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                  child: BlocBuilder<HadithCubit, HadithState>(
                    builder: (context, state) {
                      if (state is InfaqCategoriesLoaded) {
                        infaqCategoryList = state.infaqCategories;

                        if (selectedCategoryName.isEmpty) {
                          selectedCategoryName =
                              infaqCategoryList.first.id.toString();
                        }

                        if (infaqDetailsList.isEmpty) {
                          infaqDetailsList =
                              BlocProvider.of<ScreensDetailsCubit>(context)
                                  .fetchInfaqDetails(
                                      selectedCategoryName, false);
                        }

                        return Container(
                            padding: EdgeInsets.only(left: 15, right: 15),
                            width: double.infinity,
                            height: 35,
                            decoration: new BoxDecoration(
                                color: Color(0xff1B1B1B),
                                borderRadius: BorderRadius.circular(8)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                icon: Image.asset(
                                  ImageResource.down_arrow,
                                  alignment: Alignment.centerRight,
                                  height: 16,
                                  width: 16,
                                ),
                                dropdownColor: Color(0xff1B1B1B),
                                onChanged: (value) {
                                  if (value != '0' && value != '1000') {
                                    searchData.clear();
                                    print('--------------$value');
                                    setState(() {
                                      selectedCategoryName = value ?? '';
                                    });
                                    infaqDetailsList =
                                        BlocProvider.of<ScreensDetailsCubit>(
                                                context)
                                            .fetchInfaqDetails(
                                                selectedCategoryName, true);
                                  } else if (value == '1000') {
                                    searchData.clear();
                                    print('--------------$value');
                                    setState(() {
                                      selectedCategoryName = value ?? '';
                                    });
                                    infaqDetailsList =
                                        BlocProvider.of<ScreensDetailsCubit>(
                                                context)
                                            .fetchInfaqDetails(
                                                selectedCategoryName, false);
                                  }
                                },
                                value: selectedCategoryName,
                                items: infaqCategoryList
                                    .map<DropdownMenuItem<String>>(
                                        (e) => DropdownMenuItem(
                                            value: e.id.toString(),
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  78,
                                              child: Text(
                                                e.name!,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color:
                                                        e.id.toString() == '0'
                                                            ? getColor(theme)
                                                            : Color(0xffFFFFFF),
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 12,
                                                    fontStyle:
                                                        FontStyle.normal),
                                              ),
                                            )))
                                    .toList(),
                              ),
                            ));
                      } else {
                        return Shimmer.fromColors(
                          enabled: true,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 35,
                            decoration: new BoxDecoration(
                                color: Color(0xFF383838),
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          baseColor: Color(0xFF383838),
                          highlightColor: Color(0xFF484848),
                        );
                      }
                    },
                  ),
                ),
                Expanded(
                  child: BlocBuilder<ScreensDetailsCubit, ScreensDetailsState>(
                      builder: (context, state) {
                    if (state is InfaqListLoaded) {
                      infaqDetailsList = state.detailsList;
                    }
                    return Container(
                      padding: EdgeInsets.only(bottom: 60),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: ListView.builder(
                          itemCount: state is InfaqListLoading
                              ? 10
                              : infaqDetailsList != null &&
                                      infaqDetailsList.isNotEmpty &&
                                      searchData != null &&
                                      searchData.isNotEmpty
                                  ? searchData.length
                                  : infaqDetailsList.length,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (context, index) {
                            return Column(children: [
                              state is InfaqListLoading
                                  ? Shimmer.fromColors(
                                      enabled: true,
                                      child: ListTile(
                                        title: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              32,
                                          height: 14,
                                          decoration: new BoxDecoration(
                                              color: Color(0xFF383838),
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                        ),
                                        subtitle: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              32,
                                          height: 14,
                                          decoration: new BoxDecoration(
                                              color: Color(0xFF383838),
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                        ),
                                        trailing: Image.asset(
                                          ImageResource.right_arrow,
                                          height: 24,
                                          width: 24,
                                        ),
                                        onTap: () {},
                                      ),
                                      baseColor: Color(0xFF383838),
                                      highlightColor: Color(0xFF484848),
                                    )
                                  : state is InfaqListLoaded &&
                                          infaqDetailsList != null &&
                                          infaqDetailsList.isNotEmpty
                                      ? ListTile(
                                          title: Text(
                                            searchData != null &&
                                                    searchData.isNotEmpty
                                                ? searchData[index]
                                                    .organizationName!
                                                : infaqDetailsList[index]
                                                    .organizationName!,
                                            style: TextStyle(
                                                color: getColor(theme)),
                                          ),
                                          subtitle: Text(
                                            searchData != null &&
                                                    searchData.isNotEmpty
                                                ? searchData[index]
                                                        .maybankNo
                                                        .toString() +
                                                    " (${searchData[index].bankName})"
                                                : infaqDetailsList[index]
                                                        .maybankNo
                                                        .toString() +
                                                    " (${infaqDetailsList[index].bankName})",
                                            style: TextStyle(
                                                color: Color(0xff929292)),
                                          ),
                                          trailing: Image.asset(
                                            ImageResource.right_arrow,
                                            height: 24,
                                            width: 24,
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Senarai_Infaq_Details(
                                                          searchData != null &&
                                                                  searchData
                                                                      .isNotEmpty
                                                              ? searchData[
                                                                  index]
                                                              : infaqDetailsList[
                                                                  index])),
                                            );
                                          },
                                        )
                                      : Container(),
                              infaqDetailsList != null &&
                                      infaqDetailsList.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                        left: 12,
                                        right: 12,
                                      ),
                                      child: Container(
                                        height: 1,
                                        color: Color(0xff787878),
                                      ),
                                    )
                                  : Container(),
                            ]);
                          }),
                    );
                  }),
                )
              ],
            ),
          )),
    );
  }
}
