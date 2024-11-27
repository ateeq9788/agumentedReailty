import 'package:flutter/material.dart';

Widget buildDot(int index, int currentPage) {
  return AnimatedContainer(
    duration: Duration(milliseconds: 300),
    margin: EdgeInsets.symmetric(horizontal: 4.0),
    height: currentPage == index ? 12.0 : 8.0,
    width: currentPage == index ? 12.0 : 8.0,
    decoration: BoxDecoration(
      color: currentPage == index ? Colors.blue : Colors.white,
      shape: BoxShape.circle,
    ),
  );
}
