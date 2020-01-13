import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skill_box/src/datas/project.dart';
import 'package:skill_box/src/datas/user.dart';
import 'package:skill_box/src/models/project_model.dart';
import 'package:skill_box/src/models/user_model.dart';
import 'package:skill_box/src/screens/chat_screen.dart';

class ChatsTab extends StatefulWidget {
  @override
  _ChatsTabState createState() => _ChatsTabState();
}

class _ChatsTabState extends State<ChatsTab> {
  UserModel _userModel;

  @override
  void initState() {
    super.initState();

    _userModel = UserModel.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection("usuarios").document(_userModel.user.userId).collection("projetos").orderBy("lastMessageDate", descending: true).snapshots(),
        builder: (context,listProjectsSnapshot){
          if(listProjectsSnapshot.hasData){
            return ListView(
              children: listProjectsSnapshot.data.documents.map(
                (docProject){
                  return StreamBuilder<DocumentSnapshot>(
                    stream: Firestore.instance.collection("projetos").document(docProject.documentID).snapshots(),
                    builder: (context,projectSnapshot){
                      if(projectSnapshot.hasData){
                        return Column(
                          children: <Widget>[
                            FlatButton(
                              onPressed: (){
                                ProjectModel.project = Project.fromDocument(projectSnapshot.data);

                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context)=>ChatScreen())
                                );
                              },
                              child: Container(
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(top: 5.0),
                                      child: Row(
                                        children: <Widget>[
                                          Icon(Icons.supervised_user_circle, size: 50.0, color: Colors.grey),
                                          Flexible(
                                            child: Padding(
                                              padding: EdgeInsets.only(left: 5.0),
                                              child: Text(
                                                projectSnapshot.data["titulo"],
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 17.0
                                                ),
                                              )
                                            )
                                          ),
                                        ],
                                      )
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 5.0),
                                      child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Flexible(
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 55.0),
                                            child: StreamBuilder<QuerySnapshot>(
                                              stream: Firestore.instance.collection("usuarios").document(_userModel.user.userId).collection("mensagens").where("projectId", isEqualTo: docProject.documentID).snapshots(),
                                              builder: (context, mensagemSnapshot){
                                                if(mensagemSnapshot.hasData && mensagemSnapshot.data.documents.length > 0){
                                                  if(mensagemSnapshot.data.documents[mensagemSnapshot.data.documents.length-1].data["imgUrl"] != null){
                                                    return Row(
                                                      children: <Widget>[
                                                        mensagemSnapshot.data.documents[mensagemSnapshot.data.documents.length-1].data["senderId"] != _userModel.user.userId ?
                                                          Text(
                                                            mensagemSnapshot.data.documents[mensagemSnapshot.data.documents.length-1].data["senderName"].toString().substring(
                                                              0, mensagemSnapshot.data.documents[mensagemSnapshot.data.documents.length-1].data["senderName"].toString().indexOf(" ")) + ": ",
                                                            style: TextStyle(color: Colors.grey[600]),
                                                          )
                                                        : Text(""),
                                                        Icon(Icons.camera_alt, color: Colors.grey[600], size: 20.0),
                                                        Text(
                                                          " Foto",
                                                          style: TextStyle(color: Colors.grey[600]),
                                                        )
                                                      ],
                                                    );
                                                  }else if(mensagemSnapshot.data.documents[mensagemSnapshot.data.documents.length-1].data["docUrl"] != null){
                                                    return Row(
                                                      children: <Widget>[
                                                        mensagemSnapshot.data.documents[mensagemSnapshot.data.documents.length-1].data["senderId"] != _userModel.user.userId ?
                                                          Text(
                                                            mensagemSnapshot.data.documents[mensagemSnapshot.data.documents.length-1].data["senderName"].toString().substring(
                                                              0, mensagemSnapshot.data.documents[mensagemSnapshot.data.documents.length-1].data["senderName"].toString().indexOf(" ")) + ": ",
                                                            style: TextStyle(color: Colors.grey[600]),
                                                          )
                                                        : Text(""),
                                                        Icon(Icons.description, color: Colors.grey[600], size: 20.0),
                                                        Flexible(
                                                          child: Text(
                                                            mensagemSnapshot.data.documents[mensagemSnapshot.data.documents.length-1].data["fileName"],
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(color: Colors.grey[600]),
                                                          )
                                                        )
                                                      ],
                                                    );
                                                  }else{
                                                    return Row(
                                                      children: <Widget>[
                                                        mensagemSnapshot.data.documents[mensagemSnapshot.data.documents.length-1].data["senderId"] != _userModel.user.userId ?
                                                          Text(
                                                            mensagemSnapshot.data.documents[mensagemSnapshot.data.documents.length-1].data["senderName"].toString().substring(
                                                              0, mensagemSnapshot.data.documents[mensagemSnapshot.data.documents.length-1].data["senderName"].toString().indexOf(" ")) + ": ",
                                                            style: TextStyle(color: Colors.grey[600]),
                                                          )
                                                        : Text(""),
                                                        Flexible(
                                                          child: Text(
                                                            mensagemSnapshot.data.documents[mensagemSnapshot.data.documents.length-1].data["text"],
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(color: Colors.grey[600]),
                                                          )
                                                        )
                                                      ],
                                                    );
                                                  }
                                                }

                                                return Text(" ");
                                              },
                                            )
                                          )
                                        ),
                                        StreamBuilder<QuerySnapshot>(
                                          stream: Firestore.instance.collection("usuarios").document(_userModel.user.userId).collection("mensagens").where("projectId", isEqualTo: docProject.documentID).where("visualizado", isEqualTo: false).snapshots(),
                                          builder: (context,notificationSnapshot){
                                            if(notificationSnapshot.hasData && notificationSnapshot.data.documents.length > 0){
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
                                                      notificationSnapshot.data.documents.length.toString(),
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                                                    )
                                                  )
                                                ],
                                              );
                                            }

                                            return Container();
                                          },
                                        )
                                      ],
                                    )
                                    )
                                  ],
                                )
                              )
                            ),
                            Divider(color: Colors.grey)
                          ],
                        );
                      }else{
                        return Container();
                      }
                    },
                  );
                }
              ).toList(),
            );
          }else{
            return Container();
          }
        },
      )
    );
  }
}