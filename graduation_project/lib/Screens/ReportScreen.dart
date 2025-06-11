import 'dart:developer'; 
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Stateful widget for the Report Screen
class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key}); // Constructor with a unique key for widget identification

  @override
  _ReportScreenState createState() => _ReportScreenState(); // Creates the mutable state for ReportScreen
}

// The mutable state class for the ReportScreen widget
class _ReportScreenState extends State<ReportScreen> {
  File? _image; // Stores the selected image
  final _formKey = GlobalKey<FormState>(); // GlobalKey for managing the form's state
  String? _selectedProblem; // Stores the selected problem type
  final TextEditingController _descriptionController = TextEditingController(); // Controller for the problem description field

  // Picks an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Sets the selected image file
      });
    }
  }

  // Submits the form and validates the inputs
  void _submitForm() {
    if (_formKey.currentState!.validate() && _selectedProblem != null) {
      // Displays a success message if the form is valid
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('The report has been successfully submitted!')),
      );
    } else {
      // Displays an error message if the form is incomplete
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF519FEE)),
          onPressed: () => Navigator.pop(context), // Navigates back to the previous screen
        ),
        title: Text(
          'Report',
          style: TextStyle(color: Color(0xFF519FEE), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white, // Sets the AppBar background color to white
        elevation: 0, // Removes the shadow
      ),
      body: SingleChildScrollView(
        // Ensures the screen is scrollable if the content overflows
        child: Padding(
          padding: EdgeInsets.all(16.0), // Adds padding around the content
          child: Form(
            key: _formKey, // Binds the form to the GlobalKey
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the start of the column
              children: [
                // Image Picker Section
                GestureDetector(
                  onTap: _pickImage, // Opens the image picker when tapped
                  child: Container(
                    height: 250, // Sets the height of the image picker container
                    width: double.infinity, // Makes the container full width
                    decoration: BoxDecoration(
                      color: Color(0xFFF0F3FB), // Background color
                      borderRadius: BorderRadius.circular(20), // Rounded corners
                      border: Border.all(color: Colors.grey), // Border color
                    ),
                    child: _image == null
                        // If no image is selected, show the placeholder
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center, // Centers content vertically
                            children: [
                              Icon(Icons.add_photo_alternate_outlined, size: 60, color: Color(0xFF519FEE)), // Add photo icon
                              SizedBox(height: 8),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {}, // Button to add images (not functional here)
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF519FEE), // Button background color
                                  foregroundColor: Colors.white, // Button text color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(21), // Button rounded corners
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                ),
                                child: const Text('Add images'), // Button label
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '5MB maximum file size accepted in the following formats: .jpg .jpeg .png .gif',
                                textAlign: TextAlign.center, // Centers the text
                                style: TextStyle(fontSize: 10, color: Colors.black38), // Text style
                              ),
                            ],
                          )
                        : Image.file(_image!, fit: BoxFit.cover), // Displays the selected image
                  ),
                ),
                SizedBox(height: 45),

                // Problem Type Dropdown
                Text(
                  'Problem Type',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Label style
                ),
                DropdownButtonFormField<String>(
                  value: _selectedProblem, // Binds the dropdown to the selected problem type
                  items: ['Water Leak', 'Electricity Issue', 'Other'].map((problem) {
                    return DropdownMenuItem(value: problem, child: Text(problem)); // Dropdown items
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedProblem = value), // Updates the selected problem
                  validator: (value) => value == null ? 'Please choose a problem type' : null, // Validates the dropdown
                  decoration: InputDecoration(
                    filled: true, // Fills the background
                    fillColor: Colors.white, // Background color
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), // Rounded corners
                  ),
                ),
                SizedBox(height: 45),

                // Problem Description Input Field
                Text(
                  'Describe The Problem',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Label style
                ),
                TextFormField(
                  controller: _descriptionController, // Binds the controller to the field
                  maxLines: 4, // Allows multiline input
                  decoration: InputDecoration(
                    filled: true, // Fills the background
                    fillColor: Colors.white, // Background color
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), // Rounded corners
                  ),
                  validator: (value) => value!.isEmpty ? 'Please describe the problem' : null, // Validates the field
                ),
                SizedBox(height: 70),

                // Submit Button
                SizedBox(
                  width: double.infinity, // Makes the button full width
                  child: ElevatedButton(
                    onPressed: _submitForm, // Calls the submit form function
                    child: const Text('Submit', style: TextStyle(fontSize: 16, color: Colors.white)), // Button label
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF519FEE), // Button background color
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Button rounded corners
                      padding: EdgeInsets.symmetric(vertical: 16), // Button padding
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}