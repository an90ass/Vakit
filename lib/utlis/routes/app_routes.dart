import 'package:flutter/material.dart';

import '../../screens/home_screen.dart';

class AppRoutes {
  static Route onGenerateRoute(RouteSettings settings) {

   switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (context) => const HomeScreen());
  
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  
    
  }
}
