import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart';

import 'package:wemeet/src/models/chat_model.dart';

class SocketService {

  SocketService._internal();

  static final SocketService _socketService = SocketService._internal();

  factory SocketService() {
    return _socketService;
  }

  Socket _socket;

  // Joined rooms
  List<String> _rooms = [];
  
  void init() async {
    if(_socket == null) {
      _connect();
    }
  }

  void join(String room) {
    // check if connection is initialiazed
    if(_socket == null) {
      _connect();
    }

    if(_rooms.contains(room)) {
      return;
    }

    print("joining room $room");
    _socket.emit("join", room);
    _rooms.add(room);
  }

  StreamController<ChatModel> _chatController =
      StreamController<ChatModel>.broadcast();
  Stream<ChatModel> get onChatReceived =>
      _chatController.stream;

  void addChat(ChatModel val) {
    _chatController.add(val);
  }


  void _connect() async {
    print("...connecting");
    _socket = io(
      'https://dev.wemeet.africa/api/messaging-service/socket',
      <String, dynamic>{
        'transports': ['websocket'],
      }
    );
    _socket.onConnect((data) => print("socket is connected..."));
    _socket.onDisconnect((data) => print("socket is disconnected..."));
    _socket.on('fromServer', (_) => print(_));

    // set chat message listener
    _socket.on('new message', (data) {
      print("Received $data");
      Map mssg = data["message"];
      if(mssg == null || mssg.isEmpty) {
        return;
      }
      _chatController.add(ChatModel.fromMap(mssg));
    });
  }

}