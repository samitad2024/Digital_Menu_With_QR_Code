import '../../../domain/entities/menu_item.dart';

class AdminMenuItemFormModel {
  String id;
  String amharic;
  String english;
  String section;
  String imageUrl;

  AdminMenuItemFormModel({
    this.id = '',
    this.amharic = '',
    this.english = '',
    this.section = '',
    this.imageUrl = '',
  });

  factory AdminMenuItemFormModel.fromMenuItem(MenuItem item) {
    return AdminMenuItemFormModel(
      id: item.id,
      amharic: item.amharic,
      english: item.english,
      section: item.section,
      imageUrl: item.imageUrl,
    );
  }

  MenuItem toMenuItem() {
    return MenuItem(
      id: id,
      amharic: amharic,
      english: english,
      section: section,
      imageUrl: imageUrl,
    );
  }
}
