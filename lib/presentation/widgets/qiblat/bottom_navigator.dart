import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class TabNavigator extends StatelessWidget {
  TabNavigator({
    Key? key,
    //required this.index,
    // required this.tabController
  }) : super(key: key);
  int index = 0;
  //final TabController tabController;
  final List<Color> colors = const [Colors.white, Colors.black];
  final List<double> sizes = const <double>[20.0, 35.0];
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    //final width=MediaQuery.of(context).size.width;
    return Container();
    return Container(
      height: 60,
      decoration: BoxDecoration(
          color: HexColor('000000'),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      width: MediaQuery.of(context).size.width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: TextButton(
              child: Image.asset(
                './assets/images/bottom_bar/utama.png',
                height: 50,
                fit: BoxFit.cover,
              ),
              onPressed: () {
                // tabController.animateTo(0,duration: Duration(milliseconds: 50));
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: TextButton(
              child: Image.asset(
                './assets/images/bottom_bar/qiblat.png',
                height: 50,
                fit: BoxFit.cover,
              ),
              onPressed: () {
                // tabController.animateTo(1,duration: Duration(milliseconds: 50));
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: TextButton(
              child: Image.asset(
                './assets/images/bottom_bar/quran.png',
                height: 50,
                fit: BoxFit.cover,
              ),
              onPressed: () {
                //tabController.animateTo(2,duration: Duration(milliseconds: 50));
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: TextButton(
              child: Image.asset(
                './assets/images/bottom_bar/hadith.png',
                height: 50,
                fit: BoxFit.cover,
              ),
              onPressed: () {
                //tabController.animateTo(3,duration: Duration(milliseconds: 50));
              },
            ),
          ),
        ],
      ),
    );
  }
}
