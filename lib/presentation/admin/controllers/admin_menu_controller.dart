import 'package:flutter/material.dart';
import '../../../domain/entities/menu_item.dart';
import '../../../domain/usecases/get_all_menu_items.dart';
import '../../../domain/usecases/add_menu_item.dart';
import '../../../domain/usecases/update_menu_item.dart';
import '../../../domain/usecases/delete_menu_item.dart';
import '../../../core/error/failures.dart';

class AdminMenuController extends ChangeNotifier {
  final GetAllMenuItems getAllMenuItems;
  final AddMenuItem addMenuItem;
  final UpdateMenuItem updateMenuItem;
  final DeleteMenuItem deleteMenuItem;

  List<MenuItem> _items = [];
  List<MenuItem> get items => _items;
  String? _error;
  String? get error => _error;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AdminMenuController({
    required this.getAllMenuItems,
    required this.addMenuItem,
    required this.updateMenuItem,
    required this.deleteMenuItem,
  });

  Future<void> fetchMenuItems() async {
    _isLoading = true;
    notifyListeners();
    final result = await getAllMenuItems();
    result.fold(
      (failure) => _error = _mapFailureToMessage(failure),
      (items) => _items = items,
    );
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addItem(MenuItem item) async {
    _isLoading = true;
    notifyListeners();
    final result = await addMenuItem(item);
    result.fold(
      (failure) => _error = _mapFailureToMessage(failure),
      (_) => fetchMenuItems(),
    );
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateItem(MenuItem item) async {
    _isLoading = true;
    notifyListeners();
    final result = await updateMenuItem(item);
    result.fold(
      (failure) => _error = _mapFailureToMessage(failure),
      (_) => fetchMenuItems(),
    );
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteItem(String id) async {
    _isLoading = true;
    notifyListeners();
    final result = await deleteMenuItem(id);
    result.fold(
      (failure) => _error = _mapFailureToMessage(failure),
      (_) => fetchMenuItems(),
    );
    _isLoading = false;
    notifyListeners();
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return 'Server error occurred.';
    if (failure is CacheFailure) return 'Cache error occurred.';
    return 'Unexpected error.';
  }
}
