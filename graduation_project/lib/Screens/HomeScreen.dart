import 'package:flutter/material.dart';
import 'package:graduation_project/file/apartment_model.dart';
import 'package:graduation_project/Screens/api_service.dart';
import 'package:graduation_project/file/wishlist_service.dart';
import 'package:share_plus/share_plus.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  late Future<List<Apartment>> futureApartments;
  Map<String, dynamic>? currentFilters;

  @override
  void initState() {
    super.initState();
    futureApartments = ApiService.fetchApartments();
  }

  void _applyFilters(Map<String, dynamic> filters) {
    setState(() {
      currentFilters = filters;
      futureApartments = ApiService.fetchApartments(filters: filters);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Search Bar
            GestureDetector(
              onTap: () async {
                final filters = await Navigator.pushNamed(context, 'SearchScreen');
                if (filters != null && filters is Map<String, dynamic>) {
                  _applyFilters(filters);
                }
              },
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF519FEE)),
                    suffixIcon: IconButton(
                      onPressed: () async {
                        final filters = await Navigator.pushNamed(context, 'SearchScreen');
                        if (filters != null && filters is Map<String, dynamic>) {
                          _applyFilters(filters);
                        }
                      },
                      icon: const Icon(Icons.filter_alt_outlined, color: Color(0xFF519FEE)),
                    ),
                    hintText: 'Search',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(35),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Filter Indicator
            if (currentFilters != null)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.filter_list, color: Color(0xFF519FEE), size: 16),
                    const SizedBox(width: 8),
                    const Text('Filters applied', style: TextStyle(color: Color(0xFF519FEE))),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          currentFilters = null;
                          futureApartments = ApiService.fetchApartments();
                        });
                      },
                      child: const Icon(Icons.close, color: Colors.grey, size: 18),
                    ),
                  ],
                ),
              ),

            // Apartment List
            Expanded(
              child: FutureBuilder<List<Apartment>>(
                future: futureApartments,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No apartments found.'));
                  }

                  final apartments = snapshot.data!;

                  return ListView.builder(
                    itemCount: apartments.length,
                    itemBuilder: (context, index) {
                      final apartment = apartments[index];
                      final isFemale = apartment.gender.toLowerCase() == 'female';

                      return GestureDetector(
                        onTap: () => Navigator.pushNamed(context, 'VeiwApart', arguments: apartment.id),
                        child: Container(
                          width: double.infinity,
                          height: 470,
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 3,
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Image.network(
                                      apartment.images.isNotEmpty
                                          ? apartment.images.first
                                          : 'https://via.placeholder.com/400x200?text=No+Image',
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          height: 200,
                                          color: Colors.grey[200],
                                          child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                        );
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    top: 8.0,
                                    right: 8.0,
                                    child: IconButton(
                                      icon: Icon(
                                        WishlistService().contains(apartment)
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: WishlistService().contains(apartment)
                                            ? Colors.red
                                            : Colors.white,
                                        size: 27,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          if (WishlistService().contains(apartment)) {
                                            WishlistService().remove(apartment);
                                          } else {
                                            WishlistService().add(apartment);
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    top: 54,
                                    right: 8.0,
                                    child: CircleAvatar(
                                      backgroundColor: const Color(0xFF519FEE),
                                      child: IconButton(
                                        onPressed: () {
                                          Share.share(
                                            'Check out this apartment: ${apartment.title}\n${apartment.address}',
                                          );
                                        },
                                        icon: const Icon(Icons.share, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                apartment.universityName,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  color: Color(0xFF519FEE),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    isFemale ? Icons.female : Icons.male,
                                    color: const Color(0xFF519FEE),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isFemale ? 'Female Apartment' : 'Male Apartment',
                                    style: const TextStyle(
                                      color: Color(0xFF519FEE),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                apartment.title,
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${apartment.price.toStringAsFixed(2)} L.E / Monthly',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${apartment.numberOfRooms} Rooms - ${apartment.space} Sqft',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 12.0),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, color: Color(0xFF519FEE)),
                                  const SizedBox(width: 6.0),
                                  Expanded(
                                    child: Text(
                                      apartment.address,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
