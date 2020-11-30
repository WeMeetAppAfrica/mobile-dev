import 'package:flutter/material.dart';

class PaymentSuccess extends StatelessWidget {
  const PaymentSuccess({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromRGBO(245, 253, 237, 1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Payment Successful',
              style: TextStyle(
                fontSize: 36,
                fontFamily: 'Berkshire Swash',
                fontWeight: FontWeight.w400,
                color: Color.fromRGBO(142, 198, 63, 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
