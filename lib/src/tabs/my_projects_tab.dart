import 'package:flutter/material.dart';
import 'package:skill_box/src/models/project_model.dart';
import 'package:skill_box/src/models/user_model.dart';
import 'package:skill_box/src/screens/add_project_screen.dart';
import 'package:skill_box/src/screens/edit_project_screen.dart';
import 'package:skill_box/src/widgets/detail_project_dialog.dart';

class MyProjectsTab extends StatefulWidget {
  @override
  _MyProjectsTab createState() => _MyProjectsTab();
}

class _MyProjectsTab extends State<MyProjectsTab> {

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
      body: _userModel.isLoading ? Center(child: CircularProgressIndicator()) : 
        _userModel.user.projetos == null || _userModel.user.projetos.isEmpty ? Center(child: Text("Você não possui projetos ainda")) : 
        Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: 20.0, top: 20.0),
                  child: Text(
                    "Criados por você",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0
                    ),
                  ),
                )
              ],
            ),
            Container(
              padding: EdgeInsets.all(10.0),
              height: 230.0,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _userModel.user.projetos.map(
                  (project){
                    if(project.adminId == _userModel.user.userId){
                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context){
                              return DetailProjectDialog(project, _projectModel, false);
                            }
                          );
                        },
                        child: Container(
                          width: 300.0,
                          margin: EdgeInsets.all(10.0),
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
                                          icon: Icon(Icons.subject, color: Colors.white,),
                                          onSelected: (String result){
                                            switch (result) {
                                              case "editar":
                                                ProjectModel.project = project;
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(builder: (context)=>EditProjectScreen())
                                                );
                                              break;
                                              case "sair":
                                                print("sair");
                                              break;
                                              case "excluir":
                                                print("excluir");
                                              break;
                                            }
                                          },
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
                                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                            const PopupMenuItem(
                                              value: "editar",
                                              child: Text('Editar')
                                            ),
                                            const PopupMenuItem(
                                              value: "sair",
                                              child: Text('Sair do projeto'),
                                            ),
                                            const PopupMenuItem(
                                              value: "excluir",
                                              child: Text('Excluir'),
                                            ),
                                          ]
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                                    child: Text(
                                      project.titulo,
                                      overflow: TextOverflow.fade,
                                      maxLines: 5,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.0,
                                      ),
                                    )
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                                    child: Text(
                                      project.descricao,
                                      maxLines: 5,
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
                                          project.membros.length > 1 ? project.membros.length.toString() + " membros" : project.membros.length.toString() + " membro",
                                        ),
                                        Text(
                                          " - ${project.dataCriacao.toDate().day}/${project.dataCriacao.toDate().month}/${project.dataCriacao.toDate().year}",
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
                      return Row();
                    }
                  }
                ).toList(),
              ),
            ),
            Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: 20.0, top: 10.0),
                  child: Text(
                    "Que você participa",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0
                    ),
                  ),
                )
              ],
            ),
            Container(
              padding: EdgeInsets.all(10.0),
              height: 230.0,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _userModel.user.projetos.map(
                  (project){
                    if(project.adminId != _userModel.user.userId){
                      return GestureDetector(
                        onTap: (){
                          showDialog(
                            context: context,
                            builder: (context){
                              return DetailProjectDialog(project, _projectModel, false);
                            }
                          );
                        },
                        child: Container(
                          width: 300.0,
                          margin: EdgeInsets.all(10.0),
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
                                          icon: Icon(Icons.subject, color: Colors.deepPurple),
                                          onSelected: (String result){
                                            if(result == "sair"){
                                              ProjectModel.project = project;
                                              _projectModel.removeMember(_projectModel.userModel.user);
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
                                    padding: EdgeInsets.symmetric(horizontal: 15.0),
                                    child: Text(
                                      project.titulo,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.0,
                                      ),
                                    )
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                                    child: Text(
                                      project.descricao,
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
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Text(
                                      project.membros.length > 1 ? project.membros.length.toString() + " membros" : project.membros.length.toString() + " membro",
                                    ),
                                    Text(
                                      " - ${project.dataCriacao.toDate().day}/${project.dataCriacao.toDate().month}/${project.dataCriacao.toDate().year}",
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                      ),
                                    )
                                  ],
                                )
                              )
                            ],
                          )
                        )
                      );
                    }else{
                      return Row();
                    }
                  }
                ).toList(),
              ),
            ),
          ],
        )
    );
  }
}