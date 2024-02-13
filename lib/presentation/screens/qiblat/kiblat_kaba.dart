import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:location/location.dart';
import 'package:mukim_app/presentation/screens/qiblat/main_screen.dart';
import 'package:mukim_app/presentation/widgets/qiblat/compass_models.dart';
import 'package:mukim_app/presentation/widgets/qiblat/triangle_animate.dart';
import 'package:mukim_app/utils/qiblat/compass_logic.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class TrianglesLine extends StatefulWidget {
  final String oldCity, oldDistrict;

  const TrianglesLine(
      {Key? key, required this.oldCity, required this.oldDistrict})
      : super(key: key);

  @override
  _TrianglesLineState createState() => _TrianglesLineState();
}

class _TrianglesLineState extends State<TrianglesLine>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  List<String> images = [
    'assets/images/kiblat_kaba/down_triangle_line_left.png',
    'assets/images/kiblat_kaba/center.png',
    'assets/images/kiblat_kaba/down_triangle_line_right.png',
  ];
  CameraController _cameraController = CameraController(
    CameraDescription(
        name: "Front",
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 0),
    ResolutionPreset.medium,
    enableAudio: true,
    imageFormatGroup: ImageFormatGroup.jpeg,
  );
  int compassDesign = 0;
  Location _location = Location();
  double _lat = 0;
  double _long = 39;
  double kiblatAngleDegree = 0;
  int imageFlag = 1; //flage to chose image according to kiblat direction
  bool fiveSecondsFlag = true;
  double pi = 3.141592654;
  bool enableAudio = true;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  int _imageIndex = 0;
  Completer<int> imagePosition = new Completer<int>();
  StreamController<List> _imagePositionController = StreamController();
  StreamController<int> speedController = StreamController();
  ScrollController _scrollController = ScrollController();

  int aeroSpeed = 150;

  Stream<int> positionAnimation() async* {
    for (int i = 1; i <= 6; i++) {
      yield i;
      await Future.delayed(Duration(milliseconds: 150));
      if (i == 6) {
        i = 0;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    initShared();
    setLatLong();

    List list = [0, 50];
    _imagePositionController.add(list);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      onNewCameraSelected();
    });
  }

  initShared() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    compassDesign = sharedPreferences.getInt('compassDesign') ?? 0;
  }

  setLatLong() async {
    _lat = (await _location.getLocation()).latitude ?? 0;
    _long = (await _location.getLocation()).longitude ?? 39;
  }

  Future<bool> askPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      return await permission.request().isGranted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => Kibat2(
              cityName: widget.oldCity,
              zone: widget.oldDistrict,
            ),
          ),
        );
        return Future.value(false);
      },
      child: Scaffold(
        body: Stack(
          children: [
            StreamBuilder(
                stream: FlutterQiblah.qiblahStream,
                builder: (_, AsyncSnapshot<QiblahDirection> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator());

                  final qiblahDirection = snapshot.data;
                  bool isValid = false;
                  double angle = 0;
                  if (qiblahDirection != null) {
                    angle = ((qiblahDirection.qiblah ?? 0) * (pi / 180) * -1);
                    isValid = qiblahDirection.offset -
                                qiblahDirection.direction >=
                            (angle) - 0.5 &&
                        qiblahDirection.offset - qiblahDirection.direction <=
                            (angle) + 0.5;
                  }
                  int _imageIndex = 1;
                  double lastPer = 50;
                  double opacity = 0;

                  double offset = Utils.getOffsetFromNorth(_lat, _long);
                  angle = (angle * (-1 * 180 / pi));
                  if (angle > 360) {
                    angle = angle - 360;
                  } else {}

                  double per = ((angle * 100) / 360);

                  if (per < 30) {
                    opacity = (100 - per) / 100;
                  } else if (per > 70) {
                    opacity = per / 100;
                  } else {
                    opacity = 0;
                  }

                  if (angle > 3 && angle < 190) {
                    _imageIndex = 0;
                  } else if (angle < 357 && angle > 170) {
                    _imageIndex = 2;
                  }
                  if (this._imageIndex != _imageIndex) {
                    this._imageIndex = _imageIndex;
                    List list = [_imageIndex, per];
                    _imagePositionController.add(list);
                  }
                  if (_scrollController.positions.isNotEmpty) {
                    double maxScroll =
                        _scrollController.position.maxScrollExtent / 2;
                    double per1 = ((maxScroll * per) / 100);

                    if (per >= 50) {
                      _scrollController
                          .jumpTo((maxScroll - (maxScroll - per1)));
                    } else {
                      _scrollController.jumpTo((maxScroll + (per1)));
                    }
                    if (per < 30) {
                      opacity = (100 - per) / 100;
                    }
                    if (per > 70) {
                      opacity = per / 100;
                    }
                  }
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_imageIndex != 1) _cameraPreviewWidget(),
                      Opacity(
                        opacity: opacity != null && opacity >= 0 && opacity <= 1
                            ? opacity
                            : 1.0,
                        child: Container(
                          height: height,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            scrollDirection: Axis.horizontal,
                            child: Image.asset(
                              './assets/images/kiblat_kaba/full.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 40,
                        left: 15,
                        child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => Kibat2(
                                    cityName: widget.oldCity,
                                    zone: widget.oldDistrict,
                                  ),
                                ),
                              );
                            },
                            child: Icon(
                              Icons.arrow_back_ios,
                              size: 25,
                              color: Colors.white,
                            )),
                      ),
                      Positioned(
                        top: 60,
                        left: (width - 40) / 2,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => Kibat2(
                                        cityName: widget.oldCity,
                                        zone: widget.oldDistrict)));
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.pinkAccent,
                            radius: 20,
                            child: Icon(
                              Icons.view_in_ar,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 140,
                        left: (width - 180) / 2,
                        child: Column(
                          children: [
                            fiveSecondsFlag
                                ? Container(
                                    width: 180,
                                    height: 0,
                                    child: (_imageIndex != 1)
                                        ? Stack(
                                            children: [
                                              Opacity(
                                                opacity: .5,
                                                child: Container(
                                                  width: 180,
                                                  height: 80,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10)),
                                                      color:
                                                          HexColor('3A343D')),
                                                ),
                                              ),
                                              Center(
                                                child: Text(
                                                  'Tekan butang ini \nuntuk keluar dari \n‘mode’ arah Kiblat',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16),
                                                ),
                                              ),
                                            ],
                                          )
                                        : SizedBox(),
                                  )
                                : SizedBox(height: 80),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: 220,
                          height: 80,
                          margin: EdgeInsets.symmetric(vertical: 100),
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: HexColor('3A343D')),
                          child: Center(
                              child: (_imageIndex != 1)
                                  ? Text(
                                      ' Gerakkan telefon\nbimbit anda mengikut arah anak\npanah di bawah',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14),
                                      textAlign: TextAlign.center,
                                    )
                                  : Text(
                                      'Tahniah, anda telah \nmenjumpai arah Kiblat!',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    )),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: Opacity(
                          opacity: .7,
                          child: Container(
                            width: width,
                            height: 90,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
            StreamBuilder(
                stream: _imagePositionController.stream,
                builder: (context, AsyncSnapshot<List> snapshot) {
                  if (snapshot != null && snapshot.data != null) {
                    int _imageIndex = snapshot.data![0];

                    print('per------------------- ${snapshot.data![1]}');
                    if (snapshot.data![1] < 30) {
                      aeroSpeed = 500;
                    } else if (snapshot.data![1] > 70) {
                      aeroSpeed = 500;
                    } else {
                      aeroSpeed = 150;
                    }

                    return Positioned(
                      bottom: _imageIndex != 1 ? 30 : 25,
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: Duration(microseconds: 10),
                            curve: Curves.bounceOut,
                            child: Container(
                                width: width,
                                height: _imageIndex != 1 ? 40 : 80,
                                child: Stack(
                                  children: [
                                    Image.asset(
                                      images[_imageIndex],
                                      width: width,
                                      fit: BoxFit.fill,
                                    ),
                                    _imageIndex != 1
                                        ? StreamBuilder<int>(
                                            initialData: 1,
                                            stream: Stream.periodic(
                                                Duration(milliseconds: 150),
                                                (event) {
                                              return (event % 6) + 1;
                                            }),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.active) {
                                                return Positioned(
                                                  top: 7,
                                                  right: _imageIndex == 0
                                                      ? (snapshot.data)! *
                                                              (width / 11.1) +
                                                          (snapshot.data! - 1) *
                                                              15
                                                      : null,
                                                  left: _imageIndex == 2
                                                      ? (snapshot.data)! *
                                                              (width / 11.1) +
                                                          (snapshot.data! - 1) *
                                                              15
                                                      : null,
                                                  child: Container(
                                                      width: 25,
                                                      height: 25,
                                                      child: Triangle(
                                                        direction:
                                                            _imageIndex != 0,
                                                      )),
                                                );
                                              } else {
                                                return Positioned(
                                                  top: 6,
                                                  right: _imageIndex == 0
                                                      ? (snapshot.data)! *
                                                              (width / 11.1) +
                                                          (snapshot.data! - 1) *
                                                              15
                                                      : null,
                                                  left: _imageIndex == 2
                                                      ? (snapshot.data)! *
                                                              (width / 11.1) +
                                                          (snapshot.data! - 1) *
                                                              15
                                                      : null,
                                                  child: Container(
                                                      width: 25,
                                                      height: 25,
                                                      child: Triangle(
                                                        direction:
                                                            _imageIndex != 0,
                                                      )),
                                                );
                                              }
                                            })
                                        : SizedBox()
                                  ],
                                )),
                          ),
                          _imageIndex != 1
                              ? Text(
                                  'Sila gerakkan handphone anda...',
                                  style: TextStyle(color: Colors.white),
                                )
                              : SizedBox(),
                        ],
                      ),
                    );
                  } else {
                    return SizedBox();
                  }
                }),
            Positioned(
              top: 25,
              left: (width / 2) - width / 6.8,
              child: Compass1(
                design: compassDesign != 0 ? compassDesign : 1,
                scaled: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController cameraController = _cameraController;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected();
    }
  }

  void onNewCameraSelected() async {
    await _cameraController.dispose();
    var camerraList = await availableCameras();
    final CameraController cameraController = CameraController(
      camerraList[0],
      ResolutionPreset.veryHigh,
      enableAudio: enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    _cameraController = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) setState(() {});
      if (cameraController.value.hasError) {}
    });

    try {
      await cameraController.initialize();
      await Future.wait([
        cameraController
            .getMinExposureOffset()
            .then((value) => _minAvailableExposureOffset = value),
        cameraController
            .getMaxExposureOffset()
            .then((value) => _maxAvailableExposureOffset = value),
        cameraController
            .getMaxZoomLevel()
            .then((value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((value) => _minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description!);
  }

  void logError(String code, String message) {
    if (message != null) {
      print('Error: $code\nError Message: $message');
    } else {
      print('Error: $code');
    }
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    CameraController cameraController = _cameraController;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return CameraPreview(
        cameraController,
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
          );
        }),
      );
    }
  }
}
