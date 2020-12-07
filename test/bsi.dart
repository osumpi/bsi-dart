import 'dart:convert';

import 'package:bsi/bsi.dart';

main(List<String> args) {
  var testMessage = TestMessage();

  print(jsonEncode(testMessage));
}
