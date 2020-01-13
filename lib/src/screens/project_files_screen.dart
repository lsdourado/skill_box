import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:skill_box/src/datas/project.dart';
import 'package:skill_box/src/models/project_model.dart';
import 'package:http/http.dart' as http;

class ProjectFilesScreen extends StatefulWidget {
  @override
  _ProjectFilesScreenState createState() => _ProjectFilesScreenState();
}

class _ProjectFilesScreenState extends State<ProjectFilesScreen> {

  Project _project;
  ProjectModel _projectModel;

  @override
  void initState() {
    super.initState();

    _projectModel = ProjectModel.of(context);
    _project = ProjectModel.project;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_project.titulo)
      ),
      floatingActionButton: _project.adminId == _projectModel.userModel.user.userId ?
        FloatingActionButton(
          onPressed: (){
            _getDocument();
          },
          mini: true,
          child: Icon(Icons.file_upload, color: Colors.white, size: 20.0)
        )
      : null,
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Padding(
            padding: _project.adminId == _projectModel.userModel.user.userId ? EdgeInsets.only(bottom: 70.0) : EdgeInsets.all(0.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _projectModel.isSendingFile ?
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                _projectModel.docName
                              )
                            ),
                            SizedBox(
                              height: 30.0,
                              width: 30.0,
                              child: CircularProgressIndicator()
                            )
                          ],
                        )
                      ),
                    ],
                  )
                : Container(),
                FutureBuilder<QuerySnapshot>(
                  future: Firestore.instance.collection("projetos").document(_project.projectId).collection("arquivos").getDocuments(),
                  builder: (context, filesSnapshot){
                    if(filesSnapshot.hasData && filesSnapshot.data.documents.isNotEmpty){
                      return Column(
                        children: filesSnapshot.data.documents.reversed.map(
                          (file){
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                border: Border.all(
                                  width: 0.5,
                                  color:Colors.deepPurple
                                )
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: filesSnapshot.data.documents[0].documentID == file.documentID ? EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 15.0) : EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Flexible(
                                          child: Text(
                                            file.data["docName"].toString().substring(
                                              file.data["docName"].toString().lastIndexOf("#")+1,
                                              file.data["docName"].toString().length
                                            )
                                          )
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.only(right: 10.0),
                                              child: GestureDetector(
                                                onTap: () async {
                                                  File localFile = await _downloadFile(file.data["docUrl"], file.data["docName"]);

                                                  OpenFile.open(localFile.path);
                                                },
                                                child: CircleAvatar(
                                                  radius: 15.0,
                                                  backgroundColor: Colors.green,
                                                  child: Icon(Icons.file_download, color: Colors.white, size: 15.0),
                                                )
                                              )
                                            ),
                                            _project.adminId == _projectModel.userModel.user.userId ?
                                              GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context){
                                                    return AlertDialog(
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
                                                      content: Text("Excluir arquivo?"),
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
                                                          _projectModel.deleteFile(file);

                                                          Navigator.pop(context, true);
                                                          },
                                                          child: Text("OK"),
                                                        )
                                                      ],
                                                    );
                                                  }
                                                );
                                              },
                                              child: CircleAvatar(
                                                radius: 15.0,
                                                backgroundColor: Colors.redAccent,
                                                child: Icon(Icons.delete, color: Colors.white, size: 15.0),
                                              )
                                            )
                                          : Container()
                                          ],
                                        )
                                      ],
                                    )
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                    child: Text(
                                      file.data["sentDate"].toDate().toLocal().day.toString()+"/"+file.data["sentDate"].toDate().toLocal().month.toString()+"/"+file.data["sentDate"].toDate().toLocal().year.toString(),
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey
                                      ),                              
                                    )
                                  )
                                ],
                              )
                            );
                          }
                        ).toList()
                      );
                    }

                    return Container();
                  },
                )
              ],
            )
          )
        ),
      ),
    );
  }

  void _getDocument() async {
    File file = await FilePicker.getFile();
                
    if(file == null) return;

    _projectModel.sendFile(file);
  }

  Future<File> _downloadFile(String url, String filename) async {
    http.Client client = new http.Client();
    var req = await client.get(Uri.parse(url));
    var bytes = req.bodyBytes;
    String dir = (await getTemporaryDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }
}