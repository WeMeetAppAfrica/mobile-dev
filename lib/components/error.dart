import 'package:flutter/material.dart';

class ErrorComponent extends StatelessWidget {

  final String text;
  final String buttonText;
  final VoidCallback callback;
  const ErrorComponent({Key key, @required this.text, this.callback, this.buttonText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(text),
          ),
          callback != null ? FlatButton(
            onPressed: callback, 
            child: Text(buttonText ?? "Retry")
          ) : null
        ].where((element) => element != null).toList(),
      ),
    );
  }
}