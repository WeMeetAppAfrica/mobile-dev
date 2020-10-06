import 'package:bubble/bubble.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:wemeet/values/values.dart';

class ChatOld extends StatefulWidget {
  ChatOld({Key key}) : super(key: key);

  @override
  _ChatOldState createState() => _ChatOldState();
}

class _ChatOldState extends State<ChatOld> {
  List messages = [];
  TextEditingController message = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    messages = [
      {'type': 'from', 'text': 'Hello'},
      {'type': 'to', 'text': 'Hi'},
      {'type': 'from', 'text': 'How are you doing?'},
      {'format': 'music', 'type': 'to'},
      {'type': 'from', 'text': 'Are you there?'},
      {'format': 'music', 'type': 'from'},
    ];
  }

  addMessage() {
    if (message.text != '')
      setState(() {
        messages.add({'text': message.text, 'type': 'to'});
        message.text = '';
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(FeatherIcons.chevronLeft),
          color: AppColors.accentText,
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: new IconThemeData(color: AppColors.primaryText),
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Row(
          children: [
            CircleAvatar(
              child: Text('DM'),
            ),
            SizedBox(
              width: 8,
            ),
            Text(
              "Diana Mills",
              style: TextStyle(
                color: AppColors.accentText,
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(FeatherIcons.music),
            color: AppColors.accentText,
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(FeatherIcons.flag),
            color: AppColors.accentText,
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
              child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (BuildContext ctxt, int index) {
                    Widget chat;
                    if (messages[index]['format'] == 'music') {
                      chat = Align(
                        alignment: messages[index]['type'] == 'to'
                            ? Alignment.topRight
                            : Alignment.topLeft,
                        child: Container(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          margin: EdgeInsets.only(
                              top: 10,
                              right: messages[index]['type'] == 'to' ? 8 : 0,
                              left: messages[index]['type'] == 'from' ? 8 : 0),
                          decoration: BoxDecoration(
                              color: AppColors.secondaryElement,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          height: 100,
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Row(
                            children: [
                              Container(
                                height: 80,
                                width: 80,
                                decoration: new BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(16)),
                                    image: new DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                          'https://picsum.photos/1080',
                                        ))),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Gaga Shuffle',
                                    style: TextStyle(
                                      color: AppColors.secondaryText,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '2 Baba',
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(180, 255, 255, 255),
                                        fontSize: 12),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        FeatherIcons.rewind,
                                        color: AppColors.secondaryText,
                                        size: 32,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Icon(
                                        FeatherIcons.playCircle,
                                        color: AppColors.secondaryText,
                                        size: 32,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Icon(
                                        FeatherIcons.fastForward,
                                        color: AppColors.secondaryText,
                                        size: 32,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      chat = Bubble(
                        margin: BubbleEdges.only(top: 10),
                        alignment: messages[index]['type'] == 'to'
                            ? Alignment.topRight
                            : Alignment.topLeft,
                        nip: BubbleNip.no,
                        color: messages[index]['type'] == 'to'
                            ? null
                            : Color.fromRGBO(228, 228, 228, 1.0),
                        child: Text(messages[index]['text'],
                            textAlign: TextAlign.right),
                      );
                    }
                    return chat;
                  })),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: message,
                    keyboardType: TextInputType.multiline,
                    maxLength: 1000,
                    minLines: 1,
                    maxLines: 5,
                    decoration: InputDecoration(hintText: 'Say something...'),
                  ),
                ),
                IconButton(
                  onPressed: () => addMessage(),
                  icon: Icon(Icons.send),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
