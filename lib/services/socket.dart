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

  String _currentRoom;
  String get room => _currentRoom;

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
    _socket.emit("join", {"chatId": room});
    _rooms.add(room);
  }

  void joinRooms(List val) {
    // check if connection is initialiazed
    if(_socket == null || val == null || val.isEmpty){
      _connect();
    }

    val.forEach((room) {
      if(_rooms.contains(room)) {
        return;
      }
      _socket.emit("join", {"chatId": room});
      _rooms.add(room);
    });
  }

  // new chat stream controller
  StreamController<ChatModel> _chatController =
      StreamController<ChatModel>.broadcast();
  Stream<ChatModel> get onChatReceived =>
      _chatController.stream;

  // Active chat stream controller
  StreamController<String> _roomController =
      StreamController<String>.broadcast();
  Stream<String> get onRoomChanged =>
      _roomController.stream;

  void addChat(ChatModel val) {
    _chatController.add(val);
  }

  void setRoom(String val) {
    _currentRoom = val;
    _roomController.add(val);
  }

  void _connect() async {
    print("...connecting");
    _socket = io(
      'https://dev.wemeet.africa/api/messaging-service/socket',
      OptionBuilder()
        .setTransports(['websocket'])
        .build()
      // <String, dynamic>{
      //   'transports': ['websocket'],
      // }
    );
    _socket.onConnect((data) {
      print("##### Socket is connected");
      print("##### With $data");

      // join rooms
      joinRooms(_rooms ?? []);

      // Subscribe to new message
      _socket.on('new message', (data) {
        print("Received $data");
        Map mssg = data["message"];
        if(mssg == null || mssg.isEmpty) {
          return;
        }
        _chatController.add(ChatModel.fromMap(mssg));
      });

    });
    _socket.onDisconnect((data){
      print("socket is disconnected...");
      _rooms.clear();
    });
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