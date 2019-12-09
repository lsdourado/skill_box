import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:skill_box/src/datas/interest.dart';
import 'package:skill_box/src/datas/user.dart';
import 'package:skill_box/src/models/interest_model.dart';
import 'package:skill_box/src/models/project_model.dart';
import 'package:skill_box/src/models/user_model.dart';

class AddProjectScreen extends StatefulWidget {
  @override
  _AddProjectScreen createState() => _AddProjectScreen();
}

class _AddProjectScreen extends State<AddProjectScreen> {

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final ScrollController _scrollController = ScrollController();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusDismiss();
      },

      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Novo projeto"),
          centerTitle: true,
        ),
        body: ScopedModelDescendant<InterestModel>(
          builder: (context, child, model) {
            if(model.isLoading)
                return Center(child: CircularProgressIndicator());
            else{
              return Form(
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
                              children: model.interestCategories.map(
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
                                              return Container();
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

                                  List<User> membersList = [];
                                  membersList.add(UserModel.of(context).user);

                                  Map<String, dynamic> projectData = {
                                    "adminId": UserModel.of(context).user?.userId,
                                    "titulo": _titleController.text,
                                    "descricao": _descriptionController.text,
                                  };

                                  ProjectModel.of(context).addProject(
                                    projectData: projectData,
                                    membersList: membersList,
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
              );
            }
          },
        )
      )
    );
  }

  void _focusDismiss(){
    FocusScopeNode currentFocus = FocusScope.of(context);

    if(!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  void onSuccess(){
    Navigator.pop(context);
    UserModel.of(context).reloadProjects();
  }

  void onFail(){
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text("Falha ao tentar adicionar"),
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 3),)
    );
  }
  
}
