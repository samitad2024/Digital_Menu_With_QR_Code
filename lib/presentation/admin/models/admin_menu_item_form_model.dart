import '../../../domain/entities/menu_item.dart';

class AdminMenuItemFormModel {
  String id;
  String amharic;
  String english;
  double price;
  String section;
  String imageurl;

  AdminMenuItemFormModel({
    this.id = '',
    this.amharic = '',
    this.english = '',
    this.price = 0.0,
    this.section = '',
    this.imageurl = '',
  });

  factory AdminMenuItemFormModel.fromMenuItem(MenuItem item) {
    return AdminMenuItemFormModel(
      id: item.id,
      amharic: item.amharic,
      english: item.english,
      price: item.price,
      section: item.section,
      imageurl: item.imageurl,
    );
  }

  MenuItem toMenuItem() {
    return MenuItem(
      id: id,
      amharic: amharic,
      english: english,
      price: price,
      section: section,
      imageurl: imageurl,
    );
  }
}
