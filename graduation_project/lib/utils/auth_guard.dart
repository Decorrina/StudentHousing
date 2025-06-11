import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthGuard {
  /// Returns userType from shared preferences (or null if not logged in)
  static Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userType');
  }

  /// Checks if logged in, and optionally if user is owner
  static Future<bool> checkAccess({
    required BuildContext context,
    bool requireOwner = false,
  }) async {
    final userType = await getUserType();

    if (userType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🔐 Please log in to access this feature.")),
      );
      return false;
    }

    if (requireOwner && userType != 'Owner') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🚫 This feature is only available to owners.")),
      );
      return false;
    }

    return true;
  }
}
