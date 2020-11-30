import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketIOTest extends StatefulWidget {
  SocketIOTest({Key key}) : super(key: key);

  @override
  _SocketIOTestState createState() => _SocketIOTestState();
}

class _SocketIOTestState extends State<SocketIOTest> {
  @override
  void initState() { 
    super.initState();
    initSocket();
  }
  initSocket() {
    IO.Socket socket = IO.io(
        'https://dev.wemeet.africa/api/messaging-service/socket',
        <String, dynamic>{
          'transports': ['websocket'],
          // 'extraHeaders': {'foo': 'bar'} // optional
        });
    socket.on('connect', (_) {
      print('connect');
      socket.emit('join',  {"chatId": "53_121"});
    });
    socket.on('new message', (data) => print(data));
    socket.on('disconnect', (_) => print('disconnect'));
    socket.on('fromServer', (_) => print(_));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text('hello'),
      ),
    );
  }
}
