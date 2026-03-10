import 'package:flutter/material.dart';

class Responsive {
  static bool isMobile(BuildContext context) => 
      MediaQuery.sizeOf(context).width < 650;
      
  static bool isTablet(BuildContext context) => 
      MediaQuery.sizeOf(context).width >= 650 && 
      MediaQuery.sizeOf(context).width < 1100;
      
  static bool isDesktop(BuildContext context) => 
      MediaQuery.sizeOf(context).width >= 1100;
}
