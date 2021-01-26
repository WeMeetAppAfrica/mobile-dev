import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/gestures.dart';

import 'package:wemeet/components/checkbox_field.dart';
import 'package:wemeet/components/text_field.dart';
import 'package:wemeet/components/wide_button.dart';

import 'package:wemeet/utils/colors.dart';
import 'package:wemeet/utils/svg_content.dart';
import 'package:wemeet/utils/url.dart';
import 'package:wemeet/utils/validators.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool checked = false;
  bool isLoading = false;

  void doSubmit() async {

  }

  void submit() {
    FocusScope.of(context).requestFocus(FocusNode());
    final form = formKey.currentState;
    if(form.validate()) {
      form.save();
      doSubmit();
    }
  }

  void openPage(String url) {
    openURL(url);
  }

  Widget buildForm() {
    return Form(
      key: formKey,
      child: ListView(
        children: [
          SizedBox(height: kToolbarHeight + 10.0),
          Center(
            child: SvgPicture.string(WemeetSvgContent.logoYB),
          ),
          SizedBox(height: 40.0),
          Text(
            "Create your account",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17.0
            ),
          ),
          SizedBox(height: 40.0),
          WeMeetTextField(
            // helperText: "Full Name",
            hintText: "First & Last Names",
            validator: NameValidator.validate,
          ),
          SizedBox(height: 20.0),
          WeMeetTextField(
            // helperText: "Phone Number",
            hintText: "Phone Number",
            keyboardType: TextInputType.phone,
            validator: PhoneValidator.validate,
          ),
          SizedBox(height: 20.0),
          WeMeetTextField(
            // helperText: "Email Address",
            hintText: "Email Address",
            keyboardType: TextInputType.emailAddress,
            validator: EmailValidator.validate,
          ),
          SizedBox(height: 20.0),
          WeMeetTextField(
            // helperText: "Password",
            hintText: "Password",
            isPassword: true,
            showPasswordToggle: true,
            validator: PasswordValidator.validate,
          ),
          SizedBox(height: 20.0),
          CheckboxFormField(
            initialValue: checked,
            onSaved: (val) {
              setState((){
                checked = val;
              });
            },
            validator: (val) => val ? null : "You must agree to the terms before you may proceed",
            title: Text.rich(
              TextSpan(
                text: "I agree to the ",
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
                    text: " and "
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
              style: TextStyle(
                fontSize: 13.0
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 5.0),
          ),
          SizedBox(height: 20.0),
          WWideButton(
            title: "Done",
            onTap: submit,
          ),
          SizedBox(height: 30.0),
          Text.rich(
            TextSpan(
              text: "Already have an account? ",
              children: [
                TextSpan(
                  text: "Sign in.",
                  style: TextStyle(
                    decoration: TextDecoration.underline
                  ),
                  recognizer: TapGestureRecognizer()..onTap = (){
                    Navigator.of(context).pushReplacementNamed("/login");
                  }
                ),
              ]
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.0
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
      backgroundColor: AppColors.color3,
      body: SafeArea(
        child: Container(
          color: AppColors.color3,
          child: buildForm()
        ),
      ),
    );
  }
}