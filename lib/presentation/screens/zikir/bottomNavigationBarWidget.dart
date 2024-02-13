import 'package:flutter/material.dart';
import 'package:mukim_app/resources/Imageresources.dart';

class BottomNavigationBarWidget extends StatefulWidget {
  @override
  _BottomNavigationBarWidgetState createState() =>
      _BottomNavigationBarWidgetState();
}

class _BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      showUnselectedLabels: true,
      showSelectedLabels: true,
      onTap: (index) {
        _selectedIndex = index;
        setState(() {});
      },
      backgroundColor: Colors.transparent,
      items: [
        BottomNavigationBarItem(
            backgroundColor: Colors.black.withOpacity(0.6),
            icon: Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: Image.asset(
                ImageResource.home,
                width: 22,
                height: 22,
              ),
            ),
            label: "Utama"),
        BottomNavigationBarItem(
            backgroundColor: Colors.black.withOpacity(0.6),
            icon: Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: Image.asset(
                ImageResource.qibalt,
                width: 22,
                height: 22,
              ),
            ),
            label: "Kiblat"),
        BottomNavigationBarItem(
            backgroundColor: Colors.black.withOpacity(0.6),
            icon: Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: Image.asset(
                ImageResource.quran,
                width: 22,
                height: 22,
              ),
            ),
            label: "Quran"),
        BottomNavigationBarItem(
            backgroundColor: Colors.black.withOpacity(0.6),
            icon: Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: Image.asset(
                ImageResource.hadith,
                width: 22,
                height: 22,
              ),
            ),
            label: "Hadith"),
      ],
    );
  }
}
