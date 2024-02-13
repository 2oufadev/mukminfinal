import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:panorama/panorama.dart';

class PanoramaView extends StatefulWidget {
  final String url;
  const PanoramaView({
    Key? key,
    required this.url,
  }) : super(key: key);

  @override
  _PanoramaViewState createState() => _PanoramaViewState();
}

class _PanoramaViewState extends State<PanoramaView> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          return Stack(
            children: [
              Panorama(
                sensorControl: SensorControl.AbsoluteOrientation,
                child: Image.network(widget.url),
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
            ],
          );
        },
      )),
    );
  }
}
