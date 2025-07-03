import '../../domain/entities/menu_item.dart';
import '../../domain/repositories/menu_repository.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';
import '../datasources/menu_remote_datasource.dart';
import '../datasources/menu_local_datasource.dart';

class MenuRepositoryImpl implements MenuRepository {
  final MenuRemoteDataSource remoteDataSource;
  final MenuLocalDataSource? localDataSource;

  MenuRepositoryImpl({
    required this.remoteDataSource,
    this.localDataSource,
  });

  @override
  Future<Either<Failure, List<MenuItem>>> getAllMenuItems() async {
    try {
      final items = await remoteDataSource.getAllMenuItems();
      return Right(items);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<MenuItem>>> getMenuItemsByCategory(
      String category) async {
    try {
      final items = await remoteDataSource.getMenuItemsByCategory(category);
      return Right(items);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addMenuItem(MenuItem item) async {
    try {
      await remoteDataSource.addMenuItem(item);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateMenuItem(MenuItem item) async {
    try {
      await remoteDataSource.updateMenuItem(item);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteMenuItem(String id) async {
    try {
      await remoteDataSource.deleteMenuItem(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
