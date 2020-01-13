import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:configurable_expansion_tile/configurable_expansion_tile.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:skill_box/src/datas/interest.dart';
import 'package:skill_box/src/datas/project.dart';
import 'package:skill_box/src/models/interest_model.dart';
import 'package:skill_box/src/models/project_model.dart';
import 'package:skill_box/src/widgets/detail_project_dialog.dart';

class SearchTab extends StatefulWidget {
  @override
  _SearchTabState createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  ProjectModel _projectModel;
  InterestModel _interestModel;

  @override
  void initState() {
    super.initState();

    _projectModel = ProjectModel.of(context);
    _interestModel = InterestModel.of(context);

    _interestModel.filterCategoryId = null;
    InterestModel.filterInterest = null;

    KeyboardVisibilityNotification().addNewListener(
      onHide: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if(!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(50.0)),
              border: Border.all(
                width: 0.5,
                color:Colors.deepPurple
              )
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 120.0
                    ),
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration.collapsed(hintText: "Buscar projeto por título"),
                      onChanged: (text){
                        if(text.length > 0){
                          setState(() {
                            _interestModel.filterCategoryId = null;
                            InterestModel.filterInterest = null;
                          });
                        }
                      },
                    )
                  )
                )
              ],
            )
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                GestureDetector(
                    onTap: (){
                      _interestModel.filterCategoryId = null;
                      InterestModel.filterInterest = null;
                      showDialog(
                        context: context,
                        builder: (context){
                          return SimpleDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
                            contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 5.0),
                                child: Text(
                                  "Selecione um interesse",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold
                                  ),
                                )
                              ),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: 300.0
                                ),
                                child: Scrollbar(
                                  child: SingleChildScrollView(
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
                                      initiallyExpanded: true,
                                      children: _interestModel.interestCategories.map(
                                        (category){
                                          return ScopedModelDescendant<InterestModel>(
                                            builder: (context, child, model){
                                              return ConfigurableExpansionTile(
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
                                                initiallyExpanded: model.filterCategoryId != null && model.filterCategoryId == category.categoryId ? true: false,
                                                animatedWidgetFollowingHeader: Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                                                  child: const Icon(
                                                    Icons.expand_more,
                                                  )
                                                ),
                                                children: <Widget>[
                                                  category.interests != null && category.interests.isNotEmpty ?
                                                    Container(
                                                      child: ListView(
                                                        shrinkWrap: true,
                                                        controller: _scrollController,
                                                        children: category.interests.map(
                                                          (interest){
                                                            if(InterestModel.filterInterest != null && InterestModel.filterInterest.interestId == interest.interestId){
                                                              interest.isSelected = true;
                                                            }else{
                                                              interest.isSelected = false;
                                                            }
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
                                                                _textController.clear();
                                                                model.onTapFilterInterest(interest);
                                                                Navigator.pop(context, true);
                                                              }
                                                            );
                                                          }
                                                        ).toList(),
                                                      )
                                                    )
                                                  : Container()
                                                ],
                                              );
                                            },
                                          );
                                      }).toList(),
                                    )
                                  )
                                )
                              )
                            ],
                          );
                        }
                      );
                    },
                    child: Chip(
                      avatar: Icon(Icons.filter_list),
                      label: Text("Buscar por interesse"),
                    )
                  ),
              ],
            )
          ),
          _textController.text.length > 0 ?
            FutureBuilder<QuerySnapshot>(
              future: _projectModel.searchProjectByName(_textController.text),
              builder: (context, projectsSnapshot){
                if(projectsSnapshot.hasData && projectsSnapshot.data.documents.isNotEmpty){
                  return Padding(
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: projectsSnapshot.data.documents.map(
                          (project){
                            Project _project = Project.fromDocument(project);

                            project.data["interesses"].map(
                              (interest){
                                _project.interesses.add(Interest.fromDynamic(interest, true));
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
                                margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                width: 350.0,
                                height: 200.0,
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
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                                          width: 350.0,
                                          decoration: BoxDecoration(
                                            color: Colors.deepPurple[400],
                                            borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
                                          ),
                                          child: Text(
                                              project.data["titulo"],
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14.0,
                                                color: Colors.white
                                              ),
                                            )
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                                          child: Text(
                                            project.data["descricao"],
                                            maxLines: 5,
                                            overflow: TextOverflow.fade,
                                            style: TextStyle(
                                              color: Colors.grey[600]
                                            ),
                                          )
                                        )
                                      ],
                                    ),
                                    Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: <Widget>[
                                              StreamBuilder<QuerySnapshot>(
                                                stream: _projectModel.listProjectMembers(docProject: project),
                                                builder: (context, membersSnapshot){
                                                  if(membersSnapshot.hasData && membersSnapshot.data.documents.isNotEmpty){
                                                    return Text(
                                                      membersSnapshot.data.documents.length > 1 ? membersSnapshot.data.documents.length.toString() + " membros" : membersSnapshot.data.documents.length.toString() + " membro",
                                                    );
                                                  }

                                                  return Container();
                                                },
                                              ),
                                              Text(
                                                " - ${project.data["dataCriacao"].toDate().day}/${project.data["dataCriacao"].toDate().month}/${project.data["dataCriacao"].toDate().year}",
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
                          }
                        ).toList()
                    )
                  );
                }

                return Container();
              },
            )
          : InterestModel.filterInterest != null ?
              FutureBuilder<QuerySnapshot>(
                future: _projectModel.searchProjectByInterest(InterestModel.filterInterest),
                builder: (context, projectsSnapshot){
                  if(projectsSnapshot.hasData && projectsSnapshot.data.documents.isNotEmpty){
                    return Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: projectsSnapshot.data.documents.map(
                            (project){
                              Project _project = Project.fromDocument(project);

                              project.data["interesses"].map(
                                (interest){
                                  _project.interesses.add(Interest.fromDynamic(interest, true));
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
                                  margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                  width: 350.0,
                                  height: 200.0,
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
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                                            width: 350.0,
                                            decoration: BoxDecoration(
                                              color: Colors.deepPurple[400],
                                              borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
                                            ),
                                            child: Text(
                                                project.data["titulo"],
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 3,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14.0,
                                                  color: Colors.white
                                                ),
                                              )
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                                            child: Text(
                                              project.data["descricao"],
                                              maxLines: 5,
                                              overflow: TextOverflow.fade,
                                              style: TextStyle(
                                                color: Colors.grey[600]
                                              ),
                                            )
                                          )
                                        ],
                                      ),
                                      Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: <Widget>[
                                                StreamBuilder<QuerySnapshot>(
                                                  stream: _projectModel.listProjectMembers(docProject: project),
                                                  builder: (context, membersSnapshot){
                                                    if(membersSnapshot.hasData && membersSnapshot.data.documents.isNotEmpty){
                                                      return Text(
                                                        membersSnapshot.data.documents.length > 1 ? membersSnapshot.data.documents.length.toString() + " membros" : membersSnapshot.data.documents.length.toString() + " membro",
                                                      );
                                                    }

                                                    return Container();
                                                  },
                                                ),
                                                Text(
                                                  " - ${project.data["dataCriacao"].toDate().day}/${project.data["dataCriacao"].toDate().month}/${project.data["dataCriacao"].toDate().year}",
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
                            }
                          ).toList()
                      )
                    );
                  }

                  return Container();
                },
              )
            : Container()
        ],
      )
    );
  }
}