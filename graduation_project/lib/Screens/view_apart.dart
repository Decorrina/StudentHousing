import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:share_plus/share_plus.dart';

class ViewApart extends StatefulWidget {
  const ViewApart({Key? key}) : super(key: key);

  @override
  State<ViewApart> createState() => _ViewApartState();
}

class _ViewApartState extends State<ViewApart> with SingleTickerProviderStateMixin {
  final _pageController = PageController();
  bool isLoading = true;
  Map<String, dynamic>? apartment;
  int? apartmentId;
  bool isLiked = false;

  late AnimationController _fadeController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int) {
      apartmentId = args;
      fetchApartment();
    } else {
      setState(() => isLoading = false);
    }

    if (_fadeAnimation == null) {
      _fadeAnimation = CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeIn,
      );
    }
  }

  Future<void> fetchApartment() async {
    try {
      final url = Uri.parse('http://10.0.2.2:5175/api/apartments/$apartmentId');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          apartment = json.decode(response.body);
          isLoading = false;
        });
        _fadeController.forward();
      } else {
        setState(() => isLoading = false);
      }
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  Map<String, bool> parseAmenities(dynamic value) {
    if (value is! int) return {};
    return {
      'wifi': (value & 1) != 0,
      'kitchen': (value & 2) != 0,
      'ac': (value & 4) != 0,
      'tv': (value & 8) != 0,
      'laundry': (value & 16) != 0,
    };
  }

  Widget buildAmenityRow(String label, IconData icon) {
    final raw = apartment?['amenities'];
    final amenities = parseAmenities(raw);
    if (amenities[label.toLowerCase()] == true) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          children: [
            Icon(icon, size: 35, color: Color(0xFF519FEE)),
            const SizedBox(width: 20),
            Text(label, style: GoogleFonts.sen(fontSize: 20)),
          ],
        ),
      );
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (apartment == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.error_outline, size: 80, color: Colors.redAccent),
              SizedBox(height: 20),
              Text("No apartment data available.", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent)),
            ],
          ),
        ),
      );
    }

    final images = List<String>.from(apartment!['images'] ?? []);
    final rooms = List<Map<String, dynamic>>.from(apartment!['availableRooms'] ?? []);
    final ownerName = apartment!['ownerName'] ?? 'Unknown';
    final address = apartment!['address'] ?? '';
    final title = apartment!['title'] ?? '';

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 400,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        final imageUrl = images[index].replaceFirst('localhost', '10.0.2.2');
                        return Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: MediaQuery.of(context).size.width,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              alignment: Alignment.center,
                              child: const Icon(Icons.broken_image, color: Colors.grey, size: 60),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 40,
                    left: 20,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF519FEE)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: 20,
                    child: CircleAvatar(
                      backgroundColor: const Color(0xFF519FEE),
                      child: IconButton(
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() => isLiked = !isLiked);
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 100,
                    right: 20,
                    child: CircleAvatar(
                      backgroundColor: const Color(0xFF519FEE),
                      child: IconButton(
                        icon: const Icon(Icons.share, color: Colors.white),
                        onPressed: () {
                          Share.share(
                            'Check this apartment: "$title"\n$address',
                            subject: 'Student Apartment',
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 15,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: images.length,
                        effect: const WormEffect(
                          dotHeight: 10,
                          dotWidth: 10,
                          spacing: 16,
                          dotColor: Colors.white54,
                          activeDotColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.sen(fontSize: 25)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFF519FEE)),
                        const SizedBox(width: 10),
                        Expanded(child: Text(address, style: GoogleFonts.sen(fontSize: 16))),
                      ],
                    ),
                    const Divider(height: 40),
                    Text("Gender: ${apartment!['gender']}", style: GoogleFonts.sen(fontSize: 18)),
                    const SizedBox(height: 10),
                    Text("Space: ${apartment!['space']} Sqft", style: GoogleFonts.sen(fontSize: 18)),
                    const Divider(height: 40),

                    Text('Available Rooms:', style: GoogleFonts.sen(fontSize: 20)),
                    const SizedBox(height: 10),
                    ...rooms.map((room) {
                      final bedCount = (room['beds'] as List?)?.length ?? 0;
                      final roomId = room['roomNumber'] ?? 'Room';
                      final price = room['pricePerBed'];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF519FEE),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(roomId, style: const TextStyle(color: Colors.white)),
                              Row(
                                children: [
                                  const Icon(Icons.bed, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text("$bedCount Beds", style: const TextStyle(color: Colors.white)),
                                ],
                              ),
                              Text(
                                "${price?.toStringAsFixed(0) ?? '-'} L.E",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),

                    const Divider(height: 40),
                    Text('Amenities:', style: GoogleFonts.sen(fontSize: 20)),
                    const SizedBox(height: 10),
                    buildAmenityRow("Wifi", Icons.wifi),
                    buildAmenityRow("Kitchen", Icons.kitchen),
                    buildAmenityRow("Ac", Icons.ac_unit),
                    buildAmenityRow("Tv", Icons.tv),
                    buildAmenityRow("Laundry", Icons.local_laundry_service),

                    const Divider(height: 40),
                    Text('Description:', style: GoogleFonts.sen(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text(apartment!['description'], style: GoogleFonts.sen(fontSize: 15)),

                    const Divider(height: 40),
                    Text('Owned by:', style: GoogleFonts.sen(fontSize: 18)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundImage: AssetImage('images/OIP.jfif'),
                        ),
                        const SizedBox(width: 10),
                        Text(ownerName, style: GoogleFonts.sen(fontSize: 18)),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.feedback_outlined, color: Color(0xFF519FEE)),
                          onPressed: () => Navigator.pushNamed(context, 'ReportScreen'),
                        )
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                height: 105,
                width: double.infinity,
                color: const Color(0xFF519FEE),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${apartment!['price']} L.E Monthly', style: const TextStyle(color: Colors.white, fontSize: 20)),
                    const SizedBox(height: 5),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, 'ReservationScreen'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF519FEE),
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(21),
                        ),
                      ),
                      child: const Text('Reservation'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
