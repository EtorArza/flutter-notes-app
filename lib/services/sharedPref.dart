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
