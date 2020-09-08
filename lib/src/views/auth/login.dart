import 'package:flutter/material.dart';
import 'package:wemeet/src/views/auth/register.dart';

import 'package:wemeet/values/values.dart';

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 255, 255),
        ),
        child: Column(
          children: [
            Container(
              height: 165,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    right: 0,
                    child: Image.asset(
                      "assets/images/redbg-top-2.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    left: 27,
                    top: 90,
                    child: Text(
                      "Login",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w400,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter email';
                    }
                    return null;
                  },
                  obscureText: false,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.mail_outline),
                    contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    hintText: "Email",
                  )),
            ),
            SizedBox(height: 25.0),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter password';
                  }
                  return null;
                },
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: Icon(Icons.visibility_off),
                  contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  hintText: "Password",
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Container(
                margin: EdgeInsets.only(top: 17, right: 38),
                child: Text(
                  "Forgot Password",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: AppColors.accentText,
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 72,
                height: 72,
                margin: EdgeInsets.only(top: 72),
                decoration: BoxDecoration(
                  color: AppColors.primaryBackground,
                  border: Border.fromBorderSide(Borders.primaryBorder),
                  borderRadius: BorderRadius.all(Radius.circular(36)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 16,
                      right: 16,
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryElement,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Container(),
                      ),
                    ),
                    Positioned(
                      child: Image.asset(
                        "assets/images/arrow-right.png",
                        fit: BoxFit.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            FlatButton(
              onPressed: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Register(),
                  ),
                )
              },
              color: Color.fromARGB(255, 245, 253, 237),
              textColor: Color.fromARGB(255, 141, 198, 63),
              child: Text(
                "Don’t have an account? Click Here",
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            Spacer(),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 265,
                margin: EdgeInsets.only(bottom: 58),
                child: Text(
                  "By using the We Meet platform, you agree to our Terms of Use & Privacy Policy",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.accentText,
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
