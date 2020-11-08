import 'dart:convert';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wemeet/src/blocs/bloc.dart';
import 'package:wemeet/src/resources/api_response.dart';
import 'package:wemeet/values/values.dart';

class Payment extends StatefulWidget {
  final token;
  Payment({Key key, this.token}) : super(key: key);

  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  int currentPage = 0;
  SharedPreferences prefs;
  String email = '';
  bool load = false;
  List<Widget> pages = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    PaystackPlugin.initialize(
        publicKey: 'pk_test_168c5a3a8ff410245befef2595ac1d43500cb194');
    _getUser();
    bloc.getPlans(widget.token);
  }

  _getUser() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    chargeCard(amount, access) async {
      Charge charge = Charge()
        ..amount = amount
        //  ..reference = _getReference()
        ..accessCode = access
        ..email = email;
      CheckoutResponse response = await PaystackPlugin.checkout(
        context,
        method: CheckoutMethod.card, // Defaults to CheckoutMethod.selectable
        charge: charge,
      );
      print('Response = $response');
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: new IconThemeData(color: AppColors.primaryText),
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: Container(
        color: Colors.white,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text(
                "Subscription",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: 'Berkshire Swash',
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w400,
                  fontSize: 32,
                ),
              ),
            ),
            StreamBuilder(
                stream: bloc.userStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    switch (snapshot.data.status) {
                      case Status.UPGRADEPLAN:
                        load = false;
                        print(snapshot.data.data.data);
                        // chargeCard(
                        //     1000, snapshot.data.data.data['access_code']);
                        break;
                      case Status.ERROR:
                        bloc.userSink.add(ApiResponse.idle('message'));
                        load = false;
                        try {
                          Fluttertoast.showToast(
                              msg: json
                                  .decode(snapshot.data.message)['message']);
                        } on FormatException {
                          Fluttertoast.showToast(msg: snapshot.data.message);
                        }
                        break;
                      default:
                    }
                  }

                  return Container(
                      height: MediaQuery.of(context).size.height * 0.8,
                      width: double.infinity,
                      child: StreamBuilder(
                          stream: bloc.planStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              switch (snapshot.data.status) {
                                case Status.LOADING:
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                  break;
                                case Status.DONE:
                                  bloc.planSink
                                      .add(ApiResponse.idle('message'));
                                  snapshot.data.data.data.forEach((e) => {
                                        pages.add(Padding(
                                          padding: EdgeInsets.only(
                                            top: 16.0,
                                            left: 8.0,
                                            right: 8.0,
                                          ),
                                          child: Column(
                                            children: [
                                              Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    .25,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .8,
                                                decoration: BoxDecoration(
                                                  // color: Colors.redAccent,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.0),

                                                  image: DecorationImage(
                                                      image: NetworkImage(
                                                          'https://images.pexels.com/photos/4989504/pexels-photo-4989504.jpeg?auto=compress&cs=tinysrgb&dpr=2&w=500'),
                                                      fit: BoxFit.cover),
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Center(
                                                child: FlatButton(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            18.0),
                                                  ),
                                                  onPressed: () => {},
                                                  color: AppColors
                                                      .ternaryBackground,
                                                  child: Text(
                                                    'NGN ${e.amount == null ? '0' : e.amount}  per month',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Color.fromRGBO(
                                                            142, 198, 63, 1)),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Container(
                                                child: Card(
                                                  child: Column(
                                                    children: [
                                                      ListTile(
                                                        title: Text(
                                                          'Swipes',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16),
                                                        ),
                                                        trailing: Text(
                                                          e.limits.dailySwipeLimit ==
                                                                  -1
                                                              ? 'Unlimited'
                                                              : e.limits
                                                                  .dailySwipeLimit.toString(),
                                                          style: TextStyle(
                                                              fontSize: 16),
                                                        ),
                                                      ),
                                                      ListTile(
                                                        title: Text(
                                                          'Messages',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16),
                                                        ),
                                                        trailing: Text(
                                                          e.limits.dailyMessageLimit ==
                                                                  -1
                                                              ? 'Unlimited'
                                                              : e.limits
                                                                  .dailyMessageLimit.toString(),
                                                          style: TextStyle(
                                                              fontSize: 16),
                                                        ),
                                                      ),
                                                      ListTile(
                                                        title: Text(
                                                          'Location Update',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16),
                                                        ),
                                                        trailing: Text(
                                                          e.limits.updateLocation
                                                              ? 'Supported'
                                                              : 'Not Supported',
                                                          style: TextStyle(
                                                              fontSize: 16),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Container(
                                                child: FlatButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      load = true;
                                                    });
                                                    var data = {
                                                      "amount": e.amount == null ? 0 : e.amount,
                                                      "plan_code": e.code,
                                                      "email": email
                                                    };
                                                    bloc.upgradePlan(
                                                        data, widget.token);
                                                  },
                                                  child: Text(
                                                    '${e.code == 'DEFAULT_FREE_PLAN' ? 'Downgrade' : 'Upgrade'} To This Plan',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  color: AppColors
                                                      .secondaryElement,
                                                ),
                                              )
                                            ],
                                          ),
                                        ))
                                      });
                                  break;
                                case Status.ERROR:
                                  bloc.planSink
                                      .add(ApiResponse.idle('message'));
                                  myCallback(() {
                                    Navigator.pop(context);
                                  });
                                  try {
                                    Fluttertoast.showToast(
                                        msg: json.decode(
                                            snapshot.data.message)['message']);
                                  } on FormatException {
                                    Fluttertoast.showToast(
                                        msg: snapshot.data.message);
                                  }
                                  break;
                                default:
                              }
                            }
                            return PageView.builder(
                              itemBuilder: (context, index) {
                                return Opacity(
                                  opacity: currentPage == index ? 1.0 : 0.5,
                                  child: pages[index],
                                );
                              },
                              itemCount: pages.length,
                              controller: PageController(
                                  initialPage: 0, viewportFraction: .85),
                              onPageChanged: (index) {
                                setState(() {
                                  currentPage = index;
                                });
                              },
                            );
                          }));
                }),
          ],
        ),
      ),
    );
  }

  void myCallback(Function callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callback();
    });
  }
}
