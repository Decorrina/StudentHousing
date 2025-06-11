import 'package:flutter/material.dart';
import 'package:graduation_project/Screens/Register.dart';
import 'package:graduation_project/Screens/HomeTabs.dart';
// Stateless widget representing the Explore App screen
class ExploreApp extends StatelessWidget {
  const ExploreApp({super.key});  // Constructor with a unique key for widget identification

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),// Adds padding around the entire card

          child: Card(
            color: const Color.fromARGB(255, 251, 247, 247),
            // Sets the card background color
            child: Container(

              margin: const EdgeInsets.all(24),// Adds margin inside the card
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                // Spaces children evenly along the main axis
                children: [
                  _image(context), // Displays the app logo/image
                  _text(context), // Displays the app title and description
                  _Button(context), // Displays the buttons for navigation
                ],
              ),
            ),
          ),
        )
    );
  }
}
// Helper function to display the app logo or image
 _image(context) {
    return const Column(
      children: [ 
       Image(image: AssetImage('images/LogoStudentHousingHub.png'), 
       // Loads the logo image from the assets folder
       height: 230, // Sets the height of the image
       width: 500, // Sets the width of the image
       ),
        
      ],
    );
  } 
  // Helper function to display the app title and description
   _text(context) {
    return const Column(
      children: [ 
       Text('StudentHousing  Hub', // App title
       style: TextStyle( 
        color: Colors.black, // Sets the title color
        fontWeight: FontWeight.bold, // Makes the title bold
        fontSize: 30, // Sets the title font size
       ),), 

       SizedBox(height: 10,), // Adds vertical spacing

       Text('Now your Room are in one place',  // First line of the description
       style: TextStyle( 
       color: Colors.grey, // Sets the description text color
       fontSize: 17, // Sets the description font size
       ),), 
        
        Text('and always under control',  // Second line of the description
       style: TextStyle( 
       color: Colors.grey, // Sets the description text color
       fontSize: 17, // Sets the description font size
       ),), 
      ],
    );
  } 
 // Helper function to display the navigation buttons
  _Button (context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
       // Stretches the buttons to fill the available horizontal space
      children: [
      
        GestureDetector(
           // Button to navigate to the "HomePage" screen
          onTap: () {
            Navigator.pushNamed(context, 'HomePage');
            // Navigates to the HomePage screen
          },
          child: Container( 
            width: double.infinity, // Makes the button full width
            height: 50, // Sets the button height
            decoration: BoxDecoration( 
            color: Color(0xFF519FEE), // Sets the button background color
            borderRadius: BorderRadius.all(Radius.circular(10)), 
            // Adds rounded corners to the button
              
            ),
            child: Center(child: Text('Explore App', style: TextStyle(color: Colors.white, fontSize: 17),)),
          ),
        ), 


       SizedBox( height: 10,),  // Adds spacing below the button
       GestureDetector(
        // Button to navigate to the "Login" screen
          onTap: () {
            Navigator.pushNamed(context, 'Login');
             // Navigates to the Login screen
          },
          child: Container( 
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration( 
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Center(child: Text('Login', style: TextStyle(color: Color(0xFF519FEE), fontSize: 17),)),
          ),
        ), 
 


        SizedBox( height: 10,), 
       GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, 'ChooseAccountScreen');
          },
          child: Container( 
            width: double.infinity, // Makes the button full width
            height: 50, // Sets the button height
            decoration: BoxDecoration( 
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Center(child: Text('Register', style: TextStyle(color: Color(0xFF519FEE), fontSize: 17),)),
          ),
        ), 
      ],
    );
  }