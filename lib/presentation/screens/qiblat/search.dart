import 'package:mukim_app/presentation/screens/home/home_screen.dart';
import 'package:mukim_app/presentation/screens/qiblat/main_screen.dart';
import 'package:mukim_app/presentation/widgets/qiblat/bottom_navigator.dart';
import 'package:mukim_app/resources/Imageresources.dart';
import 'package:mukim_app/resources/global.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class SearchScreen extends StatefulWidget {
  final String? oldCity;
  final String? oldZone;
  final bool? manual;
  final bool? login;

  const SearchScreen(
      {Key? key,
      required this.oldCity,
      this.manual = false,
      this.login = false,
      this.oldZone})
      : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<String> suggestions = [];
  TextEditingController searchController = TextEditingController();
  String? selectedResult;
  String? selectedState;
  bool stateActive = false;
  bool zoneActive = false;
  String stateHint = "Pilih Negeri";
  String zoneHint = "Pilih Zon";
  late SharedPreferences sharedPreferences;
  @override
  void initState() {
    super.initState();
    initShared();
  }

  initShared() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: HexColor('3A343D'),
        appBar: PreferredSize(
          child: widget.manual!
              ? Container(
                  height: 100,
                  child: Center(
                    child: Text(
                      'Tukar Lokasi',
                      style: Theme.of(context)
                          .textTheme
                          .headline6!
                          .copyWith(color: Colors.white),
                    ),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      FutureBuilder<SharedPreferences>(
                        future: SharedPreferences.getInstance(),
                        builder: (context, snapshot) {
                          String? theme;
                          if (snapshot.hasData) {
                            theme = snapshot.data!.getString('appTheme');
                          }
                          return Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                  "assets/theme/${theme ?? "default"}/appbar.png",
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Text(
                            'Tukar Lokasi',
                            style: Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: InkWell(
                          onTap: () {
                            sharedPreferences.setString(
                                'city', widget.oldCity!);
                            sharedPreferences.setString(
                                'district', widget.oldZone!);
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => Kibat2(
                                        cityName: widget.oldCity!,
                                        zone: widget.oldZone!,
                                        refreshNotifications: true)));
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.only(bottom: 20.0, left: 20),
                            child: Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: InkWell(
                          onTap: () {},
                          child: Padding(
                            padding:
                                const EdgeInsets.only(bottom: 20.0, right: 20),
                            child: Icon(
                              Icons.settings,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          preferredSize: Size.fromHeight(
            width * 0.267,
          ),
        ),
        body: Stack(
          children: [
            Opacity(
                opacity: .3,
                child: Image.asset(
                  ImageResource.searchBackground,
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.fill,
                )),
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: width,
                    padding: const EdgeInsets.all(10),
                    child: searchDropdown(),
                  ),
                ],
              ),
            ),
            Positioned(
              child: TabNavigator(),
              bottom: 0,
            )
          ],
        ));
  }

  Widget searchDropdown() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              stateActive = !stateActive;
              setState(() {});
            },
            child: Container(
              height: 30,
              margin: EdgeInsets.only(top: 4, bottom: 4),
              padding: EdgeInsets.symmetric(vertical: 7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    stateHint,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  Image.asset(
                    stateActive
                        ? ImageResource.down_arrow
                        : ImageResource.right_arrow,
                    height: 20,
                    width: 20,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          stateActive
              ? ListView.builder(
                  itemCount: Globals.statesList.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        stateHint = Globals.statesList[index];
                        onStateSelect(Globals.statesList[index]);
                        stateActive = false;
                        zoneActive = true;
                        setState(() {});
                      },
                      child: Container(
                        width: double.infinity,
                        color: Colors.transparent,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 30,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 7),
                                  child: Text(
                                    Globals.statesList[index],
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ],
                            ),
                            Divider(
                              height: 5,
                              thickness: 2,
                              endIndent: 20,
                              indent: 20,
                              color: HexColor('787878'),
                            )
                          ],
                        ),
                      ),
                    );
                  })
              : SizedBox(),
          InkWell(
            onTap: () {
              if (selectedState == null) {
                zoneActive = false;
              } else {
                zoneActive = !zoneActive;
              }
              setState(() {});
            },
            child: Container(
              height: 30,
              margin: EdgeInsets.only(top: 6, bottom: 4),
              padding: EdgeInsets.symmetric(vertical: 7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    zoneHint,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  Image.asset(
                    zoneActive
                        ? "assets/images/down_arrow.png"
                        : "assets/images/right_arrow.png",
                    height: 20,
                    width: 20,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          zoneActive && selectedState != null
              ? ListView.builder(
                  itemCount: suggestions.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        zoneHint = suggestions[index];
                        zoneActive = false;
                        sharedPreferences.setString('city', selectedState!);
                        sharedPreferences.setString(
                            'district', suggestions[index]);
                        if (widget.manual! && widget.login!) {
                          Navigator.pop(context, true);
                        } else if (widget.manual!) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(),
                            ),
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Kibat2(
                                  cityName: selectedState!,
                                  zone: suggestions[index],
                                  refreshNotifications: true),
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        color: Colors.transparent,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 30,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 7),
                                  child: Text(
                                    suggestions[index],
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ],
                            ),
                            Divider(
                              height: 5,
                              thickness: 2,
                              endIndent: 20,
                              indent: 20,
                              color: HexColor('787878'),
                            )
                          ],
                        ),
                      ),
                    );
                  })
              : SizedBox(),
        ],
      ),
    );
  }

  Widget stateDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton(
        value: selectedState,
        items: Globals.statesList.map((e) => buildStateItem(e)).toList(),
        onChanged: onStateSelect,
        hint: Text('Pilih Negeri', style: TextStyle(color: Colors.white)),
        isExpanded: true,
        iconEnabledColor: Colors.white,
        style: TextStyle(color: Colors.white),
        dropdownColor: HexColor('666600'),
      ),
    );
  }

  DropdownMenuItem<String> buildStateItem(String state) {
    return DropdownMenuItem(
      child: Text(state),
      value: state,
    );
  }

  void onStateSelect(String? state) {
    selectedState = state;
    suggestions.clear();

    for (int i = 0;
        i < Globals.zonesLists[Globals.statesList.indexOf(state!)].length;
        i++) {
      var zone = Globals.zonesLists[Globals.statesList.indexOf(state)][i];
      suggestions.add(zone);
    }

    setState(() {});
  }

  Widget zoneDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton(
        value: selectedResult,
        items: suggestions.map((e) => buildZoneItem(e)).toList(),
        onChanged: onZoneSelect,
        hint: Text('Select Location', style: TextStyle(color: Colors.white)),
        isExpanded: true,
        iconEnabledColor: Colors.white,
        style: TextStyle(color: Colors.white),
        dropdownColor: HexColor('666600'),
      ),
    );
  }

  DropdownMenuItem<String> buildZoneItem(String zone) {
    return DropdownMenuItem(
      child: Text(zone),
      value: zone,
    );
  }

  void onZoneSelect(String? zone) {
    selectedResult = zone;
    setState(() {});

    if (zone != null) {
      sharedPreferences.setString('city', selectedState!);
      sharedPreferences.setString('district', zone);
      if (widget.manual! && widget.login!) {
        Navigator.pop(context, true);
      } else if (widget.manual!) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Kibat2(
                cityName: selectedState!,
                zone: zone,
                refreshNotifications: true),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
