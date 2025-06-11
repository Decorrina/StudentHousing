import 'package:flutter/material.dart';
import 'package:graduation_project/file/wishlist_service.dart';

class Wishlistscreen extends StatelessWidget {
  const Wishlistscreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlist = WishlistService().wishlist;

    return Scaffold(
      backgroundColor: Colors.white,
      body: wishlist.isEmpty
        ? const Center(child: Text("Your wishlist is empty."))
        : ListView.builder(
            itemCount: wishlist.length,
            itemBuilder: (context, index) {
              final apartment = wishlist[index];
              return; // same card UI as before, using apartment.*;
            },
          ),
    );
  }
}
