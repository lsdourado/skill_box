import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skill_box/src/models/user_model.dart';

class NotificationsIcon extends StatefulWidget {
  @override
  _NotificationsIconState createState() => _NotificationsIconState();
}

class _NotificationsIconState extends State<NotificationsIcon> {
  UserModel _userModel;

  @override
  void initState() {
    super.initState();

    _userModel = UserModel.of(context);
  }

  @override
  Widget build(BuildContext context) {
    if(_userModel.userLoggedIn){
      if(!_userModel.isLoading){
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Icon(Icons.notifications, color: Colors.white, size: 30.0),
            Padding(
              padding: EdgeInsets.only(left: 20.0, bottom: 10.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: _userModel.checkNotificationQuantity(),
                builder: (context, snapshot){
                  if(snapshot.hasData){
                    if(snapshot.data.documents.length > 0){
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(2.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(15.0)),
                              color: Colors.redAccent
                            ),
                            child: Text(
                              snapshot.data.documents.length.toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                            )
                          )
                        ],
                      );
                    }
                  }
                  return Container();
                },
              )
            )
          ],
        );
      }
    }

    return Icon(Icons.notifications, color: Colors.white, size: 30.0);
  }
}