import 'package:flutter/material.dart';
import 'package:wemeet/values/values.dart';

class MatchCards extends StatelessWidget {
  const MatchCards({
    Key key,
    @required this.cardList,
  }) : super(key: key);

  final List<Widget> cardList;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: 327,
        height: 404,
        margin: EdgeInsets.only(top: 45),
        child: cardList.isEmpty
            ? Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    backgroundColor: AppColors.secondaryElement,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text('Finding new matches...')
                ],
              ))
            : Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 0,
                    child: Container(
                      width: 265,
                      height: 365,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 231, 208, 206),
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      child: Container(),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    child: Container(
                      width: 297,
                      height: 365,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 230, 234, 224),
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      child: Container(),
                    ),
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: cardList,
                  )
                ],
              ),
      ),
    );
  }
}
