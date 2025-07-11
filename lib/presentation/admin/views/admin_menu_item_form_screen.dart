import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import '../../../data/providers/menu_provider.dart';
import '../../../domain/entities/menu_item.dart'
    as entity; // Use alias for entity

class AdminMenuItemFormScreen extends StatefulWidget {
  const AdminMenuItemFormScreen({Key? key}) : super(key: key);

  @override
  State<AdminMenuItemFormScreen> createState() =>
      _AdminMenuItemFormScreenState();
}

class _AdminMenuItemFormScreenState extends State<AdminMenuItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _amharic, _english, _imageurl, _uploadError;
  double? _price;
  double _uploadProgress = 0.0;
  bool _uploading = false;
  String? _section; // Add section selection
  bool _adding = false; // Prevent repeated add
  XFile? _imageFile; // Store picked image file

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // If editing, initialize fields (ensure type safety)
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is entity.MenuItem) {
      _amharic = args.amharic;
      _english = args.english;
      _price = args.price;
      _section = args.section;
      _imageurl = args.imageurl;
    }
  }

  // Helper to check for duplicate items in the same section
  bool _isDuplicate(MenuProvider menuProvider) {
    final section = _section ?? '';
    final items = menuProvider.itemsBySection[section] ?? [];
    return items.any((item) =>
        item.amharic == (_amharic ?? '') &&
        item.english == (_english ?? '') &&
        // Only check imageurl for duplication if an image has been selected
        (item.imageurl == (_imageurl ?? '') &&
            _imageurl != null &&
            _imageurl!.isNotEmpty));
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() {
      _imageFile = picked;
      _imageurl = null; // Reset URL if new image picked
      _uploadError = null;
    });
  }

  void _save() async {
    // Validate form fields first (excluding image for initial check)
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    // Check for image presence before saving
    if (_imageFile == null && (_imageurl == null || _imageurl!.isEmpty)) {
      // Show the pop-out screen for image required error
      showDialog(
        context: context,
        // barrierDismissible: true allows the user to tap outside to close,
        // but we want it to close automatically after 2 seconds.
        // So, we'll manually pop it after the delay.
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          content: const Text('Image is required to add an item.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Manually close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );

      // Dismiss the dialog automatically after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        // Check if the dialog context is still valid and the dialog is open
        // Using `mounted` for the widget itself is not enough for the dialog context.
        // It's safer to pop using `rootNavigator: true` if you're not sure if it's the current context.
        if (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }
      });
      return; // Stop the save process if image is missing
    }

    // Prevent repeated addition if already in progress
    if (_adding) return;

    _formKey.currentState?.save(); // Save form fields if image is present

    final menuProvider = Provider.of<MenuProvider>(context, listen: false);

    if (_isDuplicate(menuProvider)) {
      setState(() {
        _uploadError =
            'Duplicate item in this section!'; // Using _uploadError for general errors
      });
      return;
    }

    setState(() {
      _adding = true;
      _uploadError = null; // Clear any general errors before adding
    });

    try {
      // Upload image if not already uploaded
      if (_imageFile != null && (_imageurl == null || _imageurl!.isEmpty)) {
        setState(() {
          _uploading = true;
        });
        final url = await menuProvider.uploadImage(
          _imageFile!,
          onProgress: (progress) {
            setState(() {
              _uploadProgress = progress;
            });
          },
        );
        setState(() {
          _uploading = false;
        });
        if (url != null && !url.startsWith('Image must be')) {
          _imageurl = url;
        } else {
          setState(() {
            _uploadError = url ?? 'Image upload failed. Please try again.';
          });
          return;
        }
      }
      await menuProvider.addMenuItem(
        MenuItem(
          id: '', // ID will be generated by the backend/provider
          amharic: _amharic ?? '',
          english: _english ?? '',
          price: _price ?? 0.0,
          section: _section ?? '',
          imageurl: _imageurl ?? '',
        ),
      );
      // Item added successfully, navigate back
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      // Handle potential errors during addMenuItem (e.g., network issues)
      setState(() {
        _uploadError = 'Failed to add item: ${e.toString()}';
      });
    } finally {
      setState(() {
        _adding = false;
        _uploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);
    // If you ever initialize _price from a MenuItem, use priceToString(item.price)
    // Example: _price = priceToString(item.price);
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Add Menu Item',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                const SizedBox(height: 16),
                // Section dropdown
                DropdownButtonFormField<String>(
                  value: _section,
                  items: [
                    const DropdownMenuItem(
                        value: '',
                        child:
                            Text('Uncategorized')), // Option for uncategorized
                    ...menuProvider.itemsBySection.keys
                        .where((s) => s
                            .isNotEmpty) // Exclude empty string if already present in keys
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s),
                            ))
                        .toList(),
                  ],
                  onChanged: (v) => setState(() {
                    _section = v;
                    _uploadError = null; // Clear error on section change
                  }),
                  decoration: const InputDecoration(labelText: 'Section'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Select section' : null,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _uploading ? null : _pickImage,
                  child: (_imageFile == null &&
                          (_imageurl == null || _imageurl!.isEmpty))
                      ? Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.camera_alt,
                              size: 48, color: Colors.black54),
                        )
                      : _imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: kIsWeb
                                  ? FutureBuilder<Uint8List>(
                                      future: _imageFile!.readAsBytes(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                                ConnectionState.done &&
                                            snapshot.hasData) {
                                          return Image.memory(
                                            snapshot.data!,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          );
                                        } else {
                                          return const SizedBox(
                                            width: 100,
                                            height: 100,
                                            child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2)),
                                          );
                                        }
                                      },
                                    )
                                  : Image.file(
                                      xFileToFile(_imageFile!),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _imageurl!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.error,
                                        color: Colors.red),
                                  );
                                },
                              ),
                            ),
                ),
                if (_uploading)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: LinearProgressIndicator(value: _uploadProgress),
                  ),
                if (_uploadError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      _uploadError!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Amharic'),
                  onChanged: (v) => setState(() {
                    _amharic = v;
                    _uploadError = null; // Clear error on text change
                  }),
                  onSaved: (v) => _amharic = v,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'English'),
                  onChanged: (v) => setState(() {
                    _english = v;
                    _uploadError = null; // Clear error on text change
                  }),
                  onSaved: (v) => _english = v,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Price (AED)'),
                  keyboardType: TextInputType.number,
                  initialValue: _price != null ? _price.toString() : '',
                  onChanged: (v) => setState(() {
                    _price = double.tryParse(v) ?? 0.0;
                    _uploadError = null;
                  }),
                  onSaved: (v) => _price = double.tryParse(v ?? '') ?? 0.0,
                  validator: (v) => v == null || v.isEmpty
                      ? 'Required'
                      : (double.tryParse(v) == null
                          ? 'Enter a valid number'
                          : null),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _uploading || _adding
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _uploading || _adding
                          ? null
                          : () {
                              _save();
                            },
                      autofocus: false,
                      focusNode: AlwaysDisabledFocusNode(),
                      child: _adding
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Add this class at the bottom of your file:
class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
  @override
  void requestFocus([FocusNode? node]) {}
}

// Helper for converting XFile to File (for non-web platforms)
File xFileToFile(XFile file) {
  return File(file.path);
}
