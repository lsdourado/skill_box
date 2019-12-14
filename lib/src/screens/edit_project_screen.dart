import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:skill_box/src/datas/interest.dart';
import 'package:skill_box/src/models/interest_model.dart';
import 'package:skill_box/src/models/project_model.dart';
import 'package:skill_box/src/models/user_model.dart';

class EditProjectScreen extends StatefulWidget {
  @override
  _EditProjectScreen createState() => _EditProjectScreen();
}

class _EditProjectScreen extends State<EditProjectScreen> {

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final ScrollController _scrollController = ScrollController();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  InterestModel _interestModel;
  ProjectModel _projectModel;

  @override
  void initState() {
    super.initState();

    KeyboardVisibilityNotification().addNewListener(
      onHide: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if(!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      }
    );

    _interestModel = InterestModel.of(context);
    _interestModel.clearSelections();

    _projectModel = ProjectModel.of(context);
    
    _titleController.text = ProjectModel.project?.titulo;
    _descriptionController.text = ProjectModel.project?.descricao;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Novo projeto"),
        centerTitle: true,
      ),
      body: _interestModel.isLoading || _projectModel.isLoading ? Center(child: CircularProgressIndicator()) :
        Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.fromLTRB(16.0, 25.0, 16.0, 25.0),
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: "Título",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0)
                            )
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      
                      Padding(
                        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: TextFormField(
                          maxLines: 5,
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            alignLabelWithHint: true,
                            labelText: "Descrição",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0)
                            )
                          ),
                          keyboardType: TextInputType.multiline,
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(top: 8.0, bottom: 16.0),
                        child: Card(
                          child: ExpansionTile(
                            title: Text("Áreas de interesse"),
                            leading: Icon(Icons.list),
                            children: _interestModel.interestCategories.map(
                              (category){
                                return Ink(
                                  child: ExpansionTile(
                                    title: Text(
                                      category.titulo,
                                    ),
                                    children: <Widget>[
                                      ScopedModelDescendant<InterestModel>(
                                        builder: (context, child, model){
                                          if(category.interests != null && category.interests.isNotEmpty) {
                                            return Container(
                                              child: ListView(
                                                shrinkWrap: true,
                                                controller: _scrollController,
                                                children: category.interests.map(
                                                  (interest){
                                                    return GestureDetector(
                                                      child: Ink(
                                                        color: interest.isSelected ? Colors.green[200] : Colors.grey[100],
                                                        child: ListTile(
                                                          title: Text(interest.titulo),
                                                          contentPadding: EdgeInsets.only(left: 30.0),
                                                        )
                                                      ),
                                                      onTap: () {
                                                        model.onTapInterest(interest);
                                                      }
                                                    );
                                                  }
                                                ).toList(),
                                              )
                                            );
                                          }else{
                                            return Container(
                                              child: Text("Essa categoria não possui itens ainda"),
                                            );
                                          }
                                        },
                                      )
                                    ],
                                  )
                                );
                            }).toList(),
                          )
                        ),
                      ),

                      SizedBox(
                        height: 44.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            RaisedButton(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                              child: Text(
                                "Cancelar",
                                style: TextStyle(
                                  fontSize: 18.0
                                ),
                              ),
                              textColor: Colors.white,
                              color: Colors.red,
                              onPressed: (){
                                Navigator.pop(context);
                              }
                            ),
                            SizedBox(width: 15.0),
                            RaisedButton(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                              child: Text(
                                "Salvar",
                                style: TextStyle(
                                  fontSize: 18.0
                                ),
                              ),
                              textColor: Colors.white,
                              color: Colors.green,
                              onPressed: (){
                                List<Interest> interests = [];
                                  InterestModel.of(context).interestCategories.map(
                                    (category){
                                      category.interests.map(
                                        (interest){
                                          if(interest.isSelected)
                                            interests.add(interest);
                                        }
                                      ).toList();
                                    }
                                  ).toList();

                                  Map<String, dynamic> projectData = {
                                    "adminId": _projectModel.userModel.user.userId,
                                    "projectId": ProjectModel.project.projectId,
                                    "titulo": _titleController.text,
                                    "descricao": _descriptionController.text,
                                    "data_criacao": ProjectModel.project.dataCriacao
                                  };

                                  ProjectModel.of(context).saveProject(
                                    projectData: projectData,
                                    interestList: interests,
                                    onSuccess: onSuccess,
                                    onFail: onFail
                                  );
                              }
                            )
                          ],
                        )
                      )
                    ],
                  ),

                  
                ],
              ),
            )
    );
  }

  void onSuccess(){
    Navigator.pop(context);
  }

  void onFail(){
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text("Falha ao tentar adicionar"),
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 3),)
    );
  }
  
}
