import 'package:flutter/material.dart';
import 'package:skill_box/src/models/user_model.dart';
import 'package:skill_box/src/datas/project.dart';
import 'package:skill_box/src/datas/user.dart';
import 'package:skill_box/src/models/project_model.dart';

class SwitchAdminDialog extends StatefulWidget {
  @override
  _SwitchAdminDialogState createState() => _SwitchAdminDialogState();
}

class _SwitchAdminDialogState extends State<SwitchAdminDialog> {
  UserModel _userModel;
  ProjectModel _projectModel;
  Project _project;
  User selectedMember = User(null);

  @override
  void initState() {
    super.initState();
    _userModel = UserModel.of(context);
    _projectModel = ProjectModel.of(context);
    _project = ProjectModel.project;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
      content: Container(
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Antes você precisa selecionar algum membro para transferir a administração do projeto"),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _project.membros.map(
                    (member){
                      if(member.userId != _userModel.user.userId){
                        return GestureDetector(
                          onTap: (){
                            setState(() {
                              selectedMember = member;
                            });
                          },
                          child: Chip(
                            backgroundColor: selectedMember.userId == member.userId ? Colors.deepPurple[200] : null,
                            avatar: CircleAvatar(
                              backgroundColor: Colors.grey[400],
                              foregroundColor: Colors.black,
                              backgroundImage: NetworkImage(member.urlFoto),
                            ),
                            label: Text(
                              member.nome,
                              style: TextStyle(
                                color: selectedMember.userId == member.userId ? Colors.white : null
                              ),
                            )
                          )
                        );
                      }else{
                        return Container();
                      }
                    }
                  ).toList()
                )
              ],
            )
          ),
        )
      ),
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
            _projectModel.switchAdminProject(selectedMember).then(
              (resultSwitch){
                _projectModel.leaveProject(_userModel.user);
              }
            );
            Navigator.pop(context, true);
          },
          child: Text("OK"),
        )
      ],
    );
  }
}