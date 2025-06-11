import 'package:graduation_project/file/apartment_model.dart';

class WishlistService {
  static final WishlistService _instance = WishlistService._internal();

  factory WishlistService() {
    return _instance;
  }

  WishlistService._internal();

  final List<Apartment> _wishlist = [];

  List<Apartment> get wishlist => _wishlist;

  void add(Apartment apartment) {
    if (!_wishlist.any((a) => a.id == apartment.id)) {
      _wishlist.add(apartment);
    }
  }

  void remove(Apartment apartment) {
    _wishlist.removeWhere((a) => a.id == apartment.id);
  }

  bool contains(Apartment apartment) {
    return _wishlist.any((a) => a.id == apartment.id);
  }
}
