import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skill_box/src/datas/project.dart';
import 'package:skill_box/src/models/project_model.dart';
import 'package:skill_box/src/models/user_model.dart';
import 'package:skill_box/src/widgets/chat_message.dart';
import 'package:skill_box/src/widgets/text_composer.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  Project _project;

  @override
  void initState() {
    super.initState();

    _project = ProjectModel.project;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Flexible(
                  child: Text(
                    _project.titulo,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17.0
                    ),
                  )
                )
              ],
            ),
            Text(
              _project.membros.length > 1 ? _project.membros.length.toString() + " membros" : _project.membros.length.toString() + " membro",
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 13.0
              ),
            )
          ],
        )
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: _project.membros.length == 1 ? 
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.speaker_notes_off, color: Colors.grey, size: 40.0),
                Text(
                  "Você só pode enviar mensagens se o projeto possuir outro membro",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold
                  ),
                )
              ],
            )
          : StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection("projetos").document(_project.projectId).collection("mensagens").orderBy("sentDate", descending: true).snapshots(),
              builder: (context,snapshot){
                if(snapshot.hasData && snapshot.data.documents.isNotEmpty){
                  return Scrollbar(
                    child: ListView(
                      reverse: true,
                      children: snapshot.data.documents.map(
                        (mensagem){
                          return ChatMessage(mensagem.data);
                        }
                      ).toList()
                    )
                  );
                }else{
                  return Container();
                }
              },
            )
          ),
          TextComposer()
        ],
      ),
    );
  }
}