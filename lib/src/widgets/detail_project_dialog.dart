import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:configurable_expansion_tile/configurable_expansion_tile.dart';
import 'package:flutter/material.dart';
import 'package:skill_box/src/datas/project.dart';
import 'package:skill_box/src/models/project_model.dart';

class DetailProjectDialog extends StatefulWidget {
  ProjectModel _projectModel;
  Project _project;
  bool _fromFeed;
  

  DetailProjectDialog(Project project, ProjectModel projectModel, bool fromFeed){
    _project = project;
    _projectModel = projectModel;
    _fromFeed = fromFeed;
  }

  @override
  _DetailProjectDialogState createState() => _DetailProjectDialogState();
}

class _DetailProjectDialogState extends State<DetailProjectDialog> {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      titlePadding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 1.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection("usuarios").document(widget._project.adminId).collection("convites").where("userId", isEqualTo: widget._projectModel.userModel.user.userId).snapshots(),
            builder: (context, snapshot){
              if(snapshot.hasData){
                bool flagInvited = false;

                snapshot.data.documents.map(
                  (docProject){
                    if(docProject.data["projectId"] == widget._project.projectId){
                      flagInvited = true;
                    }
                  }
                ).toList();

                if(widget._fromFeed){
                  return RaisedButton(
                    onPressed: (){
                      ProjectModel.project = widget._project;
                      flagInvited ? widget._projectModel.cancelInviteProject() : widget._projectModel.inviteProject();
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                    color: flagInvited ? Colors.red : Colors.green,
                    textColor: Colors.white,
                    child: Text(
                      flagInvited ? "Cancelar pedido" : "Pedir para participar"
                    ),
                  );
                }
              }else if(widget._fromFeed){
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

              return Container();
            },
          )
        ],
      ),
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: Text(
                  widget._project.titulo,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  )
                )
              ),
              Text(
                widget._project.descricao,
              )
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0,vertical: 10.0),
          child: ConfigurableExpansionTile(
            header: Flexible(
              child: Row(
                children: <Widget>[
                  Icon(Icons.group,size: 20.0),
                  Text(
                    " Membros (${widget._project.membros.length})",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              )
            ),
            animatedWidgetFollowingHeader: const Icon(
              Icons.expand_more,
            ),
            children: widget._project.membros.map(
              (member){
                return Padding(
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
                              backgroundImage: member != null ? NetworkImage(member.urlFoto) : Icon(Icons.person),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 10.0),
                              child: Text(member.nome),
                            ),
                          ],
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          widget._project.adminId == member.userId? 
                            Text(
                              "Admin",
                              style: TextStyle(
                                color: Colors.lightGreen,
                                fontWeight: FontWeight.bold
                              ),
                            )
                          : Text(""),

                          widget._project.adminId == widget._projectModel.userModel.user.userId  && member.userId != widget._projectModel.userModel.user.userId ? GestureDetector(
                            onTap: (){
                              setState(() {
                                ProjectModel.project = widget._project;
                                widget._projectModel.removeMember(member);
                              });
                            },
                            child: Icon(Icons.remove_circle, color: Colors.redAccent),
                          ) : Container(),
                        ],
                      )
                    ],
                  )
                );
              }
            ).toList()
          )
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: ConfigurableExpansionTile(
            header: Flexible(
              child: Row(
                children: <Widget>[
                  Icon(Icons.description, size: 20.0),
                  Text(
                    " Arquivos",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              )
            ),
            animatedWidgetFollowingHeader: const Icon(
              Icons.expand_more,
            ),
          )
        )
      ],
    );
  }

  void onSuccess(){
    Navigator.pop(context, true);
  }
}