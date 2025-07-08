import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'file_helper_io.dart' if (dart.library.html) 'file_helper_web.dart';

class MenuItem {
  final String id;
  final String amharic;
  final String english;
  final String section;
  final String imageUrl;

  MenuItem({
    required this.id,
    required this.amharic,
    required this.english,
    required this.section,
    required this.imageUrl,
  });

  factory MenuItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MenuItem(
      id: doc.id,
      amharic: data['amharic'] ?? '',
      english: data['english'] ?? '',
      section: data['section'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amharic': amharic,
      'english': english,
      'section': section,
      'imageUrl': imageUrl,
    };
  }
}

class MenuProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
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
      final snapshot = await _firestore.collection('menu').get();
      final items =
          snapshot.docs.map((doc) => MenuItem.fromFirestore(doc)).toList();
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
    debugPrint('uploadImage called with: ${fileOrXFile.runtimeType}');
    try {
      if (kIsWeb) {
        // Web: fileOrXFile is XFile
        final XFile xfile = fileOrXFile as XFile;
        final bytes = await xfile.length();
        if (bytes > 1024 * 1024) {
          debugPrint('Image too large');
          return 'Image must be less than 1MB';
        }
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${xfile.name}';
        final ref = _storage.ref().child('menu_images/$fileName');
        final uploadTask = ref.putData(await xfile.readAsBytes());
        uploadTask.snapshotEvents.listen((event) {
          if (onProgress != null && event.totalBytes > 0) {
            onProgress(event.bytesTransferred / event.totalBytes);
          }
        });
        final snapshot = await uploadTask;
        final url = await snapshot.ref.getDownloadURL();
        debugPrint('Image uploaded! Download URL: $url');
        return url;
      } else {
        // Mobile/Desktop: fileOrXFile is XFile
        final XFile xfile = fileOrXFile as XFile;
        final bytes = await xfile.length();
        if (bytes > 1024 * 1024) {
          debugPrint('Image too large');
          return 'Image must be less than 1MB';
        }
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${xfile.name}';
        final ref = _storage.ref().child('menu_images/$fileName');
        final uploadTask = ref.putFile(xFileToFile(xfile));
        uploadTask.snapshotEvents.listen((event) {
          if (onProgress != null && event.totalBytes > 0) {
            onProgress(event.bytesTransferred / event.totalBytes);
          }
        });
        final snapshot = await uploadTask;
        final url = await snapshot.ref.getDownloadURL();
        debugPrint('Image uploaded! Download URL: $url');
        return url;
      }
    } catch (e, stack) {
      debugPrint('Image upload failed: $e');
      debugPrint('Stack trace: $stack');
      print('Image upload failed: $e');
      print('Stack trace: $stack');
      return null;
    }
  }

  Future<void> addMenuItem(MenuItem item) async {
    // Prevent adding item if imageUrl is null or empty
    if (item.imageUrl.isEmpty) {
      _error = 'Image is required to add an item.';
      notifyListeners();
      return;
    }
    try {
      await _firestore.collection('menu').add(item.toMap());
      await fetchMenu();
    } catch (e) {
      _error = 'Failed to add item: $e';
      notifyListeners();
    }
  }

  Future<void> updateMenuItem(MenuItem item) async {
    try {
      await _firestore.collection('menu').doc(item.id).update(item.toMap());
      await fetchMenu();
    } catch (e) {
      _error = 'Failed to update item: $e';
      notifyListeners();
    }
  }

  Future<void> deleteMenuItem(MenuItem item) async {
    try {
      // Delete the Firestore document first
      await _firestore.collection('menu').doc(item.id).delete();
      // Delete the image from Firebase Storage if imageUrl is present
      if (item.imageUrl.isNotEmpty) {
        try {
          final ref = _storage.refFromURL(item.imageUrl);
          await ref.delete();
        } catch (e) {
          debugPrint('Failed to delete image from storage: $e');
          // Optionally handle/log error, but do not stop the process
        }
      }
      await fetchMenu();
    } catch (e) {
      _error = 'Failed to delete item: $e';
      notifyListeners();
    }
  }
}

/// Helper function to pick and upload an image, works for both web and mobile/desktop.
/// Call this from your dialog/widget and use the returned imageUrl as needed.
///
/// Example usage in your dialog:
/// ElevatedButton(
///   onPressed: () async {
///     await pickAndUploadImage(context, (imageUrl) {
///       // Use imageUrl in your form/controller
///     });
///   },
///   child: Text('Pick Image'),
/// )
Future<void> pickAndUploadImage(
    BuildContext context, Function(String) onImageUrl) async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(source: ImageSource.gallery);

  if (picked == null) return;

  dynamic fileOrXFile = picked; // Always pass XFile

  final menuProvider = Provider.of<MenuProvider>(context, listen: false);

  final imageUrl =
      await menuProvider.uploadImage(fileOrXFile, onProgress: (progress) {
    // Optionally update a progress indicator here
  });

  if (imageUrl != null && !imageUrl.startsWith('Image must be')) {
    onImageUrl(imageUrl); // Use the imageUrl in your dialog/form
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(imageUrl ?? 'Image upload failed')),
    );
  }
}
