import 'package:get_it/get_it.dart';
import 'domain/usecases/get_all_menu_items.dart';
import 'domain/usecases/get_menu_items_by_category.dart';
import 'domain/usecases/add_menu_item.dart';
import 'domain/usecases/update_menu_item.dart';
import 'domain/usecases/delete_menu_item.dart';
import 'data/repositories/menu_repository_impl.dart';
import 'data/datasources/menu_remote_datasource.dart';
import 'data/datasources/menu_local_datasource.dart';
import 'presentation/admin/controllers/admin_menu_controller.dart';
import 'presentation/home/controllers/home_menu_controller.dart';

final sl = GetIt.instance;

void init() {
  // Data sources
  sl.registerLazySingleton<MenuRemoteDataSource>(
      () => /* TODO: Implement */ throw UnimplementedError());
  sl.registerLazySingleton<MenuLocalDataSource>(
      () => /* TODO: Implement */ throw UnimplementedError());

  // Repository
  sl.registerLazySingleton(() => MenuRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetAllMenuItems(sl()));
  sl.registerLazySingleton(() => GetMenuItemsByCategory(sl()));
  sl.registerLazySingleton(() => AddMenuItem(sl()));
  sl.registerLazySingleton(() => UpdateMenuItem(sl()));
  sl.registerLazySingleton(() => DeleteMenuItem(sl()));

  // Controllers
  sl.registerFactory(() => AdminMenuController(
        getAllMenuItems: sl(),
        addMenuItem: sl(),
        updateMenuItem: sl(),
        deleteMenuItem: sl(),
      ));
  sl.registerFactory(() => HomeMenuController(
        getAllMenuItems: sl(),
        getMenuItemsByCategory: sl(),
      ));
}
