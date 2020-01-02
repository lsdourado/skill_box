import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skill_box/src/datas/interest.dart';
import 'package:skill_box/src/datas/project.dart';
import 'package:skill_box/src/datas/user.dart';
import 'package:skill_box/src/models/project_model.dart';
import 'package:skill_box/src/models/user_model.dart';
import 'package:skill_box/src/screens/add_project_screen.dart';
import 'package:skill_box/src/screens/edit_project_screen.dart';
import 'package:skill_box/src/widgets/detail_project_dialog.dart';
import 'package:skill_box/src/widgets/switch_admin_dialog.dart';

class MyProjectsTab extends StatefulWidget {
  @override
  _MyProjectsTab createState() => _MyProjectsTab();
}

class _MyProjectsTab extends State<MyProjectsTab> {

  UserModel _userModel;
  ProjectModel _projectModel;
  User selectedMember = User(null);

  @override
  void initState() {
    super.initState();
    _userModel = UserModel.of(context);
    _projectModel = ProjectModel.of(context);
  }
  
  @override
  Widget build(BuildContext context) {
    if(_userModel.userLoggedIn){
      return Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.deepPurple,
          mini: true,
          child: Icon(Icons.add),
          onPressed: (){
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context)=>AddProjectScreen())
            );
          },
        ),
        body: _userModel.isLoading || _projectModel.isLoading ? Center(child: CircularProgressIndicator()) :
          StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection("projetos").where("membros", arrayContains: _userModel.user.toMap()).snapshots(),
          builder: (context, snapshot){
            if(snapshot.hasData && snapshot.data.documents.isNotEmpty){
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          "Administrados por você",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0
                          ),
                        )
                      ],
                    ),
                    Container(
                      height: 200.0,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: snapshot.data.documents.map(
                          (project){
                            if(project.data["adminId"] == _userModel.user.userId){
                              Project _project = Project.fromDocument(project);

                              project.data["interesses"].map(
                                (interest){
                                  _project.interesses.add(Interest.fromDynamic(interest, true));
                                }
                              ).toList();

                              project.data["membros"].map(
                                (member){
                                  User u = User(null);
                                  u.fromDynamic(member);
                                  _project.membros.add(u);
                                }
                              ).toList();

                              return GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context){
                                      ProjectModel.project = _project;
                                      return DetailProjectDialog();
                                    }
                                  );
                                },
                                child: Container(
                                  width: 300.0,
                                  margin: EdgeInsets.only(top: 10.0, right: 10.0, bottom: 10.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                    border: Border.all(
                                      width: 0.5,
                                      color:Colors.deepPurple
                                    )
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            height: 35.0,
                                            decoration: BoxDecoration(
                                              color: Colors.deepPurple[400],
                                              borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: <Widget>[
                                                PopupMenuButton<String>(
                                                  icon: Icon(Icons.more_vert, color: Colors.white,),
                                                  onSelected: (String result){
                                                    ProjectModel.project = _project;
                                                    switch (result) {
                                                      case "editar":
                                                        Navigator.of(context).push(
                                                          MaterialPageRoute(builder: (context)=>EditProjectScreen())
                                                        );
                                                      break;
                                                      case "sair":
                                                        if(_project.adminId == _userModel.user.userId){
                                                          showDialog(
                                                            context: context,
                                                            builder: (context){
                                                              return SwitchAdminDialog();
                                                            }
                                                          );
                                                        }else{
                                                          _projectModel.removeMember(_userModel.user);
                                                        }
                                                      break;
                                                      case "excluir":
                                                        showDialog(
                                                          context: context,
                                                          builder: (context){
                                                            return AlertDialog(
                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
                                                              content: Text("Excluir projeto?"),
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
                                                                    _projectModel.deleteProject();
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
                                                      value: "editar",
                                                      child: Text('Editar')
                                                    ),
                                                    _project.membros.length > 1 ? const PopupMenuItem(
                                                      value: "sair",
                                                      child: Text('Sair do projeto'),
                                                    ) : null,
                                                    const PopupMenuItem(
                                                      value: "excluir",
                                                      child: Text('Excluir'),
                                                    )
                                                  ]
                                                )
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                                            child: Text(
                                              project.data["titulo"],
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14.0,
                                              ),
                                            )
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                                            child: Text(
                                              project.data["descricao"],
                                              maxLines: 3,
                                              overflow: TextOverflow.fade,
                                              style: TextStyle(
                                                color: Colors.grey[500]
                                              ),
                                            )
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                                        child: Column(
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: <Widget>[
                                                Text(
                                                  project.data["membros"].length > 1 ? project.data["membros"].length.toString() + " membros" : project.data["membros"].length.toString() + " membro",
                                                ),
                                                Text(
                                                  " - ${project.data["dataCriacao"].toDate().day}/${project.data["dataCriacao"].toDate().month}/${project.data["dataCriacao"].toDate().year}",
                                                  style: TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        )
                                      )
                                    ],
                                  )
                                )
                              );
                            }else{
                              return Container();
                            }
                          }
                        ).toList(),
                      )
                    ),

                    Row(
                      children: <Widget>[
                        Text(
                          "Que você participa",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0
                          ),
                        )
                      ],
                    ),
                    Container(
                      height: 200.0,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: snapshot.data.documents.map(
                          (project){
                            if(project.data["adminId"] != _userModel.user.userId){
                              Project _project = Project.fromDocument(project);

                              project.data["interesses"].map(
                                (interest){
                                  _project.interesses.add(Interest.fromDynamic(interest, true));
                                }
                              ).toList();

                              project.data["membros"].map(
                                (member){
                                  User u = User(null);
                                  u.fromDynamic(member);
                                  _project.membros.add(u);
                                }
                              ).toList();

                              return GestureDetector(
                                onTap: (){
                                  showDialog(
                                    context: context,
                                    builder: (context){
                                      ProjectModel.project = _project;
                                      return DetailProjectDialog();
                                    }
                                  );
                                },
                                child: Container(
                                  width: 300.0,
                                  margin: EdgeInsets.only(top: 10.0, right: 10.0, bottom: 10.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                    border: Border.all(
                                      width: 0.5,
                                      color:Colors.deepPurple
                                    )
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            height: 35.0,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: <Widget>[
                                                PopupMenuButton<String>(
                                                  icon: Icon(Icons.more_vert, color: Colors.deepPurple),
                                                  onSelected: (String result){
                                                    if(result == "sair"){
                                                      ProjectModel.project = _project;
                                                      _projectModel.leaveProject(_projectModel.userModel.user);
                                                    }
                                                  },
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
                                                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                                    const PopupMenuItem(
                                                      value: "sair",
                                                      child: Text('Sair do projeto'),
                                                    ),
                                                  ]
                                                )
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                                            child: Text(
                                              project.data["titulo"],
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14.0,
                                              ),
                                            )
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                                            child: Text(
                                              project.data["descricao"],
                                              maxLines: 3,
                                              overflow: TextOverflow.fade,
                                              style: TextStyle(
                                                color: Colors.grey[500]
                                              ),
                                            )
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                                        child: Column(
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: <Widget>[
                                                Text(
                                                  project.data["membros"].length > 1 ? project.data["membros"].length.toString() + " membros" : project.data["membros"].length.toString() + " membro",
                                                ),
                                                Text(
                                                  " - ${project.data["dataCriacao"].toDate().day}/${project.data["dataCriacao"].toDate().month}/${project.data["dataCriacao"].toDate().year}",
                                                  style: TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        )
                                      )
                                    ],
                                  )
                                )
                              );
                            }else{
                              return Container();
                            }
                          }
                        ).toList(),
                      )
                    )
                  ],
                )
              );
            }else{
              return Container();
            }
          },
        )
      );
    }else{
      return Container();
    }
  }
}