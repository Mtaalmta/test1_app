import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'item_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('inventory.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const doubleType = 'REAL NOT NULL';

    await db.execute('''
CREATE TABLE items (
  id $idType,
  name $textType,
  description TEXT,
  quantity $intType,
  purchasePrice $doubleType,
  sellingPrice $doubleType
)
''');
  }

  Future<Item> create(Item item) async {
    final db = await instance.database;
    await db.insert('items', item.toMap());
    return item;
  }

  Future<Item?> readItem(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      'items',
      columns: [
        'id',
        'name',
        'description',
        'quantity',
        'purchasePrice',
        'sellingPrice'
      ],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Item.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Item>> readAllItems() async {
    final db = await instance.database;
    const orderBy = 'name ASC';
    final result = await db.query('items', orderBy: orderBy);
    return result.map((json) => Item.fromMap(json)).toList();
  }

  Future<int> update(Item item) async {
    final db = await instance.database;
    return db.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await instance.database;
    return await db.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}