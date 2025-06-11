import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:http/http.dart' as http;
import 'package:graduation_project/Screens/api_service.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();

  File? _selectedImage;
  bool _passwordInVisible = true;
  bool _password = true;
  String? _selectedGender;
  String? _userType;
  String? _phoneNumber;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime? _pickedDate;

  bool _isSubmitting = false;
  final List<String> _genders = ['Male', 'Female'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['userType'] != null) {
      _userType = args['userType'];
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _pickedDate = picked;
        _dateController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_userType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing user type')),
      );
      return;
    }

    if (_pickedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your date of birth')),
      );
      return;
    }

    if (_nationalIdController.text.trim().length != 14) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('National ID must be exactly 14 digits')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final base64Image = _selectedImage != null
        ? base64Encode(await _selectedImage!.readAsBytes())
        : "";

    final body = {
      "firstName": _firstNameController.text.trim(),
      "lastName": _lastNameController.text.trim(),
      "email": _emailController.text.trim(),
      "password": _passwordController.text.trim(),
      "phoneNo": _phoneNumber ?? '',
      "dateOfBirth": _pickedDate!.toIso8601String(),
      "gender": _selectedGender ?? "Male",
      "nationalId": _nationalIdController.text.trim(),
      "image": base64Image,
      "userType": _userType, // ✅ critical
    };

    log("Sending registration: ${jsonEncode(body)}");

    try {
      final response = await ApiService.registerUser(body);

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Registered Successfully")),
        );
        Navigator.pushNamed(context, 'SubmittedSuccessful');
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ ${error['message'] ?? 'Registration failed'}")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Network error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF519FEE)),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Icon(Icons.account_circle, size: 85, color: Color(0xFF519FEE)),
                      const SizedBox(height: 15),
                      _buildTextField(_firstNameController, 'First Name', TextInputType.name),
                      const SizedBox(height: 15),
                      _buildTextField(_lastNameController, 'Last Name', TextInputType.name),
                      const SizedBox(height: 15),
                      _buildTextField(_emailController, 'Email', TextInputType.emailAddress),
                      const SizedBox(height: 15),
                      _buildPasswordField('Password', _passwordInVisible, _passwordController, () {
                        setState(() => _passwordInVisible = !_passwordInVisible);
                      }),
                      const SizedBox(height: 15),
                      _buildPasswordField('Confirm Password', _password, _confirmPasswordController, () {
                        setState(() => _password = !_password);
                      }),
                      const SizedBox(height: 15),
                      IntlPhoneField(
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                        ),
                        initialCountryCode: 'EG',
                        onChanged: (phone) => _phoneNumber = phone.completeNumber,
                      ),
                      const SizedBox(height: 15),
                      _buildDateField(),
                      const SizedBox(height: 15),
                      _buildGenderDropdown(),
                      const SizedBox(height: 15),
                      _buildTextField(_nationalIdController, 'National ID', TextInputType.number),
                      const SizedBox(height: 15),
                      _buildImageUploadSection(),
                      const SizedBox(height: 25),
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF519FEE),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        ),
                        child: const Text('Submit', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, TextInputType inputType) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        hintText: hint,
        border: const OutlineInputBorder(),
        filled: true,
      ),
      validator: (value) => value == null || value.isEmpty ? '$hint is required' : null,
    );
  }

  Widget _buildPasswordField(String hintText, bool obscure, TextEditingController controller, VoidCallback toggle) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(),
        filled: true,
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: toggle,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        if (hintText == 'Confirm Password' && value != _passwordController.text) {
          return 'Passwords do not match';
        }
        if (value.length < 6) return 'Min 6 characters';
        return null;
      },
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _dateController,
      readOnly: true,
      onTap: _selectDate,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'mm/dd/yyyy',
        suffixIcon: Icon(Icons.calendar_today, color: Color(0xFF519FEE)),
        filled: true,
      ),
      validator: (value) => value == null || value.isEmpty ? 'Select date' : null,
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      hint: const Text('Gender'),
      decoration: const InputDecoration(border: OutlineInputBorder()),
      isExpanded: true,
      items: _genders.map((gender) => DropdownMenuItem<String>(
        value: gender,
        child: Text(gender),
      )).toList(),
      onChanged: (value) => setState(() => _selectedGender = value),
      validator: (value) => value == null ? 'Select gender' : null,
    );
  }

  Widget _buildImageUploadSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3FB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.add_photo_alternate_outlined, size: 40, color: Color(0xFF519FEE)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _pickImageFromCamera,
            child: const Text("Upload Image"),
          ),
          if (_selectedImage != null) ...[
            const SizedBox(height: 10),
            Image.file(_selectedImage!, height: 100),
          ]
        ],
      ),
    );
  }
}
