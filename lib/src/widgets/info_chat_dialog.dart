import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skill_box/src/datas/project.dart';
import 'package:skill_box/src/datas/user.dart';
import 'package:skill_box/src/models/chat_model.dart';
import 'package:skill_box/src/models/project_model.dart';
import 'package:skill_box/src/screens/user_info_screen.dart';

class InfoChatDialog extends StatefulWidget {
  @override
  _InfoChatDialogState createState() => _InfoChatDialogState();
}

class _InfoChatDialogState extends State<InfoChatDialog> {

  Project _project;
  ChatModel _chatModel;
  ProjectModel _projectModel;

  @override
  void initState() {
    super.initState();

    _project = ProjectModel.project;
    _chatModel = ChatModel.of(context);
    _projectModel = ProjectModel.of(context);
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _projectModel.getProjectInfo(localProject: _project),
      builder: (context, projectSnapshot){
        if(projectSnapshot.hasData){
          return SimpleDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
            contentPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            title: Column(
              children: <Widget>[
                Icon(Icons.supervised_user_circle, size: 70.0, color: Colors.grey),
                Text(projectSnapshot.data["titulo"])
              ],
            ),
            children: <Widget>[
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 300.0
                ),
                child: Scrollbar(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: ChatModel.chatMembers.map(
                        (member){
                          return StreamBuilder<DocumentSnapshot>(
                            stream: _chatModel.userModel.getUserInfo(docUser: member),
                            builder: (context, memberSnapshot){
                              if(memberSnapshot.hasData){
                                return GestureDetector(
                                  onTap: (){
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context)=>UserInfoScreen(memberSnapshot.data))
                                    );
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 4.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Container(
                                          child: Row(
                                            children: <Widget>[
                                              CircleAvatar(
                                                radius: 15.0,
                                                backgroundColor: Colors.grey[400],
                                                foregroundColor: Colors.black,
                                                backgroundImage: member != null ? NetworkImage(memberSnapshot.data["urlFoto"]) : Icon(Icons.person),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(left: 10.0),
                                                child: Text(memberSnapshot.data["nome"]),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: <Widget>[
                                            projectSnapshot.data["adminId"] == memberSnapshot.data.documentID? 
                                              Text(
                                                "Admin",
                                                style: TextStyle(
                                                  color: Colors.lightGreen,
                                                  fontWeight: FontWeight.bold
                                                ),
                                              )
                                            : Text(""),

                                            projectSnapshot.data["adminId"]== _chatModel.userModel.user.userId  && memberSnapshot.data.documentID != _chatModel.userModel.user.userId ?                                    
                                              PopupMenuButton<String>(
                                                child: Icon(Icons.more_vert),
                                                onSelected: (String result){
                                                  ProjectModel.project = _project;
                                                  switch (result) {
                                                    case "remover":
                                                      showDialog(
                                                        context: context,
                                                        builder: (context){
                                                          return AlertDialog(
                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
                                                            content: Text("Remover do projeto?"),
                                                            actions: <Widget>[
                                                              FlatButton(
                                                                splashColor: Colors.transparent,
                                                                textColor: Colors.deepPurple,
                                                                onPressed: (){
                                                                  Navigator.pop(context, true);
                                                                },
                                                                child: Text("Cancelar"),
                                                              ),
                                                              FlatButton(
                                                                splashColor: Colors.transparent,
                                                                textColor: Colors.deepPurple,
                                                                onPressed: (){
                                                                  User u = User(null);

                                                                  u.fromDocument(memberSnapshot.data);

                                                                  _projectModel.removeMember(u);

                                                                  Navigator.pop(context, true);
                                                                },
                                                                child: Text("OK"),
                                                              )
                                                            ],
                                                          );
                                                        }
                                                      );
                                                    break;
                                                    case "switch_admin":
                                                      showDialog(
                                                        context: context,
                                                        builder: (context){
                                                          return AlertDialog(
                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
                                                            content: Text("Remover do projeto?"),
                                                            actions: <Widget>[
                                                              FlatButton(
                                                                splashColor: Colors.transparent,
                                                                textColor: Colors.deepPurple,
                                                                onPressed: (){
                                                                  Navigator.pop(context, true);
                                                                },
                                                                child: Text("Cancelar"),
                                                              ),
                                                              FlatButton(
                                                                splashColor: Colors.transparent,
                                                                textColor: Colors.deepPurple,
                                                                onPressed: (){
                                                                  User u = User(null);

                                                                  u.fromDocument(memberSnapshot.data);

                                                                  _projectModel.switchAdminProject(u);

                                                                  Navigator.pop(context, true);
                                                                },
                                                                child: Text("OK"),
                                                              )
                                                            ],
                                                          );
                                                        }
                                                      );
                                                    break;
                                                  }
                                                },
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
                                                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                                  const PopupMenuItem(
                                                    value: "remover",
                                                    child: Text('Remover do projeto'),
                                                  ),
                                                  const PopupMenuItem(
                                                    value: "switch_admin",
                                                    child: Text('Transferir administração'),
                                                  )
                                                ]
                                              ) : Container(),
                                          ],
                                        )
                                      ],
                                    )
                                  )
                                );
                              }

                              return Container();
                            },
                          );
                        }
                      ).toList()
                    )
                  )
                )
              )
            ],
          );
        }
        
        return Container();
      },
    );
  }
}