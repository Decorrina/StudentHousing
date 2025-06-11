import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// Stateless widget for the "Contact Us" screen
class ContactUs extends StatelessWidget {
  const ContactUs({super.key});  // Constructor with a unique key for widget identification


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,  // Set screen background color to white
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pop(context); 
           // Navigates back to the previous screen when back button is pressed
        }, icon: Icon(Icons.arrow_back, color: Color(0xFF519FEE),), 
         // Back arrow icon with a custom color
        ),
      ),
      body:SingleChildScrollView( 
        // Allows scrolling when the screen content overflows
        child: Padding(
          padding: const EdgeInsets.all(24.0),// Adds padding around the entire content
          child: Column( 
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
            // Spaces children evenly along the main axis
            children: [
              SizedBox(height: 15,), // Adds vertical spacing
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Contact Us',// The screen title text
                   style: TextStyle(
                    color: Color(0xFF519FEE),
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),),
                ],
              ),
                SizedBox(height: 30,), // Adds spacing below the title
                // Container for "Chat on WhatsApp" option
              Container(
                height: 250,// Height of the container
                width: double.infinity,// Full width of the screen
                decoration: BoxDecoration( 
                  color: Colors.white, 
                  boxShadow: [BoxShadow(
                   color: Colors.grey,// Shadow color
                    blurRadius: 5,// Blurring radius of the shadow
                    offset: Offset(0, 1),// Shadow position
                    spreadRadius: 1,// Spread radius of the shadow
                  )],
                  borderRadius: BorderRadius.circular(10),
                   // Rounded corners for the container
                ),
                child: Center(
                  child: Column(
                    children: [  
                      SizedBox(height: 80,),// Adds spacing above the icon
                      Icon(FontAwesomeIcons.whatsapp, 
                      // WhatsApp icon from Font Awesome
                       color: Colors.green[900], size: 50,),
                      SizedBox(height: 60,),// Adds spacing below the icon
                      Text('chat on Whatsapp',// Label for WhatsApp option
                       style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),)
                    ],
                  ),
                )
              ),
               SizedBox(height: 30,),// Adds spacing below the container 
                // Container for "Email Us" option
              Container(
                height: 250,// Height of the container
                width: double.infinity, // Full width of the screen
                decoration: BoxDecoration( 
                  color: Colors.white, 
                  boxShadow: [BoxShadow( 
                      color: Colors.grey, // Shadow color
                      blurRadius: 5, // Blurring radius of the shadow
                      offset: Offset(0, 1), // Shadow position
                      spreadRadius: 1, // Spread radius of the shadow
                  )],
                  borderRadius: BorderRadius.circular(10), 
                   // Rounded corners for the container
                ),
                child: Center(
                  child: Column(
                    children: [  
                      SizedBox(height: 80,), // Adds spacing above the icon
                      Icon(Icons.mail, color: Colors.blueAccent, size: 50,),
                      SizedBox(height: 60,), // Adds spacing above the icon
                      Text('Email Us',// Label for Email option 
                       style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),)
                    ],
                  ),
                ),
              ),
             SizedBox(height: 30,), // Adds spacing below the container

              // Container for "Call Us" option
              Container(
                height: 250,// Height of the container
                width: double.infinity, // Full width of the screen
                decoration: BoxDecoration( 
                  color: Colors.white, 
                  boxShadow: [BoxShadow(
                   color: Colors.grey, // Shadow color
                      blurRadius: 5, // Blurring radius of the shadow
                      offset: Offset(0, 1), // Shadow position
                      spreadRadius: 1, // Spread radius of the shadow
                  )],
                  borderRadius: BorderRadius.circular(10), 
                  // Rounded corners for the container
                ),
                child: Center(
                  child: Column(
                    children: [  
                      SizedBox(height: 80,),// Adds spacing above the icon
                      Icon(Icons.call, color: Colors.blueAccent, size: 50,),
                      SizedBox(height: 60,),// Adds spacing above the icon
                      Text('Call Us',// Label for Call option 
                      style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ) ,
    );
  }
}