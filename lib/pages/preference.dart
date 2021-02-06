import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_xlider/flutter_xlider.dart';

import 'package:wemeet/components/dismissable_keyboard.dart';
import 'package:wemeet/components/text_field.dart';
import 'package:wemeet/components/wide_button.dart';
import 'package:wemeet/components/loader.dart';

import 'package:wemeet/utils/colors.dart';
import 'package:wemeet/utils/converters.dart';
import 'package:wemeet/utils/svg_content.dart';
import 'package:wemeet/utils/toast.dart';
import 'package:wemeet/utils/validators.dart';
import 'package:wemeet/utils/errors.dart';

import 'package:wemeet/models/app.dart';
import 'package:wemeet/models/user.dart';

import 'package:wemeet/services/user.dart';

class UserPreferencePage extends StatefulWidget {

  final AppModel model;
  const UserPreferencePage({Key key, this.model}) : super(key: key);

  @override
  _UserPreferencePageState createState() => _UserPreferencePageState();
}

class _UserPreferencePageState extends State<UserPreferencePage> {

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController bioC = TextEditingController();
  TextEditingController dobC = TextEditingController();

  Map<String, String> genders = {
    "MALE": "Guy",
    "FEMALE": "Girl"
  }; 

  Map<String, String> prefs = {
    "MALE": "Guys",
    "FEMALE": "Girls",
    "None": "I'd rather not say"
  };

  Map<String, String> eStatuses = {
    "WORKING": "Employed",
    "SELF_EMPLOYED": "Self-Employed",
    "UNEMPLOYED": "Unemployed",
    "STUDENT": "Student"
  };

  AppModel model;
  UserModel user;

  @override
  void initState() { 
    super.initState();
    
    model = widget.model;
    user = model.user;

    setDefault();
  }

  @override
  void dispose() { 
    dobC.dispose();
    bioC.dispose();
    super.dispose();
  }

  void updateProfile() async {
    bool canPop = Navigator.of(context).canPop();

    WeMeetLoader.showLoadingModal(context);

    Map data = {
      "bio": bioC.text,
      "dateOfBirth": user.dob,
      "gender": user.gender,
      "genderPreference": user.genderPreference,
      "maxAge": user.maxAge,
      "minAge": user.minAge,
      "swipeRadius": user.swipeRadius,
      "workStatus": user.workStatus
    };

    try {

      var res = await UserService.postUpdateProfile(data);

      Map userMap = res["data"];
      model.setUserMap(userMap);

      WeMeetToast.toast(res["message"] ?? "Successfully saved user profile", true);

      // if can't pop and profile image is not set
      if(!canPop) {
        if(userMap["profileImage"] == null) {
          Navigator.of(context).pushNamedAndRemoveUntil("/complete-profile", (route) => false);
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil("/start", (route) => false);
        }
        return;
      }
      
    } catch (e) {
      WeMeetToast.toast(kTranslateError(e), true);
    } finally {
      if(Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }

  }

  void submit() {
    FocusScope.of(context).requestFocus(FocusNode());
    final form = formKey.currentState;
    if(form.validate()) {
      form.save();
      updateProfile();
    }
  }

  void setDefault() {
    // set bio
    bioC = TextEditingController(text: user.bio ?? "");

    // set dob
    if(user.dob < 10000000000) {
      user.dob = DateTime.now().subtract(Duration(days: 365 * 18)).millisecondsSinceEpoch;
    }

    dobC = TextEditingController(text: formatDate(DateTime.fromMillisecondsSinceEpoch(user.dob), [dd, ' ', M, ', ', yyyy]));
    setState(() {});
  }

  void pickDob() {
    FocusScope.of(context).requestFocus(FocusNode());

    DateTime current = DateTime.fromMillisecondsSinceEpoch(user.dob);

    int maxYear = DateTime.now().year - 18;
    DatePicker.showDatePicker(
      context,
      minDateTime: DateTime(1920),
      maxDateTime: DateTime(maxYear),
      initialDateTime: current,
      dateFormat: "dd-MMMM-yyyy",
      locale: DateTimePickerLocale.en_us,
      pickerTheme: DateTimePickerTheme(
        itemHeight: 40.0,
        confirm: Text(
          "Save",
          style: TextStyle(
            color: AppColors.color1
          ),
        ),
        cancel: Text(
          "Cancel",
          style: TextStyle(
            color: Colors.red
          ),
        )
      ),
      pickerMode: DateTimePickerMode.date, // show TimePicker
      onConfirm: (date, l) {
        dobC.text = formatDate(date, [dd, ' ', M, ', ', yyyy]);
        setState(() {
          user.dob = date.millisecondsSinceEpoch;          
        });
      },
    );
  }

  Widget _tile(String title, Widget child, {String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey
                ),
              )
            ),
            if (subtitle != null) Container(
              margin: EdgeInsets.only(left: 10.0),
              child: Text(
                subtitle
              ),
            )
          ],
        ),
        SizedBox(height: 10.0),
        child
      ],
    );
  }

  Widget _toggleGroup({List<String> items, List<String> values, Function(String) onSelect, bool slide = false, bool multiple = false, bool left = false}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: Colors.black45),
          color: Color(0xfff0e5fe)
        ),
        child: Stack(
          // fit: StackFit.loose,
          children: [
            if(slide) AnimatedPositioned(
              duration: Duration(milliseconds: 200),
              left: left ? 0.0 : 58.0,
              child: Container(
                width: 60.0,
                height: 34.0,
                decoration: BoxDecoration(
                  color: AppColors.color1,
                  borderRadius: BorderRadius.circular(20.0)
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: items.map((i) {
                bool active = values.contains(i);
                return InkWell(
                  onTap: () => onSelect(i),
                  borderRadius: BorderRadius.circular(20.0),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 100),
                    padding: EdgeInsets.symmetric(horizontal: 17.0, vertical: 7.0),
                    decoration: BoxDecoration(
                      color: (active && !slide) ? AppColors.color1 : Colors.transparent,
                      borderRadius: BorderRadius.circular(active ? 20.0 : 0.0)
                    ),
                    child: Text(
                      i,
                      style: TextStyle(
                        color: active ? Colors.white : Colors.black87
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGender() {
    return _tile(
      "Hey! You're a",
      _toggleGroup(
        items: genders.values.toList(),
        values: [genders[user.gender]],
        slide: true,
        left: user.gender == "MALE",
        onSelect: (val){
          genders.forEach((k, v){
            if(v == val) {
              val = k;
            }
          });
          setState(() {
            user.gender = val;                  
          });
        }
      )
    );
  }

  Widget buildInterests() {
    return _tile(
      "You're interested in",
      _toggleGroup(
        items: prefs.values.toList(),
        values: (user.genderPreference.isEmpty) ? [prefs["None"]] : user.genderPreference.map((e) => prefs[e]).toList(),
        multiple: true,
        onSelect: (val){
          if(val == "I'd rather not say") {
            setState(() {
              user.genderPreference = [];                    
            });
            return;
          }

          List g = user.genderPreference;
          prefs.forEach((k, v){
            if(v == val) {
              if(g.contains(k)) {
                g.remove(k);
                return;
              }
              g.add(k);
              g = g.toSet().toList();
              print(g);
            }
          });
          
          setState(() {
            user.genderPreference = g;                  
          });
          print("User prefs: ${user.genderPreference}");
        }
      )
    );
  }

  Widget buildAgeRange() {
    return _tile(
      "Age range",
      FlutterSlider(
        values: [(user.minAge ?? 18).toDouble(), (user.maxAge ?? 30).toDouble()],
        min: 18,
        max: 60.0,
        rangeSlider: true,
        tooltip: FlutterSliderTooltip(
          alwaysShowTooltip: false,
          disabled: true
        ),
        onDragging: (i, l, u) {
          setState(() {
            user.minAge = ensureInt(l);    
            user.maxAge = ensureInt(u);                
          });
        },
        handler: FlutterSliderHandler(
          decoration: BoxDecoration(),
          child: Container(
            width: 20.0,
            height: 20.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.color1),
              color: Colors.white
            )
          )
        ),
        rightHandler: FlutterSliderHandler(
          decoration: BoxDecoration(),
          child: Container(
            width: 20.0,
            height: 20.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.color1),
              color: Colors.white
            )
          )
        ),
        trackBar: FlutterSliderTrackBar(
          activeTrackBarHeight: 1.5,
          inactiveTrackBarHeight: 1.5,
          inactiveTrackBar: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.black12,
          ),
          activeTrackBar: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: AppColors.color1
          ),
        ),
      ),
      subtitle: "${user.minAge} - ${user.maxAge}"
    );
  }

  Widget buildDistanceRange() {
    return _tile(
      "Distance (km)",
      FlutterSlider(
        values: [(user.swipeRadius ?? 0).toDouble()],
        min: 0,
        max: 200.0,
        rangeSlider: false,
        tooltip: FlutterSliderTooltip(
          alwaysShowTooltip: false,
          disabled: true
        ),
        onDragging: (i, l, u) {
          setState(() {
            user.swipeRadius = ensureInt(l);                
          });
        },
        handler: FlutterSliderHandler(
          decoration: BoxDecoration(),
          child: Container(
            child: Icon(FeatherIcons.mapPin, color: AppColors.color1,),
            alignment: Alignment.topCenter,
          )
        ),
        trackBar: FlutterSliderTrackBar(
          activeTrackBarHeight: 1.5,
          inactiveTrackBarHeight: 1.5,
          inactiveTrackBar: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.black12,
          ),
          activeTrackBar: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: AppColors.color1
          ),
        ),
        handlerHeight: 50.0,
        handlerWidth: 20.0,
      ),
      subtitle: "${user.swipeRadius ?? 0} km"
    );
  }

  Widget buildWorkStatus() {
    return _tile(
      "You're currently",
      Container(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 20.0,
          runSpacing: 15.0,
          children: eStatuses.values.map((e) {
            bool active = eStatuses[user.workStatus] == e;
            return InkWell(
              onTap: () {
                var t;
                eStatuses.forEach((k, v) {
                  if(v == e) {
                    t = k;
                  }
                });

                if(t == null) return;
                setState(() {
                  user.workStatus = t;
                });
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                width: 150.0,
                height: 35.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(20.0),
                  color: active ? AppColors.color1 : Colors.transparent
                ),
                child: Text(
                  e,
                  style: TextStyle(
                    color: active ? Colors.white : Colors.black87
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      )
    );
  }

  Widget buildForm() {
    return Form(
      key: formKey,
      child: ListView(
        children: [
          SvgPicture.string(
            WemeetSvgContent.scroll,
            alignment: Alignment.centerLeft,
          ),
          SizedBox(height: 20.0),
          Text(
            "Nice! Now let's get\nto know you",
            style: TextStyle(
              fontWeight: FontWeight.w500 ,
              fontSize: 17.0
            ),
          ),
          SizedBox(height: 20.0),
          buildGender(),
          SizedBox(height: 30.0),
          buildInterests(),
          SizedBox(height: 30.0),
          buildAgeRange(),
          SizedBox(height: 10.0),
          buildDistanceRange(),
          buildWorkStatus(),
          SizedBox(height: 30.0),
          WeMeetTextField(
            helperText: "What's your age?",
            helperColor: Colors.grey,
            controller: dobC,
            prefixIcon: Icon(FeatherIcons.calendar, color: Colors.grey,),
            enabled: false,
            onFieldTapped: pickDob,
            validator: (val) => NotEmptyValidator.validateWithMessage(val, "Please select your date of birth"),
          ),
          SizedBox(height: 30.0),
          WeMeetTextField(
            helperText: "Talk about yourself",
            helperColor: Colors.grey,
            controller: bioC,
            maxLines: 6,
            validator: (val) => NotEmptyValidator.validateWithMessage(val, "Please tell us about yourself"),
          ),
          SizedBox(height: 30.0),
          WWideButton(
            title: "Apply",
            onTap: submit,
          ),
          SizedBox(height: 30.0),
        ],
        padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
        physics: ClampingScrollPhysics(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

      ),
      body: WKeyboardDismissable(child: buildForm(),),
    );
  }
}