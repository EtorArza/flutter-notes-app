import 'package:shared_preferences/shared_preferences.dart';

Future<String> getThemeFromSharedPref() async {
  SharedPreferences sharedPref = await SharedPreferences.getInstance();
  return sharedPref.getInt('theme') == 1 ? 'light' : 'dark';
}

void setThemeinSharedPref(int val) async {
  SharedPreferences sharedPref = await SharedPreferences.getInstance();
  sharedPref.setInt('theme', val);
}

// card position in review
void setCardPositionInReviewInSharedPref(String val) async {
  SharedPreferences sharedPref = await SharedPreferences.getInstance();
  sharedPref.setString('cardPositionInReview', val);
}

Future<String> getCardPositionInReviewInSharedPref() async {
  SharedPreferences sharedPref = await SharedPreferences.getInstance();
  return sharedPref.getString('cardPositionInReview');
}
