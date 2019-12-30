import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skill_box/src/datas/project.dart';
import 'package:skill_box/src/models/user_model.dart';
import 'package:skill_box/src/screens/notifications_screen.dart';

class NotificationsIcon extends StatefulWidget {
  @override
  _NotificationsIconState createState() => _NotificationsIconState();
}

class _NotificationsIconState extends State<NotificationsIcon> {
  UserModel _userModel;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _userModel = UserModel.of(context);
  }

  @override
  Widget build(BuildContext context) {
    if(_userModel.userLoggedIn){
      if(!_userModel.isLoading){
        return GestureDetector(
          onTap: (){
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context)=>NotificationsScreen())
            );
          },
          child: Padding(
            padding: EdgeInsets.only(right: 10.0, top: 15.0),
            child: Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 25.0),
                  child: Icon(Icons.notifications)
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: _userModel.checkNotificationQuantity(),
                  builder: (context, snapshot){
                    if(snapshot.hasData){
                      if(snapshot.data.documents.length > 0){
                        return CircleAvatar(
                          backgroundColor: Colors.red,
                          radius: 8.0,
                          child: Text(
                            snapshot.data.documents.length.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 13.0, fontWeight: FontWeight.bold)
                          )
                        );
                      }
                    }
                    return Container();
                  },
                )
              ],
            )
          )
        );
      }
    }

    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(right: 35.0, top: 15.0),
        child: Icon(Icons.notifications)
      )
    );
  }
}