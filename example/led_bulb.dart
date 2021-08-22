import 'dart:io';

import 'package:core/core.dart';

Future<void> main(List<String> args) async {
  final configFile = File('example/service.yaml');
  await LedBulb(configFile).initialize();
}

class LedBulb extends Service {
  LedBulb(File configFile) : super(configFile);

  late final State<bool> ledState = state<bool>('isON');

  @override
  void onMessageReceived(ServiceMessage message) {
    super.onMessageReceived(message);

    if (message.arguments.single == 'on') {
      ledState.set(true);
    } else if (message.arguments.single == 'off') {
      ledState.set(false);
    }
  }
}
