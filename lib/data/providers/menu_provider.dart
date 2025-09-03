import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'file_helper_io.dart' if (dart.library.html) 'file_helper_web.dart';

class MenuItem {
  final String id;
  final String amharic;
  final String english;
  final double price;
  final String section;
  final String imageurl;

  MenuItem({
    required this.id,
    required this.amharic,
    required this.english,
    required this.price,
    required this.section,
    required this.imageurl,
  });

  factory MenuItem.fromMap(Map<String, dynamic> data, String id) {
    return MenuItem(
      id: id,
      amharic: data['amharic'] ?? '',
      english: data['english'] ?? '',
      price: (data['price'] is num)
          ? (data['price'] as num).toDouble()
          : double.tryParse(data['price']?.toString() ?? '') ?? 0.0,
      section: data['section'] ?? '',
      imageurl: data['imageurl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amharic': amharic,
      'english': english,
      'price': price,
      'section': section,
      'imageurl': imageurl,
    };
  }
}

class MenuProvider with ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  Map<String, List<MenuItem>> _itemsBySection = {};
  bool _loading = false;
  String? _error;

  Map<String, List<MenuItem>> get itemsBySection => _itemsBySection;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchMenu() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _client.from('menu').select();
      final items = (response as List)
          .map((data) =>
              MenuItem.fromMap(data, data['id'] ?? data['uuid'] ?? ''))
          .toList();
      _itemsBySection = {};
      for (var item in items) {
        _itemsBySection.putIfAbsent(item.section, () => []).add(item);
      }
    } catch (e) {
      _error = 'Failed to load menu: $e';
    }
    _loading = false;
    notifyListeners();
  }

  Future<String?> uploadImage(dynamic fileOrXFile,
      {Function(double)? onProgress}) async {
    debugPrint('uploadImage called with: \\${fileOrXFile.runtimeType}');
    try {
      final XFile xfile = fileOrXFile as XFile;
      final bytes = await xfile.length();
      if (bytes > 1024 * 1024) {
        debugPrint('Image too large');
        return 'Image must be less than 1MB';
      }
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${xfile.name}';
      final storageResponse =
          await _client.storage.from('menu-images').uploadBinary(
                fileName,
                await xfile.readAsBytes(),
                fileOptions: const FileOptions(upsert: true),
              );
      // Supabase uploadBinary returns a String path on success, or throws on error
      final url = _client.storage.from('menu-images').getPublicUrl(fileName);
      debugPrint('Image uploaded! Public URL: $url');
      return url;
    } catch (e, stack) {
      debugPrint('Image upload failed: $e');
      debugPrint('Stack trace: $stack');
      print('Image upload failed: $e');
      print('Stack trace: $stack');
      return null;
    }
  }

  Future<void> addMenuItem(MenuItem item) async {
    if (item.imageurl.isEmpty) {
      _error = 'Image is required to add an item.';
      notifyListeners();
      return;
    }
    try {
      await _client.from('menu').insert(item.toMap());
      await fetchMenu();
    } catch (e) {
      _error = 'Failed to add item: $e';
      notifyListeners();
    }
  }

  Future<void> updateMenuItem(MenuItem item) async {
    try {
      await _client.from('menu').update(item.toMap()).eq('id', item.id);
      await fetchMenu();
    } catch (e) {
      _error = 'Failed to update item: $e';
      notifyListeners();
    }
  }

  Future<void> deleteMenuItem(MenuItem item) async {
    try {
      await _client.from('menu').delete().eq('id', item.id);
      if (item.imageurl.isNotEmpty) {
        try {
          // Extract the file path from the public URL
          final uri = Uri.parse(item.imageurl);
          final segments = uri.pathSegments;
          final storageIndex = segments.indexOf('object');
          if (storageIndex != -1 && segments.length > storageIndex + 2) {
            final filePath = segments.sublist(storageIndex + 2).join('/');
            await _client.storage.from('menu-images').remove([filePath]);
          }
        } catch (e) {
          debugPrint('Failed to delete image from storage: $e');
        }
      }
      await fetchMenu();
    } catch (e) {
      _error = 'Failed to delete item: $e';
      notifyListeners();
    }
  }
}

final menuProviderProvider =
    ChangeNotifierProvider<MenuProvider>((ref) => MenuProvider());

Future<void> pickAndUploadImage(
    BuildContext context, WidgetRef ref, Function(String) onImageurl) async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(source: ImageSource.gallery);
  if (picked == null) return;
  dynamic fileOrXFile = picked;
  final menuProvider = ref.read(menuProviderProvider);
  final imageurl =
      await menuProvider.uploadImage(fileOrXFile, onProgress: (progress) {
    // Optionally update a progress indicator here
  });
  if (imageurl != null && !imageurl.startsWith('Image must be')) {
    onImageurl(imageurl);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(imageurl ?? 'Image upload failed')),
    );
  }
}
