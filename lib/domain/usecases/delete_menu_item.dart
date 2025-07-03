import '../repositories/menu_repository.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

class DeleteMenuItem {
  final MenuRepository repository;
  DeleteMenuItem(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteMenuItem(id);
  }
}
