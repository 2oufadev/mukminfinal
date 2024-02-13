import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';

ThemeData lightTheme = ThemeData(
  primaryColor: Colors.blue,
  primarySwatch: Colors.blue,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    color: Colors.white,
    elevation: 0.0,
    titleSpacing: 20.0,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ),
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(
      color: Colors.black,
      size: 25.0,
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white),
  textTheme: TextTheme(
    bodyText1: TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
  ),
  fontFamily: 'Quicksand',
);

ThemeData darkTheme = ThemeData(
  primaryColor: Colors.brown,
  primarySwatch: Colors.brown,
  fontFamily: 'Inter',
  scaffoldBackgroundColor: HexColor('#3A343D'),
  appBarTheme: AppBarTheme(
    backgroundColor: HexColor('333739'),
    elevation: 0.0,
    titleSpacing: 20.0,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: HexColor('333739'),
      statusBarIconBrightness: Brightness.light,
    ),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(
      color: Colors.white,
      size: 25.0,
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: Colors.brown,
    unselectedItemColor: Colors.grey,
    type: BottomNavigationBarType.fixed,
    backgroundColor: HexColor('#181216'),
    elevation: 20.0,
  ),
  textTheme: TextTheme(
    bodyText1: TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  ),
);
