import 'dart:math';

class NotesModel {
  int id;
  String originalContent;
  String meaningContent;
  bool isImportant;
  DateTime date;
  DateTime dueDate;

  NotesModel(
      {this.id,
      this.originalContent,
      this.meaningContent,
      this.isImportant,
      this.date,
      this.dueDate,});

  NotesModel.fromMap(Map<String, dynamic> map) {
    this.id = map['_id'];
    this.originalContent = map['originalContent'];
    this.meaningContent = map['meaningContent'];
    this.date = DateTime.parse(map['date']);
    this.dueDate = DateTime.parse(map['dueDate']);
    this.isImportant = map['isImportant'] == 1 ? true : false;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': this.id,
      'originalContent': this.originalContent,
      'meaningContent': this.meaningContent,
      'isImportant': this.isImportant == true ? 1 : 0,
      'date': this.date.toIso8601String(),
      'dueDate': this.date.toIso8601String(),
    };
  }

  NotesModel.random() {
    this.id = Random(10).nextInt(1000) + 1;
    this.originalContent = 'Lorem Ipsum ' * (Random().nextInt(4) + 1);
    this.meaningContent = 'Lorem Ipsum ' * (Random().nextInt(4) + 1);
    this.isImportant = Random().nextBool();
    this.date = DateTime.now().add(Duration(hours: Random().nextInt(100)));
    this.dueDate = DateTime.now().add(Duration(hours: Random().nextInt(100)));
  }
}
