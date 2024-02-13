import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mukim_app/presentation/screens/panorama.dart';
import 'package:mukim_app/utils/componants.dart';

class VideoPlayer360 {
  static const MethodChannel _channel =
      const MethodChannel('flutter.native/helper');

  static Future<Future<Map?>?> playVideoURL(String url,
      {int radius = 50,
      int verticalFov = 180,
      int horizontalFov = 360,
      int rows = 50,
      int columns = 50,
      bool showPlaceholder = false,
      BuildContext? context}) async {
    if (Platform.isIOS) {
      navigateTo(context: context!, screen: PanoramaView(url: url));
      return null;
    } else {
      return _channel.invokeMapMethod("playvideo", <String, dynamic>{
        'video_url': url,
        'radius': radius,
        'verticalFov': verticalFov,
        'horizontalFov': horizontalFov,
        'rows': rows,
        'columns': columns,
        'showPlaceholder': showPlaceholder,
      });
    }
  }
}
