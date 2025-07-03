import 'package:flutter/material.dart';
import '../../../domain/entities/menu_item.dart';
import '../../../domain/usecases/get_all_menu_items.dart';
import '../../../domain/usecases/get_menu_items_by_category.dart';
import '../../../core/error/failures.dart';

class HomeMenuController extends ChangeNotifier {
  final GetAllMenuItems getAllMenuItems;
  final GetMenuItemsByCategory getMenuItemsByCategory;

  List<MenuItem> _items = [];
  List<MenuItem> get items => _items;
  String? _error;
  String? get error => _error;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  HomeMenuController({
    required this.getAllMenuItems,
    required this.getMenuItemsByCategory,
  });

  Future<void> fetchAllMenuItems() async {
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

  Future<void> fetchMenuItemsByCategory(String category) async {
    _isLoading = true;
    notifyListeners();
    final result = await getMenuItemsByCategory(category);
    result.fold(
      (failure) => _error = _mapFailureToMessage(failure),
      (items) => _items = items,
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
