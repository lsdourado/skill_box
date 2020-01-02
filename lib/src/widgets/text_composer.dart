import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skill_box/src/datas/project.dart';
import 'package:skill_box/src/models/project_model.dart';
import 'package:skill_box/src/models/user_model.dart';

class TextComposer extends StatefulWidget {
  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  final _textController = TextEditingController();
  bool _isComposing = false;

  UserModel _userModel;
  Project _project;

  @override
  void initState() {
    super.initState();

    _userModel = UserModel.of(context);
    _project = ProjectModel.project;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 10.0),
              margin: EdgeInsets.only(right: 5.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50.0),
                border: Border.all(
                  style: BorderStyle.solid,
                  width: 0.5,
                  color: Colors.grey[300]
                )
              ),
              child: TextField(
                controller: _textController,
                enabled: _project.membros.length > 1,
                decoration: InputDecoration.collapsed(hintText: "Digite uma mensagem"),
                onChanged: (text) {
                  setState(() {
                    _isComposing = text.length > 0;
                  });
                },
              ),
            ),
          ),
          CircleAvatar(
            backgroundColor: _isComposing ? Colors.deepPurple : Colors.grey[400],
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: _isComposing ? () {
                _sendMessage(text: _textController.text);
              } : null,
            )
          )
        ],
      )
    );
  }

  void _sendMessage({String text, String imgUrl}){
    Firestore.instance.collection("projetos").document(_project.projectId).collection("mensagens").add(
      {
        "text" : text,
        "imgUrl" : imgUrl,
        "senderName" : _userModel.user.nome,
        "senderPhotoUrl" : _userModel.user.urlFoto,
        "senderId" : _userModel.user.userId,
        "sentDate" : Timestamp.now()
      }
    );

    _reset();
  }

  void _reset(){
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
  }
}