import 'package:flutter/material.dart';
import '../../../domain/entities/menu_item.dart';

class MenuItemCard extends StatefulWidget {
  final MenuItem item;
  final int? animationIndex; // Optional index for staggered animation
  final VoidCallback? onDelete;
  const MenuItemCard({Key? key, required this.item, this.animationIndex, this.onDelete})
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
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Stack(
        children: [
          AnimatedScale(
            scale: _hovering ? 1.04 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: AnimatedPhysicalModel(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              elevation: _hovering ? 10 : 3,
              color: Colors.white,
              shadowColor: Colors.black.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16.0),
              shape: BoxShape.rectangle,
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: SlideTransition(
                  position: _offsetAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 12.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: (widget.item.imageurl != null &&
                                  widget.item.imageurl!.isNotEmpty)
                              ? Image.network(
                                  widget.item.imageurl!,
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    }
                                    return SizedBox(
                                      width: 90,
                                      height: 90,
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
                                      width: 90,
                                      height: 90,
                                      color: Colors.grey.withOpacity(0.15),
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey,
                                        size: 44,
                                      ), 
                                    );
                                  },
                                )
                              : Container(
                                  width: 90,
                                  height: 90,
                                  color: Colors.grey.withOpacity(0.15),
                                  child: Icon(
                                    Icons.fastfood,
                                    color: Colors.grey,
                                    size: 44,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.item.amharic,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.item.english,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.item.section,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Admin delete button (top right corner)
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: Icon(Icons.delete, color: Colors.redAccent, size: 24),
              tooltip: 'Delete menu item',
              onPressed: widget.onDelete,
            ),
          ),
        ],
      ),
    );
  }
  }

