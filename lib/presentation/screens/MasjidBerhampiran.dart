import 'dart:convert';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_launcher/map_launcher.dart' as map;
import 'package:mukim_app/business_logic/cubit/subscription/userstate_cubit.dart';
import 'package:mukim_app/resources/Imageresources.dart';
import 'package:mukim_app/utils/componants.dart';
import 'package:mukim_app/providers/theme.dart';
import 'package:mukim_app/utils/get_theme_color.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:location/location.dart' as location;
import 'package:google_place/google_place.dart' as place;
import 'package:http/http.dart' as http;

class MasjidBerhampiran extends StatefulWidget {
  @override
  _MasjidBerhampiranState createState() => _MasjidBerhampiranState();
}

class _MasjidBerhampiranState extends State<MasjidBerhampiran> {
  GoogleMapController? _controller;
  location.Location _location = location.Location();
  bool showFavorite = false;
  ScrollController _scrollController = new ScrollController();

  var googlePlace =
      place.GooglePlace("AIzaSyDxnRT1NxgOqg51V97G_XDGvxOqDVmYhHw");
  CameraPosition? _cameraPosition;
  Position? position;

  Iterable markers = [];
  place.NearBySearchResponse searchResponse = new place.NearBySearchResponse();

  List<place.SearchResult> myList = [];
  int _currentLength = 5;
  bool loading = true;
  double currentLat = 0.0;
  double currentLng = 0.0;
  Map<String, dynamic>? userStateMap;
  double latitude = 4.2105, longitude = 101.9758;

  CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  @override
  void initState() {
    super.initState();
    _cameraPosition =
        CameraPosition(target: LatLng(latitude, longitude), zoom: 10.0);

    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    String? theme = Provider.of<ThemeNotifier>(context).appTheme;
    userStateMap = BlocProvider.of<UserStateCubit>(context).checkUserState();
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Color(0xff3A343D),
        extendBodyBehindAppBar: false,
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
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Image.asset(
                          ImageResource.leftArrow,
                          height: 24,
                          width: 24,
                        ),
                      ),
                      Text(
                        "Masjid Berhampiran",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                      Container(
                        height: 24,
                        width: 24,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Stack(children: [
                  ListView.separated(
                    controller: _scrollController,
                    padding: EdgeInsets.only(top: 300, bottom: 65),
                    separatorBuilder: (context, index) => Container(),
                    itemCount: loading ? myList.length + 1 : myList.length,
                    itemBuilder: (context, index) {
                      if (index == myList.length) {
                        return Center(
                            child: CircularProgressIndicator(
                                color: getColor(theme)));
                      }
                      return Container(
                        color: Color(0xff3A343D),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ListTile(
                              title: GestureDetector(
                                onTap: () async {
                                  _customInfoWindowController.addInfoWindow!(
                                    infoWindow(searchResponse.results!, index),
                                    LatLng(
                                      searchResponse.results != null
                                          ? searchResponse.results![index]
                                              .geometry!.location!.lat!
                                          : 47.611656,
                                      searchResponse.results != null
                                          ? searchResponse.results![index]
                                              .geometry!.location!.lng!
                                          : -122.119949,
                                    ),
                                  );
                                  LatLng latLng = LatLng(
                                      searchResponse.results != null
                                          ? searchResponse.results![index]
                                              .geometry!.location!.lat!
                                          : 47.611656,
                                      searchResponse.results != null
                                          ? searchResponse.results![index]
                                              .geometry!.location!.lng!
                                          : -122.11994);
                                  _cameraPosition = CameraPosition(
                                      target: latLng, zoom: 12.0);
                                  ScreenCoordinate projection =
                                      await _controller!
                                          .getScreenCoordinate(latLng);
                                  ScreenCoordinate proj = ScreenCoordinate(
                                      x: projection.x, y: projection.y - 200);

                                  LatLng targetPosition =
                                      await _controller!.getLatLng(proj);
                                  _controller!.animateCamera(
                                      CameraUpdate.newCameraPosition(
                                          CameraPosition(
                                              target: targetPosition,
                                              zoom: 12.0)));
                                },
                                child: Text(
                                  searchResponse.results!
                                      .elementAt(index)
                                      .name!,
                                  style: TextStyle(
                                      color: getColor(theme),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      fontStyle: FontStyle.normal),
                                ),
                              ),
                              subtitle: Text(
                                (Geolocator.distanceBetween(
                                                currentLat,
                                                currentLng,
                                                searchResponse.results![index]
                                                    .geometry!.location!.lat!,
                                                searchResponse.results![index]
                                                    .geometry!.location!.lng!) /
                                            1000)
                                        .toStringAsFixed(2) +
                                    " KM",
                                style: TextStyle(color: Color(0xff929292)),
                              ),
                              trailing: GestureDetector(
                                onTap: () {
                                  openMapsSheet(
                                      context,
                                      searchResponse.results![index].geometry!
                                          .location!.lat,
                                      searchResponse.results![index].geometry!
                                          .location!.lng!,
                                      searchResponse.results![index].name);
                                },
                                child: Image.asset(
                                  ImageResource.map,
                                  width: 16.75,
                                  height: 24,
                                ),
                              ),
                              onTap: () {},
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 12, right: 12, top: 3, bottom: 3),
                              child: Container(
                                height: 1,
                                color: Color(0xff787878),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 300,
                    child: Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: _cameraPosition!,
                          mapType: MapType.normal,
                          myLocationEnabled: true,
                          markers: Set.from(markers),
                          onTap: (position) {
                            _customInfoWindowController.hideInfoWindow!();
                          },
                          onCameraMove: (position) {
                            _customInfoWindowController.onCameraMove!();
                          },
                          onMapCreated: (GoogleMapController controller) {
                            _controller = (controller);
                            _controller!.animateCamera(
                                CameraUpdate.newCameraPosition(
                                    _cameraPosition!));
                            _customInfoWindowController.googleMapController =
                                controller;
                          },
                          onCameraIdle: () {
                            setState(() {});
                          },
                        ),
                        CustomInfoWindow(
                          controller: _customInfoWindowController,
                          height: 140,
                          width: 200,
                          offset: 50,
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
              SizedBox(height: 100)
            ],
          ),
        ),
      ),
    );
  }

  Future nearBySearch(double lat, double lng) async {
    var res = await http.get(Uri.parse(
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?keyword=masjid&location=$lat,$lng&rankby=distance&type=masjid&key=AIzaSyDxnRT1NxgOqg51V97G_XDGvxOqDVmYhHw"));
    if (res != null) {
      place.NearBySearchResponse places =
          place.NearBySearchResponse.fromJson(json.decode(res.body.toString()));
      setState(() {
        searchResponse = places;

        print({searchResponse.status});
        setMarker(places);
        for (int i = _currentLength; i < _currentLength + 5; i++) {
          myList.add(places.results![i + 1]);
        }
        _scrollController.addListener(() {
          if (_scrollController.position.pixels ==
                  _scrollController.position.maxScrollExtent &&
              places.results!.length > _currentLength) {
            setState(() {
              loading = true;
            });

            for (int i = _currentLength; i < _currentLength + 5; i++) {
              myList.add(places.results![i]);
              print("working");
            }

            setState(() {
              _currentLength = _currentLength + 5;
            });
            Future.delayed(Duration(seconds: 3)).then((value) {
              setState(() {
                loading = false;
              });
            });
          }
        });
      });
    }
  }

  void getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((value) {
      setState(() {
        position = value;
        print(value.latitude);
        nearBySearch(value.latitude, value.longitude);
        currentLat = value.latitude;
        currentLng = value.longitude;
        _cameraPosition = CameraPosition(
            target: LatLng(position!.latitude, position!.longitude),
            zoom: 12.0);
        if (_controller != null) {
          _controller!
              .animateCamera(CameraUpdate.newCameraPosition(_cameraPosition!));
        }
      });
    });
  }

  void setMarker(place.NearBySearchResponse response) {
    Iterable _markers = Iterable.generate(response.results!.length, (index) {
      return Marker(
        consumeTapEvents: true,
        markerId: MarkerId(response.results![index].name ?? ""),
        position: LatLng(
          response.results != null
              ? response.results![index].geometry!.location!.lat!
              : 47.611656,
          response.results != null
              ? response.results![index].geometry!.location!.lng!
              : -122.119949,
        ),
        onTap: () async {
          _customInfoWindowController.addInfoWindow!(
            infoWindow(response.results!, index),
            LatLng(
              response.results != null
                  ? response.results![index].geometry!.location!.lat!
                  : 47.611656,
              response.results != null
                  ? response.results![index].geometry!.location!.lng!
                  : -122.119949,
            ),
          );
          if (response.results != null) {
            LatLng latLng = LatLng(
                response.results![index].geometry!.location!.lat!,
                response.results![index].geometry!.location!.lng!);
            ScreenCoordinate projection =
                await _controller!.getScreenCoordinate(latLng);
            ScreenCoordinate proj =
                ScreenCoordinate(x: projection.x, y: projection.y - 200);

            LatLng targetPosition = await _controller!.getLatLng(proj);
            _controller!.animateCamera(CameraUpdate.newCameraPosition(
                CameraPosition(target: targetPosition, zoom: 12.0)));
          }
        },
      );
    }).toList();
    setState(() {
      markers = _markers;
    });
  }

  Widget infoWindow(List<place.SearchResult> results, int index) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 60,
                    // width: double.infinity,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(
                                "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=${results != null && results[index].photos != null ? results[index].photos![0].photoReference : ""}&key=AIzaSyDxnRT1NxgOqg51V97G_XDGvxOqDVmYhHw"),
                            fit: BoxFit.cover)),
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 8.0,
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                results != null ? results[index].name! : "",
                                style: TextStyle(),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                            SizedBox(width: 4),
                            GestureDetector(
                                onTap: () {
                                  openMapsSheet(
                                      context,
                                      searchResponse.results![index].geometry!
                                          .location!.lat,
                                      searchResponse.results![index].geometry!
                                          .location!.lng,
                                      searchResponse.results![index].name);
                                },
                                child: Icon(
                                  Icons.navigation_rounded,
                                  color: Color(0xff4A89F3),
                                )),
                            SizedBox(width: 2),
                          ],
                        ),
                      )
                    ],
                  ),
                  RatingBar.builder(
                    itemSize: 20,
                    initialRating: searchResponse.results![index].rating!,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 3.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 5,
                    ),
                    onRatingUpdate: (rating) {
                      print(rating);
                    },
                  ),
                  Row(
                    children: [
                      searchResponse.results![index].openingHours != null &&
                              searchResponse
                                      .results![index].openingHours!.openNow !=
                                  null
                          ? Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Text(
                                searchResponse
                                        .results![index].openingHours!.openNow!
                                    ? "Open Now"
                                    : "Closed",
                                style: searchResponse
                                        .results![index].openingHours!.openNow!
                                    ? TextStyle(color: Colors.green)
                                    : TextStyle(color: Colors.red),
                              ),
                            )
                          : SizedBox(),
                    ],
                  )
                ],
              ),
            ),
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ],
    );
  }

  openMapsSheet(context, lat, lng, title) async {
    try {
      final coords = map.Coords(lat, lng);

      final availableMaps = await map.MapLauncher.installedMaps;

      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Container(
                child: Wrap(
                  children: <Widget>[
                    for (var map in availableMaps)
                      ListTile(
                        onTap: () => map.showMarker(
                          coords: coords,
                          title: title,
                        ),
                        title: Text(map.mapName),
                        leading: SvgPicture.asset(
                          map.icon,
                          height: 30.0,
                          width: 30.0,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ).then((value) {
        setState(() {
          myList = [];
          getCurrentLocation();
        });
      });
    } catch (e) {
      print(e);
    }
  }
}
