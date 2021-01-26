import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wemeet/components/wide_button.dart';

import 'package:wemeet/models/app.dart';

import 'package:wemeet/components/text_field.dart';

import 'package:wemeet/utils/colors.dart';
import 'package:wemeet/utils/svg_content.dart';
import 'package:wemeet/utils/validators.dart';
import 'package:wemeet/utils/url.dart';

class LoginPage extends StatefulWidget {

  final AppModel model;

  const LoginPage({Key key, this.model}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  AppModel model;

  @override
  void initState() { 
    super.initState();
    
    model = widget.model;

  }

  void doLogin() {

  }

  void submit() {
    FocusScope.of(context).requestFocus(FocusNode());
    final form = formKey.currentState;
    if(form.validate()) {
      form.save();
      doLogin();
    }
  }

  Widget buildForm() {
    return Form(
      key: formKey,
      child: ListView(
        children: [
          SizedBox(height: kToolbarHeight + 10.0),
          Center(
            child: SvgPicture.string(WemeetSvgContent.logoWY),
          ),
          SizedBox(height: 40.0),
          Text(
            "Welcome Back",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17.0,
              color: Colors.white
            ),
          ),
          SizedBox(height: 40.0),
          WeMeetTextField(
            // helperText: "Email Address",
            hintText: "Email Address",
            keyboardType: TextInputType.emailAddress,
            validator: EmailValidator.validate,
            borderColor: AppColors.color3,
            hintColor: Colors.white,
            textColor: Colors.white,
            errorColor: AppColors.orangeColor,
          ),
          SizedBox(height: 40.0),
          WeMeetTextField(
            // helperText: "Password",
            hintText: "Password",
            isPassword: true,
            showPasswordToggle: true,
            validator: PasswordValidator.validate,
            borderColor: AppColors.color3,
            hintColor: Colors.white,
            textColor: Colors.white,
            errorColor: AppColors.orangeColor,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: FlatButton(
              onPressed: (){},
              child: Text("Forgot Password?"),
              textColor: AppColors.orangeColor,
            ),
          ),
          SizedBox(height: 40.0),
          Text.rich(
            TextSpan(
              text: "Already have an account? ",
              children: [
                TextSpan(
                  text: "Sign in.",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: AppColors.color4
                  ),
                  recognizer: TapGestureRecognizer()..onTap = (){
                    Navigator.of(context).pushReplacementNamed("/register");
                  }
                ),
              ]
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.0,
              color: AppColors.color4
            ),
          ),
          SizedBox(height: 40.0),
          WWideButton(
            title: "Sign In",
            color: AppColors.yellowColor,
            onTap: submit,
            textColor: AppColors.color1,
          ),
          SizedBox(height: 30.0),
          Text.rich(
            TextSpan(
              text: "By Using the WeMeet pltform, you agree to our",
              children: [
                TextSpan(
                  text: "Terms of Use",
                  style: TextStyle(
                    decoration: TextDecoration.underline
                  ),
                  recognizer: TapGestureRecognizer()..onTap = (){
                    openURL("https://wemeet.africa/termsandconditions.pdf");
                  }
                ),
                TextSpan(
                  text: " & "
                ),
                TextSpan(
                  text: "Privacy Policy.",
                  style: TextStyle(
                    decoration: TextDecoration.underline
                  ),
                  recognizer: TapGestureRecognizer()..onTap = (){
                    openURL("https://wemeet.africa/privacypolicy.pdf");
                  }
                )
              ]
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.0,
              color: AppColors.color4
            ),
          ),
        ],
        padding: EdgeInsets.symmetric(horizontal: 30.0),
        physics: ClampingScrollPhysics(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color1,
      body: SafeArea(
        child: Container(
          child: buildForm()
        ),
      ),
    );
  }
}