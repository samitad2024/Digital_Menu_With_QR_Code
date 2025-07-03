import '../repositories/menu_repository.dart';
import '../entities/menu_item.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

class GetMenuItemsByCategory {
  final MenuRepository repository;
  GetMenuItemsByCategory(this.repository);

  Future<Either<Failure, List<MenuItem>>> call(String category) async {
    return await repository.getMenuItemsByCategory(category);
  }
}
