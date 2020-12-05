import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketUtils {
  IO.Socket socket;
  initSocket() {
    /*
    print('connecting...');
    socket = IO.io(
        'https://dev.wemeet.africa/api/messaging-service/socket',
        <String, dynamic>{
          'transports': ['websocket'],
          // 'extraHeaders': {'foo': 'bar'} // optional
        });
        socket.on('connect', (_) {
     print('connect');
    //  socket.emit('join',  {"chatId": "52_22"});
    });
    socket.on('disconnect', (_) => print('disconnect'));
    socket.on('fromServer', (_) => print(_));*/
  }

  setConnectListener(Function onConnect) {
    // print('checking connect');
    // socket.on('connect', (data) {
    //   onConnect(data);
    // });
  }

  setOnChatMessageReceivedListener(Function onChatMessageReceived) {
    // socket.on('new message', (data) {
    //   print("Received $data");
    //   onChatMessageReceived(data);
    // });
  }

  joinRoom(groupChatId) {
    // if (null == socket) {
    //   print("Socket is Null, Cannot send message");
    //   return;
    // }
    // print('joining');
    // socket.emit("join", {"chatId": groupChatId});
  }
}
