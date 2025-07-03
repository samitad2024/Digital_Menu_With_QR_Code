import '../../domain/entities/menu_item.dart';

abstract class MenuRemoteDataSource {
  Future<List<MenuItem>> getAllMenuItems();
  Future<List<MenuItem>> getMenuItemsByCategory(String category);
  Future<void> addMenuItem(MenuItem item);
  Future<void> updateMenuItem(MenuItem item);
  Future<void> deleteMenuItem(String id);
}
