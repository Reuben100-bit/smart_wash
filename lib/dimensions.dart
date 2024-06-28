import 'package:flutter/material.dart';

class Dimensions {
  static  MediaQueryData? _mediaQueryData;
  static  double? phoneScreenWidth;
  static  double? phoneScreenHeight;
  static double? defaultSize;
  static  Orientation? orientation;

  Dimensions();

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    phoneScreenWidth = _mediaQueryData!.size.width;
    phoneScreenHeight = _mediaQueryData!.size.height;
    orientation = _mediaQueryData!.orientation;
  }

  


    //getProportionateScreenWidth
   double pSW(double inputWidth) {
    double? screenWidth = Dimensions.phoneScreenWidth;
    double designWidth = isTablet ? 600 : 375;
    return (inputWidth / designWidth) * screenWidth!;
  }

   //getProportionateScreenHeight
  double pSH(double inputHeight) {
    double? screenHeight = Dimensions.phoneScreenHeight;
    double designHeight = isTablet ? 926 : 812;
    return (inputHeight / designHeight) * screenHeight!;
  }

    bool get isTablet {
    double? width = Dimensions.phoneScreenWidth! > Dimensions.phoneScreenHeight!
        ? Dimensions.phoneScreenHeight
        : Dimensions.phoneScreenWidth;
    return (width! > 599);
  }

  static const double kStandardHeight = 811;
  static const double kStandardWidth = 408;

  double getPhoneScreenWidth(){
    return phoneScreenWidth!;
  }
  double getPhoneScreenHeight(){
    return phoneScreenHeight!;
  }
}

