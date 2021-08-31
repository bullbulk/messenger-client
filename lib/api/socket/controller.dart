import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart';

class StreamSocket {
  final _socketResponse = StreamController<dynamic>();

  void Function(dynamic) get addResponse => _socketResponse.sink.add;

  Stream<dynamic> get getResponse => _socketResponse.stream;

  void dispose() {
    _socketResponse.close();
  }
}

class SocketController {
  late Socket socket;

  SocketController(int userId) {
    socket = io('https://messenger.bullbulk.ru', <String, dynamic>{
      'transports': ['websocket']
    });
    // socket.on('new_message', (data) => newMessageHandler(data));
    socket.emit('register_callback', {'user_id': userId});
  }

  void bindHandler(String event, Function(dynamic) handler) {
    socket.on(event, handler);
  }
}
