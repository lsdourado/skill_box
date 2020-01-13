import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:skill_box/src/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:skill_box/src/widgets/image_photo_view.dart';


class ChatMessage extends StatelessWidget {

  final Map<String, dynamic> mensagem;

  ChatMessage(this.mensagem);
  

  @override
  Widget build(BuildContext context) {
    UserModel _userModel = UserModel.of(context);
        
    return Row(
      mainAxisAlignment: mensagem["senderId"] != _userModel.user.userId && mensagem["userStatus"] == false ? 
        MainAxisAlignment.start
      : mensagem["userStatus"] == false ?
        MainAxisAlignment.end
      : MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        mensagem["userStatus"] == true ?
          Flexible(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
              child: Text(
                mensagem["text"],
                textAlign: TextAlign.center,
              )
            )
          )
        : mensagem["senderId"] != _userModel.user.userId ? 
          Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: CircleAvatar(
              radius: 15.0,
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(mensagem["senderPhotoUrl"]),
            )
          )
        : Container(),

        mensagem["userStatus"] == false ?
          Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 300.0
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              margin: EdgeInsets.only(top: 15.0, left: 5.0, right: 10.0),
              decoration: BoxDecoration(
                color: mensagem["senderId"] != _userModel.user.userId ? Colors.white : Colors.deepPurple[200],
                border: Border.all(
                  color: Colors.grey[300],
                ),
                borderRadius: mensagem["senderId"] != _userModel.user.userId ? 
                  BorderRadius.only(bottomLeft: Radius.circular(20.0), bottomRight: Radius.circular(20.0), topRight: Radius.circular(20.0))
                : BorderRadius.only(bottomLeft: Radius.circular(20.0), bottomRight: Radius.circular(20.0), topLeft: Radius.circular(20.0)),
              ),
              child: mensagem["senderId"] != _userModel.user.userId ? 
                Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 5.0),
                    child: Text(
                      mensagem["senderName"],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )
                    )
                  ),

                  mensagem["imgUrl"] != null && mensagem["text"].toString().length > 0 ?
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        GestureDetector(
                          onTap: (){
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context)=>ImagePhotoView(mensagem["imgUrl"],mensagem["fileName"]))
                            );
                          },
                          child: Image.network(mensagem["imgUrl"], width: 200.0)
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text(mensagem["text"])
                        )
                      ],
                    )
                  : mensagem["docUrl"] != null && mensagem["text"].toString().length > 0 ?
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () async {
                              File file = await _downloadFile(mensagem["docUrl"], mensagem["fileName"]);

                              OpenFile.open(file.path);
                            },
                            child: Container(
                              padding: EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                color: Colors.grey.withOpacity(0.2)
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(Icons.description, color: Colors.grey[600]),
                                  Flexible(
                                    child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                                      child: Text(
                                        " " + mensagem["fileName"],
                                        style: TextStyle(color: Colors.grey[600]),
                                      )
                                    )
                                  )
                                ],
                              )
                            )
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: Text(mensagem["text"])
                          )
                        ],
                      )
                    : mensagem["imgUrl"] != null ?
                      GestureDetector(
                        onTap: (){
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context)=>ImagePhotoView(mensagem["imgUrl"],mensagem["fileName"]))
                          );
                        },
                        child: Image.network(mensagem["imgUrl"], width: 200.0)
                      )
                    : mensagem["docUrl"] != null ?
                        GestureDetector(
                          onTap: () async {
                            File file = await _downloadFile(mensagem["docUrl"], mensagem["fileName"]);

                            OpenFile.open(file.path);
                          },
                          child: Container(
                            padding: EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(15.0)),
                              color: Colors.grey.withOpacity(0.2)
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(Icons.description, color: Colors.grey[600]),
                                Flexible(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                                    child: Text(
                                      " " + mensagem["fileName"],
                                      style: TextStyle(color: Colors.grey[600]),
                                    )
                                  )
                                )
                              ],
                            )
                          )
                        )
                      : Text(mensagem["text"])
                ],
              )
            : mensagem["imgUrl"] != null && mensagem["text"].toString().length > 0 ?
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    GestureDetector(
                      onTap: (){
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context)=>ImagePhotoView(mensagem["imgUrl"],mensagem["fileName"]))
                        );
                      },
                      child: Image.network(mensagem["imgUrl"], width: 200.0)
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        mensagem["text"],
                        style: TextStyle(color: Colors.white),
                      )
                    )
                  ],
                )
              : mensagem["docUrl"] != null && mensagem["text"].toString().length > 0 ?
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () async {
                          File file = await _downloadFile(mensagem["docUrl"], mensagem["fileName"]);

                          OpenFile.open(file.path);
                        },
                        child: Container(
                          padding: EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(15.0)),
                            color: Colors.white.withOpacity(0.2)
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(Icons.description, color: Colors.white),
                              Flexible(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                                  child: Text(
                                    mensagem["fileName"],
                                    style: TextStyle(color: Colors.white),
                                  )
                                )
                              )
                            ],
                          )
                        )
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Text(
                          mensagem["text"],
                          style: TextStyle(color: Colors.white),
                        )
                      )
                    ],
                  )
                : mensagem["imgUrl"] != null ?
                    GestureDetector(
                      onTap: (){
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context)=>ImagePhotoView(mensagem["imgUrl"],mensagem["fileName"]))
                        );
                      },
                      child: Image.network(mensagem["imgUrl"], width: 200.0)
                    )
                : mensagem["docUrl"] != null ?
                    GestureDetector(
                      onTap: () async {
                        File file = await _downloadFile(mensagem["docUrl"], mensagem["fileName"]);

                        OpenFile.open(file.path);
                      },
                      child: Container(
                        padding: EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                          color: Colors.white.withOpacity(0.2)
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(Icons.description, color: Colors.white),
                            Flexible(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5.0),
                                child: Text(
                                  mensagem["fileName"],
                                  style: TextStyle(color: Colors.white),
                                )
                              )
                            )
                          ],
                        )
                      )
                    )
                  : Text(
                      mensagem["text"],
                      style: TextStyle(color: Colors.white),
                    )
            )
          ),
        )
        : Container()
      ],
    );
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