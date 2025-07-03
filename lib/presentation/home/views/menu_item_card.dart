import 'package:flutter/material.dart';
import '../../../domain/entities/menu_item.dart'; // Adjust path if needed based on your project structure

class MenuItemCard extends StatelessWidget {
  final MenuItem item;

  const MenuItemCard({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      // Added some styling for better visual appeal
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: ListTile(
        leading: ClipRRect(
          // ClipRRect helps round the image corners
          borderRadius: BorderRadius.circular(8.0),
          child: (item.imageUrl != null && item.imageUrl!.isNotEmpty)
              ? Image.network(
                  item.imageUrl!, // Use the Firebase Storage URL
                  width: 60, // Slightly increased size for better visibility
                  height: 60,
                  fit: BoxFit.cover, // Ensure image fills the space
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return SizedBox(
                      width: 60,
                      height: 60,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null, // Value will be null for indeterminate progress
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    // Show a fallback icon/image if the network image fails to load
                    // Useful for debugging: print('Error loading image for ${item.name}: $error');
                    return Container(
                      width: 60,
                      height: 60,
                      color: Colors
                          .grey[300], // Light grey background for placeholder
                      child: Icon(
                        Icons.image_not_supported, // Icon for broken image
                        color: Colors.grey[600],
                        size: 30, // Adjust icon size
                      ),
                    );
                  },
                )
              : Container(
                  // Placeholder if imageUrl is null or empty
                  width: 60,
                  height: 60,
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.fastfood, // Generic icon for menu item
                    color: Colors.grey[600],
                    size: 30,
                  ),
                ),
        ),
        title: Text(item.name),
        // Ensure description handles null safely
        subtitle: Text(item.description ?? 'No description provided.'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${_formatPrice(item.price)} AED',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        // You might want to add an onTap handler for navigation or details
        // onTap: () {
        //   // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => MenuItemDetailPage(item: item)));
        //   print('Tapped on ${item.name}');
        // },
      ),
    );
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '';
    String priceStr = price.toString().replaceAll('\$', '').replaceAll(' ', ''); // Remove $ and spaces
    if (priceStr.contains('.')) {
      double? d = double.tryParse(priceStr);
      if (d != null && d == d.roundToDouble()) {
        return d.toInt().toString();
      }
      return d?.toString() ?? priceStr;
    }
    return priceStr;
  }
}
