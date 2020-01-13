import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:skill_box/src/datas/user.dart';
import 'package:skill_box/src/models/user_model.dart';
import 'package:skill_box/src/models/project_model.dart';


class ChatModel extends Model{
  final _firestore = Firestore.instance;

  static int messagesNotVisualized = 0;

  static List<DocumentSnapshot> chatMembers = [];

  UserModel userModel;

  ChatModel(this.userModel);

  static ChatModel of(BuildContext context) => ScopedModel.of<ChatModel>(context);

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);

  }

  void setChatMembers(List<DocumentSnapshot> listMembers){
    chatMembers = listMembers;
    notifyListeners();
  }

  Future<Null> checkMessagesQuantity(DocumentSnapshot docProject) async {
    await _firestore.collection("usuarios").document(userModel.user.userId).collection("projetos").document(docProject.documentID).collection("mensagens").where("visualizado", isEqualTo: false).getDocuments().then(
      (messages){
        ChatModel.messagesNotVisualized = 0;
        if(messages.documents != null){
          messagesNotVisualized += messages.documents.length;
        }
      }
    );
  }
  
  void sendMessage({String text, String imgUrl, String docUrl, String fileName, bool userStatus, List<User> projectMembers}) {
    if(projectMembers == null){
      chatMembers.map(
        (member) {
          DateTime sentDate = Timestamp.now().toDate().toUtc();
          Firestore.instance.collection("usuarios").document(member.data["userId"]).collection("mensagens").document(sentDate.toString()).setData(
            {
              "text" : text,
              "imgUrl" : imgUrl,
              "docUrl": docUrl,
              "fileName": fileName,
              "senderName" : userModel.user.nome,
              "senderPhotoUrl" : userModel.user.urlFoto,
              "senderId" : userModel.user.userId,
              "visualizado": false,
              "projectId": ProjectModel.project.projectId,
              "userStatus": userStatus
            }
          ).then(
            (resultAdd) {
              Firestore.instance.collection("usuarios").document(member.data["userId"]).collection("projetos").document(ProjectModel.project.projectId).updateData(
                {
                  "lastMessageDate" : sentDate
                }
              );
            }
          );
        }
      ).toList();
    }else{
      projectMembers.map(
        (member) {
          DateTime sentDate = Timestamp.now().toDate().toUtc();
          Firestore.instance.collection("usuarios").document(member.userId).collection("mensagens").document(sentDate.toString()).setData(
            {
              "text" : text,
              "imgUrl" : imgUrl,
              "docUrl": docUrl,
              "fileName": fileName,
              "senderName" : userModel.user.nome,
              "senderPhotoUrl" : userModel.user.urlFoto,
              "senderId" : userModel.user.userId,
              "visualizado": false,
              "projectId": ProjectModel.project.projectId,
              "userStatus": userStatus
            }
          ).then(
            (resultAdd) {
              Firestore.instance.collection("usuarios").document(member.userId).collection("projetos").document(ProjectModel.project.projectId).updateData(
                {
                  "lastMessageDate" : sentDate
                }
              );
            }
          );
        }
      ).toList();
    }
  }

}