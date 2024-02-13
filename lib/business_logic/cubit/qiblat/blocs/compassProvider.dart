import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:location/location.dart';
import 'package:mukim_app/utils/qiblat/compass_logic.dart';
import 'package:permission_handler/permission_handler.dart';

class CompassProvider with ChangeNotifier, DiagnosticableTreeMixin {
  double _compassAngle = 0;
  double _kiblatAngle = 0;
  double _lat = 0;
  double _long = 0;
  StreamSubscription? _event;
  Location _location = Location();
  final Iterable<Duration> pauses = [
    const Duration(milliseconds: 500),
  ];
  double get compassAngle => _compassAngle;
  double get kiblatAngle => _kiblatAngle;
  Future<bool> canVibrate = Vibrate.canVibrate;

  CompassProvider() {
    askPermission(Permission.location).then((value) async {
      if (value == true) {
        _lat = (await _location.getLocation()).latitude ?? 0;
        _long = (await _location.getLocation()).longitude ?? 39;
      }
    });
    try {
      if (_event != null) {
        return;
      }
      _event = FlutterCompass.events!.listen((angle) {
        _compassAngle = angle.heading ?? 0;
        _kiblatAngle =
            (-_compassAngle + Utils.getOffsetFromNorth(_lat, _long)) *
                (pi / 180);

        notifyListeners();
      });
    } catch (e) {
      print(e);
    }
  }

  Future<bool> askPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      return await permission.request().isGranted;
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (_event != null) {
      _event!.cancel();
      _event = null;
    }
  }
}
