import 'package:notes_sqflite/Models/notes_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io' as io;

class DBHelper {
  static Database? _db;
  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDatabase();
    }
    return null;
  }

  initDatabase() async {
    io.Directory documentDirectory = await getApplicationSupportDirectory();
    String path = join(documentDirectory.path, 'note.db');
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE note (id INTEGER PRIMARY KEY , title TEXT, desc TEXT) ');
  }

  Future<void> insert(Note note) async {
    var dbClient = await db;
    await dbClient!.insert(
      'note',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Note>> getNoteList() async {
    var dbClient = await db;
    final List<Map<String, dynamic>> queryResult =
        await dbClient!.query('note');
    return queryResult.map((e) => Note.fromMap(e)).toList();
  }

  Future<int> updateQuantity(Note note) async {
    var dbClient = await db;
    return await dbClient!
        .update('note', note.toMap(), where: 'id = ?', whereArgs: [note.id]);
  }

  Future<int?> deleteItem(int? id) async {
    var dbClient = await db;
    return await dbClient!.delete('note', where: 'id = ?', whereArgs: [id]);
  }
}
