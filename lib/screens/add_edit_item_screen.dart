import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatters
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test1_app/data/item_model.dart';
import 'package:test1_app/providers/item_provider.dart';

// import 'package:image_picker/image_picker.dart'; // For image picking
// import 'dart:io'; // For File

class AddEditItemScreen extends ConsumerStatefulWidget {
  final Item? itemToEdit; // Null if adding a new item

  const AddEditItemScreen({super.key, this.itemToEdit});

  @override
  ConsumerState<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends ConsumerState<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _quantityController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _sellingPriceController;

  // File? _selectedImage; // For image picking

  bool get _isEditing => widget.itemToEdit != null;

  @override
  void initState() {
    super.initState();
    final item = widget.itemToEdit;
    _nameController = TextEditingController(text: item?.name ?? '');
    _descriptionController = TextEditingController(text: item?.description ?? '');
    _quantityController = TextEditingController(text: item?.quantity.toString() ?? '');
    _purchasePriceController = TextEditingController(
        text: item?.purchasePrice.toStringAsFixed(2) ?? '');
    _sellingPriceController = TextEditingController(
        text: item?.sellingPrice.toStringAsFixed(2) ?? '');
    // if (item?.imagePath != null) {
    //   _selectedImage = File(item!.imagePath!);
    // }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    super.dispose();
  }

  // Future<void> _pickImage() async {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text('Image picking not fully implemented.')),
  //   );
  // }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final name = _nameController.text;
      final description = _descriptionController.text;
      final quantity = int.tryParse(_quantityController.text) ?? 0;
      final purchasePrice = double.tryParse(_purchasePriceController.text) ?? 0.0;
      final sellingPrice = double.tryParse(_sellingPriceController.text) ?? 0.0;

      final itemNotifier = ref.read(itemListProvider.notifier);

      try {
        if (_isEditing) {
          final updatedItem = widget.itemToEdit!.copyWith(
            name: name,
            description: description,
            quantity: quantity,
            purchasePrice: purchasePrice,
            sellingPrice: sellingPrice,
          );
          await itemNotifier.updateItem(updatedItem);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${updatedItem.name} updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          final newItem = Item(
            name: name,
            description: description,
            quantity: quantity,
            purchasePrice: purchasePrice,
            sellingPrice: sellingPrice,
          );
          await itemNotifier.addItem(newItem);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${newItem.name} added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving item: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Item' : 'Add New Item'),
        backgroundColor: colorScheme.surfaceVariant,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Placeholder for image selection
              // Center(
              //   child: GestureDetector(
              //     onTap: _pickImage,
              //     child: CircleAvatar(
              //       radius: 50,
              //       backgroundColor: Colors.grey[300],
              //       backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
              //       child: _selectedImage == null ? Icon(Icons.camera_alt, size: 40, color: Colors.grey[700]) : null,
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 24.0),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Item Name*'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the item name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description (Optional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity*'),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the quantity';
                  }
                  if (int.tryParse(value) == null || int.parse(value) < 0) {
                    return 'Please enter a valid non-negative quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _purchasePriceController,
                      decoration: const InputDecoration(labelText: 'Purchase Price* (\$)'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter purchase price';
                        }
                        if (double.tryParse(value) == null || double.parse(value) < 0) {
                          return 'Enter a valid price';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _sellingPriceController,
                      decoration: const InputDecoration(labelText: 'Selling Price* (\$)'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter selling price';
                        }
                        if (double.tryParse(value) == null || double.parse(value) < 0) {
                          return 'Enter a valid price';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(_isEditing ? 'Update Item' : 'Add Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
