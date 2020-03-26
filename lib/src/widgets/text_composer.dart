import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:path_provider/path_provider.dart';
import 'package:skill_box/src/models/chat_model.dart';


class TextComposer extends StatefulWidget {

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  final _textController = TextEditingController();
  bool _isComposing = false;
  bool clickAttachTop = false;
  bool keyBoardOpen = false;
  File imgFile;
  File docFile;

  ChatModel _chatModel;

  @override
  void initState() {
    super.initState();

    KeyboardVisibilityNotification().addNewListener(
      onHide: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if(!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },

      onChange: (bool visibility){
        keyBoardOpen = visibility;
      }
    );

    _chatModel = ChatModel.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        imgFile != null ?
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Image.file(imgFile, width: 100),
                GestureDetector(
                  onTap: (){
                    setState(() {
                      imgFile = null;
                      _isComposing = false;
                    });
                  },
                  child: Icon(Icons.cancel, color: Colors.deepPurple)
                )
              ],
            )
          )
        : Container(),
        docFile != null?
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.description, color: Colors.grey),
                Flexible(
                  child: Text(docFile.path.substring(docFile.path.lastIndexOf("/")+1, docFile.path.length))
                ),
                GestureDetector(
                  onTap: (){
                    setState(() {
                      docFile = null;
                      _isComposing = false;
                    });
                  },
                  child: Icon(Icons.cancel, color: Colors.deepPurple)
                )
              ],
            )
          )
        : Container(),
        clickAttachTop ? 
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                GestureDetector(
                  onTap: (){
                    setState(() {
                      if(keyBoardOpen){
                        FocusScope.of(context).requestFocus(FocusNode());
                      }
                      _getDocument();
                      clickAttachTop = false;
                    });
                  },
                  child: CircleAvatar(
                    radius: 25.0,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.description, color: Colors.white, size: 20.0)
                  )
                ),
                GestureDetector(
                  onTap: (){
                    setState(() {
                      if(keyBoardOpen){
                        FocusScope.of(context).requestFocus(FocusNode());
                      }
                      _getGallery();
                      clickAttachTop = false;
                    });
                  },
                  child: CircleAvatar(
                    radius: 25.0,
                    backgroundColor: Colors.deepOrange,
                    child: Icon(Icons.photo, color: Colors.white, size: 20.0)
                  )
                ),
                GestureDetector(
                  onTap: (){
                    setState(() {
                      if(keyBoardOpen){
                        FocusScope.of(context).requestFocus(FocusNode());
                      }
                      _getCamera();
                      clickAttachTop = false;
                    });
                  },
                  child: CircleAvatar(
                    radius: 25.0,
                    backgroundColor: Colors.blueGrey,
                    child: Icon(Icons.camera_alt, color: Colors.white, size: 20.0)
                  )
                )
              ],
            )
          )
        : Container(),
        Divider(height: 1.0),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 120.0
                  ),
                  child: Scrollbar(
                    child: TextField(
                      controller: _textController,
                      maxLines: null,
                      decoration: InputDecoration.collapsed(hintText: "Digite uma mensagem"),
                      onChanged: (text) {
                        setState(() {
                          _isComposing = text.length > 0;
                        });
                      },
                    )
                  )
                )
              ),
              GestureDetector(
                onTap: (){
                  setState(() {
                    if(clickAttachTop){
                      clickAttachTop = false;
                    }else{
                      clickAttachTop = true;
                    }
                  });
                },
                child: CircleAvatar(
                  backgroundColor: Colors.grey[400],
                  child: Icon(Icons.attach_file, color: Colors.white, size: 20.0)
                )
              ),
              Padding(
                padding: EdgeInsets.only(left: 5.0),
                child: CircleAvatar(
                  backgroundColor: _isComposing ? Colors.deepPurple : Colors.grey[400],
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white, size: 20.0),
                    onPressed: _isComposing ? () async {
                      if(imgFile != null){
                        String imgName = imgFile.path.substring(imgFile.path.lastIndexOf("/")+1, imgFile.path.length);
                            
                        StorageReference ref = FirebaseStorage.instance.ref().child(imgName);
                        StorageUploadTask uploadTask = ref.putFile(imgFile);

                        var dowUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
                        String url = dowUrl.toString();

                        _chatModel.sendMessage(imgUrl: url, fileName: imgName, text: _textController.text, userStatus: false);
                      }else if(docFile != null){
                        String docName = docFile.path.substring(docFile.path.lastIndexOf("/")+1, docFile.path.length);

                        StorageReference ref = FirebaseStorage.instance.ref().child(docName);
                        StorageUploadTask uploadTask = ref.putFile(docFile);

                        var dowUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
                        String url = dowUrl.toString();

                        _chatModel.sendMessage(docUrl: url, fileName: docName, text: _textController.text, userStatus: false);
                      }else{
                        _chatModel.sendMessage(text: _textController.text, userStatus: false);
                      }

                      _reset();
                    } : null,
                  )
                )
              ),
            ],
          )
        ),
      ],
    );
  }
  void _reset(){
    _textController.clear();
    setState(() {
      _isComposing = false;
      imgFile = null;
      docFile = null;
    });
  }

  void _getCamera() async {
    File localImgFile = await ImagePicker.pickImage(source: ImageSource.camera);

    if(localImgFile == null) return;

    setState(() {
      imgFile = localImgFile;
      _isComposing = true;
    });

    
  }

  void _getGallery() async {
    File localImgFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if(localImgFile == null) return;

    setState(() {
      imgFile = localImgFile;
      _isComposing = true;
    });
    
  }

  void _getDocument() async {
    File file = await FilePicker.getFile();
                
    if(file == null) return;

    setState(() {
      docFile = file;
      _isComposing = true;
    });
  }
}