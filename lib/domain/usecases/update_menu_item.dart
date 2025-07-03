import '../repositories/menu_repository.dart';
import '../entities/menu_item.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

class UpdateMenuItem {
  final MenuRepository repository;
  UpdateMenuItem(this.repository);

  Future<Either<Failure, void>> call(MenuItem item) async {
    return await repository.updateMenuItem(item);
  }
}
