import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:skill_box/src/datas/interest.dart';
import 'package:skill_box/src/datas/project.dart';
import 'package:skill_box/src/datas/user.dart';
import 'package:skill_box/src/models/chat_model.dart';
import 'package:skill_box/src/models/user_model.dart';

class ProjectModel extends Model{
  final _firestore = Firestore.instance;
  UserModel userModel;
  ChatModel chatModel;

  bool isLoading = false;
  bool isSendingFile = false;

  String docName;
  DateTime docSentDate;

  static Project project;

  List<Project> searchList = [];

  ProjectModel(this.userModel, this.chatModel);

  static ProjectModel of(BuildContext context) => ScopedModel.of<ProjectModel>(context);

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
  }

void addProject({@required Map<String, dynamic> projectData,@required VoidCallback onSuccess, @required VoidCallback onFail}) {
  isLoading = true;
  notifyListeners();

  _firestore.collection("projetos").document(projectData["dataCriacao"].toString()).setData(projectData).then(
    (result) {
      _firestore.collection("projetos").document(projectData["dataCriacao"].toString()).collection("membros").document(userModel.user.userId).setData(
        {
          "userId": userModel.user.userId,
          "nome": userModel.user.nome
        }
      ).then(
        (result) {
          projectData["projectId"] = projectData["dataCriacao"].toString();

          _firestore.collection("usuarios").document(userModel.user?.userId).collection("projetos").document(projectData["dataCriacao"].toString()).setData({
            "projectId": projectData["dataCriacao"].toString(),
            "lastMessageDate": projectData["dataCriacao"],
            "adminId": userModel.user.userId
          });

          onSuccess();
          
          isLoading = false;
          notifyListeners();
        }
      );
    }
  ).catchError((e){
    onFail();
    isLoading = false;
    notifyListeners();
  });
}

  void saveProject({@required Map<String, dynamic> projectData,@required VoidCallback onSuccess, @required VoidCallback onFail}) {
    isLoading = true;
    notifyListeners();

    _firestore.collection("projetos").document(projectData["projectId"]).updateData(
      {
        "adminId": projectData["adminId"],
        "projectId": projectData["projectId"],
        "titulo": projectData["titulo"],
        "descricao": projectData["descricao"],
        "interesses": projectData["interesses"]
      }
    ).then(
      (result) {
        onSuccess();

        isLoading = false;
        notifyListeners();
      }
    ).catchError((e){
      onFail();
      isLoading = false;
      notifyListeners();
    });
  }

  void inviteProject() {
    project.convites.add(userModel.user);

    Map<String, dynamic> mapInvite = Map();
    mapInvite["userId"] = userModel.user.userId;
    mapInvite["userName"] = userModel.user.nome;
    mapInvite["projectId"] = project.projectId;
    mapInvite["adminId"] = project.adminId;
    mapInvite["visualizado"] = false;

    DateTime sentDate = Timestamp.now().toDate().toUtc();

    _firestore.collection("usuarios").document(project.adminId).collection("convites").document(sentDate.toString()).setData(mapInvite);
  }

  Future<Null> cancelInviteProject() async {
    await _firestore.collection("usuarios").document(project.adminId).collection("convites").where("projectId", isEqualTo: project.projectId).getDocuments().then(
      (projects){
        projects.documents.map(
          (inviteProject) {
            if(inviteProject.data["userId"] == userModel.user.userId){
              _firestore.collection("usuarios").document(project.adminId).collection("convites").document(inviteProject.documentID).delete();
            }
          }
        ).toList();
      }
    );
  }

  void addMember(DocumentSnapshot userInvite) {
    _firestore.collection("usuarios").document(userInvite.data["userId"]).collection("projetos").document(userInvite.data["projectId"]).setData({
      "adminId": userInvite.data["adminId"],
      "projectId": userInvite.data["projectId"],
      "lastMessageDate": Timestamp.now().toDate().toUtc()
    }).then(
      (result) async {
        await _firestore.collection("projetos").document(userInvite.data["projectId"]).collection("membros").document(userInvite.data["userId"]).setData(
          {
            "userId": userInvite.data["userId"],
            "nome": userInvite.data["userName"]
          }
        ).then(
          (result) {
            _firestore.collection("usuarios").document(userInvite.data["adminId"]).collection("convites").document(userInvite.documentID).delete().then(
              (result) async {
                QuerySnapshot query = await _firestore.collection("projetos").document(userInvite.data["projectId"]).collection("membros").getDocuments();

                if(query.documents != null){
                  ChatModel.chatMembers = [];
                  query.documents.map(
                    (member){
                      if(member.documentID != userInvite.data["userId"]){
                        ChatModel.chatMembers.add(member);
                      }
                    }
                  ).toList();
                }

                chatModel.sendMessage(text: userInvite.data["userName"]+" entrou para o projeto", userStatus: true);
              }
            );
          }
        );
      }
    );
  }

  void switchAdminProject(User member) {
    project.membros.map(
      (projectMember) {
        _firestore.collection("usuarios").document(projectMember.userId).collection("projetos").document(project.projectId).updateData(
          {
            "adminId": member.userId
          }
        ).then(
          (resultUpdate) {
            _firestore.collection("projetos").document(project.projectId).updateData(
              {
                "adminId": member.userId
              }
            ).then(
              (result) async {
                await _firestore.collection("usuarios").document(userModel.user.userId).collection("convites").where("projectId", isEqualTo: project.projectId).getDocuments().then(
              (result){
                if(result.documents != null){
                  result.documents.map(
                    (docInvite){
                      docInvite.data["visualizado"] = false;
                      docInvite.data["adminId"] = member.userId;
                      _firestore.collection("usuarios").document(member.userId).collection("convites").document(docInvite.documentID).setData(docInvite.data);
                      _firestore.collection("usuarios").document(userModel.user.userId).collection("convites").document(docInvite.documentID).delete();
                    }
                  ).toList();
                }
              }
            );
              }
            );
          }
        );
      }
    ).toList();

    chatModel.sendMessage(text: member.nome+" tornou-se o administrador do projeto", userStatus: true, projectMembers: project.membros);
  }

  void deleteProject() {
    project.membros.map(
      (member) {
        _firestore.collection("usuarios").document(member.userId).collection("projetos").document(project.projectId).delete().then(
          (result) {
            _firestore.collection("projetos").document(project.projectId).collection("membros").document(member.userId).delete().then(
              (result){
                _firestore.collection("projetos").document(project.projectId).delete().then(
                  (result) async {
                    await _firestore.collection("usuarios").document(member.userId).collection("mensagens").where("projectId", isEqualTo: project.projectId).getDocuments().then(
                      (messages){
                        if(messages.documents != null){
                          messages.documents.map(
                            (message){
                              _firestore.collection("usuarios").document(member.userId).collection("mensagens").document(message.documentID).delete();
                            }
                          ).toList();
                        }
                      }
                    );
                  }
                );
              }
            );
          }
        );
      }
    ).toList();
  }

  void leaveProject() async {
    _firestore.collection("usuarios").document(userModel.user.userId).collection("projetos").document(project.projectId).delete().then(
      (result) async {
        _firestore.collection("projetos").document(project.projectId).collection("membros").document(userModel.user.userId).delete().then(
          (result) async {
            await _firestore.collection("usuarios").document(userModel.user.userId).collection("mensagens").where("projectId", isEqualTo: project.projectId).getDocuments().then(
              (messages){
                if(messages.documents != null){
                  messages.documents.map(
                    (message){
                      _firestore.collection("usuarios").document(userModel.user.userId).collection("mensagens").document(message.documentID).delete();
                    }
                  ).toList();
                }
              }
            );
          }
        );
      }
    );

    QuerySnapshot query = await _firestore.collection("projetos").document(project.projectId).collection("membros").getDocuments();

    if(query.documents != null){
      ChatModel.chatMembers = [];
      
      query.documents.map(
        (projectMember){
          if(projectMember.documentID != userModel.user.userId){
            ChatModel.chatMembers.add(projectMember);
          }
        }
      ).toList();
    }

    chatModel.sendMessage(text: userModel.user.nome+" saiu do projeto", userStatus: true);
  }

  void removeMember(User member) async {
    _firestore.collection("usuarios").document(member.userId).collection("projetos").document(project.projectId).delete().then(
      (result) {
        _firestore.collection("projetos").document(project.projectId).collection("membros").document(member.userId).delete().then(
          (result) async {
            await _firestore.collection("usuarios").document(member.userId).collection("mensagens").where("projectId", isEqualTo: project.projectId).getDocuments().then(
              (messages) {
                if(messages.documents != null){
                  messages.documents.map(
                    (message){
                      _firestore.collection("usuarios").document(member.userId).collection("mensagens").document(message.documentID).delete();
                    }
                  ).toList();
                }
              }
            );
          }
        );
      }
    );

    QuerySnapshot query = await _firestore.collection("projetos").document(project.projectId).collection("membros").getDocuments();

    if(query.documents != null){
      ChatModel.chatMembers = [];

      query.documents.map(
        (projectMember){
          if(projectMember.documentID != member.userId){
            ChatModel.chatMembers.add(projectMember);
          }
        }
      ).toList();
    }

    chatModel.sendMessage(text: member.nome+" foi removido do projeto", userStatus: true);
  }

  Stream<QuerySnapshot> listUserProjects({DocumentSnapshot docUser, User localUser}) {
    if(docUser != null){
      return _firestore.collection("usuarios").document(docUser.documentID).collection("projetos").snapshots();
    }else{
      return _firestore.collection("usuarios").document(localUser.userId).collection("projetos").snapshots();
    }
  }
  
  Stream<QuerySnapshot> listOnlyUserAdminProjects({DocumentSnapshot docUser, User localUser}) {
    if(docUser != null){
      return _firestore.collection("usuarios").document(docUser.documentID).collection("projetos").where("adminId", isEqualTo: docUser.documentID).snapshots();
    }else{
      return _firestore.collection("usuarios").document(localUser.userId).collection("projetos").where("adminId", isEqualTo: localUser.userId).snapshots();
    }
  }

  Stream<DocumentSnapshot> getProjectInfo({DocumentSnapshot docProject, Project localProject}) {
    if(docProject != null){
      return _firestore.collection("projetos").document(docProject.data["projectId"]).snapshots();
    }else{
      return _firestore.collection("projetos").document(localProject.projectId).snapshots();
    }
  }

  Stream<QuerySnapshot> listProjectMembers({DocumentSnapshot docProject, Project localProject}) {
    if(docProject != null){
      return _firestore.collection("projetos").document(docProject.documentID).collection("membros").orderBy("nome", descending: false).snapshots();
    }else{
      return _firestore.collection("projetos").document(localProject.projectId).collection("membros").orderBy("nome", descending: false).snapshots();
    }
  }

  void sendFile(File docFile) async {
    isSendingFile = true;
    notifyListeners();

    docSentDate = Timestamp.now().toDate().toUtc();

    docName = docFile.path.substring(docFile.path.lastIndexOf("/")+1, docFile.path.length);

    StorageReference ref = FirebaseStorage.instance.ref().child(docSentDate.toString()+"#"+docName);
    StorageUploadTask uploadTask = ref.putFile(docFile);

    var dowUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
    String url = dowUrl.toString();

    _firestore.collection("projetos").document(project.projectId).collection("arquivos").document(docSentDate.toString()).setData(
      {
        "docUrl": url,
        "docName": docSentDate.toString()+"#"+docName,
        "sentDate": docSentDate
      }
    );

    isSendingFile = false;
    notifyListeners();
  }

  void deleteFile(DocumentSnapshot docFile){
    var ref = FirebaseStorage.instance.ref().child(docFile["docName"]);
    ref.delete().then(
      (result) {
        _firestore.collection("projetos").document(project.projectId).collection("arquivos").document(docFile.documentID).delete();
        notifyListeners();
    }).catchError(
      (error) {
        print(error);
    });
  }

  Future<QuerySnapshot> searchProjectByName(String title) {
    return _firestore.collection("projetos").orderBy("titulo").endAt([title + '\uf8ff']).startAt([title]).getDocuments();
  }

  Future<QuerySnapshot> searchProjectByInterest(Interest interest) {
    return _firestore.collection("projetos").where("interesses", arrayContains: interest.toMap()).getDocuments();
  }

}