import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:configurable_expansion_tile/configurable_expansion_tile.dart';
import 'package:flutter/material.dart';
import 'package:skill_box/src/datas/interest.dart';
import 'package:skill_box/src/datas/project.dart';
import 'package:skill_box/src/datas/user.dart';
import 'package:skill_box/src/models/project_model.dart';
import 'package:skill_box/src/models/user_model.dart';
import 'package:skill_box/src/widgets/detail_project_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class UserInfoScreen extends StatefulWidget {

  DocumentSnapshot docUser;

  UserInfoScreen(this.docUser);

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {

  UserModel _userModel;
  ProjectModel _projectModel;

  @override
  void initState() {
    super.initState();

    _userModel = UserModel.of(context);
    _projectModel = ProjectModel.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Perfil de usuário"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: CircleAvatar(
                  radius: 40.0,
                  backgroundColor: Colors.grey[400],
                  foregroundColor: Colors.black,
                  backgroundImage: NetworkImage(widget.docUser.data["urlFoto"])
                )
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Center(
                  child: Chip(
                    elevation: 2.0,
                    label: Text(
                      widget.docUser.data["nome"],
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500
                      ),
                    )
                  )
                )
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "E-mail",
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                    child: Row(
                      children: <Widget>[
                        Text(
                          widget.docUser.data["email"] != null ? widget.docUser.data["email"] : "",
                          style: TextStyle(
                            fontSize: 15.0
                          ),
                        ),
                        widget.docUser.data["email"] != null ?
                          GestureDetector(
                            onTap: () async {
                              if(await canLaunch("mailto:"+widget.docUser.data["email"].toString())){
                                await launch("mailto:"+widget.docUser.data["email"].toString());
                              } else {
                                throw 'Could not launch';
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.only(left: 10.0),
                              child: CircleAvatar(
                                radius: 15.0,
                                backgroundColor: Colors.redAccent,
                                child: Icon(Icons.email, size: 15.0, color: Colors.white),
                              )
                            )
                          )
                        : Container()
                      ],
                    )
                  )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "E-mail secundário",
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  Padding(
                    padding: widget.docUser.data["emailSecundario"].toString().length > 0 ? EdgeInsets.only(bottom: 10.0, top: 10.0): EdgeInsets.all(0.0),
                    child: Row(
                      children: <Widget>[
                        Text(
                          widget.docUser.data["emailSecundario"].toString().length > 0 ? widget.docUser.data["emailSecundario"] : "",
                          style: TextStyle(
                            fontSize: 15.0
                          ),
                        ),
                        widget.docUser.data["emailSecundario"].toString().length > 0 ?
                          GestureDetector(
                            onTap: () async {
                              if(await canLaunch("mailto:"+widget.docUser.data["emailSecundario"].toString())){
                                await launch("mailto:"+widget.docUser.data["emailSecundario"].toString());
                              } else {
                                throw 'Could not launch';
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.only(left: 10.0),
                              child: CircleAvatar(
                                radius: 15.0,
                                backgroundColor: Colors.blueAccent,
                                child: Icon(Icons.email, size: 15.0, color: Colors.white),
                              )
                            )
                          )
                        : Container()
                      ],
                    )
                  )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Telefone",
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  Padding(
                    padding: widget.docUser.data["telefone"].toString().length > 0 ? EdgeInsets.only(bottom: 10.0, top: 10.0): EdgeInsets.all(0.0),
                    child: Row(
                      children: <Widget>[
                        Text(
                          widget.docUser.data["telefone"].toString().length > 0 ? widget.docUser.data["telefone"] : "",
                          style: TextStyle(
                            fontSize: 15.0
                          ),
                        ),
                        widget.docUser.data["telefone"].toString().length > 0 ?
                          GestureDetector(
                            onTap: () async {
                              if(await canLaunch("tel:"+widget.docUser.data["telefone"].toString())){
                                await launch("tel:"+widget.docUser.data["telefone"].toString());
                              } else {
                                throw 'Could not launch';
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.only(left: 10.0),
                              child: CircleAvatar(
                                radius: 15.0,
                                backgroundColor: Colors.orangeAccent,
                                child: Icon(Icons.phone, size: 15.0, color: Colors.white),
                              )
                            )
                          )
                        : Container()
                      ],
                    )
                  )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    "Sobre",
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  Padding(
                    padding: widget.docUser.data["sobre"].toString().length > 0 ? EdgeInsets.only(bottom: 5.0, top: 10.0): EdgeInsets.all(0.0),
                    child: Text(
                      widget.docUser.data["sobre"].toString().length > 0 ? widget.docUser.data["sobre"] : "",
                      style: TextStyle(
                        fontSize: 15.0
                      ),
                    )
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5.0),
                child: StreamBuilder<QuerySnapshot>(
                  stream: _userModel.getUserInterests(widget.docUser),
                  builder: (context, interestsSnapshot){
                    if(interestsSnapshot.hasData && interestsSnapshot.data.documents.isNotEmpty){
                      return ConfigurableExpansionTile(
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
                        children: interestsSnapshot.data.documents.map(
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
                                        interest.data["titulo"],
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
                      );
                    }

                    return Container();
                  },
                )
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(bottom: 5.0),
                      child: Text(
                        "Projetos que administra",
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500
                        ),
                      )
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: _projectModel.listOnlyUserAdminProjects(docUser: widget.docUser),
                      builder: (context, projectsSnapshot){
                        if(projectsSnapshot.hasData && projectsSnapshot.data.documents.isNotEmpty){
                          return Container(
                            height: 200.0,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: projectsSnapshot.data.documents.reversed.map(
                                (docProject){
                                  if(docProject.data["adminId"] == widget.docUser.documentID){
                                    return StreamBuilder<DocumentSnapshot>(
                                      stream: _projectModel.getProjectInfo(docProject: docProject),
                                      builder: (context, projectSnapshot){
                                        if(projectSnapshot.hasData){

                                          Project _project = Project.fromDocument(projectSnapshot.data);

                                          projectSnapshot.data["interesses"].map(
                                            (interest){
                                              _project.interesses.add(Interest.fromDynamic(interest, true));
                                            }
                                          ).toList();

                                          return StreamBuilder<QuerySnapshot>(
                                            stream: _projectModel.listProjectMembers(docProject: projectSnapshot.data),
                                            builder: (context, membersSnapshot){
                                              if(membersSnapshot.hasData && membersSnapshot.data.documents.isNotEmpty){

                                                membersSnapshot.data.documents.map(
                                                  (member){
                                                    User u = User(null);
                                                    u.fromDocument(member);
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
                                                    padding: EdgeInsets.only(top: 5.0),
                                                    decoration: BoxDecoration(
                                                      color: Colors.deepPurple[400],
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
                                                            Padding(
                                                              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                                                              child: Text(
                                                                projectSnapshot.data["titulo"],
                                                                overflow: TextOverflow.ellipsis,
                                                                maxLines: 3,
                                                                style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 14.0,
                                                                ),
                                                              )
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                                                              child: Text(
                                                                projectSnapshot.data["descricao"],
                                                                maxLines: 3,
                                                                overflow: TextOverflow.fade,
                                                                style: TextStyle(
                                                                  color: Colors.white
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
                                                                    membersSnapshot.data.documents.length > 1 ? membersSnapshot.data.documents.length.toString() + " membros" : membersSnapshot.data.documents.length.toString() + " membro",
                                                                    style: TextStyle(
                                                                      color: Colors.white
                                                                    )
                                                                  ),
                                                                  Text(
                                                                    " - " + projectSnapshot.data["dataCriacao"].toDate().toLocal().day.toString() + "/" + projectSnapshot.data["dataCriacao"].toDate().toLocal().month.toString() + "/" + projectSnapshot.data["dataCriacao"].toDate().toLocal().year.toString(),
                                                                    style: TextStyle(
                                                                      color: Colors.white
                                                                    )  
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
                                          );
                                        }else{
                                          return Container();
                                        }
                                      }
                                    );
                                  }else{
                                    return Container();
                                  }
                                }
                              ).toList(),
                            )
                          );
                        }

                        return Container(height: 200.0);
                      },
                    )
                  ],
                )
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(bottom: 5.0),
                      child: Text(
                        "Projetos que participa",
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500
                        ),
                      )
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: _projectModel.listUserProjects(docUser: widget.docUser),
                      builder: (context, projectsSnapshot){
                        if(projectsSnapshot.hasData && projectsSnapshot.data.documents.isNotEmpty){
                          return Container(
                            height: 200.0,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: projectsSnapshot.data.documents.reversed.map(
                                (docProject){
                                  if(docProject.data["adminId"] != widget.docUser.documentID){
                                    return StreamBuilder<DocumentSnapshot>(
                                      stream: _projectModel.getProjectInfo(docProject: docProject),
                                      builder: (context, projectSnapshot){
                                        if(projectSnapshot.hasData){

                                          Project _project = Project.fromDocument(projectSnapshot.data);

                                          projectSnapshot.data["interesses"].map(
                                            (interest){
                                              _project.interesses.add(Interest.fromDynamic(interest, true));
                                            }
                                          ).toList();

                                          return StreamBuilder<QuerySnapshot>(
                                            stream: _projectModel.listProjectMembers(docProject: projectSnapshot.data),
                                            builder: (context, membersSnapshot){
                                              if(membersSnapshot.hasData && membersSnapshot.data.documents.isNotEmpty){

                                                membersSnapshot.data.documents.map(
                                                  (member){
                                                    User u = User(null);
                                                    u.fromDocument(member);
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
                                                    padding: EdgeInsets.only(top: 5.0),
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
                                                            Padding(
                                                              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                                                              child: Text(
                                                                projectSnapshot.data["titulo"],
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
                                                                projectSnapshot.data["descricao"],
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
                                                                    membersSnapshot.data.documents.length > 1 ? membersSnapshot.data.documents.length.toString() + " membros" : membersSnapshot.data.documents.length.toString() + " membro",
                                                                  ),
                                                                  Text(" - " + projectSnapshot.data["dataCriacao"].toDate().toLocal().day.toString() + "/" + projectSnapshot.data["dataCriacao"].toDate().toLocal().month.toString() + "/" + projectSnapshot.data["dataCriacao"].toDate().toLocal().year.toString())
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
                                          );
                                        }else{
                                          return Container();
                                        }
                                      }
                                    );
                                  }else{
                                    return Container();
                                  }
                                }
                              ).toList(),
                            )
                          );
                        }

                        return Container(height: 200.0);
                      },
                    )
                  ],
                )
              )
            ],
          )
        )
      )
    );
  }
}