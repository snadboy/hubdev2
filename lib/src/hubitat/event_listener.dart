import 'dart:io';

import '../../isolates.dart';
import '../../logger.dart' as logger;
import 'event_service.dart';

class EventListener {
  static int cnt = 0;

  static void createInstance(IsolateMessageRouter messageRouter, {int count = 1, dynamic address = '0.0.0.0', int port = 8082}) async {
    logger.log('Creating $count instances of EventListener');

    final limit = cnt + count;
    for (cnt; cnt < limit; cnt++) {
      final name = 'Event${cnt}';

      await Isolates.spawnAnIsolate(name, EventIsolate.entry, messageRouter);
      Isolates.sendToIsolate(name, {
        'init': {'address': address, 'port': port}
      });
    }
  }
}
