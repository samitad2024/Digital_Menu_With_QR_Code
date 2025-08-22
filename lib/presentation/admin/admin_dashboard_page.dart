import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import '../../data/providers/menu_provider.dart';
import 'news_page.dart';
import '../common_widgets/qr_generator_widget.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> sections = [
    'Our Special',
    'Breakfast',
    'Lunch & Dinner',
    'Vege. & Fasting',
    'Drinks',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: sections.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MenuProvider>(context, listen: false).fetchMenu();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFF179C5B),
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.newspaper, color: Colors.white),
            label: const Text('News+'),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NewsPage(),
                ),
              );
              setState(() {}); // Refresh after returning from NewsPage
            },
          ),
          // QR Code button - placed next to News+
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.qr_code, color: Colors.white),
            label: const Text('QR'),
            onPressed: () async {
              await QrGeneratorWidget.show(context);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: sections.map((s) => Tab(text: s)).toList(),
        ),
      ),
      body: Consumer<MenuProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(
                child: Text(provider.error!,
                    style: const TextStyle(color: Colors.red)));
          }
          return TabBarView(
            controller: _tabController,
            children: sections.map((section) {
              final items = provider.itemsBySection[section] ?? [];
              return _SectionCRUD(
                section: section,
                items: items,
                provider: provider,
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _SectionCRUD extends StatelessWidget {
  final String section;
  final List<MenuItem> items;
  final MenuProvider provider;
  const _SectionCRUD(
      {required this.section, required this.items, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$section Menu',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF179C5B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _showAddEditDialog(context, provider, section),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('No items found.'))
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 0),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          leading: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[100],
                            ),
                            child: ClipOval(
                              child: item.imageurl.isNotEmpty
                                  ? Image.network(
                                      item.imageurl,
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[200],
                                          child: const Icon(
                                            Icons.broken_image,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      (loadingProgress
                                                              .expectedTotalBytes ??
                                                          1)
                                                  : null,
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : const Center(
                                      child: Icon(
                                      Icons.camera_alt,
                                      color: Colors.grey,
                                    )),
                            ),
                          ),
                          title: Text(
                            item.amharic + ' / ' + item.english,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle:
                              Text('AED ${item.price.toStringAsFixed(2)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Edit button: circular, subtle background, tooltip
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(24),
                                  onTap: () => _showAddEditDialog(
                                      context, provider, section,
                                      item: item),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.10),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.edit, // professional edit icon
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Delete button: circular red background
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(24),
                                  onTap: () => _showDeleteDialog(
                                      context, provider, item),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.10),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog(
      BuildContext context, MenuProvider provider, String section,
      {MenuItem? item}) {
    final amharicController = TextEditingController(text: item?.amharic ?? '');
    final englishController = TextEditingController(text: item?.english ?? '');
    final priceController =
        TextEditingController(text: item != null ? item.price.toString() : '');
    final imageurl = item?.imageurl ?? '';
  XFile? selectedImage;
  String? errorMsg;
  double? uploadProgress;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                item == null ? 'Add Menu Item' : 'Edit Menu Item',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              content: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Image preview (circular) with picker on tap
                      GestureDetector(
                        onTap: () async {
                          final picker = ImagePicker();
                          final picked =
                              await picker.pickImage(source: ImageSource.gallery);
                          if (picked != null) {
                            final bytes = await picked.length();
                            if (bytes > 1024 * 1024) {
                              setState(() {
                                errorMsg = 'Image must be less than 1MB';
                                selectedImage = null;
                              });
                            } else {
                              setState(() {
                                selectedImage = picked;
                                errorMsg = null;
                                uploadProgress = 0.0;
                              });
                              // preview only, upload on Add/Update
                            }
                          }
                        },
                        child: CircleAvatar(
                          radius: 44,
                          backgroundColor: Colors.grey[100],
                          child: ClipOval(
                            child: SizedBox(
                              width: 86,
                              height: 86,
                              child: selectedImage != null
                                  ? (kIsWeb
                                      ? FutureBuilder<Uint8List>(
                                          future: selectedImage!.readAsBytes(),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                    ConnectionState.done &&
                                                snapshot.hasData) {
                                              return Image.memory(snapshot.data!,
                                                  fit: BoxFit.cover);
                                            }
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          },
                                        )
                                      : Image.file(
                                          // ignore: unnecessary_cast
                                          selectedImage as dynamic,
                                          fit: BoxFit.cover,
                                        ))
                                  : (imageurl.isNotEmpty
                                      ? Image.network(
                                          imageurl,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Center(
                                                      child: Icon(
                                            Icons.broken_image,
                                            color: Colors.grey,
                                          )),
                                          loadingBuilder:
                                              (context, child, loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          },
                                        )
                                      : const Center(
                                          child: Icon(
                                          Icons.camera_alt,
                                          color: Colors.grey,
                                        ))),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (errorMsg != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(errorMsg!,
                              style: const TextStyle(color: Colors.red)),
                        ),
                      // Input fields
                      TextField(
                        controller: amharicController,
                        decoration: const InputDecoration(
                          labelText: 'Amharic',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: englishController,
                        decoration: const InputDecoration(
                          labelText: 'English',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price (AED)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      if (uploadProgress != null && uploadProgress! < 1.0)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: LinearProgressIndicator(value: uploadProgress),
                        ),
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF179C5B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    if (amharicController.text.isEmpty ||
                        englishController.text.isEmpty ||
                        priceController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('All fields are required!')));
                      return;
                    }
                    String finalImageurl = imageurl;
                    if (selectedImage != null) {
                      setState(() {
                        uploadProgress = 0.0;
                      });
                      final url = await provider.uploadImage(
                        selectedImage!,
                        onProgress: (progress) {
                          setState(() {
                            uploadProgress = progress;
                          });
                        },
                      );
                        if (url == null || !url.toString().startsWith('http')) {
                        setState(() {
                          errorMsg = 'Image upload failed. Please try again.';
                          uploadProgress = null;
                        });
                        return;
                      }
                      finalImageurl = url;
                      setState(() {
                        uploadProgress = null;
                      });
                    }
                    final newItem = MenuItem(
                      id: item?.id ?? '',
                      amharic: amharicController.text,
                      english: englishController.text,
                      price: double.tryParse(priceController.text) ?? 0.0,
                      section: section,
                      imageurl: finalImageurl,
                    );
                    if (item == null) {
                      await provider.addMenuItem(newItem);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Item added successfully!')));
                    } else {
                      await provider.updateMenuItem(newItem);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Item updated successfully!')));
                    }
                    Navigator.pop(context);
                  },
                  child: Text(item == null ? 'Add' : 'Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(
      BuildContext context, MenuProvider provider, MenuItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Confirmation'),
          content: Text(
              'Are you sure you want to delete "${item.amharic} / ${item.english}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await provider.deleteMenuItem(item);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Item deleted successfully!')));
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
