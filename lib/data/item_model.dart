import 'package:uuid/uuid.dart';

var uuid = Uuid();

class Item {
  final String id;
  String name;
  String description;
  int quantity;
  double purchasePrice;
  double sellingPrice;

  // String? imagePath; // For simplicity, omitting image handling in this core example

  Item({
    String? id, // Make id optional for creation
    required this.name,
    this.description = '',
    required this.quantity,
    required this.purchasePrice,
    required this.sellingPrice,
    // this.imagePath,
  }) : id = id ?? uuid.v4(); // Generate ID if not provided

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'quantity': quantity,
      'purchasePrice': purchasePrice,
      'sellingPrice': sellingPrice,
      // 'imagePath': imagePath,
    };
  }

  static Item fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      quantity: map['quantity'],
      purchasePrice: (map['purchasePrice'] as num).toDouble(),
      sellingPrice: (map['sellingPrice'] as num).toDouble(),
      // imagePath: map['imagePath'],
    );
  }

  Item copyWith({
    String? id,
    String? name,
    String? description,
    int? quantity,
    double? purchasePrice,
    double? sellingPrice,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
    );
  }
}