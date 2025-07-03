import '../repositories/menu_repository.dart';
import '../entities/menu_item.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

class GetAllMenuItems {
  final MenuRepository repository;
  GetAllMenuItems(this.repository);

  Future<Either<Failure, List<MenuItem>>> call() async {
    return await repository.getAllMenuItems();
  }
}
