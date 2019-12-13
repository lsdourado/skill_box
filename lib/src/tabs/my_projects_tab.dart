import 'package:flutter/material.dart';
import 'package:skill_box/src/models/project_model.dart';
import 'package:skill_box/src/models/user_model.dart';
import 'package:skill_box/src/screens/edit_project_screen.dart';

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
    if(_userModel.userLoggedIn){
      if(_userModel.isLoading)
        return Center(child: CircularProgressIndicator());
      
      if(_userModel.user.projetos == null || _userModel.user.projetos.isEmpty)
        return Center(child: Text("Você não possui projetos ainda"));

      else{
        return ListView(
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
              height: 225.0,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _userModel.user.projetos.reversed.map(
                  (project){
                    if(project.adminId == _userModel.user.userId){
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context)=>EditProjectScreen())
                          );
                        },
                        child: Container(
                          width: 300.0,
                          padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
                          margin: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            color: Colors.blueAccent,
                            border: Border.all(
                              color:Colors.grey.withOpacity(0.5)
                            )
                          ),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "Título",
                                    style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                    color: Colors.white
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    project.titulo,
                                    style: TextStyle(
                                      color: Colors.white
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(
                                  height: 12.0,
                                ),
                                Text(
                                  "Descrição",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                    color: Colors.white
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    project.descricao,
                                    style: TextStyle(
                                      color: Colors.white
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
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
                  padding: EdgeInsets.only(left: 20.0, top: 20.0),
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
              height: 225.0,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _userModel.user.projetos.map(
                  (project){
                    if(project.adminId != _userModel.user.userId){
                      return GestureDetector(
                        onTap: (){
                          print(project.titulo);
                        },
                        child: Container(
                          width: 300.0,
                          padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
                          margin: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            border: Border.all(
                              color:Colors.grey.withOpacity(0.5)
                            )
                          ),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "Título",
                                    style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    project.titulo,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(
                                  height: 12.0,
                                ),
                                Text(
                                  "Descrição",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    project.descricao,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
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
        );
      }
    }else{
      return Container();
    }
  }
}