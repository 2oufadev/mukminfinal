import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:location/location.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:mukim_app/providers/theme.dart';
import 'package:mukim_app/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_settings/app_settings.dart';
import 'main_screen.dart';

class GoogleEarth extends StatefulWidget {
  final bool refresh;

  const GoogleEarth({Key? key, this.refresh = false}) : super(key: key);
  @override
  _GoogleEarthState createState() => _GoogleEarthState();
}

class _GoogleEarthState extends State<GoogleEarth> {
  double lati = 4.2105, longi = 101.9758;
  Location _locationTracker = Location();
  LocationData? _currentposition;
  LocationData? _currentPosition;
  Location location = new Location();
  bool img = false;
  bool locationDisplayed = false;
  late SharedPreferences sharedPreferences;
  Timer? tim;
  String? cityName = '';
  String? district = '';
  var angle;
  Timer? timer;

  getloc() async {
    Location location = new Location();
    bool _serviceEnabled = false;
    PermissionStatus _permissionGranted;
    LocationData _locationData;
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return AppSettings.openLocationSettings;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return AppSettings.openLocationSettings;
      }
    }
    _currentposition = await _locationTracker.getLocation();
    if (mounted) {
      setState(() {
        lati = _currentposition!.latitude ?? 0;
        longi = _currentposition!.longitude ?? 0;
      });
    }

    _locationData = await location.getLocation();
    lati = _locationData.latitude ?? 0;
    longi = _locationData.longitude ?? 0;

    location.getLocation();
    location.onLocationChanged.listen((LocationData currentLocation) {
      lati = currentLocation.latitude ?? 0;
      longi = currentLocation.longitude ?? 0;
    });
  }

  fetchLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _currentPosition = await location.getLocation();
    location.onLocationChanged.listen((LocationData currentLocation) {
      if (_currentposition != null && currentLocation != null) {
        if (mounted) {
          setState(() {
            _currentPosition = currentLocation;
            lati = _currentposition!.latitude ?? 0;
            longi = _currentposition!.longitude ?? 0;
          });
        }
      }
    });
  }

  void _onMapCreated() {
    //_moveToNextCity();
  }

  void _onCameraMove(LatLng latLon, double zoom) {
    if (mounted) {
      setState(() {
        if (img == false && zoom > 10.0 && locationDisplayed == false) {
          img = true;
          locationDisplayed = true;
        } else if (locationDisplayed == true && zoom < 10.0) {
          img = false;
        }
      });
    }
  }

  void _moveToNextCity() async {
    location.getLocation();
    location.onLocationChanged.listen((LocationData currentLocation) {
      lati = currentLocation.latitude ?? 0;

      longi = currentLocation.longitude ?? 0;
    });
    LocationData _locationData;
    _locationData = await location.getLocation();
    lati = _locationData.latitude ?? 0;
    longi = _locationData.longitude ?? 0;

    if (widget.refresh) {
      List<Placemark> addresses = await placemarkFromCoordinates(lati, longi);

      cityName = addresses.first.administrativeArea!;
      if (cityName == null) {
        addresses.forEach((element) {
          if (element.administrativeArea != null) {
            cityName = element.administrativeArea;
            return;
          }
        });
      }
      district = cityName != null
          ? modifyDistrictName(cityName!.toLowerCase(), addresses)
          : '';

      if (cityName == null) cityName = '';
      if (district == null) district = '';
      if (district!.isNotEmpty) {
        sharedPreferences.setString('district', district!);
        sharedPreferences.setString('city', cityName!);
      }
    }
    // _controller!.animateCamera(
    //     newLatLon: LatLon(lati, longi).inRadians(),
    //     riseZoom: 2.2,
    //     fallZoom: 20,
    //     panSpeed: 1500,
    //     riseSpeed: 5.5,
    //     fallSpeed: 100);
  }

  void _moveToKaaba() {
    const double lat = 21.4225;
    const double lon = 39.8262;
    angle = SphericalUtil.computeAngleBetween(
        LatLng(lati, longi), LatLng(lat, lon));
    // _controller.animateCamera(
    //     newLatLon: LatLon(lat, lon).inRadians(),
    //     riseZoom: 2.2,
    //     fallZoom: 19,
    //     panSpeed: 70,
    //     riseSpeed: 5,
    //     fallSpeed: 1.2);

    tim = Timer.periodic(Duration(seconds: 1), (Timer t) {
      print('~~~~~~~~~~~~~~~~');
      // checkAnimation(_controller.isAnimating);
    });
  }

  checkAnimation(bool isAnim) {
    print('is animation    ${isAnim.toString()}');
    if (!isAnim) {
      if (tim != null) {
        tim!.cancel();

        setEarth();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => Kibat2(
                  cityName: cityName!,
                  zone: district!,
                  refreshNotifications: widget.refresh ? true : false)),
        );
      } else {
        setEarth();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => Kibat2(
                  cityName: cityName!,
                  zone: district!,
                  refreshNotifications: widget.refresh ? true : false)),
        );
      }
    }
  }

  setEarth() async {
    sharedPreferences.setBool('earth', false);
    sharedPreferences.setDouble('angle', angle);
  }

  @override
  void initState() {
    super.initState();
    getShared();
    getloc();
    fetchLocation();
    getloc();
    fetchLocation();

    // _control = VideoPlayerController.asset("assets/stars.mp4")
    //   ..initialize().then((_) {
    //     _control.play();
    //     _control.setLooping(true);
    //     if (mounted) {
    //       setState(() {});
    //     }
    //   });
    Timer(const Duration(milliseconds: 500), () {
      _moveToNextCity();
    });
    timer = Timer(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          _moveToKaaba();
        });
      }
    });
  }

  getShared() async {
    sharedPreferences = await SharedPreferences.getInstance();
    cityName = sharedPreferences.getString('city') ?? '';
    district = sharedPreferences.getString('district') ?? '';
  }

  @override
  void dispose() {
    if (tim != null) {
      tim!.cancel();
    }

    timer?.cancel();

    // _controller.clearCache();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String theme = Provider.of<ThemeNotifier>(context).appTheme;

    return SafeArea(
      top: false,
      child: Stack(children: [
        Positioned.fill(
          child: AbsorbPointer(
            child: Center(
              child: Stack(
                children: <Widget>[
                  // Positioned(
                  //     top: 0,
                  //     bottom: 0,
                  //     left: 0,
                  //     right: 0,
                  //     child: VideoPlayer(_control)),
                  Column(
                    children: <Widget>[
                      Expanded(
                        // child: FlutterEarth(
                        //   //onTileStart: _ontilestart,
                        //   url:
                        //       'http://mt0.google.cn/vt/lyrs=y&hl=en&x={x}&y={y}&z={z}',
                        //   radius: 150,
                        //   onMapCreated: _onMapCreated,
                        //   onCameraMove: _onCameraMove,
                        // ),
                        child: Container(),
                      ),
                    ],
                  ),
                  img != true
                      ? const SizedBox()
                      : Center(
                          child: Container(
                              height: MediaQuery.of(context).size.height * 0.13,
                              width: MediaQuery.of(context).size.width * 0.13,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 45,
                              ))),
                ],
              ),
            ),
          ),
        ),
        Positioned(
            bottom: 0,
            left: 0,
            child: Container(
                color: Colors.black,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    DefaultTextStyle(
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      child: Text(
                        'Slow Loading / Rendering? Please Click Skip',
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFF807BB2),
                      ),
                      onPressed: () {
                        const double lat = 21.4225;
                        const double lon = 39.8262;
                        angle = SphericalUtil.computeAngleBetween(
                            LatLng(lati, longi), LatLng(lat, lon));
                        checkAnimation(false);
                      },
                      child: Text("SKIP"),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                  ],
                )))
      ]),
    );
  }
}
