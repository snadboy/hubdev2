import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'evt.dart';
import '../logger/logger.dart' as logger;
import '../isolates/isolates.dart';

part 'event_service.g.dart'; // generated with 'pub run build_runner build'

class EventIsolate {
  static void entry(SendPort parentSendPort) async {
    logger.log('Entered EventIsolate.entry');
    Isolates.isolateWasSpawned(parentSendPort, _init);
  }

  static void _init(dynamic message) async {
    logger.log('Entered EventIsolate._init');
    EventService.create(message['init']['address'], message['init']['port']);
  }

  // static void messageRouter(dynamic message) {
  //   if (!(message is Map)) {
  //     logger.log('Message recieved by ${Isolate.current.debugName}, but message is not a Map; message ignored -=- $message', level: logger.LogLevel.error);
  //     return;
  //   }

  //   final prefix = 'Event received from Isolate ${message["isolateSource"]}:';
  //   switch (message['data'].runtimeType.toString()) {
  //     // case 'SendPort':
  //     //   addIsolateDestination(message.isolateSender, message.data);
  //     //   break;
  //     case 'Evt':
  //       logger.log('$prefix ${message['data']}');
  //       break;
  //     default:
  //       logger.log('$prefix Received data type not recognized -=- ${message.data.runtimeType.toString()}', level: logger.LogLevel.error);
  //   }
  // }
}

class EventService {
  static HttpServer _server;
  static HttpServer get server => _server;
  static final EventService instance = EventService();

  static void create(dynamic address, int port) async {
    _server = await shelf_io.serve(
      EventService().router.handler,
      address,
      port,
      shared: true,
    );

    logger.log('Event Handler running at ${server.address.host}:${server.port}');
  }

  Router get router => _$EventServiceRouter(instance);

  @Route.post('/event')
  Future<Response> event(Request request) async {
    final evt = Evt.fromJson(await request.read().transform(Utf8Decoder()).join());
    Isolates.sendToParentIsolate({'isolate': 'event', 'data': evt});
    return Response.ok('');
  }

  // @Route.get('/users/<userId>')
  // Future<Response> fetchUser(Request request, String userId) async {
  //   if (userId == 'user1') {
  //     return Response.ok('user1');
  //   }
  //   return Response.notFound('no such user');
  // }

}
