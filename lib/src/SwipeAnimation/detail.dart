import 'package:cached_network_image/cached_network_image.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:wemeet/src/SwipeAnimation/data.dart';
import 'package:flutter/material.dart';
import 'package:wemeet/src/SwipeAnimation/styles.dart';
import 'package:flutter/scheduler.dart';
import 'package:wemeet/src/blocs/swipe_bloc.dart';
import 'package:wemeet/src/views/dashboard/payment.dart';
import 'package:wemeet/values/values.dart';

class DetailPage extends StatefulWidget {
  final dynamic type;
  final from;
  final token;
  const DetailPage({Key key, this.type, this.from, this.token})
      : super(key: key);
  @override
  _DetailPageState createState() => new _DetailPageState(type: type);
}

enum AppBarBehavior { normal, pinned, floating, snapping }

class _DetailPageState extends State<DetailPage> with TickerProviderStateMixin {
  AnimationController _containerController;
  Animation<double> width;
  Animation<double> heigth;
  String interest = '';
  dynamic type;
  int swipesLeft = 0;
  bool disableSwipe = false;
  _DetailPageState({this.type});
  List data = imageData;
  List selectedData = [];
  double _appBarHeight = 500.0;
  AppBarBehavior _appBarBehavior = AppBarBehavior.pinned;

  dismissImg(img) {
    var req = {"swipeeId": img.id, "type": "UNLIKE"};
    print(req);
    swipeBloc.swipe(req, widget.token);
    Navigator.of(context).pop();
  }

  addImg(img) {
    var req = {"swipeeId": img.id, "type": "LIKE"};
    print(req);
    swipeBloc.swipe(req, widget.token);
    Navigator.of(context).pop();
  }

  void initState() {
    _containerController = new AnimationController(
        duration: new Duration(milliseconds: 2000), vsync: this);
    super.initState();
    width = new Tween<double>(
      begin: 200.0,
      end: 220.0,
    ).animate(
      new CurvedAnimation(
        parent: _containerController,
        curve: Curves.ease,
      ),
    );
    heigth = new Tween<double>(
      begin: 400.0,
      end: 400.0,
    ).animate(
      new CurvedAnimation(
        parent: _containerController,
        curve: Curves.ease,
      ),
    );
    type.genderPreference.forEach((e) => {
          e == 'FEMALE' ? e = 'Ladies' : e = 'Guys',
          setState(() {
            interest = interest == '' ? e : interest + ', ' + e;
          })
        });
    heigth.addListener(() {
      setState(() {
        if (heigth.isCompleted) {}
      });
    });
    _containerController.forward();
  }

  @override
  void dispose() {
    _containerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 0.7;
    int img = data.indexOf(type);
    //print("detail");
    return new Theme(
      data: new ThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.secondaryElement,
        platform: Theme.of(context).platform,
      ),
      child: new Container(
        width: width.value,
        height: heigth.value,
        child: new Hero(
          tag: "img",
          child: new Material(
            color: Colors.transparent,
            child: new Container(
              alignment: Alignment.center,
              width: width.value,
              height: heigth.value,
              decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: new BorderRadius.circular(10.0),
              ),
              child: new Stack(
                alignment: AlignmentDirectional.bottomCenter,
                children: <Widget>[
                  new CustomScrollView(
                    shrinkWrap: false,
                    slivers: <Widget>[
                      new SliverAppBar(
                        elevation: 0.0,
                        forceElevated: true,
                        leading: new IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: new Icon(
                            Icons.chevron_left,
                            size: 30.0,
                          ),
                        ),
                        expandedHeight: _appBarHeight,
                        pinned: _appBarBehavior == AppBarBehavior.pinned,
                        floating: _appBarBehavior == AppBarBehavior.floating ||
                            _appBarBehavior == AppBarBehavior.snapping,
                        snap: _appBarBehavior == AppBarBehavior.snapping,
                        flexibleSpace: Stack(
                          children: [
                            Positioned(
                                child: type.profileImage != null
                                    ? CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Container(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    AppColors.secondaryElement),
                                          ),
                                          width: 200.0,
                                          height: 200.0,
                                          padding: EdgeInsets.all(70.0),
                                          decoration: BoxDecoration(
                                            color: Color.fromRGBO(
                                                228, 228, 228, 1.0),
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(8.0),
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                                child: Center(
                                          child: Icon(FeatherIcons.alertCircle),
                                        )),
                                        imageUrl: type.profileImage,
                                      )
                                    : Container(),
                                top: 0,
                                left: 0,
                                right: 0,
                                bottom: 0),
                            Positioned(
                              child: Container(
                                height: 70,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(30),
                                  ),
                                ),
                              ),
                              bottom: -1,
                              left: 0,
                              right: 0,
                            ),
                            widget.from == 'SWIPE'
                                ? Positioned(
                                    bottom: 35,
                                    left: -5,
                                    right: 5,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        RawMaterialButton(
                                          onPressed: () {
                                            dismissImg(type);
                                          },
                                          elevation: 2.0,
                                          fillColor:
                                              Color.fromARGB(255, 142, 198, 63),
                                          child: Icon(
                                            FeatherIcons.x,
                                            color: AppColors.secondaryText,
                                          ),
                                          padding: EdgeInsets.all(13.0),
                                          shape: CircleBorder(),
                                        ),
                                        Spacer(),
                                        RawMaterialButton(
                                          onPressed: () {
                                            addImg(type);
                                          },
                                          elevation: 2.0,
                                          fillColor: AppColors.secondaryElement,
                                          child: Icon(
                                            Icons.favorite,
                                            color: AppColors.secondaryText,
                                          ),
                                          padding: EdgeInsets.all(20.0),
                                          shape: CircleBorder(),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container()
                          ],
                        ),
                      ),
                      new SliverList(
                        delegate: new SliverChildListDelegate(<Widget>[
                          new Container(
                            decoration: new BoxDecoration(
                              color: Colors.white,
                              borderRadius: new BorderRadius.circular(30.0),
                            ),
                            child: new Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 35),
                              child: new Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  new Container(
                                    padding: new EdgeInsets.only(bottom: 20.0),
                                    alignment: Alignment.center,
                                    decoration: new BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    child: new Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          '${type.firstName} ${type.lastName}, ${type.age}',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'Berkshire Swash',
                                            color: AppColors.primaryText,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 24,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          '${type.workStatus}',
                                        ),
                                        new Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            new Icon(
                                              FeatherIcons.mapPin,
                                            ),
                                            new Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: new Text(
                                                  '${type.distanceInKm != 0 ? type.distanceInKm : 1}km away'),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  type.additionalImages.length > 0
                                      ? Container(
                                          margin:
                                              new EdgeInsets.only(top: 25.0),
                                          padding: new EdgeInsets.only(
                                              top: 5.0, bottom: 10.0),
                                          height: 120.0,
                                          decoration: new BoxDecoration(
                                            color: Colors.white,
                                          ),
                                          child: new Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Container(
                                                height: 80,
                                                child: ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount: type
                                                        .additionalImages
                                                        .length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Container(
                                                        margin: EdgeInsets.only(
                                                            right: 10),
                                                        child:
                                                            CachedNetworkImage(
                                                                width: 90,
                                                                fit: BoxFit
                                                                    .cover,
                                                                placeholder:
                                                                    (context,
                                                                            url) =>
                                                                        Container(
                                                                          child:
                                                                              CircularProgressIndicator(
                                                                            valueColor:
                                                                                AlwaysStoppedAnimation<Color>(AppColors.secondaryElement),
                                                                          ),
                                                                          width:
                                                                              200.0,
                                                                          height:
                                                                              200.0,
                                                                          padding:
                                                                              EdgeInsets.all(70.0),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color: Color.fromRGBO(
                                                                                228,
                                                                                228,
                                                                                228,
                                                                                1.0),
                                                                            borderRadius:
                                                                                BorderRadius.all(
                                                                              Radius.circular(8.0),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                errorWidget: (context,
                                                                        url,
                                                                        error) =>
                                                                    Container(
                                                                        child:
                                                                            Center(
                                                                      child: Icon(
                                                                          FeatherIcons
                                                                              .alertCircle),
                                                                    )),
                                                                imageUrl:
                                                                    type.additionalImages[
                                                                        index]),
                                                      );
                                                    }),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container(),
                                  Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(18.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Bio",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(type.bio),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Card(
                                    child: Column(
                                      children: [
                                        ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor:
                                                Color.fromRGBO(142, 198, 63, 1),
                                            radius: 8,
                                          ),
                                          title: Text('I am a'),
                                          trailing: Text(
                                            type.gender == 'FEMALE'
                                                ? 'Lady'
                                                : 'Guy',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Divider(),
                                        ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor:
                                                Color.fromRGBO(142, 198, 63, 1),
                                            radius: 8,
                                          ),
                                          title: Text('I am interested in'),
                                          trailing: Text(
                                            interest,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  new Container(
                                    height: 100.0,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _showDialog() async {
    await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
                title: Text(
                  'Upgrade',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Berkshire Swash',
                    color: AppColors.secondaryElement,
                    fontWeight: FontWeight.w400,
                    fontSize: 24,
                  ),
                ),
                contentPadding: const EdgeInsets.all(16.0),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'You are out of swipes for today.',
                      textAlign: TextAlign.center,
                    ),
                    FlatButton(
                      color: AppColors.secondaryElement,
                      child: Text(
                        'Subscribe',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Payment(
                                token: widget.token,
                              ),
                            ))
                      },
                    )
                  ],
                ));
          },
        );
      },
    );
  }
}
