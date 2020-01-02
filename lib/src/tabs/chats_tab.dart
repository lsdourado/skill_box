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
        stream: Firestore.instance.collection("projetos").where("membros", arrayContains: _userModel.user.toMap()).snapshots(),
        builder: (context,snapshot){
          if(snapshot.hasData){
            return ListView(
              children: snapshot.data.documents.map(
                (docProject){
                  return Column(
                    children: <Widget>[
                      FlatButton(
                        onPressed: (){
                          ProjectModel.project = Project.fromDocument(docProject);

                          docProject.data["membros"].map(
                            (member){
                              User u = User(null);
                              u.fromDynamic(member);
                              ProjectModel.project.membros.add(u);
                            }
                          ).toList();

                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context)=>ChatScreen())
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(top: 10.0),
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.supervised_user_circle, size: 50.0, color: Colors.grey),
                                  Flexible(
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 5.0),
                                      child: Text(
                                        docProject.data["titulo"],
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
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Flexible(
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 55.0),
                                    child: Text(
                                      "mensagemmensagemmensagemmensagemmensagemmensagemmensagemmensagemmensagemmensagemmensagemmensagemmensagem",
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  )
                                ),
                                Container(
                                  padding: EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.redAccent
                                  ),
                                  child: Text(
                                    "2",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                                  )
                                )
                              ],
                            )
                          ],
                        )
                      ),
                      Divider(color: Colors.grey)
                    ],
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