import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skill_box/src/datas/project.dart';
import 'package:skill_box/src/datas/user.dart';
import 'package:skill_box/src/models/chat_model.dart';
import 'package:skill_box/src/models/project_model.dart';
import 'package:skill_box/src/models/user_model.dart';
import 'package:skill_box/src/widgets/chat_message.dart';
import 'package:skill_box/src/widgets/info_chat_dialog.dart';
import 'package:skill_box/src/widgets/text_composer.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  Project _project;
  UserModel _userModel;
  ProjectModel _projectModel;
  ChatModel _chatModel;
  bool hasNotVisualized = false;
  int listMessagesCount = 0;

  @override
  void initState() {
    super.initState();

    _project = ProjectModel.project;
    _userModel  =  UserModel.of(context);
    _projectModel = ProjectModel.of(context);
    _chatModel = ChatModel.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      top: false,
      child: WillPopScope(
        onWillPop: () {
          return new Future(() async {
            await Firestore.instance.collection("usuarios").document(_userModel.user.userId).collection("mensagens").where("projectId", isEqualTo: _project.projectId).where("visualizado", isEqualTo: false).getDocuments().then(
              (messages){
                if(messages.documents != null && messages.documents.isNotEmpty){
                  messages.documents.map(
                    (message) {
                      Firestore.instance.collection("usuarios").document(_userModel.user.userId).collection("mensagens").document(message.documentID).updateData(
                        {
                          "visualizado": true
                        }
                      );
                    }
                  ).toList();
                }
              }
            );
            return true;
          });
        },
        child: Scaffold(
          backgroundColor: Colors.grey[200],
          appBar: AppBar(
            title: GestureDetector(
              onTap: (){
                showDialog(
                  context: context,
                  builder: (context){
                    ProjectModel.project = _project;
                    return InfoChatDialog();
                  }
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          _project.titulo,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17.0
                          ),
                        )
                      )
                    ],
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: _projectModel.listProjectMembers(localProject: _project),
                    builder: (context, membersSnapshot){
                      if(membersSnapshot.hasData && membersSnapshot.data.documents.isNotEmpty){
                        _chatModel.setChatMembers(membersSnapshot.data.documents);
                        return Container(
                          height: 20.0,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: membersSnapshot.data.documents.map(
                              (member){
                                User u = User(null);

                                u.fromDocument(member);

                                _project.membros.add(u);

                                return membersSnapshot.data.documents.indexOf(member) == membersSnapshot.data.documents.length - 1 ?
                                  Text(
                                    member.data["nome"],
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 13.0
                                    )
                                  )
                                : Text(
                                    member.data["nome"] + ", ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 13.0
                                    )
                                  );
                              }
                            ).toList()
                          )
                        );
                      }else{
                        return Container();
                      }
                    },
                  )
                ],
              )
            )
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                child: FutureBuilder<QuerySnapshot>(
                  future: Firestore.instance.collection("usuarios").document(_userModel.user.userId).collection("mensagens").where("projectId", isEqualTo: _project.projectId).where("visualizado", isEqualTo: false).getDocuments(),
                  builder: (context,isNotVisualizedSnapshot){
                    return StreamBuilder<QuerySnapshot>(
                      stream: Firestore.instance.collection("usuarios").document(_userModel.user.userId).collection("mensagens").where("projectId", isEqualTo: _project.projectId).snapshots(),
                      builder: (context, snapshot){
                        if(snapshot.hasData && snapshot.data.documents.isNotEmpty){
                          if(isNotVisualizedSnapshot.data.documents != null && isNotVisualizedSnapshot.data.documents.isNotEmpty){
                            hasNotVisualized = true;
                            return Scrollbar(
                              child: ListView(
                                reverse: true,
                                children: <Widget>[
                                  Column(
                                    children: snapshot.data.documents.map(
                                      (mensagem){
                                        if(mensagem.data["visualizado"] == false){
                                          return ChatMessage(mensagem.data);
                                        }else{
                                          return Container();
                                        }
                                      }
                                    ).toList(),
                                  ),
                                  listMessagesCount == 0 ? 
                                    Container(
                                      margin: EdgeInsets.only(top: 10.0),
                                      child: Chip(
                                        elevation: 3.0,
                                        backgroundColor: Colors.white,
                                        label: Text(
                                          isNotVisualizedSnapshot.data.documents.length == 1 ? isNotVisualizedSnapshot.data.documents.length.toString() + " mensagem não visualizada"
                                          : isNotVisualizedSnapshot.data.documents.length.toString() + " mensagens não visualizadas"
                                        ),
                                      )
                                    )
                                  : Container(),
                                  Column(
                                    children: snapshot.data.documents.map(
                                      (mensagem){
                                        if(mensagem.data["visualizado"] == true){
                                          return ChatMessage(mensagem.data);
                                        }else{
                                          return Container();
                                        }
                                      }
                                    ).toList(),
                                  ),
                                ],
                              )
                            );
                          }else{
                            hasNotVisualized = false;
                            return Scrollbar(
                              child: ListView(
                                reverse: true,
                                children: snapshot.data.documents.reversed.map(
                                  (mensagem){
                                    listMessagesCount++;
                                    return ChatMessage(mensagem.data);
                                  }
                                ).toList()
                              )
                            );
                          }
                        }

                        return Container();
                      },
                    );
                  },
                )
              ),
              Container(
                margin: EdgeInsets.only(top: 10.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                ),
                child: TextComposer(),
              )
            ],
          ),
        )
      )
    );
  }
}