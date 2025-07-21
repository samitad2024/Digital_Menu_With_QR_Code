import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/menu_provider.dart';
import '../../admin/admin_dashboard_page.dart';
import 'package:flutter/widgets.dart'; // Added this import for ValueKey and SizedBox
import 'package:confetti/confetti.dart';
import 'package:url_launcher/url_launcher.dart';

// HomePage main widget for routing
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // You can add your previous HomePage state and build method here
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _startConfettiLoop();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache the cover image for faster display (context is available here)
    precacheImage(const AssetImage('asset/images/cover.jpeg'), context);
  }

  void _startConfettiLoop() async {
    _confettiController.play();
    while (mounted) {
      await Future.delayed(const Duration(seconds: 5));
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchNews() async {
    final response = await Supabase.instance.client.from('news').select();
    return List<Map<String, dynamic>>.from(response);
  }

  // Custom confetti shape to match the provided image (party popper)
  Path _drawConfettiShape(Size size) {
    final path = Path();
    path.moveTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();
    return path;
  }

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
      body: Stack(
        children: [
          // Fullscreen background image with blur
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                    sigmaX: 20,
                    sigmaY: 20), // Reduced blur for faster rendering
                child: Image.asset(
                  'asset/images/cover.jpeg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  alignment: Alignment.center,
                ),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Restaurant name at top
                Stack(
                  children: [
                    // Restaurant name with blurred background
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 8.0, left: 15.0, right: 15.0, bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Blurred rectangular background
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 12, sigmaY: 12),
                                    child: Container(
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.55),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                            color: Colors.amber, width: 1.5),
                                      ),
                                    ),
                                  ),
                                ),
                                // White stroke effect using two Text widgets
                                Text(
                                  'RAHMA RESTOURANT',
                                  style: TextStyle(
                                    fontFamily: 'LuckiestGuy',
                                    fontSize: 25,
                                    letterSpacing: 2.5,
                                    foreground: Paint()
                                      ..style = PaintingStyle.stroke
                                      ..strokeWidth = 5
                                      ..color = Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                // Main colored text with shadow
                                Text(
                                  'RAHMA RESTOURANT',
                                  style: TextStyle(
                                    fontFamily: 'LuckiestGuy',
                                    fontSize: 25,
                                    color: const Color(0xFFFF3B1F),
                                    letterSpacing: 2.5,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.25),
                                        offset: const Offset(2, 4),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 18.0, right: 3.0),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(8),
                                        onTap: () async {
                                          await showDialog(
                                            context: context,
                                            builder: (context) =>
                                                _AdminLoginDialog(),
                                          );
                                        },
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.85),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 4,
                                                offset: Offset(0, 0),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(Icons.person,
                                              color: Colors.amber, size: 17),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // News area with confetti animation
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // News auto-refresh with StreamBuilder
                      StreamBuilder<List<Map<String, dynamic>>>(
                        stream: Stream.periodic(const Duration(seconds: 2))
                            .asyncMap((_) => _fetchNews()),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(height: 96);
                          }
                          final newsList = snapshot.data ?? [];
                          if (newsList.isNotEmpty) {
                            return Container(
                              width: double.infinity,
                              constraints: const BoxConstraints(
                                  minHeight: 96, maxHeight: 180),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 24, horizontal: 18),
                              margin: const EdgeInsets.only(bottom: 18),
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(255, 255, 255, 1)
                                    .withOpacity(0.95),
                                borderRadius: BorderRadius.circular(14),
                                border:
                                    Border.all(color: Colors.amber, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.amber.withOpacity(0.15),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: SingleChildScrollView(
                                child: Text(
                                  newsList.first['text'] ?? '',
                                  style: const TextStyle(
                                    color: Color(0xFF3B3B3B),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 26,
                                    fontFamily: 'Pacifico', // Stylish font
                                    letterSpacing: 1.2,
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          } else {
                            return const SizedBox(height: 96);
                          }
                        },
                      ),
                      // Centered confetti animation
                      Align(
                        alignment: Alignment.center,
                        child: IgnorePointer(
                          child: ConfettiWidget(
                            confettiController: _confettiController,
                            blastDirectionality: BlastDirectionality.explosive,
                            emissionFrequency: 0.08,
                            numberOfParticles: 18,
                            maxBlastForce: 18,
                            minBlastForce: 8,
                            gravity: 0.25,
                            colors: const [
                              Colors.yellow,
                              Colors.purple,
                              Colors.blue,
                              Colors.green,
                              Colors.orange,
                              Colors.pink,
                              Colors.white,
                            ],
                            createParticlePath: _drawConfettiShape,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Spacer to push menu grid lower
                const SizedBox(height: 8),
                // Menu grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      childAspectRatio:
                          1.4, // reduced aspect ratio for smaller grid boxes
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
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
                  ),
                ),
                // Footer
                Padding(
                  padding: const EdgeInsets.only(top: 30.0, bottom: 8.0),
                  child: Column(
                    children: [
                      Divider(color: Colors.brown[200]),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // WhatsApp icon button
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () async {
                                  const whatsappUrl =
                                      'https://wa.me/971556887182';
                                  if (await canLaunchUrl(
                                      Uri.parse(whatsappUrl))) {
                                    await launchUrl(Uri.parse(whatsappUrl),
                                        mode: LaunchMode.externalApplication);
                                  }
                                },
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.85),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(7.0),
                                    child: Image.network(
                                      'https://upload.wikimedia.org/wikipedia/commons/6/6b/WhatsApp.svg',
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 18),
                          // TikTok icon button (PNG instead of SVG)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () async {
                                  const tiktokUrl =
                                      'https://www.tiktok.com/@rahmarestaurant1';
                                  if (await canLaunchUrl(
                                      Uri.parse(tiktokUrl))) {
                                    await launchUrl(Uri.parse(tiktokUrl),
                                        mode: LaunchMode.externalApplication);
                                  }
                                },
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.85),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(7.0),
                                    child: Image.network(
                                      'https://cdn-icons-png.flaticon.com/512/3046/3046122.png',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 18),
                          // Map icon button (placeholder)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(Icons.map,
                                    color: Colors.amber, size: 24),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Blurred background for copyright text
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Text(
                              '© 2025 Rahma Restaurant. All rights reserved.',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF3B3B3B),
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
    if (email == "rahma@gmail.com" && password == "Rahma2025") {
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
            const CircleAvatar(
              radius: 28,
              backgroundColor: Color.fromARGB(255, 221, 200, 83),
              child: Icon(Icons.person, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),
            const Text("Admin Login",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 221, 200, 83),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text("Login",
                        style: TextStyle(fontWeight: FontWeight.bold)),
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
              Icon(icon, size: 30, color: Color.fromARGB(255, 233, 126, 4)),
              const SizedBox(height: 6),
              Text(
                amharic,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 3),
              Text(
                english,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.black,
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
      duration: const Duration(milliseconds: 2500),
    );
    _rotationAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 2 * 3.1415926535)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
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
    return MouseRegion(
      onEnter: (_) => _triggerRotation(),
      child: GestureDetector(
        onTap: _triggerRotation,
        child: Card(
          color: const Color(0xFFFFF3E0),
          margin: const EdgeInsets.only(bottom: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
                                color: const Color(0xFF179C5B),
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
        ),
      ),
    );
  }
}

