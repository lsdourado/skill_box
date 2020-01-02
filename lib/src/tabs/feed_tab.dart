import 'package:configurable_expansion_tile/configurable_expansion_tile.dart';
import 'package:flutter/material.dart';
import 'package:skill_box/src/models/project_model.dart';
import 'package:skill_box/src/models/user_model.dart';
import 'package:skill_box/src/widgets/detail_project_dialog.dart';

class FeedTab extends StatefulWidget {
  @override
  _FeedTabState createState() => _FeedTabState();
}

class _FeedTabState extends State<FeedTab> {

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
      return RefreshIndicator(
          displacement: 20.0,
          onRefresh: () async {
            _userModel.loadFeedProjects();
          },
          child: ListView(
            children: _userModel.user.interesses.map(
              (userInterest){
                bool hasProject = false;

                UserModel.feedProjects.map(
                  (project){
                    project.interesses.map(
                      (projectInterest){
                        if(projectInterest.interestId == userInterest.interestId){
                          hasProject = true;
                        }
                      }
                    ).toList();
                  }
                ).toList();

                return Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: ConfigurableExpansionTile(
                        initiallyExpanded: true,
                        animatedWidgetFollowingHeader: const Icon(
                          Icons.expand_more,
                        ),
                        header: Flexible(
                          child: Row(
                            children: <Widget>[
                              Container(
                                child: Text(
                                  userInterest.titulo,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ),
                        children: <Widget>[
                          hasProject ? Container(
                            height: 230.0,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: UserModel.feedProjects.map(
                                (project){
                                  bool hasInterest = false;

                                  project.interesses.map(
                                    (projectInterest){
                                      if(projectInterest.interestId == userInterest.interestId){
                                        hasInterest = true;
                                      }
                                    }
                                  ).toList();

                                  if(hasInterest){
                                    return GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context){
                                            ProjectModel.project = project;
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
                                                  padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                                                  width: 300.0,
                                                  decoration: BoxDecoration(
                                                    color: Colors.deepPurple[400],
                                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
                                                  ),
                                                  child: Text(
                                                      project.titulo,
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
                                                    project.descricao,
                                                    maxLines: 5,
                                                    overflow: TextOverflow.fade,
                                                    style: TextStyle(
                                                      color: Colors.grey[600]
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
                                    return Container();
                                  }
                                }
                              ).toList(),
                            ),
                          ) : Container()
                        ],
                      )
                    ),
                  ],
                );
              }
            ).toList()
          )
        );
    }else{
      return Container();
    }
  }
}
