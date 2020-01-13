import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skill_box/src/models/chat_model.dart';
import 'package:skill_box/src/models/project_model.dart';
import 'package:skill_box/src/models/user_model.dart';

class ChatNotificationsIcon extends StatefulWidget {
  @override
  _ChatNotificationsIconState createState() => _ChatNotificationsIconState();
}

class _ChatNotificationsIconState extends State<ChatNotificationsIcon> {
  ChatModel _chatModel;
  ProjectModel _projectModel;
  UserModel _userModel;

  @override
  void initState() {
    super.initState();

    _chatModel = ChatModel.of(context);
    _projectModel = ProjectModel.of(context);
    _userModel = UserModel.of(context);
  }

  @override
  Widget build(BuildContext context) {
    if(_userModel.userLoggedIn){
      if(!_userModel.isLoading){
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Icon(Icons.chat_bubble, color: Colors.white, size: 30.0),
            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection("usuarios").document(_userModel.user.userId).collection("mensagens").where("visualizado", isEqualTo: false).snapshots(),
              builder: (context, notificationsSnapshot){
                if(notificationsSnapshot.hasData && notificationsSnapshot.data.documents.length > 0){
                  return Padding(
                    padding: EdgeInsets.only(left: 20.0, bottom: 10.0),
                    child: Row(
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
                            notificationsSnapshot.data.documents.length.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                          )
                        )
                      ],
                    )
                  );
                }

                return Container();
              }
            )
          ],
        );
      }
    }

    return Icon(Icons.chat_bubble, color: Colors.white, size: 30.0);
  }
}

