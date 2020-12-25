import 'package:shared_preferences/shared_preferences.dart';

// card position in review
void setCardPositionInReviewInSharedPref(String val) async {
  SharedPreferences sharedPref = await SharedPreferences.getInstance();
  sharedPref.setString('cardPositionInReview', val);
}

Future<String> getCardPositionInReviewInSharedPref() async {
  SharedPreferences sharedPref = await SharedPreferences.getInstance();
  return sharedPref.getString('cardPositionInReview');
}

// card position in review
void setnDaysRepeatInSharedPref(List<int> val) async {
  SharedPreferences sharedPref = await SharedPreferences.getInstance();
  sharedPref.setStringList('nDaysRepeat', val.map((e) => e.toString()).toList());
}

Future<List<int>> getnDaysRepeatInSharedPref() async {
  SharedPreferences sharedPref = await SharedPreferences.getInstance();
  return sharedPref.getStringList('nDaysRepeat')?.map((e) => int.parse(e))?.toList();
}

Future<void> deleteAllPrefs() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.clear();
  return;
}
