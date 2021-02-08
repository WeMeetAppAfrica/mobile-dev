import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import 'package:wemeet/components/wide_button.dart';
import 'package:wemeet/components/loader.dart';

import 'package:wemeet/models/app.dart';
import 'package:wemeet/models/user.dart';

import 'package:wemeet/services/auth.dart';
import 'package:wemeet/services/user.dart';

import 'package:wemeet/utils/colors.dart';
import 'package:wemeet/utils/errors.dart';
import 'package:wemeet/utils/toast.dart';

class SettingsPage extends StatefulWidget {

  final AppModel model;
  const SettingsPage({Key key, this.model}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {


  AppModel model;
  UserModel user;

  @override
  void initState() { 
    super.initState();
    
    model = widget.model;
    user = model.user;

  }

  void routeTo(String page) {
    Navigator.pushNamed(context, page);
  }

  void deleteAccount() async {
    bool val = await WeMeetLoader.showBottomModalSheet(
      context,
      "Delete Your Account? 😨",
      content: "This will delete your account. Are you sure you want to proceed?",
      cancelText: "No, Just Kidding",
      okText: "Yes, Delete",
      okColor: AppColors.redColor,
      cancelColor: AppColors.color1
    );

    if(!val) {
      return;
    }

    WeMeetLoader.showLoadingModal(context);

    try {
      await AuthService.postSelfDelete();
      WeMeetToast.toast("Account deleted successfully", true);
    } catch (e) {
      WeMeetToast.toast(kTranslateError(e), true);
    } finally {
      if(Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  Widget _tile({String title = "", String subtitle = "", VoidCallback callback, Widget trailing}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2.0)
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.0
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            height: 1.6,
            fontSize: 13.0
          ),
        ),
        trailing: trailing,
        onTap: callback,
      ),
    );
  }

  Widget buildBody() {
    return ListView(
      physics: ClampingScrollPhysics(),
      children: [
        _tile(
          title: "Change Location",
          subtitle: "Lagos, Nigeria",
          trailing: Icon(Ionicons.chevron_forward)
        ),
        SizedBox(height: 2.0),
        _tile(
          title: "Turn On/Off Location",
          subtitle: "Decide whether users see your location",
          trailing: Icon(
            !user.hideLocation ? Icons.toggle_off : Icons.toggle_on,
            size: 30.0,
            color: user.hideLocation ? AppColors.color1 : Colors.grey,
          )
        ),
        SizedBox(height: 10.0),
        _tile(
          title: "Change Password",
          subtitle: "Update your WeMeet login password",
          callback: () => routeTo("/change-password"),
          trailing: Icon(Ionicons.chevron_forward)
        ),
        SizedBox(height: 10.0),
        _tile(
          title: "Blocked Users",
          subtitle: "See all users that have been blocked",
          trailing: Icon(Ionicons.chevron_forward)
        ),
        SizedBox(height: 2.0),
        _tile(
          title: "Hide My Profile",
          subtitle: "Lagos, Nigeria",
          trailing: Icon(
            !user.hideProfile ? Icons.toggle_off : Icons.toggle_on,
            size: 30.0,
            color: user.hideProfile ? AppColors.color1 : Colors.grey,
          )
        ),
        SizedBox(height: 30.0),
        GestureDetector(
          onTap: (){
            Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false);
            model.logOut();
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2.0)
            ),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10.0,
              children: [
                Icon(Ionicons.exit_outline, color: Colors.redAccent,),
                Text("Logout", style: TextStyle(color: Colors.redAccent),)
              ],
            ),
          ),
        ),
        SizedBox(height: 30.0),
        WWideButton(
          title: "Delete Account",
          onTap: deleteAccount,
          color: Colors.redAccent,
        ),
      ],
      padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xfff5f5f5),
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: buildBody(),
    ); 
  }
}