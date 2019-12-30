import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skill_box/src/datas/user.dart';
import 'package:skill_box/src/models/project_model.dart';
import 'package:skill_box/src/models/user_model.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  UserModel _userModel;
  ProjectModel _projectModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _userModel = UserModel.of(context);
    _userModel.setNotificationsViewed();

    _projectModel = ProjectModel.of(context);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        backgroundColor: Colors.deepPurple,
        title: Text(
          "Notificações",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _userModel.listNotifications(),
        builder: (context,snapshot){
          if(snapshot.hasData && snapshot.data.documents.length > 0 && !_userModel.isLoading){
            return ListView(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                  child: Container(
                    margin: EdgeInsets.only(right: 150.0),
                    height: 30.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.grey[200],
                      border: new Border.all(
                        color: Colors.grey[300],
                        style: BorderStyle.solid
                      )
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Solicitações de participação ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        Text(
                          snapshot.data.documents.length.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red
                          ),
                        )
                      ],
                    )
                  )
                ),
                Column(
                  children: snapshot.data.documents.map(
                    (invite){
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    CircleAvatar(
                                      radius: 20.0,
                                      backgroundColor: Colors.grey[400],
                                      foregroundColor: Colors.black,
                                      backgroundImage: NetworkImage(invite.data["urlFoto"]),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 10.0),
                                        child: Text(
                                        invite.data["nome"],
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      )
                                    ),
                                    Text(
                                      " pediu para participar do projeto"
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 50.0),
                                  child: Row(
                                  children: <Widget>[
                                    Flexible(
                                      child: Text(
                                        invite.data["projectTitle"],
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic
                                        ),
                                        overflow: TextOverflow.visible,
                                      )
                                    )
                                  ],
                                )
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(right: 10.0, top: 15.0),
                                  height: 25.0,
                                  width: 80.0,
                                  child: RaisedButton(
                                    onPressed: (){
                                      _projectModel.addMember(invite);
                                    },
                                    color: Colors.green,
                                    textColor: Colors.white,
                                    child: Text("Aceitar"),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                                  )
                                ),
                                Container(
                                  height: 25.0,
                                  width: 80.0,
                                  margin: EdgeInsets.only(top: 15.0),
                                  child: RaisedButton(
                                    onPressed: (){
                                      _userModel.deleteInvite(invite.documentID);
                                    },
                                    child: Text("Excluir"),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                                  )
                                )
                              ],
                            ),
                          ],
                        )
                      );
                    }
                  ).toList()
                )
              ],
            );
          }else{
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.notifications_off, color: Colors.grey,size: 40.0),
                  Text(
                    "Você não tem notificações",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold
                    ),
                  )
                ],
              )
            );
          }
        },
      )
    );
  }
}