import '../entities/menu_item.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

abstract class MenuRepository {
  Future<Either<Failure, List<MenuItem>>> getAllMenuItems();
  Future<Either<Failure, List<MenuItem>>> getMenuItemsByCategory(
      String category);
  Future<Either<Failure, void>> addMenuItem(MenuItem item);
  Future<Either<Failure, void>> updateMenuItem(MenuItem item);
  Future<Either<Failure, void>> deleteMenuItem(String id);
}
