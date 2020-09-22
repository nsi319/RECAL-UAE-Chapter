import 'package:flutter/material.dart';

class UIUtills {
  factory UIUtills() {
    return _singleton;
  }

  static final UIUtills _singleton = UIUtills._internal();

  UIUtills._internal() {
    print("Instance created UIUtills");
  }

//region Screen Size and Proportional according to device
  double _screenHeight;
  double _screenWidth;

  double get screenHeight => _screenHeight;

  double get screenWidth => _screenWidth;
  final double _refrenceScreenHeight = 640;
  final double _refrenceScreenWidth = 360;

  void updateScreenDimesion({double width, double height}) {
    _screenWidth = (width != null) ? width : _screenWidth;
    _screenHeight = (height != null) ? height : _screenHeight;
  }

  double getProportionalHeight({double height, int choice = 0}) {
    if (_screenHeight == null) return height;
    if (choice == 0)
      return _screenHeight * height / _refrenceScreenHeight;
    else if (choice == 1)
      return _screenHeight * height / 672.0;
    else if (choice == 3) {
      return _screenHeight * height / 690.0;
    } else
      return 0;
  }

  double getProportionalWidth({double width, int choice = 0}) {
    if (_screenWidth == null) return width;
    var w;
    if (choice == 0)
      w = _screenWidth * width / _refrenceScreenWidth;
    else if (choice == 1)
      w = _screenWidth * width / 360.0;
    else if (choice == 3)
      w = _screenWidth * width / 360.0;
    else
      w = 0;
    return w.ceilToDouble();
  }
}
