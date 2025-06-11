import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http; // Import http package
import 'dart:convert'; // For json encoding (though mostly multipart in this case)

class Room {
  final int beds;
  final double price;
  const Room({this.beds = 1, this.price = 450.0});
}
// Main widget for Ad Details Screen
class AdDetailsScreen extends StatefulWidget {
  const AdDetailsScreen({super.key});

  @override
  State<AdDetailsScreen> createState() => _AdDetailsScreenState();
}
// State class for AdDetailsScreen
class _AdDetailsScreenState extends State<AdDetailsScreen> { 
  // List to store Room objects
  List<Room> rooms = const [Room(), Room()]; 
   // Set to store selected amenities
  Set<String> selectedAmenities = {}; 
    // Controllers to manage input fields
  final titleController = TextEditingController();
  final areaController = TextEditingController(); // Maps to UniversityName in backend
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController(); // Maps to PriceMonthly in backend
  final mapLocationController = TextEditingController(); // Not directly mapped to backend yet
   // Variables for floor and resident type
  int floor = 1; // Default floor is 1
  String selectedResidentType = 'Male'; // Default resident type 
   // Variable for storing selected image
  File? _selectedImage; // Currently handles only one image

  // State variables for UI feedback during API call
  bool _isLoading = false;
  String? _errorMessage;

  // List of amenities to choose from - IMPORTANT: These strings must match C# enum names (case-insensitive for parsing)
  static const List<String> amenitiesList = [
    'WiFi',
    'Parking',
    'Air Conditioning',
    'Kitchen',
    'TV',
    'Washing Machine',
  ];
   // List of resident types
  static const List<String> residentTypes = [
    'Male',
    'Female',
  ];

   // Method to add a new room
  void addRoom() {
    setState(() {
      rooms = [...rooms, const Room()];
    });
  }
  // Method to remove a room by index
  void removeRoom(int index) {
    if (rooms.length > 1) { // Ensure at least one room remains
      setState(() {
        List<Room> newRooms = List.from(rooms);
        newRooms.removeAt(index);
        rooms = newRooms;
      });
    }
  }
   // Method to update the number of beds in a room
  void updateBeds(int index, bool increment) {
    setState(() {
      final List<Room> newRooms = List.from(rooms);
      final currentBeds = rooms[index].beds; 
       // Increment or decrement the number of beds, minimum 1 bed
      newRooms[index] = Room(
        beds: increment ? currentBeds + 1 : (currentBeds > 1 ? currentBeds - 1 : 1),
        price: rooms[index].price,
      );
      rooms = newRooms;
    });
  }
  // Method to update the price of a room
  void updatePrice(int index, String value) {
    setState(() {
      final List<Room> newRooms = List.from(rooms); 
      // Parse the price value and update the room
      newRooms[index] = Room(
        beds: rooms[index].beds,
        price: double.tryParse(value) ?? rooms[index].price, // Fallback to current price if parse fails
      );
      rooms = newRooms;
    });
  }
   // Method to update the floor number
  void updateFloor(bool increment) {
    setState(() {
      if (increment) {
        floor++; // Increment floor
      } else if (floor > 1) { // Allow floor 0, or adjust to floor > 1 if minimum floor is 1
        floor--; // Decrement floor only if greater than 0
      }
    });
  }

  // Method to pick an image from the gallery
  Future<void> _pickImageFromGallery() async {
   final returnedImage = await ImagePicker().pickImage(source: ImageSource.gallery); 
   if (returnedImage == null) return; // User cancelled picking
   setState(() {
     _selectedImage = File(returnedImage.path); // Convert picked XFile to File
   });
  }

  // New method to submit the ad data to the backend
  Future<void> _submitAd() async {
    // Set loading state and clear previous errors
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Replace with your actual backend base URL
    // For Android emulator, use 10.0.2.2. For iOS simulator/web, use localhost or 127.0.0.1.
    // For a physical device, use your machine's IP address.
    const String baseUrl = 'http://10.0.2.2:5175/api/Apartments/AddApartment'; // Adjust URL to use port 5175

    try {
      // Create a MultipartRequest for sending form data and files
      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));

      // Add image file if selected
      if (_selectedImage != null) {
        // 'ImageFiles' must match the property name in your C# AddApartmentDto (List<IFormFile> ImageFiles)
        request.files.add(await http.MultipartFile.fromPath(
          'ImageFiles',
          _selectedImage!.path,
          // You might want to specify contentType if not automatically detected
          // contentType: MediaType('image', 'jpeg'),
        ));
      }

      // Add other text fields as form fields.
      // The keys here must match the property names in your C# AddApartmentDto.
      request.fields['UniversityName'] = areaController.text;
      request.fields['Title'] = titleController.text;
      request.fields['Address'] = addressController.text;
      request.fields['Gender'] = selectedResidentType;
      request.fields['Floor'] = floor.toString();
      request.fields['Description'] = descriptionController.text;
      request.fields['PriceMonthly'] = priceController.text;
      // IMPORTANT: Replace '1' with the actual authenticated OwnerId.
      // This would typically come from a user session or authentication service.
      request.fields['OwnerId'] = '1'; // Placeholder OwnerId, replace with actual user ID

      // Add rooms data
      // Use indexed names to bind to a list of objects in C#
      for (int i = 0; i < rooms.length; i++) {
        request.fields['AvailableRooms[$i].Beds'] = rooms[i].beds.toString();
        request.fields['AvailableRooms[$i].Price'] = rooms[i].price.toString();
      }

      // Add amenities data
      // Use indexed names to bind to a list of strings in C#
      int amenityIndex = 0;
      for (var amenity in selectedAmenities) {
        request.fields['SelectedAmenities[$amenityIndex]'] = amenity;
        amenityIndex++;
      }

      // Send the request
      var response = await request.send();
      // Read the response body
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        // Ad submitted successfully
        print('Ad submitted successfully: $responseBody');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ad submitted successfully!')),
        );
        // Navigate to success screen or clear form
        Navigator.pushNamed(context, 'SubmittedSuccessful'); 
      } else {
        // Backend returned an error status code
        print('Failed to submit ad: ${response.statusCode} - $responseBody');
        setState(() {
          // Display error message from backend if available
          _errorMessage = 'Failed to submit ad: ${response.statusCode}\n${responseBody}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit ad: ${response.statusCode}')),
        );
      }
    } catch (e) {
      // Catch any network errors or other exceptions
      print('Error submitting ad: $e');
      setState(() {
        _errorMessage = 'Error submitting ad: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting ad: $e')),
      );
    } finally {
      // Always stop loading, regardless of success or failure
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Removed AppBar as it was not part of the original UI provided
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24), // Spacer

                // Image Upload Section
                Container(
                  width: double.infinity, // Takes full available width
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F3FB),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [ 
                       // Placeholder for image icon
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 30,
                          color: Color(0xFF519FEE),
                        ),
                      ),
                      const SizedBox(height: 16), 
                       // Button to pick an image
                      ElevatedButton(
                        onPressed: _pickImageFromGallery, // Call image picker
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF519FEE),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(21),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Add images'),
                      ),
                      const SizedBox(height: 8),
                      // Display the selected image or prompt to select 
                      _selectedImage != null 
                          ? Image.file(_selectedImage!, height: 200, fit: BoxFit.cover,) // Display selected image
                          : const Text(
                              'Please Selected an image',
                              style: TextStyle(color: Colors.grey),
                            ),
                      const SizedBox(height: 8),
                      const Text(
                        '5MB maximum file size accepted in the following formats: .jpg .jpeg .png .gif',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Ad title input field
                _buildTextField(
                  label: 'Ad title',
                  controller: titleController,
                ),

                const SizedBox(height: 16),

                // Area input field
                _buildTextField(
                  label: 'Area', // Corresponds to UniversityName in backend
                  controller: areaController,
                ),
                const SizedBox(height: 16),

                // Resident Type
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gender',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity, // Takes full available width
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButton<String>(
                        value: selectedResidentType,
                        isExpanded: true, // Allows dropdown to take full width
                        underline: const SizedBox(),
                        items: residentTypes.map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedResidentType = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Floor
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Floor',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      // No fixed width, lets it adapt
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () => updateFloor(false),
                          ),
                          Text(
                            floor.toString(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => updateFloor(true),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Divider(height: 1, thickness: 2),
                const SizedBox(height: 24),

                // Rooms Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rooms (${rooms.length})',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF519FEE),
                      ),
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: addRoom,
                          icon: const Icon(Icons.add),
                          label: const Text('Add'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF519FEE),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(34),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Room Cards
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                        side: const BorderSide(color: Color(0xFFC4C4C4)),
                      ),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                // Beds Counter
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Bed',
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove),
                                          onPressed: () => updateBeds(index, false),
                                        ),
                                        Text(
                                          '${rooms[index].beds}',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: () => updateBeds(index, true),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Price Input for Room
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Price',
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.end,
                                        decoration: const InputDecoration(
                                          suffix: Text('L.E'),
                                          border: OutlineInputBorder(),
                                        ),
                                        controller: TextEditingController(
                                          text: rooms[index].price.toStringAsFixed(2),
                                        ),
                                        onChanged: (value) => updatePrice(index, value),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (rooms.length > 1)
                            Positioned(
                              top: 2,
                              right: 2,
                              child: IconButton(
                                icon: const Icon(Icons.close,
                                    color: Colors.red, size: 20),
                                onPressed: () => removeRoom(index),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),

                const Divider(height: 32, thickness: 2),

                // Amenities Section
                const Text(
                  'Amenities',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: amenitiesList.map((amenity) {
                    final isSelected = selectedAmenities.contains(amenity);
                    return FilterChip(
                      label: Text(amenity),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedAmenities.add(amenity);
                          } else {
                            selectedAmenities.remove(amenity);
                          }
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor:
                      const Color(0xFF519FEE).withAlpha(51),
                      checkmarkColor: const Color(0xFF519FEE),
                      side: BorderSide(
                        color:
                        isSelected ? const Color(0xFF519FEE) : Colors.grey,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Address
                _buildTextField(
                  label: 'Address',
                  controller: addressController,
                ),

                const SizedBox(height: 16),

                // Google Map Location
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: mapLocationController,
                        decoration: InputDecoration(
                          hintText: 'Enter location',
                          prefixIcon: const Icon(Icons.location_on,
                              color: Color(0xFF519FEE)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Description
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        border: OutlineInputBorder( 
                          
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ), 
                        labelText: 'Description'
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Price',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(9),
                              ),
                            ),
                            child: const Text(
                              'EGP',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: priceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                border: InputBorder.none,
                                hintText: 'Enter price',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Display error message if any
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    // Disable button and show loading indicator while submitting
                    onPressed: _isLoading ? null : _submitAd, // Call _submitAd
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF519FEE),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white) // Show loading indicator
                        : const Text(
                            'Submit',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
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
  // Helper method for building text fields
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }
}
