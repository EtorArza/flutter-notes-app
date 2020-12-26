import 'dart:math';

class NotesModel {
  int id;
  String originalContent;
  String meaningContent;
  bool isLearned;
  bool isExpanded;
  DateTime date;
  DateTime dueDate;
  bool isSelected = false;

  NotesModel({
    this.id,
    this.originalContent,
    this.meaningContent,
    this.isLearned,
    this.date,
    this.dueDate,
    this.isExpanded,
  });

  NotesModel.fromMap(Map<String, dynamic> map) {
    this.id = map['_id'];
    this.originalContent = map['originalContent'];
    this.meaningContent = map['meaningContent'];
    this.isLearned = map['isLearned'] == 1 ? true : false;
    this.date = DateTime.parse(map['date']);
    this.dueDate = DateTime.parse(map['dueDate']);
    this.isExpanded = false;
    this.isSelected = false;
  }

  Map<String, dynamic> toMap() {
    var dueDate = this.dueDate;

    print("Is learned: " + this.isLearned.toString());
    print("due date before:" + this.dueDate.toIso8601String());

    if (this.isLearned) {
      dueDate = this.date.add(Duration(days: 300 * 365));
    }

    // change date back to now only if it was set as learned, an therefore, the due date is in 100 years.
    if (!this.isLearned && this.dueDate.isAfter(DateTime.now().add(Duration(days: 100 * 365)))) {
      dueDate = DateTime.now();
    }
    print("due date after:" + this.dueDate.toIso8601String());

    return <String, dynamic>{
      '_id': this.id,
      'originalContent': this.originalContent,
      'meaningContent': this.meaningContent,
      'isLearned': this.isLearned == true ? 1 : 0,
      'date': this.date.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
    };
  }

  NotesModel.random() {
    this.id = Random(10).nextInt(1000) + 1;
    this.originalContent = 'Lorem Ipsum ' * (Random().nextInt(4) + 1);
    this.meaningContent = 'Lorem Ipsum ' * (Random().nextInt(4) + 1);
    this.isLearned = Random().nextBool();
    this.date = DateTime.now().add(Duration(hours: Random().nextInt(100)));
    this.dueDate = DateTime.now().add(Duration(hours: Random().nextInt(100)));
    this.isExpanded = false;
    this.isSelected = false;
  }

  void toggleExpand() {
    this.isExpanded = !this.isExpanded;
  }

  void toggleSelected() {
    this.isSelected = !this.isSelected;
  }
}
