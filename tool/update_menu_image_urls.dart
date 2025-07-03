import 'package:cloud_firestore/cloud_firestore.dart';

/// Run this script ONCE to update all menu items in Firestore that are missing an imageUrl.
/// It will set a placeholder image for any item with an empty or missing imageUrl.
Future<void> main() async {
  final firestore = FirebaseFirestore.instance;
  final placeholderUrl =
      'https://via.placeholder.com/100x100.png?text=No+Image';

  final menuCollection = firestore.collection('menu');
  final snapshot = await menuCollection.get();
  int updated = 0;
  for (final doc in snapshot.docs) {
    final data = doc.data();
    if (data['imageUrl'] == null || (data['imageUrl'] as String).isEmpty) {
      await doc.reference.update({'imageUrl': placeholderUrl});
      updated++;
    }
  }
  print('Updated $updated menu items with placeholder imageUrl.');
}
