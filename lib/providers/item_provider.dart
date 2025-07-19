import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database_helper.dart';
import '../data/item_model.dart';

// Provider for the DatabaseHelper instance
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

// StateNotifier for managing the list of items
class ItemListNotifier extends StateNotifier<AsyncValue<List<Item>>> {
  final DatabaseHelper _dbHelper;

  ItemListNotifier(this._dbHelper) : super(const AsyncValue.loading()) {
    fetchItems();
  }

  Future<void> fetchItems() async {
    state = const AsyncValue.loading();
    try {
      final items = await _dbHelper.readAllItems();
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      // You could also log the error to a service or show a user-friendly message
      print("Error fetching items: $e");
    }
  }

  Future<void> addItem(Item item) async {
    // Optimistic update: Add to current state immediately for better UX
    // final previousState = state;
    // state.whenData((items) => state = AsyncValue.data([...items, item]));

    try {
      await _dbHelper.create(item);
      await fetchItems(); // Refresh the list from DB to ensure consistency
    } catch (e, st) {
      // If error, revert to previous state or set error state
      // state = previousState;
      state = AsyncValue.error("Failed to add item: $e", st);
      print("Error adding item: $e");
      // Potentially rethrow or handle in UI
    }
  }

  Future<void> updateItem(Item item) async {
    try {
      await _dbHelper.update(item);
      await fetchItems(); // Refresh the list
    } catch (e, st) {
      state = AsyncValue.error("Failed to update item: $e", st);
      print("Error updating item: $e");
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _dbHelper.delete(id);
      await fetchItems(); // Refresh the list
    } catch (e, st) {
      state = AsyncValue.error("Failed to delete item: $e", st);
      print("Error deleting item: $e");
    }
  }

  // Example: Update quantity for a sale or purchase
  Future<void> updateItemQuantity(String itemId, int changeInQuantity) async {
    try {
      final item = await _dbHelper.readItem(itemId);
      if (item != null) {
        final updatedQuantity = item.quantity + changeInQuantity;
        if (updatedQuantity < 0) {
          // Or handle this as a specific error/validation message in UI
          throw Exception("Cannot have negative stock.");
        }
        final updatedItem = item.copyWith(quantity: updatedQuantity);
        await _dbHelper.update(updatedItem);
        await fetchItems();
      } else {
        throw Exception("Item not found for quantity update.");
      }
    } catch (e, st) {
      // It's good to propagate the error or a user-friendly version of it
      // so the UI can react, e.g., show a SnackBar.
      state = AsyncValue.error("Failed to update quantity: $e", st);
      print("Error updating item quantity: $e");
      // Rethrow if you want the calling UI to handle it specifically
      // throw;
    }
  }
}

// The provider for the ItemListNotifier
final itemListProvider = StateNotifierProvider<ItemListNotifier,
    AsyncValue<List<Item>>>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return ItemListNotifier(dbHelper);
});

// Provider for a single item, useful for detail screens or edit screens
// This could fetch the item when needed or be derived from the itemListProvider
final singleItemProvider = FutureProvider.family<Item?, String>((ref,
    itemId) async {
  final dbHelper = ref.watch(databaseHelperProvider);
  return dbHelper.readItem(itemId);
});