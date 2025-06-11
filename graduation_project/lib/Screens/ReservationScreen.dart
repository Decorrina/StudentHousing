import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

// Stateful widget for the Reservation Screen
class ReservationScreen extends StatefulWidget {
  @override
  _ReservationScreenState createState() => _ReservationScreenState(); // Creates the mutable state for ReservationScreen
}

// The mutable state class for the ReservationScreen widget
class _ReservationScreenState extends State<ReservationScreen> {
  // Controllers for text fields
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _idController = TextEditingController();

  // Variables for storing selected dates
  DateTime? checkInDate;
  DateTime? checkOutDate;

  // Variable for storing the selected image
  File? _selectedImage;

  // Function to pick a date from the date picker
  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Sets the initial date to today
      firstDate: DateTime(2020), // Sets the earliest selectable date
      lastDate: DateTime(2030), // Sets the latest selectable date
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          checkInDate = picked; // Sets the check-in date
        } else {
          checkOutDate = picked; // Sets the check-out date
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Main body of the screen
      body: SingleChildScrollView(
        // Ensures the screen is scrollable if the content overflows
        padding: EdgeInsets.all(16), // Adds padding around the content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the start of the column
          children: [
            // Back button
            Container(
              padding: EdgeInsets.only(top: 30),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context); // Navigates back to the previous screen
                    },
                    icon: Icon(Icons.arrow_back),
                    color: Color(0xFF519FEE), // Icon color
                    iconSize: 45, // Icon size
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),

            // Title of the screen
            Row(
              children: [
                Text(
                  'Reservation',
                  style: TextStyle(
                    color: Color(0xFF519FEE), // Text color
                    fontWeight: FontWeight.bold, // Makes the text bold
                    fontSize: 25, // Font size for the title
                  ),
                ),
              ],
            ),
            SizedBox(height: 50),

            // First Name input field
            _buildTextField('First Name', _firstNameController),

            SizedBox(height: 50),

            // Last Name input field
            _buildTextField('Last Name', _lastNameController),

            SizedBox(height: 50),

            // Phone Number input field
            _buildTextField('Phone No.', _phoneController, isPhone: true),

            SizedBox(height: 50),

            // Room selection dropdown
            DropdownButtonFormField(
              items: [
                DropdownMenuItem(child: Text('Room 1'), value: 'Room 1'),
                DropdownMenuItem(child: Text('Room 2'), value: 'Room 2'),
              ],
              onChanged: (value) {}, // Handles room selection
              decoration: _buildInputDecoration('Room'),
            ),

            SizedBox(height: 50),

            // Check-in date picker
            _buildDatePicker('Check In Date', true),

            SizedBox(height: 50),

            // Check-out date picker
            _buildDatePicker('Check Out Date', false),

            SizedBox(height: 50),

            // National ID input field
            _buildTextField('National ID', _idController),

            SizedBox(height: 50),

            // Image upload section
            _buildImageUploadSection(),

            SizedBox(height: 50),

            // Submit button
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  // Function to build a text input field
  Widget _buildTextField(String label, TextEditingController controller, {bool isPhone = false}) {
    return TextField(
      controller: controller, // Binds the controller to the field
      decoration: _buildInputDecoration(label),
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text, // Sets keyboard type
    );
  }

  // Function to build input decoration for text fields
  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label, // Label text
      labelStyle: TextStyle(
        color: Colors.black, // Label text color
        fontSize: 17, // Label font size
        fontWeight: FontWeight.w500, // Label font weight
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15), // Rounded corners
      ),
    );
  }

  // Function to build a date picker
  Widget _buildDatePicker(String label, bool isCheckIn) {
    return GestureDetector(
      onTap: () => _selectDate(context, isCheckIn), // Opens the date picker
      child: AbsorbPointer(
        // Prevents manual input into the date field
        child: TextFormField(
          decoration: _buildInputDecoration(label).copyWith(
            suffixIcon: Icon(Icons.calendar_today, color: Color(0xFF519FEE)), // Calendar icon
          ),
          controller: TextEditingController(
            text: (isCheckIn ? checkInDate : checkOutDate) != null
                ? DateFormat('MM/dd/yyyy').format(isCheckIn ? checkInDate! : checkOutDate!)
                : '',
          ), // Formats the selected date
        ),
      ),
    );
  }

  // Function to build the image upload section
  Widget _buildImageUploadSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3FB),
        borderRadius: BorderRadius.circular(20), // Rounded corners for the container
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white, // Background color for the icon container
              borderRadius: BorderRadius.circular(30), // Circular container
            ),
            child: const Icon(
              Icons.add_photo_alternate_outlined,
              size: 30, // Icon size
              color: Color(0xFF519FEE), // Icon color
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _pickImageFromgallery, // Opens the image picker
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF519FEE), // Button background color
              foregroundColor: Colors.white, // Button text color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(21), // Button rounded corners
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Add images'), // Button text
          ),
          const SizedBox(height: 8),
          _selectedImage != null
              ? Image.file(_selectedImage!) // Displays the selected image
              : const Text('Please select an image'),
          const Text(
            '5MB maximum file size accepted in the following formats: .jpg .jpeg .png .gif',
            textAlign: TextAlign.center, // Centers the text
            style: TextStyle(fontSize: 10, color: Colors.black38), // Text style
          ),
        ],
      ),
    );
  }

  // Function to build the submit button
  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(right: 5, left: 7),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, 'SubmittedSuccessful'); // Navigates to the success screen
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, // Button text color
          backgroundColor: Color(0xFF519FEE), // Button background color
          padding: EdgeInsets.all(16), // Button padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Button rounded corners
          ),
        ),
        child: Text('Submit'), // Button text
      ),
    );
  }

  // Function to pick an image from the gallery
  Future<void> _pickImageFromgallery() async {
    final returnImage = await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnImage == null) return;
    setState(() {
      _selectedImage = File(returnImage.path); // Sets the selected image
    });
  }
}