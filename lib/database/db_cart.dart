import 'dart:io';
import 'package:hostess/model/cart.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class MastersDatabaseProvider {
  MastersDatabaseProvider._();

  static final MastersDatabaseProvider db = MastersDatabaseProvider._();
  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await getDatabaseInstance();
    return _database;
  }

  Future<Database> getDatabaseInstance() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, "cart.db");
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE Cart ("
          "id INTEGER primary key AUTOINCREMENT,"
          "image TEXT,"
          "price INTEGER,"
          "title TEXT,"
          "amount TEXT,"
          "description TEXT"
          ")");
    });
  }

  addItemToDatabaseCart(Cart cart) async {
    final db = await database;
    var raw = await db.insert(
      "Cart",
      cart.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return raw;
  }

  Future<List<Cart>> getAllCart() async {
    final db = await database;
    var response = await db.query("Cart");
    List<Cart> list = response.map((c) => Cart.fromMap(c)).toList();
    return list;
  }

  Future calculateTotal() async {
    final db = await database;
    var result = await db.rawQuery("SELECT SUM(price) as Total FROM Cart");
    int value = result[0]["Total"];
    return value;
  }

  deleteItemWithId(int id) async {
    final db = await database;
    return db.delete("Cart", where: "id = ?", whereArgs: [id]);
  }

  deleteAllCart() async {
    final db = await database;
    db.delete("Cart");
  }
}
