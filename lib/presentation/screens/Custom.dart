import 'package:flutter/material.dart';
import 'package:mukim_app/resources/Imageresources.dart';

void main() => runApp(MyApp1());

class MyApp1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double itemWidth = 60.0;
  int itemCount = 5;
  int selected = 50;
  FixedExtentScrollController _scrollController =
      FixedExtentScrollController(initialItem: 1);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: RotatedBox(
            quarterTurns: -1,
            child: ListWheelScrollView(
              // magnification: 5.0,
              // useMagnifier: true,
              onSelectedItemChanged: (x) {
                setState(() {
                  selected = x;
                });
                // print(selected);
              },
              controller: _scrollController,
              children: List.generate(
                  itemCount,
                  (x) => FittedBox(
                        fit: BoxFit.none,
                        child: RotatedBox(
                            quarterTurns: 1,
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.none,
                                child: AnimatedContainer(
                                    duration: Duration(milliseconds: 400),
                                    width: x == selected ? 125 : 115,
                                    height: x == selected ? 110 : 100,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        color: x == selected
                                            ? Colors.red
                                            : Colors.grey,
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          alignment: Alignment.center,
                                          image: AssetImage(
                                              ImageResource.sliderImg1),
                                        )),
                                    child: Text('$x')),
                              ),
                            )),
                      )),
              itemExtent: 60,
            )),
      )),
    );
  }
}
