import 'dart:developer' as developer;

void log(
  String message, {
  DateTime time,
  int sequenceNumber,
  int level = 0,
  Object error,
  StackTrace stackTrace,
}) =>
    developer.log(
      message,
      time: time,
      sequenceNumber: sequenceNumber,
      level: level,
      name: "BSI",
      error: error,
      stackTrace: stackTrace,
    );
