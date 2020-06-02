import 'package:hubdev2/logger.dart' as logger;
import 'package:hubdev2/hubitat.dart' as hubitat;

void main() async {
  logger.log('Here we go...');

  await hubitat.HubAutomation.init(eventListeners: 5);
}
