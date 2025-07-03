import '../../../domain/entities/menu_item.dart';

class AdminMenuItemFormModel {
  String id;
  String name;
  String description;
  double price;
  String category;
  String imageUrl;

  AdminMenuItemFormModel({
    this.id = '',
    this.name = '',
    this.description = '',
    this.price = 0.0,
    this.category = '',
    this.imageUrl = '',
  });

  factory AdminMenuItemFormModel.fromMenuItem(MenuItem item) {
    return AdminMenuItemFormModel(
      id: item.id,
      name: item.name,
      description: item.description,
      price: item.price,
      category: item.category,
      imageUrl: item.imageUrl,
    );
  }

  MenuItem toMenuItem() {
    return MenuItem(
      id: id,
      name: name,
      description: description,
      price: price,
      category: category,
      imageUrl: imageUrl,
    );
  }
}
