import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test1_app/data/item_model.dart';
import 'package:test1_app/providers/item_provider.dart';
import 'package:test1_app/screens/add_edit_item_screen.dart';
// import 'package:inventory_app/screens/item_detail_screen.dart'; // You'll create this

class ItemListScreen extends ConsumerWidget {
  const ItemListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemListAsync = ref.watch(itemListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Items'),
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .primaryContainer,
        // actions: [
        //   IconButton(icon: Icon(Icons.search), onPressed: () { /* TODO: Implement Search */ }),
        // ],
      ),
      body: itemListAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'No items yet. Tap + to add one!',
                style: TextStyle(fontSize: 18),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ItemCard(
                  item: item); // Using a separate widget for the card
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error loading items: $error'),
                  ElevatedButton(
                    onPressed: () => ref.refresh(itemListProvider),
                    // Manual refresh
                    child: const Text('Retry'),
                  )
                ],
              ),
            ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditItemScreen()),
          );
        },
        label: const Text('Add Item'),
        icon: const Icon(Icons.add),
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .tertiaryContainer,
        foregroundColor: Theme
            .of(context)
            .colorScheme
            .onTertiaryContainer,
      ),
    );
  }
}

// Optional: Separate ItemCard widget for better organization
class ItemCard extends ConsumerWidget {
  final Item item;

  const ItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme
        .of(context)
        .colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        // leading: item.imagePath != null
        //     ? Image.file(File(item.imagePath!), width: 50, height: 50, fit: BoxFit.cover)
        //     : CircleAvatar(child: Icon(Icons.inventory_2_outlined), backgroundColor: colorScheme.secondaryContainer),
        leading: CircleAvatar(
          backgroundColor: colorScheme.secondaryContainer,
          foregroundColor: colorScheme.onSecondaryContainer,
          child: Text(item.name.isNotEmpty ? item.name[0].toUpperCase() : "?"),
        ),
        title: Text(item.name, style: Theme
            .of(context)
            .textTheme
            .titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Qty: ${item.quantity} | Price: \$${item.sellingPrice
                .toStringAsFixed(2)}'),
            if (item.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(item.description, maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit_outlined, color: colorScheme.primary),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditItemScreen(itemToEdit: item),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: colorScheme.error),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) =>
                      AlertDialog(
                        title: const Text('Delete Item?'),
                        content: Text(
                            'Are you sure you want to delete "${item.name}"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Delete'),
                            style: FilledButton.styleFrom(
                                backgroundColor: colorScheme.error),
                          ),
                        ],
                      ),
                );
                if (confirm == true) {
                  try {
                    await ref.read(itemListProvider.notifier).deleteItem(
                        item.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${item.name} deleted'),
                          backgroundColor: Colors.green),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete: $e'),
                          backgroundColor: colorScheme.error),
                    );
                  }
                }
              },
            ),
          ],
        ),
        onTap: () {
          // Navigate to ItemDetailScreen (You'll need to create this screen)
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => ItemDetailScreen(itemId: item.id)),
          // );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(
                'Tapped on ${item.name}. Detail screen not implemented.')),
          );
        },
      ),
    );
  }
}