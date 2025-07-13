import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/providers/menu_provider.dart';
import '../../admin/admin_dashboard_page.dart';

// Admin login dialog widget
class _AdminLoginDialog extends StatefulWidget {
  @override
  State<_AdminLoginDialog> createState() => _AdminLoginDialogState();
}

class _AdminLoginDialogState extends State<_AdminLoginDialog> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  void _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    await Future.delayed(const Duration(seconds: 1)); // Simulate network
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email == "rahma01@gmail.com" && password == "Rahma090909") {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text("Login successful!"),
            ],
          ),
          backgroundColor: Colors.black87,
        ),
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => MenuProvider(),
            child: const AdminDashboardPage(),
          ),
        ),
      );
    } else {
      setState(() {
        _error = "Invalid email or password.";
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color.fromARGB(255, 221, 200, 83),
              child: const Icon(Icons.person, color: Colors.white, size: 32),
            ),
            SizedBox(height: 16),
            Text("Admin Login",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            if (_error != null) ...[
              SizedBox(height: 10),
              Text(_error!, style: TextStyle(color: Colors.red)),
            ],
            SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 221, 200, 83),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _loading ? null : _login,
                child: _loading
                    ? SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text("Login",
                        style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sections = [
      {'amharic': 'የቤት ስፔሻል', 'english': 'Our Special', 'icon': Icons.star},
      {'amharic': 'ቁርስ', 'english': 'Breakfast', 'icon': Icons.free_breakfast},
      {
        'amharic': 'ምሳ ና እራት',
        'english': 'Lunch & Dinner',
        'icon': Icons.restaurant_menu
      },
      {'amharic': 'የጾም ምግብ', 'english': 'Vege. & Fasting', 'icon': Icons.eco},
      {'amharic': 'መጠጦች', 'english': 'Drinks', 'icon': Icons.local_drink},
      {'amharic': 'በሌሎች', 'english': 'Others', 'icon': Icons.more_horiz},
    ];
    return Scaffold(
      backgroundColor: const Color(0xFFFDF1E2),
      body: SafeArea(
        child: Stack(
          children: [
            // Blurred background image
            Positioned.fill(
              child: Stack(
                children: [
                  ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                          sigmaX: 24, sigmaY: 24), // Increased blur
                      child: Image.asset(
                        'asset/images/cover.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.black
                        .withOpacity(0.35), // Dark overlay for contrast
                  ),
                ],
              ),
            ),
            // Main content
            SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Rahma Restaurant',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(67, 1, 250, 1),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Authentic Ethiopian Cuisine',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color.fromRGBO(245, 242, 242, 1),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Rating row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, color: Colors.amber[700], size: 20),
                        Icon(Icons.star, color: Colors.amber[700], size: 20),
                        Icon(Icons.star, color: Colors.amber[700], size: 20),
                        Icon(Icons.star, color: Colors.amber[700], size: 20),
                        Icon(Icons.star_half,
                            color: Colors.amber[700], size: 20),
                        const SizedBox(width: 6),
                        const Text('4.8',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Experience authentic Ethiopian flavors with traditional recipes and spices passed down through generations.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13,
                          color: Color.fromRGBO(248, 247, 247, 1)),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Digital Menu',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 248, 247, 246),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Category buttons grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1.2,
                      children: sections.map((section) {
                        return _MenuCategoryCard(
                          amharic: section['amharic'] as String,
                          english: section['english'] as String,
                          icon: section['icon'] as IconData,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MenuSectionPage(
                                  section: section['english'] as String,
                                  amharic: section['amharic'] as String,
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    // Footer
                    Divider(color: Colors.brown[200]),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.phone, color: Colors.brown[400], size: 18),
                        const SizedBox(width: 10),
                        Icon(Icons.location_on,
                            color: Colors.brown[400], size: 18),
                        SizedBox(width: 10),
                        Icon(Icons.language,
                            color: Colors.brown[400], size: 18),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '© 2024 Rahma Restaurant. All rights reserved.',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color.fromRGBO(241, 238, 236, 1)),
                    ),
                  ],
                ),
              ),
            ),
            // Admin button (top right)
            Positioned(
              top: 18,
              right: 18,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () async {
                    await showDialog(
                      context: context,
                      builder: (context) => _AdminLoginDialog(),
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child:
                        const Icon(Icons.person, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Card-style menu category button with image placeholder
class _MenuCategoryCard extends StatelessWidget {
  final String amharic;
  final String english;
  final IconData icon;
  final VoidCallback? onTap;
  const _MenuCategoryCard({
    required this.amharic,
    required this.english,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        color: Colors.brown[50],
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 6.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 38, color: Colors.brown[400]),
              const SizedBox(height: 8),
              Text(
                amharic,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.brown,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                english,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.brown,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
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

  Future<List<Map<String, dynamic>>> fetchMenuItems() async {
    final response = await Supabase.instance.client
        .from('menu')
        .select()
        .eq('section', section);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 238, 219, 111),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(amharic, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(section, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchMenuItems(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Error: \\${snapshot.error}',
                    style: const TextStyle(color: Colors.red)));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!;
          if (docs.isEmpty) {
            return const Center(child: Text('No items found.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index];
              return _AnimatedMenuItem(
                key: ValueKey(data['id'] ?? index),
                imageurl: data['imageurl'] ?? '',
                amharic: data['amharic'] ?? '',
                english: data['english'] ?? '',
                price: data['price']?.toString() ?? '',
                section: data['section'] ?? '',
                animationIndex: index,
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

// Animated menu item widget
class _AnimatedMenuItem extends StatefulWidget {
  final String imageurl;
  final String amharic;
  final String english;
  final String price;
  final String section;
  final int animationIndex;
  const _AnimatedMenuItem({
    Key? key,
    required this.imageurl,
    required this.amharic,
    required this.english,
    required this.price,
    required this.section,
    required this.animationIndex,
  }) : super(key: key);

  @override
  State<_AnimatedMenuItem> createState() => _AnimatedMenuItemState();
}

class _AnimatedMenuItemState extends State<_AnimatedMenuItem>
    with TickerProviderStateMixin {
  late AnimationController _imgController;
  late AnimationController _textController;
  late Animation<Offset> _imgOffset;
  late Animation<Offset> _textOffset;
  late Animation<double> _imgOpacity;
  late Animation<double> _textOpacity;

  // Rotation animation controller
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    final delay = Duration(milliseconds: 100 * widget.animationIndex);
    _imgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _imgOffset = Tween<Offset>(begin: const Offset(-0.5, 0), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _imgController, curve: Curves.easeOut));
    _textOffset = Tween<Offset>(begin: const Offset(0.5, 0), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _textController, curve: Curves.easeOut));
    _imgOpacity = Tween<double>(begin: 0, end: 1).animate(_imgController);
    _textOpacity = Tween<double>(begin: 0, end: 1).animate(_textController);
    Future.delayed(delay, () {
      if (mounted) _imgController.forward();
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) _textController.forward();
      });
    });

    // Fast 360-degree rotation and back
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _rotationAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 2 * 3.1415926535)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
      /* TweenSequenceItem(
        tween: Tween<double>(begin: 2 * 3.1415926535, end: 0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),*/
    ]).animate(_rotationController);
  }

  void _triggerRotation() {
    _rotationController.forward(from: 0);
  }

  @override
  void dispose() {
    _imgController.dispose();
    _textController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFF3E0),
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _imgOpacity,
              child: SlideTransition(
                position: _imgOffset,
                child: MouseRegion(
                  onEnter: (_) => _triggerRotation(),
                  child: GestureDetector(
                    onTap: _triggerRotation,
                    child: AnimatedBuilder(
                      animation: _rotationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationAnimation.value,
                          child: child,
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            65), // Half of width/height for perfect circle
                        child: widget.imageurl.isNotEmpty
                            ? Image.network(
                                widget.imageurl,
                                width: 130,
                                height: 130,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    shape: BoxShape.circle,
                                  ),
                                  child:
                                      const Icon(Icons.broken_image, size: 50),
                                ),
                              )
                            : Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.image, size: 50),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FadeTransition(
                opacity: _textOpacity,
                child: SlideTransition(
                  position: _textOffset,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.amharic,
                        style: const TextStyle(
                          color: Color(0xFFD32F2F),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        widget.english,
                        style: const TextStyle(
                          color: Color(0xFFD32F2F),
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 12),
                      if (widget.price.isNotEmpty)
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Color(0xFF179C5B),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            '${widget.price} AED',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
