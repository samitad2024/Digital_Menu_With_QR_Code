import '../../domain/entities/menu_item.dart';

class MenuItemModel extends MenuItem {
  MenuItemModel({
    required String id,
    required String amharic,
    required String english,
    required String section,
    required String imageUrl,
  }) : super(
          id: id,
          amharic: amharic,
          english: english,
          section: section,
          imageUrl: imageUrl,
        );

  factory MenuItemModel.fromMap(Map<String, dynamic> map) {
    return MenuItemModel(
      id: map['id'] ?? '',
      amharic: map['amharic'] ?? '',
      english: map['english'] ?? '',
      section: map['section'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amharic': amharic,
      'english': english,
      'section': section,
      'imageUrl': imageUrl,
    };
  }
}
