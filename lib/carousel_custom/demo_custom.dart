import 'package:flutter/material.dart';

void main() => runApp(new MyApp3());

class MyApp3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new HomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => new _HomePageState();
}

// class _MyHomePageState extends State<MyHomePage> {
//   final List<String> imgList = [
//     ImageResource.sliderImg5,
//     ImageResource.sliderImg4,
//     ImageResource.sliderImg1,
//     ImageResource.sliderImg2,
//     ImageResource.sliderImg3
//   ];
//   @override
//   Widget build(BuildContext context) {
//     return new Scaffold(
//         appBar: new AppBar(
//           title: new Text(widget.title),
//         ),
//         body: new Swiper(
//           itemBuilder: (BuildContext context, int index) {
//             return new Image.asset(
//               imgList[index],
//               // fit: BoxFit.contain,
//             );
//           },
//           itemCount: imgList.length,
//           viewportFraction: 0.4,
//           scale: 3,
//           layout: SwiperLayout.DEFAULT,
//         ));
//   }
// }

class _HomePageState extends State<HomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: SizedBox(
            height: 90, // card height
            child: PageView.builder(
              itemCount: 10,
              controller: PageController(viewportFraction: 0.4),
              onPageChanged: (int index) => setState(() => _index = index),
              itemBuilder: (_, i) {
                return Transform.scale(
                  scale: i == _index ? 1.2 : 0.92,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Center(
                        child: Text(
                          "Card ${i + 1}",
                          style: TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
