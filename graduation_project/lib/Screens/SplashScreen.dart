import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/Screens/ExploreApp.dart';
import 'package:page_transition/page_transition.dart';

// Stateless widget for the Splash Screen
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key}); // Constructor with a unique key for widget identification

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      // AnimatedSplashScreen widget provides a splash screen with animations
      splashIconSize: 250, // Sets the size of the splash icon
      pageTransitionType: PageTransitionType.bottomToTop, 
      // Defines the transition animation from the splash screen to the next screen
      splash: CircleAvatar(
        radius: 100, // Radius of the circular splash container
        backgroundColor: Colors.white, // Background color of the circle
        backgroundImage: AssetImage(
          'images/LogoStudentHousingHub.png', 
          // Path to the splash screen logo image
        ),
      ),
      nextScreen: ExploreApp(), 
      // Specifies the next screen to navigate to after the splash screen
      splashTransition: SplashTransition.fadeTransition, 
      // Sets the transition animation for the splash screen (fade effect)
    );
  }
}