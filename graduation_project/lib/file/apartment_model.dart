class Apartment {
  final int id;
  final String title;
  final String address;
  final List<String> images;
  final int numberOfRooms;
  final double space;
  final double price;
  final String universityName;
  final String gender;
  final int floor;

  Apartment({
    required this.id,
    required this.title,
    required this.address,
    required this.images,
    required this.numberOfRooms,
    required this.space,
    required this.price,
    required this.universityName,
    required this.gender,
    required this.floor,
  });

  factory Apartment.fromJson(Map<String, dynamic> json) {
    final images = (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [];

    return Apartment(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      address: json['address'] ?? '',
      images: images,
      numberOfRooms: (json['availableRooms'] as List?)?.length ?? 0,
      space: (json['space'] as num?)?.toDouble() ?? 0.0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      universityName: json['universityName'] ?? '',
      gender: json['gender'] ?? 'Any',
      floor: json['floor'] ?? 0,
    );
  }
}
