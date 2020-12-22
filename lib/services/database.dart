import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../data/models.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share/share.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:flutter/material.dart';
import '../screens/settings.dart';

const String collectionListName = 'ehahdugvbypgtuttjrvexksuehgpqmn';

const String stringToReplaceLeftBracket = 'k5utzq5n5z3z';
const String stringToReplaceRightBracket = 'k2vuh93u937i';

const String extensionForNoteCard = '.notecard';
const String extensionForCollection = '.collection';

const String fieldDelimiter = 'WhtSfXqwEBD9GfG4U87*3*J5uxPbtG';
const String fieldDelimiter2 = 'vhtSfXqwEBD9GfD4U87*3*J5uxPbt3F';
const String fieldDelimiter3 = 'xhtSfXqwEBD9Gfr4U87*3*J5uxPbt3M';
const String defaultColectionName = 'New Collection';

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
      String newTableName = fromCollectionNameToTableName(defaultColectionName);
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

  Future<String> whichCollectionIsOpen() async {
    String res = await whichTableIsOpen();
    res = fromTableNameToCollectionName(res);
    return res;
  }

  markCollectionAsOpen(String collectionName) async {
    String tableName = fromCollectionNameToTableName(collectionName);
    final db = await database;
    await db.update(collectionListName, <String, int>{'isOpen': 0}, where: 'isOpen = ?', whereArgs: [1]);
    await db.update(collectionListName, <String, int>{'isOpen': 1}, where: 'tableName = ?', whereArgs: [tableName]);
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

    List<String> tableNames = await listOfTableNames();
    tableNames = tableNames.map((item) => item.toUpperCase()).toList();
    int alreadyExistCounter = 2;
    String candidateTableName = tableName;

    while (tableNames.contains(candidateTableName.toUpperCase())) {
      candidateTableName = tableName + ' (' + alreadyExistCounter.toString() + ')';
      alreadyExistCounter += 1;
    }

    await db.execute('CREATE TABLE [' +
        candidateTableName +
        '] (_id INTEGER PRIMARY KEY, originalContent TEXT, meaningContent TEXT, isImportant INTEGER, date TEXT, dueDate TEXT);');
    int id = await db.transaction((transaction) {
      transaction.rawInsert('INSERT into ' + collectionListName + '(tableName, isOpen) VALUES ("$candidateTableName", "0");');
    });
    return;
  }

  renameCollection(String oldCollectionName, String newCollectionName) async {
    String oldTableName = fromCollectionNameToTableName(oldCollectionName);
    String newTableName = fromCollectionNameToTableName(newCollectionName);
    if (oldTableName == newTableName) {
      return;
    }
    List<String> tableNames = await listOfTableNames();
    tableNames = tableNames.map((item) => item.toUpperCase()).toList();

    int alreadyExistCounter = 2;
    String candidateTableName = newTableName;

    while (tableNames.contains(candidateTableName.toUpperCase())) {
      candidateTableName = newTableName + ' (' + alreadyExistCounter.toString() + ')';
      alreadyExistCounter += 1;
    }

    final db = await database;
    await db.execute('ALTER TABLE [$oldTableName] RENAME TO [$candidateTableName];');
    await db.update(collectionListName, <String, String>{'tableName': '$candidateTableName'}, where: 'tableName = ?', whereArgs: [oldTableName]);
    //await db.update(collectionListName, <String, int>{'isOpen': 1}, where: 'tableName = ?', whereArgs: [tableName]);

    return;
  }

  void deleteCollection(String collectionName) async {
    final db = await database;
    String tableName = fromCollectionNameToTableName(collectionName);
    int numberOfCOllections = await getNumberOfCollections();
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
    String tableName = await whichTableIsOpen();
    final db = await database;
    List<NotesModel> notesList = [];
    List<Map> maps = await db.rawQuery('SELECT _id, originalContent, meaningContent, isImportant, date, dueDate FROM [$tableName] LIMIT 5000');
    if (maps.length > 0) {
      maps.forEach((map) {
        notesList.add(NotesModel.fromMap(map));
      });
    }
    return notesList;
  }

  Future<NotesModel> getMostDueNoteFromDB() async {
    String tableName = await whichTableIsOpen();
    final db = await database;
    NotesModel notesList;
    List<Map> maps = await db.query('[' + tableName + ']',
        columns: ['_id', 'originalContent', 'meaningContent', 'isImportant', 'date', 'dueDate'], limit: 1, orderBy: 'dueDate');
    notesList = NotesModel.fromMap(maps.first);
    return notesList;
  }

  Future<int> getNumberOfSecondsDueOfSecondNote() async {
    String tableName = await whichTableIsOpen();
    final db = await database;
    NotesModel notesList;
    List<Map> maps = await db.query('[' + tableName + ']',
        columns: ['_id', 'originalContent', 'meaningContent', 'isImportant', 'date', 'dueDate'], limit: 1, orderBy: 'dueDate');

    DateTime res;
    if (maps.length == 1) {
      res = DateTime.now();
    } else {
      res = NotesModel.fromMap(maps[1]).dueDate;
    }
    return res.difference(DateTime.now()).inMilliseconds;
  }

  updateNoteInDB(NotesModel updatedNote) async {
    String tableName = await whichTableIsOpen();
    final db = await database;
    await db.update('[' + tableName + ']', updatedNote.toMap(), where: '_id = ?', whereArgs: [updatedNote.id]);
  }

  deleteNoteInDB(NotesModel noteToDelete) async {
    String tableName = await whichTableIsOpen();
    final db = await database;
    await db.delete('[' + tableName + ']', where: '_id = ?', whereArgs: [noteToDelete.id]);
  }

  Future<NotesModel> addNoteInDB(NotesModel newNote) async {
    String tableName = await whichTableIsOpen();
    final db = await database;
    int id = await db.transaction((transaction) {
      transaction.rawInsert('INSERT into [' +
          tableName +
          '] (originalContent, meaningContent, isImportant, date, dueDate) VALUES ("${newNote.originalContent}", "${newNote.meaningContent}", "${newNote.isImportant == true ? 1 : 0}", "${newNote.date.toIso8601String()}", "${newNote.dueDate.toIso8601String()}");');
    });
    newNote.id = id;
    return newNote;
  }

  Future<bool> isCollectionDue(String collectionName) async {
    String tableName = fromCollectionNameToTableName(collectionName);
    final db = await database;
    NotesModel notesList;
    List<Map> maps = await db.query('[' + tableName + ']',
        columns: ['_id', 'originalContent', 'meaningContent', 'isImportant', 'date', 'dueDate'], limit: 1, orderBy: 'dueDate');

    if (maps.length == 0) {
      return false;
    }

    notesList = NotesModel.fromMap(maps.first);
    return notesList.dueDate.difference(DateTime.now()).inSeconds <= 0;
  }

  Future<List<bool>> listOfCollectionsAreTheyDue(List<String> fetchedListOfCollectionNames) async {
    if (fetchedListOfCollectionNames.length == 0) {
      return [];
    }

    final listOfFutures = fetchedListOfCollectionNames.map((element) {
      return isCollectionDue(element);
    }).toList();

    return Future.wait(listOfFutures);
  }

  Future<void> backupEntireDB() async {
    List<String> allCollectionNames = await listOfCollectionNames();
    String stringToBeSaved = '';
    final db = await database;
    for (var collectionName in allCollectionNames) {
      List<NotesModel> notesList = [];
      String tableName = fromCollectionNameToTableName(collectionName);
      List<Map> maps = await db.rawQuery('SELECT _id, originalContent, meaningContent, isImportant, date, dueDate FROM [$tableName]');
      if (maps.length > 0) {
        maps.forEach((map) {
          notesList.add(NotesModel.fromMap(map));
        });
      }
      stringToBeSaved += collectionName + fieldDelimiter3;
      stringToBeSaved += fromListOfNotesModelToString(notesList) + fieldDelimiter3;
    }
    String filename = 'backup_' + DateTime.now().toIso8601String() + '.AppNameDB';
    final file = await getLocalFile(filename);

    await file.writeAsString(stringToBeSaved);

    Share.shareFiles([file.path], text: 'AppName backup ' + DateTime.now().toIso8601String());
  }

  Future<void> restoreBackup(SettingsPageState settingsStatePage, BuildContext context) async {
    FilePickerResult result = await FilePicker.platform.pickFiles(allowMultiple: false, allowedExtensions: ["AppNameDB"], type: FileType.custom);

    // reset the database
    String path = await getDatabasesPath();
    path = join(path, 'notes.db');

    // TODO: properly handle delete previous DB and check for file integrity before backup
    // await deleteDatabase(path);
    // _database = null;
    final db = await database;

    int nCollections = await getNumberOfCollections();

    if (result != null) {
      bool isBackupBeingRestored = true;

      List<String> listOfCurrentCollections = await listOfCollectionNames();

      settingsStatePage.showProgressBar();

      for (var collectionName in listOfCurrentCollections) {
        await deleteCollection(collectionName);
      }

      String filePath = result.files.first.path;
      if (result.files.first.path.split('.').last == 'AppNameDB') {
        String readString = await File(filePath).readAsString();

        List<String> listOfCollectionStringsAndNames = readString.split(fieldDelimiter3);

        Widget linearProgress = LinearProgressIndicator(value: 0.0);
        bool popProgress = false;

        for (var i = 0; i < listOfCollectionStringsAndNames.length - 1; i += 2) {
          settingsStatePage.setBackupProgress(i.toDouble() / listOfCollectionStringsAndNames.length.toDouble());

          String collectionName = listOfCollectionStringsAndNames[i];
          String collectionStringListCards = listOfCollectionStringsAndNames[i + 1];
          List<NotesModel> listReadNotes = fromStringToListOfNotesModel(collectionStringListCards);
          await createNewCollection(collectionName);
          await markCollectionAsOpen(collectionName);

          double currentProgress = i.toDouble() / listOfCollectionStringsAndNames.length.toDouble();
          int noteIndex = 1;
          int nNotes = listReadNotes.length;
          for (var readNote in listReadNotes) {
            noteIndex++;
            await NotesDatabaseService.db.addNoteInDB(readNote);
            if (noteIndex % 50 == 0) {
              currentProgress += 1.toDouble() / listOfCollectionStringsAndNames.length.toDouble() / nNotes.toDouble() * 50.toDouble();
              settingsStatePage.setBackupProgress(currentProgress);
            }
          }
        }
        settingsStatePage.setBackupProgress(1.0);
        settingsStatePage.closeProgressBar();
      }
      markCollectionAsOpen((await NotesDatabaseService.db.listOfCollectionNames()).first);

      isBackupBeingRestored = false;
    }
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
  return res;
}

String fromTableNameToCollectionName(String tableName) {
  String res = tableName.replaceFirst('_', '');

  res = res.replaceAll(stringToReplaceLeftBracket, '[');
  res = res.replaceAll(stringToReplaceRightBracket, ']');
  return res;
}

Future<bool> importNoteCard() async {
  FilePickerResult result =
      await FilePicker.platform.pickFiles(allowMultiple: false, allowedExtensions: [".card", ".collection"], type: FileType.custom);

  if (result != null) {
    String filePath = result.files.first.path;
    if (result.files.first.path.split('.').last == 'card') {
      NotesModel readNote = fromStringToNotesModel(await File(filePath).readAsString());
      NotesDatabaseService.db.addNoteInDB(readNote);
      return true;
    } else if (result.files.first.path.split('.').last == 'collection') {
      List<NotesModel> listReadNotes = fromStringToListOfNotesModel(await File(filePath).readAsString());
      for (var readNote in listReadNotes) {
        NotesDatabaseService.db.addNoteInDB(readNote);
      }
      return true;
    } else {
      print("ERROR: only .card or .collection files supported.");
    }
  } else {
    return false;
  }
}

void shareNoteCard(NotesModel noteCard) async {
  String filename = 'shared_card_' + DateTime.now().toIso8601String() + '.card';

  String stringNoteCard = fromNoteCardToString(noteCard);
  final file = await getLocalFile(filename);

  await file.writeAsString(stringNoteCard);

  Share.shareFiles([file.path], text: 'Shared card');
}

void shareListOfNoteCards(List<NotesModel> listOfNoteCards) async {
  if (listOfNoteCards.length == 0) {
    print("ERROR: Cannot share empty list of notes.");
    exit(1);
  }

  String filename = 'shared_collection_' + DateTime.now().toIso8601String() + '.collection';
  final file = await getLocalFile(filename);
  String res = await fromListOfNotesModelToString(listOfNoteCards);
  //String stringNoteCard = fromNoteCardToString(noteCard);

  await file.writeAsString(res);

  Share.shareFiles([file.path], text: 'Shared collection');
}

NotesModel fromStringToNotesModel(String stringNoteCard) {
  List<String> listOfFields = stringNoteCard.split(fieldDelimiter);
  NotesModel res = NotesModel(
    originalContent: listOfFields[0],
    meaningContent: listOfFields[1],
    date: DateTime.parse(listOfFields[2]),
    dueDate: DateTime.parse(listOfFields[3]),
    isExpanded: false,
    isImportant: false,
  );
  return res;
}

List<NotesModel> fromStringToListOfNotesModel(String stringCollection) {
  List<String> listOfCardStrings = stringCollection.split(fieldDelimiter2);

  List<NotesModel> res = [];

  if (listOfCardStrings.length == 1) {
    if (listOfCardStrings[0] == '') {
      return [];
    }
  }
  for (var item in listOfCardStrings) {
    res.add(fromStringToNotesModel(item));
  }

  return res;
}

String fromNoteCardToString(NotesModel noteCard) {
  String res = '';
  res += noteCard.originalContent + fieldDelimiter;
  res += noteCard.meaningContent + fieldDelimiter;
  res += noteCard.date.toIso8601String() + fieldDelimiter;
  res += noteCard.dueDate.toIso8601String();
  return res;
}

String fromListOfNotesModelToString(List<NotesModel> listOfNoteCards) {
  List<String> listOfNoteCardStrings = listOfNoteCards.map((noteCard) => fromNoteCardToString(noteCard)).toList();
  String res = listOfNoteCardStrings.join(fieldDelimiter2);
  return res;
}

Future<String> getLocalPath() async {
  final directory = await getApplicationSupportDirectory();
  return directory.path;
}

Future<File> getLocalFile(String filename) async {
  final path = await getLocalPath();
  return File('$path/$filename');
}

Future<void> _deleteCacheDir() async {
  final cacheDir = await getTemporaryDirectory();

  if (cacheDir.existsSync()) {
    cacheDir.deleteSync(recursive: true);
  }
}
