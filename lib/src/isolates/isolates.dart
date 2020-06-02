import 'dart:async';
import 'dart:isolate';
import '../logger/logger.dart' as logger;

typedef SpawnEntry = void Function(SendPort sendPort);
typedef ListenRouter = void Function(dynamic);
typedef IsolateMessageRouter = void Function(dynamic message);

const entry_isolateSourceName = 'isolateSourceName';
const entry_receivePort = 'receivePort';
const entry_sendPort = 'sendPort';
const entry_isolate = 'isolate';

class Isolates {
  static final Map<String, Map<String, dynamic>> _spawnerIsolates = {};
  static Map<String, dynamic> getEntry(String isolateName) => _spawnerIsolates[isolateName];
  static void createEntry(String isolateName) => _spawnerIsolates.putIfAbsent(isolateName, () => {});
  static void removeEntry(String isolateName) => _spawnerIsolates.remove(isolateName);
  static dynamic getEntryValue(String isolateName, String entryKey) => getEntry(isolateName)[entryKey];
  static void setEntryValue(String isolateName, String entryKey, dynamic value) => getEntry(isolateName).putIfAbsent(entryKey, () => value);

  static ReceivePort _spawneeIsolateReceivePort = ReceivePort();
  static SendPort get _spawneeSendPort => _spawneeIsolateReceivePort.sendPort;
  static SendPort _parentSendPort;

  // Setup isolate, after it is spawned
  static void isolateWasSpawned(
    SendPort parentSendPort,
    IsolateMessageRouter isolateMessageRouter,
  ) {
    logger.log('Setting up newly created Isolate [${Isolate.current.debugName}] (aka spawnee)');

    if (_parentSendPort != null) {
      logger.log('spawneeIsolate function has already been called.  Only one call per Isolate is permitted', level: logger.LogLevel.error);
      throw Exception('Isolate parent has already been set');
    }

    // Setup a ReceivePort
    _spawneeIsolateReceivePort = ReceivePort();

    // Setup listener for any incoming messages
    _spawneeIsolateReceivePort.listen(isolateMessageRouter);

    // Save the parent's SendPort
    _parentSendPort = parentSendPort;

    // Send our SendPort to the parent
    logger.log('Sending the SendPort of the spawnee to its parent');
    sendToParentIsolate({'sendPort': _spawneeSendPort});
  }

  // Spawn and setup a new isolate
  static Future<SendPort> spawnAnIsolate(
    nameNewIsolate,
    SpawnEntry spawneeEntry,
    IsolateMessageRouter isolateMessageRouter,
  ) async {
    logger.log('Spawning an Isolate to be named $nameNewIsolate');

    if (_spawnerIsolates.containsKey(nameNewIsolate)) {
      logger.log('An Isolate named $nameNewIsolate has alread been created.  Duplicates are not permitted', level: logger.LogLevel.error);
      throw Exception('An Isolate named "$nameNewIsolate" has already been created.  Duplicates are not permitted');
    }

    createEntry(nameNewIsolate);
    setEntryValue(nameNewIsolate, entry_receivePort, ReceivePort());

    // The completer will ultimately return the SendPort of ??????????????????
    final completer = Completer<SendPort>();

    // Setup ReceivePort listener for this
    ReceivePort receivePort = getEntryValue(nameNewIsolate, entry_receivePort);
    receivePort.listen(
      (message) {
        if (message['sendPort'] != null) {
          logger.log('Message received from Isolate [${message['isolateSource']}]: Saving SendPort of Isolate [$nameNewIsolate]');
          setEntryValue(nameNewIsolate, entry_sendPort, message['sendPort']);
          completer.complete(receivePort.sendPort);
        } else {
          isolateMessageRouter(message);
        }
      },
      onError: (e) {
        getEntryValue(nameNewIsolate, entry_receivePort).close();
        removeEntry(nameNewIsolate);
        logger.log('Isolate, "$nameNewIsolate", had error -=- $e', level: logger.LogLevel.error);
      },
      onDone: () {
        getEntryValue(nameNewIsolate, entry_receivePort).close();
        removeEntry(nameNewIsolate);
        logger.log('Isolate, "$nameNewIsolate", done');
      },
      cancelOnError: true,
    );

    logger.log('Spawning Isolate [$nameNewIsolate]');
    setEntryValue(nameNewIsolate, entry_isolate, await Isolate.spawn(spawneeEntry, receivePort.sendPort, debugName: nameNewIsolate));
    logger.log('Spawn of Isolate [$nameNewIsolate] is complete');

    return completer.future;
  }

  static void sendToParentIsolate(Map<String, dynamic> data) {
    final msg = {'isolateSource': Isolate.current.debugName as dynamic};
    msg.addAll(data);

    _parentSendPort.send(msg);
  }

  // Send message, with given data, to given isolateDestinationName
  static void sendToIsolate(String isolateDestinationName, dynamic data) {
    if (getEntry(isolateDestinationName) == null) {
      throw Exception('Unknown isolateDestinationName, $isolateDestinationName');
    }

    final destSendPort = getEntryValue(isolateDestinationName, entry_sendPort);
    if (destSendPort == null) {
      logger.log('Cannot send message to Isolate [$isolateDestinationName}], no sendPort found');
      throw Exception('Cannot send message to Isolate [$isolateDestinationName}], no sendPort found');
    }

    destSendPort.send(data);
  }
}
