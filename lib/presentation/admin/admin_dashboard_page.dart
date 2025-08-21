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
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF179C5B),
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: Colors.brown[900],
            ),
            icon: const Icon(Icons.newspaper, color: Colors.brown),
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
              foregroundColor: Colors.brown[900],
            ),
            icon: const Icon(Icons.qr_code, color: Colors.brown),
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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
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
                        child: ListTile(
                          leading: item.imageurl.isNotEmpty
                              ? Image.network(item.imageurl,
                                  width: 50, height: 50, fit: BoxFit.cover)
                              : Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image, size: 24),
                                ),
                          title: Text(item.amharic + ' / ' + item.english),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showAddEditDialog(
                                    context, provider, section,
                                    item: item),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    _showDeleteDialog(context, provider, item),
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
    bool imageUploadSuccess = false;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(item == null ? 'Add Menu Item' : 'Edit Menu Item'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                              imageUploadSuccess = false;
                            });
                          } else {
                            setState(() {
                              selectedImage = picked;
                              errorMsg = null;
                              imageUploadSuccess = false;
                              uploadProgress = 0.0;
                            });
                            // Do NOT upload here. Only preview. Upload will happen on Add.
                          }
                        }
                      },
                      child: selectedImage != null
                          ? (kIsWeb
                              ? FutureBuilder<Uint8List>(
                                  future: selectedImage!.readAsBytes(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                            ConnectionState.done &&
                                        snapshot.hasData) {
                                      return Image.memory(snapshot.data!,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover);
                                    } else {
                                      return const SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: Center(
                                            child: CircularProgressIndicator()),
                                      );
                                    }
                                  },
                                )
                              : Image.file(
                                  // ignore: unnecessary_cast
                                  selectedImage as dynamic,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover))
                          : (imageurl.isNotEmpty
                              ? Image.network(imageurl,
                                  width: 100, height: 100, fit: BoxFit.cover)
                              : Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.camera_alt, size: 40),
                                )),
                    ),
                    if (errorMsg != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(errorMsg!,
                            style: const TextStyle(color: Colors.red)),
                      ),
                    if (imageUploadSuccess)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text('Image uploaded successfully!',
                            style: const TextStyle(color: Colors.green)),
                      ),
                    TextField(
                      controller: amharicController,
                      decoration: const InputDecoration(labelText: 'Amharic'),
                    ),
                    TextField(
                      controller: englishController,
                      decoration: const InputDecoration(labelText: 'English'),
                    ),
                    TextField(
                      controller: priceController,
                      decoration:
                          const InputDecoration(labelText: 'Price (AED)'),
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
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
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
                          imageUploadSuccess = false;
                        });
                        return;
                      }
                      finalImageurl = url;
                      setState(() {
                        uploadProgress = null;
                        imageUploadSuccess = true;
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
