import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:configurable_expansion_tile/configurable_expansion_tile.dart';
import 'package:flutter/material.dart';
import 'package:skill_box/src/datas/project.dart';
import 'package:skill_box/src/datas/user.dart';
import 'package:skill_box/src/models/project_model.dart';
import 'package:skill_box/src/screens/user_info_screen.dart';

class DetailProjectDialog extends StatefulWidget {

  @override
  _DetailProjectDialogState createState() => _DetailProjectDialogState();
}

class _DetailProjectDialogState extends State<DetailProjectDialog> { 
  ProjectModel _projectModel;
  Project _project;
  bool _isMember = false;

  @override
  void initState() {
    super.initState();
    _projectModel = ProjectModel.of(context);
    _project = ProjectModel.project;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance.collection("projetos").document(_project.projectId).snapshots(),
      builder: (context, snapshot){
        if(snapshot.hasData){
          return SimpleDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
            contentPadding: !_isMember ? EdgeInsets.only(top: 10.0) : EdgeInsets.only(top: 10.0, bottom: 10.0),
            children: <Widget>[
              StreamBuilder<QuerySnapshot>(
                stream: _projectModel.listProjectMembers(docProject: snapshot.data),
                builder: (context, projectMembersSnapshot){
                  if(projectMembersSnapshot.hasData && projectMembersSnapshot.data.documents.isNotEmpty){

                    projectMembersSnapshot.data.documents.map(
                      (member){
                        if(member.data["userId"] == _projectModel.userModel.user.userId){
                          _isMember = true;
                        }
                      }
                    ).toList();

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: 350.0
                          ),
                          child: Scrollbar(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 15.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.only(bottom: 10.0),
                                          child: Text(
                                            _project.titulo,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.0,
                                            )
                                          )
                                        ),
                                        Text(
                                          _project.descricao,
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0, bottom: 5.0),
                                    child: ConfigurableExpansionTile(
                                      header: Flexible(
                                        child: Row(
                                          children: <Widget>[
                                            Icon(Icons.list, size: 20.0),
                                            Text(
                                              " Interesses",
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        )
                                      ),
                                      animatedWidgetFollowingHeader: const Icon(
                                        Icons.expand_more,
                                      ),
                                      children: _project.interesses.map(
                                        (interest){
                                          return Row(
                                            children: <Widget>[
                                              Chip(
                                                avatar: Padding(
                                                  padding: EdgeInsets.only(left: 5.0),
                                                  child: Icon(
                                                    Icons.check,
                                                    color: Colors.white, size: 20.0,
                                                  )
                                                ),
                                                elevation: 4.0,
                                                label: Row(
                                                  children: <Widget>[
                                                    Text(
                                                      interest.titulo,
                                                      style: TextStyle(
                                                        color: Colors.white
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                backgroundColor: Colors.deepPurple[200],
                                              )
                                            ],
                                          );
                                        }
                                      ).toList()
                                    )
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                                    child: ConfigurableExpansionTile(
                                      header: Flexible(
                                        child: Row(
                                          children: <Widget>[
                                            Icon(Icons.group,size: 20.0),
                                            Text(
                                              " Membros (${projectMembersSnapshot.data.documents.length})",
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        )
                                      ),
                                      animatedWidgetFollowingHeader: const Icon(
                                        Icons.expand_more,
                                      ),
                                      children: projectMembersSnapshot.data.documents.map(
                                        (member){
                                          return StreamBuilder<DocumentSnapshot>(
                                            stream: _projectModel.userModel.getUserInfo(docUser: member),
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
                                                            snapshot.data["adminId"] == memberSnapshot.data.documentID? 
                                                              Text(
                                                                "Admin",
                                                                style: TextStyle(
                                                                  color: Colors.lightGreen,
                                                                  fontWeight: FontWeight.bold
                                                                ),
                                                              )
                                                            : Text(""),

                                                            snapshot.data["adminId"] == _projectModel.userModel.user.userId  && memberSnapshot.data.documentID != _projectModel.userModel.user.userId ?                                    
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
                                                                            content: Text("Transferir administração?"),
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
                                              }else{
                                                return Center(child: CircularProgressIndicator());
                                              }
                                            },
                                          );
                                        }
                                      ).toList()
                                    )
                                  )
                                ],
                              )
                            )
                          )
                        ),

                        !_isMember ? Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              StreamBuilder<QuerySnapshot>(
                                stream: Firestore.instance.collection("usuarios").document(_project.adminId).collection("convites").where("userId", isEqualTo: _projectModel.userModel.user.userId).snapshots(),
                                builder: (context, snapshot){
                                  if(snapshot.hasData){
                                    bool flagInvited = false;

                                    snapshot.data.documents.map(
                                      (docProject){
                                        if(docProject.data["projectId"] == _project.projectId){
                                          flagInvited = true;
                                        }
                                      }
                                    ).toList();

                                    return RaisedButton(
                                        onPressed: (){
                                          ProjectModel.project = _project;
                                          flagInvited ? _projectModel.cancelInviteProject() : _projectModel.inviteProject();
                                        },
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                                        color: flagInvited ? Colors.red : Colors.green,
                                        textColor: Colors.white,
                                        child: Text(
                                          flagInvited ? "Cancelar pedido" : "Pedir para participar"
                                        ),
                                      );
                                  }else{
                                    return RaisedButton(
                                      highlightColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      focusElevation: 0,
                                      highlightElevation: 0,
                                      hoverElevation: 0,
                                      onPressed: (){
                                      },
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                                      color: Colors.green,
                                      textColor: Colors.white,
                                      child: Text(
                                        "Pedir para participar"
                                      ),
                                    );
                                  }
                                },
                              )
                            ],
                          )
                        ) : Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15.0),
                            child: RaisedButton(
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              focusElevation: 0,
                              highlightElevation: 0,
                              hoverElevation: 0,
                              onPressed: null,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                              child: Text(
                                "Participando",
                              ),
                            )
                          )
                        )
                      ],
                    );
                  }else{
                    return Center(child: CircularProgressIndicator());
                  }
                },
              )
            ],
          );
        }else{
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}