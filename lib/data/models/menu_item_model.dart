import '../../domain/entities/menu_item.dart';

class MenuItemModel extends MenuItem {
  MenuItemModel({
    required String id,
    required String amharic,
    required String english,
    required double price,
    required String section,
    required String imageurl,
  }) : super(
          id: id,
          amharic: amharic,
          english: english,
          price: price,
          section: section,
          imageurl: imageurl,
        );

  factory MenuItemModel.fromMap(Map<String, dynamic> map) {
    return MenuItemModel(
      id: map['id'] ?? '',
      amharic: map['amharic'] ?? '',
      english: map['english'] ?? '',
      price: (map['price'] is num)
          ? (map['price'] as num).toDouble()
          : double.tryParse(map['price']?.toString() ?? '') ?? 0.0,
      section: map['section'] ?? '',
      imageurl: map['imageurl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amharic': amharic,
      'english': english,
      'price': price,
      'section': section,
      'imageurl': imageurl,
    };
  }
}
