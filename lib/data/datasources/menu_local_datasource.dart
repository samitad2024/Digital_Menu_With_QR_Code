import '../../domain/entities/menu_item.dart';

abstract class MenuLocalDataSource {
  Future<List<MenuItem>> getCachedMenuItems();
  Future<void> cacheMenuItems(List<MenuItem> items);
}
