import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../data/models.dart';

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
    print("Entered path $path");

    return await openDatabase(path, version: 1, onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE Notes (_id INTEGER PRIMARY KEY, originalContent TEXT, meaningContent TEXT, isImportant INTEGER, date TEXT, dueDate TEXT);');
      print('New table created at $path');
    });
  }

  Future<List<NotesModel>> getNotesFromDB() async {
    final db = await database;
    List<NotesModel> notesList = [];
    List<Map> maps = await db.query('Notes', columns: ['_id', 'originalContent', 'meaningContent', 'isImportant', 'date', 'dueDate'], limit: 200);
    if (maps.length > 0) {
      maps.forEach((map) {
        notesList.add(NotesModel.fromMap(map));
      });
    }
    return notesList;
  }

  Future<NotesModel> getMostDueNoteFromDB() async {
    final db = await database;
    NotesModel notesList;
    List<Map> maps = await db.query('Notes',
        columns: ['_id', 'originalContent', 'meaningContent', 'isImportant', 'date', 'dueDate'], limit: 1, orderBy: 'dueDate');
    notesList = NotesModel.fromMap(maps.first);
    return notesList;
  }

  updateNoteInDB(NotesModel updatedNote) async {
    final db = await database;
    await db.update('Notes', updatedNote.toMap(), where: '_id = ?', whereArgs: [updatedNote.id]);
  }

  deleteNoteInDB(NotesModel noteToDelete) async {
    final db = await database;
    await db.delete('Notes', where: '_id = ?', whereArgs: [noteToDelete.id]);
    print('Note deleted');
  }

  Future<NotesModel> addNoteInDB(NotesModel newNote) async {
    final db = await database;
    int id = await db.transaction((transaction) {
      transaction.rawInsert(
          'INSERT into Notes(originalContent, meaningContent, isImportant, date, dueDate) VALUES ("${newNote.originalContent}", "${newNote.meaningContent}", "${newNote.isImportant == true ? 1 : 0}", "${newNote.date.toIso8601String()}", "${newNote.dueDate.toIso8601String()}");');
    });
    newNote.id = id;
    print('Note added: ${newNote.originalContent} ${newNote.meaningContent}');
    return newNote;
  }
}
