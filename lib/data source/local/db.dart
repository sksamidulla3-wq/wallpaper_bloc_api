import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDataBase {
  AppDataBase._();

  static final AppDataBase instance = AppDataBase._();
  Database? _database;

  static final String tableName = "wallpaper";
  static final String colId = "id";
  static final String searchData = "searchData";
  static final String colCount = "count";

  Future<Database> initDb() async {
    var docDirectory = await getApplicationDocumentsDirectory();
    var dbPath = join(docDirectory.path, "wallpaper.db");
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) {
        db.execute(
          "CREATE TABLE $tableName( $colId INTEGER PRIMARY KEY AUTOINCREMENT, $searchData TEXT UNIQUE, $colCount INTEGER DEFAULT 1 )",
        );
      },
    );
  }

  Future<Database> getDb() async {
    if (_database != null) {
      return _database!;
    } else {
      _database = await initDb();
      return _database!;
    }
  }

  Future<int> insertData(String searchData) async {
    var db = await getDb();
    var res = await db.insert(tableName, {searchData: searchData});
    return res;
  }

  Future<List<Map<String, dynamic>>> getData() async {
    var db = await getDb();
    var res = await db.query(tableName);
    return res;
  }
}
