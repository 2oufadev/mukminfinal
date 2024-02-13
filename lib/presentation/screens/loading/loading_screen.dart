import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mukim_app/presentation/screens/login_screen.dart';
import 'package:mukim_app/presentation/widgets/background.dart';
import 'package:mukim_app/resources/Imageresources.dart';
import 'package:mukim_app/utils/styles.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2)).then((value) {
      _goToLoginScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.backGroundColor,
      body: BackGround(
          child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image(
              image: new AssetImage(
                ImageResource.hello,
              ),
              height: 60,
              width: 60,
            ),
            const SizedBox(height: 16.0),
            SvgPicture.asset(ImageResource.splash),
            const SizedBox(height: 16.0),
            Text(
              'Assalamu’alaikum warahmatullahi wabarakatuh',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            )
          ],
        ),
      )),
    );
  }

  _goToLoginScreen() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()));
  }
}
