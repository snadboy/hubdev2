import 'package:http/http.dart' as http;

import '../../hubitat.dart';
import '../../logger.dart' as logger;

class HubAutomation {
  static void init({int eventListeners = 1, dynamic address = '0.0.0.0', int port}) {
    EventListener.createInstance(messageRouter);
  }

  static Future<void> messageRouter(dynamic message) async {
    if (!(message is Map)) {
      logger.log('Message recieved but is not a Map; message ignored -=- $message', level: logger.LogLevel.error);
      return;
    }

    final prefix = 'Event received from Isolate ${message["isolateSource"]}:';
    switch (message['data'].runtimeType.toString()) {
      case 'Evt':
        Evt evt = message['data'];
        if (evt.deviceId == 360) {
          logger.log('$prefix Button #${evt.value} was ${evt.attribute}');
          if (evt.attribute == 'pushed' && evt.value == '1') {
            final resp = await http.get('http://192.168.86.44/apps/api/484/devices/invokedev?access_token=4b25d19c-29e6-47ff-964f-0c9b9cd9dfdf&cmd=on&devid=81');
            logger.log(resp.toString());
          } else if (evt.attribute == 'doubleTapped' && evt.value == '1') {
            final resp = await http.get('http://192.168.86.44/apps/api/484/devices/invokedev?access_token=4b25d19c-29e6-47ff-964f-0c9b9cd9dfdf&cmd=on&devid=82');
            logger.log(resp.toString());
          }
        } else {
          logger.log('$prefix ${message['data']}');
        }
        break;
      default:
        logger.log('$prefix Received data type not expected, message ignored -=- ${message.data.runtimeType.toString()}', level: logger.LogLevel.warning);
    }
  }
}
