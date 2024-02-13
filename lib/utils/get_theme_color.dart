import 'package:flutter/material.dart';

Color getColor(String theme, {bool? isButton}) {
  Color color = Color.fromRGBO(162, 204, 128, 1);

  switch (theme ?? 'default') {
    case 'purple':
      color = Color(0xFF807BB2);
      break;
    case 'biru':
      color = Color(0xFF379C9E);
      break;
    case 'pink':
      color = Color(0xFFB1517C);
      break;

    case 'yellow':
      color = Color(0xFFD0B046);
      break;

    case 'orange':
      color = Color(0xFFFC957B);
      break;
    case 'default':
      if (isButton == true) {
        color = Color(0xFF807BB2);
      }
      break;
    default:
  }
  return color;
}
