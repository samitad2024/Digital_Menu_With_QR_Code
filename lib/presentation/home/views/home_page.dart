import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/providers/menu_provider.dart';
import '../../admin/admin_dashboard_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sections = [
      {'amharic': 'የቤት ስፔሻል', 'english': 'Our Special'},
      {'amharic': 'ቁርስ', 'english': 'Breakfast'},
      {'amharic': 'ምሳ ና እራት', 'english': 'Lunch & Dinner'},
      {'amharic': 'የአንስሳ ምግብ', 'english': 'Vege. & Fasting'},
      {'amharic': 'መጠጦች', 'english': 'Drinks'},
      {'amharic': 'በሌሎች', 'english': 'Others'},
    ];
    return Scaffold(
      backgroundColor: const Color(0xFF179C5B),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 24),
                // Stylized MENU text
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _MenuLetter(
                      letter: 'M',
                      color: Colors.orange,
                      decorations: [
                        _MenuDecoration.triangle,
                        _MenuDecoration.dot,
                      ],
                    ),
                    _MenuLetter(
                      letter: 'E',
                      color: Colors.brown,
                      decorations: [
                        _MenuDecoration.eye,
                      ],
                    ),
                    _MenuLetter(
                      letter: 'N',
                      color: Colors.red,
                      decorations: [
                        _MenuDecoration.zigzag,
                      ],
                    ),
                    _MenuLetter(
                      letter: 'U',
                      color: Colors.red,
                      decorations: [
                        _MenuDecoration.dots,
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Category buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    runSpacing: 16,
                    children: sections.map((section) {
                      return _MenuCategoryButton(
                        amharic: section['amharic']!,
                        english: section['english']!,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MenuSectionPage(
                                section: section['english']!,
                                amharic: section['amharic']!,
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              right: 16,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.brown[900],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                icon: const Icon(Icons.admin_panel_settings, size: 20),
                label: const Text('Admin Login',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider(
                        create: (_) => MenuProvider(),
                        child: const AdminDashboardPage(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// MenuSectionPage displays menu items for a section from Firestore
class MenuSectionPage extends StatelessWidget {
  final String section;
  final String amharic;
  const MenuSectionPage(
      {required this.section, required this.amharic, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF179C5B),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(amharic, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(section, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('menu')
            .where('section', isEqualTo: section)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Error: \\${snapshot.error}',
                    style: const TextStyle(color: Colors.red)));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No items found.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return Card(
                color: const Color(0xFFFFF3E0),
                margin: const EdgeInsets.only(bottom: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: data['imageUrl'] != null &&
                                data['imageUrl'] != ''
                            ? Image.network(
                                data['imageUrl'],
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  width: 90,
                                  height: 90,
                                  color: Colors.grey[300],
                                  child:
                                      const Icon(Icons.broken_image, size: 40),
                                ),
                              )
                            : Container(
                                width: 90,
                                height: 90,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image, size: 40),
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['amharic'] ?? '',
                              style: const TextStyle(
                                color: Color(0xFFD32F2F),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              data['english'] ?? '',
                              style: const TextStyle(
                                color: Color(0xFFD32F2F),
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF179C5B),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.attach_money,
                                          color: Colors.white, size: 18),
                                      Text(
                                        data['price'] ?? '',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Stylized letter widget (placeholder for custom drawing)
enum _MenuDecoration { triangle, dot, eye, zigzag, dots }

class _MenuLetter extends StatelessWidget {
  final String letter;
  final Color color;
  final List<_MenuDecoration> decorations;
  const _MenuLetter(
      {required this.letter, required this.color, required this.decorations});

  @override
  Widget build(BuildContext context) {
    // For demo, just use Text. For real, use CustomPaint or SVG.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 80,
          fontWeight: FontWeight.bold,
          color: color,
          fontFamily: 'Arial',
        ),
      ),
    );
  }
}

class _MenuCategoryButton extends StatelessWidget {
  final String amharic;
  final String english;
  final VoidCallback? onTap;
  const _MenuCategoryButton(
      {required this.amharic, required this.english, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFA726),
          foregroundColor: Colors.brown[900],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onTap,
        child: Column(
          children: [
            Text(
              amharic,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              english,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
