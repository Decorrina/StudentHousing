import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graduation_project/Screens/ChooseUrAccount.dart';
import 'package:graduation_project/Screens/api_service.dart';
// TODO: Make sure you have a route named 'ExploreApp' and the corresponding screen imported.
// For example:
// import 'package:graduation_project/Screens/ExploreApp.dart';


class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _passwordInVisible = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoggingIn = false;

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    setState(() => _isLoggingIn = true);

    try {
      final response = await ApiService.loginUser(email, password);
      if (!mounted) return;

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        print("Login response: $userData");

        final displayName = userData['displayName'];
        final userEmail = userData['email'];
        final userType = userData['userType'];

        if (userType == null || userType is! String) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid response from server")),
          );
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('displayName', displayName ?? 'User');
        await prefs.setString('email', userEmail ?? 'email@unknown.com');
        await prefs.setString('userType', userType);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login successful")),
        );

        if (userType == 'Owner') {
          Navigator.pushNamedAndRemoveUntil(context, 'HomePage', (route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, 'StudentHome', (route) => false);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You entered a wrong email or password")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoggingIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 251, 247, 247),
      appBar: AppBar(
        // ✅ Here is the new back arrow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF519FEE)),
          onPressed: () {
            // This will navigate to your 'ExploreApp' named route
            Navigator.pushReplacementNamed(context, 'ExploreApp');
          },
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _image(),
                  _header(),
                  _inputFields(),
                  _forgotPassword(),
                  const SizedBox(height: 10),
                  _signup(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _image() => const Column(
        children: [
          Image(
            image: AssetImage('images/LogoStudentHousingHub.png'),
            height: 170,
            width: 300,
          ),
          SizedBox(height: 10),
        ],
      );

  Widget _header() => const Text(
        "Login",
        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
      );

  Widget _inputFields() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              hintText: "Enter Your Email",
              labelText: 'Email',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _passwordController,
            obscureText: _passwordInVisible,
            decoration: InputDecoration(
              hintText: "Enter Your Password",
              labelText: 'Password',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: IconButton(
                icon: Icon(_passwordInVisible
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: () {
                  setState(() => _passwordInVisible = !_passwordInVisible);
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _isLoggingIn ? null : _handleLogin,
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: _isLoggingIn ? Colors.grey : const Color(0xFF519FEE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: _isLoggingIn
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Login',
                        style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      );

  Widget _forgotPassword() => TextButton(
        onPressed: () {
          // Add forgot password logic
        },
        child: const Text("Forgot password?",
            style: TextStyle(color: Color(0xFF519FEE))),
      );

  Widget _signup() => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Don't have an account?"),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ChooseAccountScreen()),
                  );
                },
                child: const Text("Sign Up",
                    style: TextStyle(color: Color(0xFF519FEE))),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text("By creating an account or signing in you"),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("agree to our"),
              TextButton(
                onPressed: () {
                  // Add terms logic
                },
                child: const Text("Terms and Conditions",
                    style: TextStyle(color: Color(0xFF519FEE))),
              ),
            ],
          )
        ],
      );
}