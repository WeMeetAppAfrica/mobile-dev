import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:wemeet/values/values.dart';

class Payment extends StatefulWidget {
  Payment({Key key}) : super(key: key);

  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      Padding(
        padding: EdgeInsets.only(
          top: 16.0,
          left: 8.0,
          right: 8.0,
        ),
        child: Column(
          
          children: [
            Container(
              height: 230,
              width: MediaQuery.of(context).size.width * .8,
              decoration: BoxDecoration(
                // color: Colors.redAccent,
                borderRadius: BorderRadius.circular(16.0),

                image: DecorationImage(
                    image: NetworkImage('https://images.pexels.com/photos/4888690/pexels-photo-4888690.jpeg?auto=compress&cs=tinysrgb&dpr=2&w=500'),
                    fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: FlatButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
                onPressed: () => {},
                color: AppColors.ternaryBackground,
                child: Text(
                  'NGN 0 per month',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(142, 198, 63, 1)),
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
                        style:
                            TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      trailing: Text(
                        '1 per day',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Messages',
                        style:
                            TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      trailing: Text(
                        'No',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Location Update',
                        style:
                            TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      trailing: Text(
                        'No',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: EdgeInsets.only(
          top: 16.0,
          left: 8.0,
          right: 8.0,
        ),
        child: Column(
          children: [
            Container(
              height: 230,
              width: MediaQuery.of(context).size.width * .8,
              decoration: BoxDecoration(
                // color: Colors.redAccent,
                borderRadius: BorderRadius.circular(16.0),

                image: DecorationImage(
                    image: NetworkImage('https://images.pexels.com/photos/4989504/pexels-photo-4989504.jpeg?auto=compress&cs=tinysrgb&dpr=2&w=500'),
                    fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: FlatButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
                onPressed: () => {},
                color: AppColors.ternaryBackground,
                child: Text(
                  'NGN 1,000 per month',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(142, 198, 63, 1)),
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
                        style:
                            TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      trailing: Text(
                        'Unlimited',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Messages',
                        style:
                            TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      trailing: Text(
                        'Unlimited',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Location Update',
                        style:
                            TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      trailing: Text(
                        'Supported',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              child: FlatButton(
                onPressed: () {},
                child: Text(
                  'Upgrade To This Plan',
                  style: TextStyle(color: Colors.white),
                ),
                color: AppColors.secondaryElement,
              ),
            )
          ],
        ),
      )
    ];

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
            Container(
                height: MediaQuery.of(context).size.height * 0.8,
                width: double.infinity,
                child: PageView.builder(
                  itemBuilder: (context, index) {
                    return Opacity(
                      opacity: currentPage == index ? 1.0 : 0.5,
                      child: pages[index],
                    );
                  },
                  itemCount: pages.length,
                  controller:
                      PageController(initialPage: 0, viewportFraction:.85),
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index;
                    });
                  },
                )),
          ],
        ),
      ),
    );
  }
}
