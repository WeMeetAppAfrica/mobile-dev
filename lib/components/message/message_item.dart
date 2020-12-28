import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:wemeet/models/app.dart';
import 'package:wemeet/src/models/MessageModel.dart';

import 'package:wemeet/values/colors.dart';
import 'package:wemeet/components/chat_player.dart';

class MessageItemComponent extends StatelessWidget {

  final Message mssg;
  final Message before;
  final Message after;
  const MessageItemComponent({Key key, this.mssg, this.before, this.after}) : super(key: key);

  static int id;

  Widget buildTag(String tag) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
        margin: EdgeInsets.symmetric(vertical: 15.0),
        child: Text(tag),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.01),
          borderRadius: BorderRadius.circular(10.0)
        ),
      ),
    );
  }

  Widget buildText(Message mssg, bool me) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      margin: EdgeInsets.only(bottom: 5.0),
      decoration: BoxDecoration(
        color: me
            ? Color.fromRGBO(247, 247, 247, 1.0)
            : Color.fromRGBO(228, 228, 228, 1.0),
        borderRadius: BorderRadius.circular(8.0)
      ),
      child: Wrap(
        children: [
          Text(
            mssg.content,
            style: TextStyle(color: AppColors.primaryText),
          ),
        ],
      ),
    );
  }

  Widget buildContent(Message mssg, bool me) {

    Widget b = Container();

    switch (mssg.type) {
      case "TEXT":
        b = buildText(mssg, me);
        break;
      case "MEDIA":
        b = ChatPlayerWidget(url: mssg.content,);
        break;
      default: b = Container();
    }

    return b;

  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppModel>(
      builder: (context, child, model) {
        id = model.user.id;
        final bool me = mssg.senderId == id;
        return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              mssg.tag != before?.tag ? buildTag(mssg.tag) : null,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                margin: EdgeInsets.only(
                  top: mssg.senderId != before?.senderId ? 5.0 : 0.0
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Stack(
                      alignment: me ? Alignment.centerRight : Alignment.centerLeft,
                      children: [
                        Container(
                          constraints: BoxConstraints(minWidth: 150.0, maxWidth: 350.0),
                          child: Column(
                            crossAxisAlignment: me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              buildContent(mssg, me)
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )
            ].where((e) => e != null).toList(),
          ),
        );
      },
    );
  }
}