import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:iosrecal/Home/NotificationDetail.dart';
import 'package:iosrecal/models/NotificationsModel.dart';
import 'package:iosrecal/models/ResponseBody.dart';
import 'package:iosrecal/models/PositionModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Constant/ColorGlobal.dart';

class NotificationsMenu extends StatefulWidget {
  @override
  _NotificationsMenuState createState() => _NotificationsMenuState();
}

class _NotificationsMenuState extends State<NotificationsMenu> {

  var notifications = new List<NotificationsModel>();
  var block_notification = new Map<String, List<NotificationsModel>>();
  int flag=0;

  initState() {
    super.initState();
    _notifications();
    print(block_notification.keys.toList().length);

  }
  int Comparison(NotificationsModel a, NotificationsModel b) {
     return b.created_at.compareTo(a.created_at);
  }


  Future<String> _notifications() async {

    notifications = new List<NotificationsModel>();
    block_notification = new Map<String, List<NotificationsModel>>();
    flag=0;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String URL = 'https://delta.nitt.edu/recal-uae/api/notifications/?id=' + "${prefs.getString("user_id")}" + '&page=1';
    var response = await http.get(
        URL,
        headers: {
          "Accept": "application/json",
          "Cookie": "${prefs.getString("cookie")}",
        }
    );
    ResponseBody responseBody = new ResponseBody();

    if (response.statusCode == 200) {
      print("success");
//        updateCookie(_response);
      responseBody = ResponseBody.fromJson(json.decode(response.body));
      print(responseBody.data);
      if (responseBody.status_code == 200) {
        setState(() {
          List list = responseBody.data["notifications"];
          notifications =
              list.map((model) => NotificationsModel.fromJson(model)).toList();
          notifications.sort(Comparison);

          notifications.forEach((element) {
            print("${element.title} ${element.created_at}");
            if(block_notification[element.created_at]==null) {
              block_notification[element.created_at] = new List<NotificationsModel>();
            }
            block_notification[element.created_at].add(element);
            print(block_notification[element.created_at].length);
          });
          flag=1;
          for(var i=0;i<block_notification.keys.toList().length;i++)
            print(block_notification.keys.toList().elementAt(i) + "  ${block_notification[(block_notification.keys.toList()).elementAt(i)].length}");
        print("dates: ${block_notification.keys.toList().length}");
        });

      } else {
        print(responseBody.data);
      }
    } else {
      print('Server error');
    }
  }
  @override
  Widget build(BuildContext context) {
    String uri;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: ColorGlobal.whiteColor,
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: ColorGlobal.textColor,
              ),
              onPressed: () {
                Navigator.pop(context);
              }
          ),
          title: Text(
            'Notifications',
            style: TextStyle(color: ColorGlobal.textColor),
          ),
        ),
        body: flag == 0 ? Center(child: CircularProgressIndicator()) : ListView.separated(
          shrinkWrap: true,
          physics: AlwaysScrollableScrollPhysics(),
          itemCount: block_notification.keys.toList().length,
          itemBuilder: (context,index1) {
            print("index1: $index1");
            List date = block_notification.keys.toList()[index1].split("-");
            return Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Column(

                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text("${date[2]}-${date[1]}-${date[0]}",
                          style: GoogleFonts.lato(
                fontWeight: FontWeight.w300,
                fontSize: 15.0,
              ),),
                      ],
                    ),
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: block_notification[(block_notification.keys.toList()).elementAt(index1)].length,
                    itemBuilder: (context, index) {
                      print("index: $index");
                      IconData icon;
                      Color color;
                      NotificationsModel notification = (block_notification[(block_notification.keys.toList()[index1])]).elementAt(index);
                      if(notification.is_read){
                        icon = Icons.notifications;
                        color = Colors.white;
                      }
                      else{
                        icon = Icons.notifications_active;
                        color = Color(0xcc26cb3c);
                      }
                      return InkWell(
                        onTap: () =>  Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationDetail(notification))).then((value) => _notifications()),
                        child: ListTile(
                          leading: CircleAvatar(
                            //backgroundColor: Color(color),
                            child: Icon(
                              icon,
                              color: color,
                              size: 25,
                            ),
                          ),
                          title: Hero(
                            tag: "Notification_" + notification.notification_id.toString(),
                            child: Material(
                              type: MaterialType.transparency,
                              child:
                              Text(notification.title,
                                style: GoogleFonts.lato(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18.0,
                                  color: notification.is_read == true ? Colors.black : Color(0xcc26cb3c),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Divider(),
                      );
                    },
                  ),

                ],
              ),
            );
          },
          separatorBuilder: (context, index1) {
            return Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Divider(color: ColorGlobal.textColor),
            );
          },
        ),
      ),
    );
  }
}
