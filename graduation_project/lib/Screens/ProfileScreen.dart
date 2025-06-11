import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// TODO: Make sure you have routes named 'Login', 'Register', 'ContactUs',
// 'ReportScreen', 'ExploreApp', and 'ChooseAccountScreen' defined in your MaterialApp.
// For demonstration, I'm assuming 'Login' and 'Register' lead to the correct flows.
// 'ChooseAccountScreen' is used for Register as per your original code.
// You might also need an 'UpdateProfileScreen' route if you want to navigate there.

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, String>?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _loadUserInfo();
  }

  Future<Map<String, String>?> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final displayName = prefs.getString('displayName');
    final email = prefs.getString('email');
    final userType = prefs.getString('userType');

    if (displayName == null || email == null || userType == null) {
      return null;
    }

    return {
      'displayName': displayName,
      'email': email,
      'userType': userType,
    };
  }

  // Helper method to create list tiles for profile options
  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF519FEE), // Default icon color
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 30),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          // Not logged in view
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Placeholder for your logo when not logged in
                  Image.asset(
                    'images/LogoStudentHousingHub.png',
                    height: 150,
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "You are not logged in.",
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                  const Text(
                    "Please log in or register to see your profile.",
                    style: TextStyle(fontSize: 14, color: Colors.black45),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF519FEE),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(220, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, 'Login');
                    },
                    child: const Text('Login', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF519FEE),
                      minimumSize: const Size(220, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Color(0xFF519FEE)),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, 'ChooseAccountScreen');
                    },
                    child: const Text('Register', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          );
        }

        // Logged-in user view - REVISED to remove left and right icons
        return Scaffold(
          backgroundColor: Colors.grey[100], // Lighter background for the screen
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Top Bar Layout (MODIFIED: Only logo remains)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 0), // Top padding for status bar
                  child: Center( // Center the logo
                    child: Image.asset(
                      'images/LogoStudentHousingHub.png', // Your logo in the middle
                      height: 50, // Adjust height as needed
                      width: 50, // Adjust width as needed
                    ),
                  ),
                ),
                // End of Top Bar Layout

                const SizedBox(height: 20), // Spacing below top bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      // Profile Card
                      Card(
                        elevation: 6, // More prominent shadow
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18), // Slightly more rounded
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0), // Increased padding
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 45, // Larger avatar
                                    backgroundColor: const Color(0xFFE3F2FD), // Lighter blue background
                                    child: Icon(Icons.person,
                                        size: 60, color: const Color(0xFF519FEE)), // Larger, vibrant icon
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user['displayName']!,
                                          style: const TextStyle(
                                            fontSize: 26, // Larger name
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          user['email']!,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        // User type label
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE3F2FD), // Light blue background
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: const Color(0xFF519FEE)), // Subtle border
                                          ),
                                          child: Text(
                                            user['userType']!,
                                            style: const TextStyle(
                                              color: Color(0xFF519FEE),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 35, thickness: 1, color: Colors.grey), // Separator
                              _buildProfileOption(
                                icon: Icons.edit_note, // More specific icon for update
                                title: 'Update Profile',
                                onTap: () {
                                  // TODO: Navigate to Update Profile Screen
                                  // Navigator.pushNamed(context, 'UpdateProfileScreen');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Navigate to Update Profile')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 25), // Spacing between cards

                      // General Options Card
                      Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Column(
                            children: [
                              _buildProfileOption(
                                icon: Icons.contact_support,
                                title: 'Contact Us',
                                onTap: () {
                                  Navigator.pushNamed(context, "ContactUs");
                                },
                              ),
                              const Divider(indent: 20, endIndent: 20, thickness: 0.5), // Subtle divider
                              _buildProfileOption(
                                icon: Icons.feedback_outlined,
                                title: 'Report',
                                onTap: () {
                                  Navigator.pushNamed(context, 'ReportScreen');
                                },
                              ),
                              const Divider(indent: 20, endIndent: 20, thickness: 0.5),
                              _buildProfileOption(
                                icon: Icons.logout,
                                title: 'Log out',
                                iconColor: Colors.redAccent, // Make logout icon red
                                onTap: () async {
                                  final prefs = await SharedPreferences.getInstance();
                                  await prefs.clear();
                                  if (!context.mounted) return;
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, 'ExploreApp', (route) => false);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20), // Spacing at the bottom
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Assuming bottom navigation bar is handled externally by your app's structure
        );
      },
    );
  }
}