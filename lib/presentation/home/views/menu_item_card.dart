import 'package:flutter/material.dart';
import '../../../domain/entities/menu_item.dart';

class MenuItemCard extends StatefulWidget {
  final MenuItem item;
  final int? animationIndex; // Optional index for staggered animation
  const MenuItemCard({Key? key, required this.item, this.animationIndex})
      : super(key: key);

  @override
  State<MenuItemCard> createState() => _MenuItemCardState();
}

class _MenuItemCardState extends State<MenuItemCard>
    with SingleTickerProviderStateMixin {
  bool _hovering = false;
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    // Staggered animation: delay based on index if provided
    final delay = Duration(milliseconds: 100 * (widget.animationIndex ?? 0));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(delay, () {
        if (mounted) _controller.forward();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale: _hovering ? 1.04 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: AnimatedPhysicalModel(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          elevation: _hovering ? 8 : 2,
          color: Colors.white,
          shadowColor: Colors.black,
          borderRadius: BorderRadius.circular(10.0),
          shape: BoxShape.rectangle,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: SlideTransition(
              position: _offsetAnimation,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: (widget.item.imageurl != null &&
                              widget.item.imageurl!.isNotEmpty)
                          ? Image.network(
                              widget.item.imageurl!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                return SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[300],
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey[600],
                                    size: 40,
                                  ),
                                );
                              },
                            )
                          : Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.fastfood,
                                color: Colors.grey[600],
                                size: 40,
                              ),
                            ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.item.amharic,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.item.english,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.item.section,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
