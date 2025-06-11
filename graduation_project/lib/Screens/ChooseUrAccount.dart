import 'package:flutter/material.dart';

class ChooseAccountScreen extends StatefulWidget {
  const ChooseAccountScreen({super.key});

  @override
  _ChooseAccountScreenState createState() => _ChooseAccountScreenState();
}

class _ChooseAccountScreenState extends State<ChooseAccountScreen> {
  String _selectedAccount = 'Student'; // Default

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text("Choose your Account", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF519FEE))),
            const SizedBox(height: 10),
            const Text("To complete the sign-up process, please make the choice", style: TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 30),

            RadioListTile(
              title: const Text("Student", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              value: "Student",
              groupValue: _selectedAccount,
              onChanged: (value) => setState(() => _selectedAccount = value.toString()),
              activeColor: const Color(0xFF519FEE),
            ),
            RadioListTile(
              title: const Text("Owner", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              value: "Owner",
              groupValue: _selectedAccount,
              onChanged: (value) => setState(() => _selectedAccount = value.toString()),
              activeColor: const Color(0xFF519FEE),
            ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    'Register',
                    arguments: {'userType': _selectedAccount},
                  );
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF519FEE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text('Next', style: TextStyle(color: Colors.white, fontSize: 17)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
