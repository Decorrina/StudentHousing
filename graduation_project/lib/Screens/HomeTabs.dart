import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graduation_project/Screens/Ad_Details.dart';
import 'package:graduation_project/Screens/HomeScreen.dart';
import 'package:graduation_project/Screens/ProfileScreen.dart';
import 'package:graduation_project/Screens/SearchScreen.dart';
import 'package:graduation_project/Screens/WishlistScreen.dart';
import 'package:graduation_project/Screens/rooms.dart';
import 'package:graduation_project/utils/auth_guard.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _currentIndex = 0;
  Key _userKey = UniqueKey(); // 🔄 Force reload key

  final _homeScreen = Homescreen();
  final _wishlistScreen = Wishlistscreen();
  final _profileScreen = ProfileScreen();
  final _restrictedPlaceholder = Center(child: Text("Access restricted"));

  Future<Map<String, String>> _loadUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('displayName');
    final email = prefs.getString('email');

    if (name == null || email == null) {
      return {
        'displayName': 'Guest',
        'email': 'Not logged in',
      };
    }

    return {
      'displayName': name,
      'email': email,
    };
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // 🧹 Clear session

    setState(() {
      _userKey = UniqueKey(); // 🔁 Force drawer to reload new data
    });

    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, 'ExploreApp', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      _homeScreen,
      _wishlistScreen,
      _currentIndex == 2 ? AdDetailsScreen() : _restrictedPlaceholder,
      _currentIndex == 3 ? RoomsScreen() : _restrictedPlaceholder,
      _profileScreen,
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(Icons.menu, size: 30, color: Color(0xFF519FEE)),
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, 'AIModel');
            },
            icon: const Icon(Icons.smart_toy, color: Color(0xFF519FEE), size: 35),
          )
        ],
      ),

      drawer: Drawer(
        key: _userKey, // ✅ Force rebuild with new user info
        child: FutureBuilder<Map<String, String>>(
          future: _loadUserDetails(),
          builder: (context, snapshot) {
            final user = snapshot.data ??
                {
                  'displayName': 'Guest',
                  'email': 'Not logged in',
                };

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(color: Color(0xFF519FEE)),
                  accountName: Text(user['displayName']!),
                  accountEmail: Text(user['email']!),
                  currentAccountPicture: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person_outline_rounded,
                        size: 50, color: Color(0xFF519FEE)),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.contact_support),
                  title: const Text('Contact Us'),
                  onTap: () => Navigator.pushNamed(context, 'ContactUs'),
                ),
                ListTile(
                  leading: const Icon(Icons.feedback_outlined),
                  title: const Text('Report'),
                  onTap: () => Navigator.pushNamed(context, 'ReportScreen'),
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Log out'),
                  onTap: _logout,
                ),
              ],
            );
          },
        ),
      ),

      body: tabs[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF519FEE),
        selectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'AD Details',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Rooms',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) async {
          if ((index == 2 || index == 3) &&
              !(await AuthGuard.checkAccess(context: context, requireOwner: true))) {
            return;
          }

          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
