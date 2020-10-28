import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../data/models.dart';

const String collectionListName = 'ehahdugvbypgtuttjrvexksuehgpqmn';

const String stringToReplaceLeftBracket = 'k5utzq5n5z3z';
const String stringToReplaceRightBracket = 'k2vuh93u937i';

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
      String newTableName = fromCollectionNameToTableName("NewCollection");
      await db.execute('CREATE TABLE ' + collectionListName + ' (_id INTEGER PRIMARY KEY, tableName TEXT, isOpen INTEGER);');
      await db.execute(
          'CREATE TABLE [$newTableName] (_id INTEGER PRIMARY KEY, originalContent TEXT, meaningContent TEXT, isImportant INTEGER, date TEXT, dueDate TEXT);');
      await db.transaction((transaction) {
        transaction.rawInsert('INSERT into ' + collectionListName + '(tableName, isOpen) VALUES ("$newTableName", "1");');
      });
    });
  }

  Future<String> whichTableIsOpen() async {
    final db = await database;
    List<Map> maps = await db.query(collectionListName, columns: ['_id', 'tableName', 'isOpen'], limit: 1, orderBy: 'isOpen DESC');
    String openTableName = maps.first['tableName'];
    return openTableName;
  }

  markCollectionAsOpen(String collectionName) async {
    print('markCollectionAsOpen(' + collectionName + ')');
    String tableName = fromCollectionNameToTableName(collectionName);
    final db = await database;
    await db.update(collectionListName, <String, int>{'isOpen': 0}, where: 'isOpen = ?', whereArgs: [1]);
    await db.update(collectionListName, <String, int>{'isOpen': 1}, where: 'tableName = ?', whereArgs: [tableName]);
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
    await db.execute('CREATE TABLE [' +
        tableName +
        '] (_id INTEGER PRIMARY KEY, originalContent TEXT, meaningContent TEXT, isImportant INTEGER, date TEXT, dueDate TEXT);');
    int id = await db.transaction((transaction) {
      transaction.rawInsert('INSERT into ' + collectionListName + '(tableName, isOpen) VALUES ("$tableName", "0");');
    });
    print('Table ' + tableName + 'added, transaction id: ' + id.toString());
    return;
  }

  renameCollection(String oldCollectionName, String newCollectionName) async {
    print("Renaming $oldCollectionName to $newCollectionName");
    String oldTableName = fromCollectionNameToTableName(oldCollectionName);
    String newTableName = fromCollectionNameToTableName(newCollectionName);
    if (oldTableName == newTableName) {
      return;
    }
    List<String> tableNames = await listOfTableNames();

    int alreadyExistCounter = 2;
    String candidateTableName = newTableName;

    while (tableNames.contains(candidateTableName)) {
      candidateTableName = newTableName + ' (' + alreadyExistCounter.toString() + ')';
      alreadyExistCounter += 1;
    }

    final db = await database;
    await db.execute('ALTER TABLE [$oldTableName] RENAME TO [$candidateTableName];');
    print(await listOfTableNames());
    await db.update(collectionListName, <String, String>{'tableName': '$candidateTableName'}, where: 'tableName = ?', whereArgs: [oldTableName]);
    print(await listOfTableNames());
    //await db.update(collectionListName, <String, int>{'isOpen': 1}, where: 'tableName = ?', whereArgs: [tableName]);

    return;
  }

  void deleteCollection(String collectionName) async {
    final db = await database;
    String tableName = fromCollectionNameToTableName(collectionName);
    int numberOfCOllections = await getNumberOfCollections();
    print('numberOfCOllections = ' + numberOfCOllections.toString());
    db.execute('DROP TABLE [' + tableName + ']');
    await db.rawDelete('DELETE FROM ' + collectionListName + ' WHERE tableName = ?', [tableName]);
  }

  Future<List<String>> listOfCollectionNames() async {
    final db = await database;
    List<String> res = [];
    List<Map> maps = await db.query(collectionListName, columns: ['tableName']);
    for (var item in maps) {
      res.add(fromTableNameToCollectionName(item['tableName']));
    }
    return res;
  }

  Future<List<String>> listOfTableNames() async {
    final db = await database;
    List<String> res = [];
    List<Map> maps = await db.query(collectionListName, columns: ['tableName']);
    for (var item in maps) {
      res.add(item['tableName']);
    }
    return res;
  }

  Future<List<NotesModel>> getNotesFromCollection() async {
    String tablenName = await whichTableIsOpen();
    print('Table ' + tablenName + 'is open in getNotesFromCollection.');
    final db = await database;
    List<NotesModel> notesList = [];
    List<Map> maps = await db.rawQuery('SELECT _id, originalContent, meaningContent, isImportant, date, dueDate FROM [$tablenName] LIMIT 200');
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
    String tableName = await whichTableIsOpen();
    final db = await database;
    await db.update(tableName, updatedNote.toMap(), where: '_id = ?', whereArgs: [updatedNote.id]);
  }

  deleteNoteInDB(NotesModel noteToDelete) async {
    String tableName = await whichTableIsOpen();
    final db = await database;
    await db.delete(tableName, where: '_id = ?', whereArgs: [noteToDelete.id]);
    print('Note deleted');
  }

  Future<NotesModel> addNoteInDB(NotesModel newNote) async {
    String tablenName = await whichTableIsOpen();
    final db = await database;
    int id = await db.transaction((transaction) {
      transaction.rawInsert('INSERT into [' +
          tablenName +
          '] (originalContent, meaningContent, isImportant, date, dueDate) VALUES ("${newNote.originalContent}", "${newNote.meaningContent}", "${newNote.isImportant == true ? 1 : 0}", "${newNote.date.toIso8601String()}", "${newNote.dueDate.toIso8601String()}");');
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

String fromCollectionNameToTableName(String collectionName) {
  String res = '_' + collectionName.trim();

  res = res.replaceAll('[', stringToReplaceLeftBracket);
  res = res.replaceAll(']', stringToReplaceRightBracket);
  print("$collectionName -> $res");
  return res;
}

String fromTableNameToCollectionName(String tableName) {
  String res = tableName.replaceFirst('_', '');

  res = res.replaceAll(stringToReplaceLeftBracket, '[');
  res = res.replaceAll(stringToReplaceRightBracket, ']');
  print("$tableName -> $res");
  return res;
}
