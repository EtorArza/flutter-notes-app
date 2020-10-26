import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../data/models.dart';

const collectionListName = 'ehahdugvbypgtuttjrvexksuehgpqmn';

class NotesDatabaseService {
  String path;

  NotesDatabaseService._();

  static final NotesDatabaseService db = NotesDatabaseService._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await init();
    return _database;
  }

  init() async {
    String path = await getDatabasesPath();
    path = join(path, 'notes.db');
    print("Opening database at path $path");

    return await openDatabase(path, version: 1, onCreate: (Database db, int version) async {
      String newCollectionName = fromCollectionNameToTableName("NewCollection");
      await db.execute('CREATE TABLE ' + collectionListName + ' (_id INTEGER PRIMARY KEY, collectionName TEXT, isOpen INTEGER);');
      await db.execute(
          'CREATE TABLE $newCollectionName (_id INTEGER PRIMARY KEY, originalContent TEXT, meaningContent TEXT, isImportant INTEGER, date TEXT, dueDate TEXT);');
      await db.transaction((transaction) {
        transaction.rawInsert('INSERT into ' + collectionListName + '(collectionName, isOpen) VALUES ($newCollectionName, "1");');
      });
    });
  }

  Future<String> whichTableIsOpen() async {
    final db = await database;
    List<Map> maps = await db.query(collectionListName, columns: ['_id', 'collectionName', 'isOpen'], limit: 1, orderBy: 'isOpen DESC');
    String openCollectionName = maps.first['collectionName'];
    return openCollectionName;
  }

  markCollectionAsOpen(String collectionName) async {
    print('markCollectionAsOpen(' + collectionName + ')');
    String tableName = fromCollectionNameToTableName(collectionName);
    final db = await database;
    await db.update(collectionListName, <String, int>{'isOpen': 0}, where: 'isOpen = ?', whereArgs: [1]);
    await db.update(collectionListName, <String, int>{'isOpen': 1}, where: 'collectionName = ?', whereArgs: [tableName]);
    print(await whichTableIsOpen() + ' is open in markCollectionAsOpen() after update');
    return;
  }

  Future<int> getNumberOfCollections() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM ' + collectionListName);
    final count = Sqflite.firstIntValue(result);
    return count;
  }

  createNewCollection(String collectionName) async {
    String tableName = fromCollectionNameToTableName(collectionName);
    final db = await database;
    print('Creating collection -> ' + collectionName);
    await db.execute('CREATE TABLE ' +
        tableName +
        ' (_id INTEGER PRIMARY KEY, originalContent TEXT, meaningContent TEXT, isImportant INTEGER, date TEXT, dueDate TEXT);');
    int id = await db.transaction((transaction) {
      transaction.rawInsert('INSERT into ' + collectionListName + '(collectionName, isOpen) VALUES ($tableName, "0");');
    });
    print('Table ' + tableName + 'added, transaction id: ' + id.toString());
    return;
  }

  void deleteCollection(String collectionName) async {
    final db = await database;
    String tableName = fromCollectionNameToTableName(collectionName);
    int numberOfCOllections = await getNumberOfCollections();
    print('numberOfCOllections = ' + numberOfCOllections.toString());
    db.execute('DROP TABLE ' + tableName);
    await db.rawDelete('DELETE FROM ' + collectionListName + ' WHERE collectionName = ?', [tableName]);
  }

  Future<List<String>> listOfCollectionNames() async {
    final db = await database;
    List<String> res = [];
    List<Map> maps = await db.query(collectionListName, columns: ['collectionName']);
    for (var item in maps) {
      res.add(fromTableNameToCollectionName(item['collectionName']));
    }
    return res;
  }

  Future<List<NotesModel>> getNotesFromCollection() async {
    String tablenName = await whichTableIsOpen();
    print('Table ' + tablenName + 'is open in getNotesFromCollection.');
    final db = await database;
    List<NotesModel> notesList = [];
    List<Map> maps = await db.query(tablenName, columns: ['_id', 'originalContent', 'meaningContent', 'isImportant', 'date', 'dueDate'], limit: 200);
    if (maps.length > 0) {
      maps.forEach((map) {
        notesList.add(NotesModel.fromMap(map));
      });
    }
    return notesList;
  }

  Future<NotesModel> getMostDueNoteFromDB() async {
    String tablenName = await whichTableIsOpen();
    final db = await database;
    NotesModel notesList;
    List<Map> maps = await db.query(tablenName,
        columns: ['_id', 'originalContent', 'meaningContent', 'isImportant', 'date', 'dueDate'], limit: 1, orderBy: 'dueDate');
    notesList = NotesModel.fromMap(maps.first);
    return notesList;
  }

  updateNoteInDB(NotesModel updatedNote) async {
    String collectionName = await whichTableIsOpen();
    final db = await database;
    await db.update(collectionName, updatedNote.toMap(), where: '_id = ?', whereArgs: [updatedNote.id]);
  }

  deleteNoteInDB(NotesModel noteToDelete) async {
    String collectionName = await whichTableIsOpen();
    final db = await database;
    await db.delete(collectionName, where: '_id = ?', whereArgs: [noteToDelete.id]);
    print('Note deleted');
  }

  Future<NotesModel> addNoteInDB(NotesModel newNote) async {
    String tablenName = await whichTableIsOpen();
    final db = await database;
    int id = await db.transaction((transaction) {
      transaction.rawInsert('INSERT into ' +
          tablenName +
          '(originalContent, meaningContent, isImportant, date, dueDate) VALUES ("${newNote.originalContent}", "${newNote.meaningContent}", "${newNote.isImportant == true ? 1 : 0}", "${newNote.date.toIso8601String()}", "${newNote.dueDate.toIso8601String()}");');
    });
    newNote.id = id;
    print('Note added into ' + tablenName + ': ${newNote.originalContent} ${newNote.meaningContent}');
    return newNote;
  }
}

// String fromCollectionNameToTableName(String collectionName) {
//   return '"' + collectionName + '"';
// }

// String fromTableNameToCollectionName(String collectionName) {
//   return collectionName; // remove _ from begining
// }

String scapeString = 'syde2w7acu4fu';

String fromCollectionNameToTableName(String collectionName) {
  String res = collectionName.replaceAll('"', '');
  return '"_' + res.replaceAll(' ', scapeString) + '"';
}

String fromTableNameToCollectionName(String collectionName) {
  String res = collectionName.replaceAll('"', '');
  res = res.replaceFirst('_', '');
  res = res.replaceAll(scapeString, ' ');
  return res;
}
