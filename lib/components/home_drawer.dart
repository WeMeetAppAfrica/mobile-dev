import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:wemeet/models/user.dart';
import 'package:wemeet/models/app.dart';

import 'package:wemeet/providers/data.dart';
import 'package:wemeet/src/blocs/bloc.dart';
import 'package:wemeet/values/colors.dart';

import 'package:wemeet/src/views/auth/login.dart';
import 'package:wemeet/src/views/dashboard/profile.dart';
import 'package:wemeet/src/views/dashboard/playlist.dart';
import 'package:wemeet/src/views/dashboard/payment.dart';


class HomeDrawer extends StatelessWidget {

  final UserModel user = DataProvider().user;
  final String token = DataProvider().token;
  static AppModel model;

  static BuildContext ctx;

  void gotoPage(Widget page, [bool clearStack = false]) async {
    await Navigator.pop(ctx);
    Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (context) => page,
      ));
  }

  void gotoUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void logOut() async {
    // To be improved
    bloc.logout({}, token);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var locationFilter = prefs.getString('locationFilter');
    prefs.clear();
    prefs.setBool('passKYC', true);
    prefs.setString('locationFilter', locationFilter);
    prefs.setBool('passWalkthrough', true);

    Navigator.pushAndRemoveUntil(
      ctx,
      MaterialPageRoute(
        builder: (context) => Login(),
      ),
      (Route<dynamic> route) => false).then((value){
        model.logOut();
      });
  }


  Widget buildItem(String title, IconData icon, VoidCallback callback) {

    bool shade = title == "Home";

    return InkWell(
      onTap: callback,
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: shade ? AppColors.secondaryElement : null,
              borderRadius: BorderRadius.circular(10.0)
            ),
            child: Wrap(
              spacing: 15.0,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Icon(icon, size: 20.0, color: shade ? Colors.white : null,),
                Text(
                  title,
                  style: TextStyle(
                    color: shade ? Colors.white : null,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildUser() {
    return Container(
      margin: EdgeInsets.only(
        left: 16,
        top: MediaQuery.of(ctx).padding.top + 10.0
      ),
      child: Column(
        // mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.0),
          GestureDetector(
            onTap: () {
              Navigator.push(
                ctx,
                MaterialPageRoute(
                  builder: (ctx) => ProfilePage(
                    token: token,
                  ),
                ));
            },
            child: Container(
              width: 64, 
              height: 64.0,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10.0),
                image: DecorationImage(
                  image: (user.profileImage == null) ? Image.asset("assets/images/profile_avatar.png") : CachedNetworkImageProvider(user.profileImage),
                  fit: BoxFit.cover
                )
              ),
            ),
          ),
          SizedBox(height: 10.0),
          Text(
            user.fullName,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontFamily: 'Berkshire Swash',
              // color: AppColors.primaryText,
              fontWeight: FontWeight.w400,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 5.0),
          Text(
            "${user.workStatus}",
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    return ScopedModelDescendant<AppModel>(
      builder: (context, child, m) {
        model = m;
        return ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(32.0),
          ),
          child: Container(
            color: Colors.white,
            width: 300.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                user != null ? buildUser() : null,
                SizedBox(height: 20.0),
                buildItem("Home", FeatherIcons.home, (){Navigator.pop(context);}),
                buildItem("Profile", FeatherIcons.user, () => gotoPage(ProfilePage(token: token,))),
                buildItem("Playlist", FeatherIcons.music, () => gotoPage(Playlist(token: token,))),
                buildItem("Subscription", FeatherIcons.creditCard, () => gotoPage(Payment(token: token,))),
                Spacer(),
                buildItem("Privacy Policy", FeatherIcons.file, () => gotoUrl("https://wemeet.africa/privacypolicy.pdf")),
                buildItem("Terms of Use", FeatherIcons.file, () => gotoUrl("https://wemeet.africa/termsandconditions.pdf")),
                Spacer(),
                buildItem("Logout", FeatherIcons.logOut, logOut),
                Spacer(),
              ].where((e) => e != null).toList()
            ),
          ),
        );
      }
    );
    
  }
}