import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:configurable_expansion_tile/configurable_expansion_tile.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:skill_box/src/datas/interest.dart';
import 'package:skill_box/src/datas/user.dart';
import 'package:skill_box/src/models/interest_model.dart';
import 'package:skill_box/src/models/project_model.dart';

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

  InterestModel _interestModel;
  ProjectModel _projectModel;

  @override
  void initState() {
    super.initState();
    _interestModel = InterestModel.of(context);
    _interestModel.clearSelections();

    _projectModel = ProjectModel.of(context);

    KeyboardVisibilityNotification().addNewListener(
      onHide: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if(!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.white
          ),
          backgroundColor: Colors.deepPurple,
          title: Text(
            "Novo projeto",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: _interestModel.isLoading ? Center(child: CircularProgressIndicator()) :
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
                            maxLines: 10,
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
                          child: ConfigurableExpansionTile(
                            header: Flexible(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.0),
                                child: Row(
                                  children: <Widget>[
                                    Icon(Icons.list),
                                    Text(
                                      " Interesses",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                )
                              )
                            ),
                            animatedWidgetFollowingHeader: const Icon(
                              Icons.expand_more,
                            ),
                            children: _interestModel.interestCategories.map(
                              (category){
                                return ConfigurableExpansionTile(
                                  initiallyExpanded: _interestModel.isCategorySelected(category) ? true : false,
                                  header: Flexible(
                                    child: Container(
                                      padding: EdgeInsets.only(left: 15.0, top: 10.0, bottom: 10.0),
                                      child: Row(
                                        children: <Widget>[
                                          Text(category.titulo)
                                        ],
                                      )
                                    )
                                  ),
                                  animatedWidgetFollowingHeader: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 15.0),
                                    child: const Icon(
                                      Icons.expand_more,
                                    )
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
                                                  model.interestsSelected.map(
                                                    (userInterest){
                                                      if(userInterest.interestId == interest.interestId){
                                                        interest.isSelected = userInterest.isSelected;
                                                      }
                                                    }
                                                  ).toList();
                                                  return GestureDetector(
                                                    child: Padding(
                                                      padding: EdgeInsets.only(left: 25.0),
                                                      child: Row(
                                                      children: <Widget>[
                                                        Chip(
                                                          avatar: interest.isSelected ? Padding(
                                                            padding: EdgeInsets.only(left: 5.0),
                                                            child: Icon(
                                                              Icons.check,
                                                              color: Colors.white, size: 20.0,
                                                            )
                                                          ) : null,
                                                          elevation: 4.0,
                                                          label: Row(
                                                            children: <Widget>[
                                                              Text(
                                                                interest.titulo,
                                                                style: TextStyle(
                                                                  color: interest.isSelected ? Colors.white : null
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                          backgroundColor: interest.isSelected ? Colors.deepPurple[200] : null,
                                                        )
                                                      ],
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
                                );
                            }).toList(),
                          )
                        ),

                        SizedBox(
                          height: 44.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              RaisedButton(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                                child: Text(
                                  "Adicionar",
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

                                  List<User> membros = [_projectModel.userModel.user];

                                  Map<String, dynamic> projectData = {
                                    "adminId": _projectModel.userModel.user.userId,
                                    "titulo": _titleController.text,
                                    "descricao": _descriptionController.text,
                                    "dataCriacao": Timestamp.now(),
                                    "interesses": interests.map((Interest) => Interest.toMap()).toList(),
                                    "membros": membros.map((User) => User.toMap()).toList()
                                  };

                                  _projectModel.addProject(
                                    projectData: projectData,
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
