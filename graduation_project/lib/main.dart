import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/AI%20Model/chat_screen.dart';
import 'package:graduation_project/Screens/Ad_Details.dart';
import 'package:graduation_project/Screens/Contact_Us.dart';
import 'package:graduation_project/Screens/ExploreApp.dart';
import 'package:graduation_project/Screens/HomeTabs.dart';
import 'package:graduation_project/Screens/Login.dart';
import 'package:graduation_project/Screens/ReportScreen.dart';
import 'package:graduation_project/Screens/ReservationScreen.dart';
import 'package:graduation_project/Screens/SearchScreen.dart';
import 'package:graduation_project/Screens/SplashScreen.dart';
import 'package:graduation_project/Screens/Register.dart';
import 'package:graduation_project/Screens/SubmittedSuccessful.dart';
import 'package:graduation_project/Screens/WishlistScreen.dart';
import 'package:graduation_project/Screens/ProfileScreen.dart';
import 'package:graduation_project/Screens/view_apart.dart';
import 'package:graduation_project/Screens/ChooseUrAccount.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  runApp(const StudentHousingHub());
}

class StudentHousingHub extends StatelessWidget {
  const StudentHousingHub({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // ✅ Route table including StudentHome
      routes: { 
        'Login': (context) => Login(),
        'Register': (context) => Register(),
        'HomePage': (context) => Homepage(), 
        'StudentHome': (context) => Homepage(), 
        'ExploreApp': (context) => ExploreApp(),
        'ChooseAccountScreen': (context) => ChooseAccountScreen(),
        'SubmittedSuccessful': (context) => Submittedsuccessful(),
        'Wishlistscreen': (context) => Wishlistscreen(), 
        'Ad_Details': (context) => AdDetailsScreen(),
        'VeiwApart': (context) => ViewApart(),
        'ProfileScreen': (context) => ProfileScreen(),
        'SearchScreen': (context) => SearchScreen(),
        'ReportScreen': (context) => ReportScreen(), 
        'ReservationScreen': (context) => ReservationScreen(),
        'ContactUs': (context) => ContactUs(),
        'AIModel': (context) => ChatScreen(),
      },

      home: SplashScreen(),
    ); 
  }
}
