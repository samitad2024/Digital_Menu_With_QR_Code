// Core business object: MenuItem
class MenuItem {
  final String id;
  final String amharic;
  final String english;
  final double price;
  final String section;
  final String imageurl;

  MenuItem({
    required this.id,
    required this.amharic,
    required this.english,
    required this.price,
    required this.section,
    required this.imageurl,
  });
}
