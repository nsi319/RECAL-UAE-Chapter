import 'dart:convert';
import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iosrecal/Constant/Constant.dart';
import 'package:iosrecal/models/MemberModel.dart';
import 'package:iosrecal/models/ResponseBody.dart';
import 'package:iosrecal/screens/Home/NoInternet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:iosrecal/Constant/ColorGlobal.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:iosrecal/screens/Home/errorWrong.dart';
import 'package:iosrecal/screens/Home/NoData.dart';
import 'package:iosrecal/Endpoint/Api.dart';
import 'package:connectivity/connectivity.dart';

class MemberDatabase extends StatefulWidget {
  @override
  _MemberDatabaseState createState() => _MemberDatabaseState();
}

class _MemberDatabaseState extends State<MemberDatabase> {
  var members = new List<MemberModel>();
  int internet = 1;
  int error = 0;

  initState() {
    super.initState();
    //_positions();
  }

  Future<List> _members() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      internet = 0;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var response = await http
        .get(Api.allUsers, headers: {
      "Accept": "application/json",
      "Cookie": "${prefs.getString("cookie")}",
    });
    ResponseBody responseBody = new ResponseBody();
    print(response.statusCode);
    if (response.statusCode == 200) {
      print("success");
      responseBody = ResponseBody.fromJson(json.decode(response.body));
      if (responseBody.status_code == 200) {
        //setState(() {
        List list = responseBody.data;
        members = list.map((model) => MemberModel.fromJson(model)).toList();
        //print(positions.length);
        //});
      }else if(responseBody.status_code == 401){
        onTimeOut();
      }else{
        error = 1;
      }
    }else{
      error = 1;
    }
    return members;
  }

  Future<bool> onTimeOut(){
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Session Timeout'),
        content: new Text('Login to continue'),
        actions: <Widget>[
          new GestureDetector(
            onTap: () async {
              //await _logoutUser();
              navigateAndReload();
            },
            child: FlatButton(
              color: Colors.red,
              child: Text("OK"),
            ),
          ),
        ],
      ),
    ) ??
        false;
  }
  navigateAndReload(){
    Navigator.pushNamed(context, LOGIN_SCREEN, arguments: true)
        .then((value) {
      Navigator.pop(context);
      setState(() {

      });
      _members();});
  }
  
  bool isEmpty(String linkedin){
    if(linkedin==null || linkedin.trim()=="")
      return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> colorArray = [Colors.blue, Colors.purple, Colors.blueGrey, Colors.deepOrange, Colors.redAccent];

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: ColorGlobal.whiteColor,
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: ColorGlobal.textColor,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
          title: Text(
            'Social Network List',
            style: TextStyle(color: ColorGlobal.textColor),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FutureBuilder(
              future: _members(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return Center(child: NoInternetScreen());
                  case ConnectionState.waiting:
                  case ConnectionState.active:
                    return Center(
                      child: SpinKitDoubleBounce(
                        color: Colors.lightBlueAccent,
                      ),
                    );
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      return internet == 1 ? Center(child: Error8Screen()) : Center(child: NoInternetScreen());
                    } else {
                      print("members length" + members.length.toString());
                      if(error == 1){
                        return Center(child: Error8Screen());
                      }
                      if(members.length==0){
                        return Center(child: NodataScreen());
                      }
                      return ListView.separated(
                        itemCount: members.length,
                        separatorBuilder: (context, index) {
                          return Divider();
                        },
                        itemBuilder: (context, index) {
//                          int color;
//                          if(members[index].gender=="male")
//                            color = 0xbb3399fe;
//                          else{
//                            color = 0xbbff3266;
//                            print("female");
//                          }
                          Color color = colorArray.elementAt(Random().nextInt(4));
                          return members[index].name !=null ? ExpansionTile(
                            title: AutoSizeText(members[index].name,
                              style: TextStyle(
                                fontSize: 18.0,
                                color: ColorGlobal.textColor,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: color,
                              child: Icon(
                                Icons.person,
                                color: ColorGlobal.whiteColor,
                              ),
                            ),
                            //backgroundColor: Colors.red,
                            children: [
                              members[index].email!=null ? ListTile(
                                title: AutoSizeText(members[index].email, maxLines: 1,),
                                leading: Icon(Icons.email, color: Colors.indigoAccent),
                              ) : Container(),
                              ListTile(
                                title: AutoSizeText(members[index].organization, maxLines: 1,),
                                leading: Icon(Icons.business, color: Colors.orange),
                              ),
                              members[index].position!=null ? ListTile(
                                title: AutoSizeText(members[index].position, maxLines: 1,),
                                leading: Icon(Icons.business_center, color: Colors.green),
                              ) : Container(),
                              !isEmpty(members[index].linkedIn_link) ? ListTile(
                                title: new GestureDetector(
                                    child: new AutoSizeText(members[index].linkedIn_link, maxLines: 1,),
                                    onTap: () =>
                                        launch(members[index].linkedIn_link)
                                ),
                                leading: Image(
                                  image: AssetImage('assets/images/linkedin.png'),
                                  height: 24.0,
                                  width: 24.0,
                                ),
                              ) : Container(),
                            ],
                          ) : Container();
                        },
                      );
                    }
                }
                return Center(child: Text("Try Again!"
                )
                );
              },
            ),

          ),
        ),
      ),
    );
  }
}