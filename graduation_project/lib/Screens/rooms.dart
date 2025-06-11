import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  List<String> rooms = [
    "Single Room",
    "Double Room",
    "Triple Room",
    "Suite",
  ];

  String? userType;

  @override
  void initState() {
    super.initState();
    _loadUserType();
  }

  Future<void> _loadUserType() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userType = prefs.getString('userType');
    });
  }

  void _onRoomTap(String room) {
    if (userType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login to access this feature.")),
      );
      return;
    }
    if (userType != 'Owner') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🚫 This feature is only available for owners.")),
      );
      return;
    }
    Navigator.pushNamed(context, 'RoomDetails', arguments: room);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF519FEE),
        title: const Text("Available Rooms", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.separated(
          itemCount: rooms.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            return ListTile(
              tileColor: Colors.grey[100],
              title: Text(
                rooms[index],
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFF519FEE)),
              onTap: () => _onRoomTap(rooms[index]),
            );
          },
        ),
      ),
    );
  }
}
