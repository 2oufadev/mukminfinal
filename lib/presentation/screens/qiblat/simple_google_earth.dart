import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:location/location.dart';
import 'package:video_player/video_player.dart';
import 'package:app_settings/app_settings.dart';

class SimpleGoogleEarth extends StatefulWidget {
  @override
  _SimpleGoogleEarthState createState() => _SimpleGoogleEarthState();
}

class _SimpleGoogleEarthState extends State<SimpleGoogleEarth> {
  double _zoom = 0;
  String _cityName = '';
  dynamic _cityList;
  double lati = 4.2105, longi = 101.9758;
  Random _random = Random();
  Location _locationTracker = Location();
  LocationData? _currentposition;
  LocationData? _currentPosition;
  Location location = new Location();
  VideoPlayerController? _control;
  bool img = false;
  bool locationDisplayed = false;

  Timer? tim;

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
    setState(() {
      lati = _currentposition!.latitude ?? 0;
      longi = _currentposition!.longitude ?? 0;
    });

    // _locationData = await location.getLocation();
    // lati = _locationData.latitude;
    // longi = _locationData.longitude;

    // location.getLocation();
    // location.onLocationChanged.listen((LocationData currentLocation) {
    //   lati = currentLocation.latitude;

    //   longi = currentLocation.longitude;
    // });
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
      if (currentLocation != null && mounted) {
        setState(() {
          _currentPosition = currentLocation;
          if (_currentposition != null) {
            lati = _currentposition!.latitude ?? 0;
            longi = _currentposition!.longitude ?? 0;
          }
        });
      }
    });
  }

  void _onMapCreated() {
    // _controller = controller;
    _moveToNextCity();
  }

  // void _onCameraMove(LatLon latLon, double zoom) {
  //   setState(() {
  //     if (img == false && zoom > 10.0 && locationDisplayed == false) {
  //       img = true;
  //       locationDisplayed = true;
  //     } else if (locationDisplayed == true && zoom < 10.0) {
  //       img = false;
  //     }
  //     _zoom = zoom;
  //     _position = latLon.inDegrees();
  //   });
  // }

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

    print(lati);
    print(longi);
    print('aaaa');
    // _controller.animateCamera(
    //     newLatLon: LatLon(lati, longi).inRadians(),
    //     riseZoom: 2.2,
    //     fallZoom: 20,
    //     panSpeed: 500,
    //     riseSpeed: 5.5,
    //     fallSpeed: 9.5);
  }

  void _moveToKaaba() {
    const double lat = 21.4225;
    const double lon = 39.8262;
    // _controller.animateCamera(
    //     newLatLon: LatLon(lat, lon).inRadians(),
    //     riseZoom: 2.2,
    //     fallZoom: 19,
    //     panSpeed: 70,
    //     riseSpeed: 5,
    //     fallSpeed: 1.2);

    tim = Timer.periodic(Duration(seconds: 1), (Timer t) {
      // checkAnimation(_controller.isAnimating);
    });
  }

  checkAnimation(bool isAnim) {
    print('is animation    ${isAnim.toString()}');
    if (!isAnim) {
      tim?.cancel();

      //Navigator.of(context).pop();
      //Kibat2(cityName: "Kuala Lumpur",compassDesign: 1,);

      /* Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  Kibat2(cityName: "Kuala Lumpur",compassDesign: 1,)),);*/
    }
  }

  @override
  void initState() {
    super.initState();

    // getloc();
    // fetchLocation();
    // Timer(const Duration(seconds: 3),(){
    //   splash=true;}
    //   );
    // _control = VideoPlayerController.asset("assets/stars.mp4")
    //   ..initialize().then((_) {
    //     _control.play();
    //     _control.setLooping(true);

    //     setState(() {});
    //   });
    // Timer(const Duration(seconds: 3), () {
    //   // _moveToNextCity();
    // });
    // final timer = Timer(const Duration(seconds: 12), () {
    //   setState(() {
    //     //_moveToKaaba();
    //   });
    // });
  }

  @override
  void dispose() {
    // tim?.cancel();
    // _controller.clearCache();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
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
                  child: Container(),
                ),
              ],
            ),
            Positioned(
              top: 40,
              left: 15,
              child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 25,
                    color: Colors.white,
                  )),
            ),
            // img != true
            //     ? const SizedBox()
            //     : Center(
            //         child: Container(
            //             height: MediaQuery.of(context).size.height * 0.13,
            //             width: MediaQuery.of(context).size.width * 0.13,
            //             child: const Icon(
            //               Icons.location_on,
            //               color: Colors.red,
            //               size: 45,
            //             ))),
          ],
        ),
      ),
    );
  }
}
