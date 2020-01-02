import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:skill_box/src/datas/project.dart';
import 'package:skill_box/src/datas/user.dart';
import 'package:skill_box/src/models/user_model.dart';

class ProjectModel extends Model{
  final _firestore = Firestore.instance;
  UserModel userModel;

  bool isLoading = false;

  static Project project;

  ProjectModel(this.userModel);

  static ProjectModel of(BuildContext context) => ScopedModel.of<ProjectModel>(context);

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
  }

Future<Null> addProject({@required Map<String, dynamic> projectData,@required VoidCallback onSuccess, @required VoidCallback onFail}) async {
  isLoading = true;
  notifyListeners();

  await _firestore.collection("projetos").add(projectData).then(
    (result) async {
      projectData["projectId"] = result.documentID;

      await _firestore.collection("usuarios").document(userModel.user?.userId).collection("projetos").document(result.documentID).setData({
        "projectId": result.documentID
      });

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

  Future<Null> saveProject({@required Map<String, dynamic> projectData,@required VoidCallback onSuccess, @required VoidCallback onFail}) async {
    isLoading = true;
    notifyListeners();

    await _firestore.collection("projetos").document(projectData["projectId"]).updateData(
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

  Future<Null> inviteProject() async {
    project.convites.add(userModel.user);

    Map<String, dynamic> mapInvite;
    mapInvite = userModel.user.toMap();
    mapInvite["projectId"] = project.projectId;
    mapInvite["projectTitle"] = project.titulo;
    mapInvite["visualizado"] = false;

    await _firestore.collection("usuarios").document(project.adminId).collection("convites").add(mapInvite);
  }

  Future<Null> cancelInviteProject() async {
    await _firestore.collection("usuarios").document(project.adminId).collection("convites").where("projectId", isEqualTo: project.projectId).getDocuments().then(
      (projects){
        projects.documents.map(
          (inviteProject) async {
            if(inviteProject.data["userId"] == userModel.user.userId){
              await _firestore.collection("usuarios").document(project.adminId).collection("convites").document(inviteProject.documentID).delete();
            }
          }
        ).toList();
      }
    );
  }

  Future<Null> addMember(DocumentSnapshot userInvite) async {
    List<User> membros = [];

    await _firestore.collection("projetos").document(userInvite["projectId"]).get().then(
      (project) async {
        project.data["membros"].map(
          (member){
            User u = User(null);

            u.userId = member["userId"];
            u.urlFoto = member["urlFoto"];
            u.telefone = member["telefone"];
            u.sobre = member["sobre"];
            u.nome = member["nome"];
            u.emailSecundario = member["emailSecundario"];
            u.email = member["email"];

            membros.add(u);
          }
        ).toList();

        User user = User(null);
        user.fromDocument(userInvite);
        user.userId = userInvite["userId"];

        membros.add(user);

        await _firestore.collection("projetos").document(project.documentID).updateData({
          "membros": membros.map((member) => member.toMap()).toList()
        }).then(
          (result) async {
            await _firestore.collection("usuarios").document(user.userId).collection("projetos").document(project.documentID).setData({
              "projectId": project.documentID
            }).then(
              (result) async {
                await _firestore.collection("usuarios").document(project.data["adminId"]).collection("convites").document(userInvite.documentID).delete();
              }
            );
          }
        );
      }
    );
  }

  Future<Null> switchAdminProject(User member) async {
    await _firestore.collection("projetos").document(project.projectId).updateData(
      {
        "adminId": member.userId
      }
    );
  }

  Future<Null> deleteProject() async {
    await _firestore.collection("projetos").document(project.projectId).delete().then(
      (result) {
        project.membros.map(
          (member) async {
            await _firestore.collection("usuarios").document(member.userId).collection("projetos").document(project.projectId).delete();
          }
        ).toList();
      }
    );
  }

  Future<Null> leaveProject(User member) async {
    List<User> membros = [];

    project.membros.map(
      (projectMember){
        if(member.userId != projectMember.userId){
          User u = User(null);

          u.userId = projectMember.userId;
          u.urlFoto = projectMember.urlFoto;
          u.telefone = projectMember.telefone;
          u.sobre = projectMember.sobre;
          u.nome = projectMember.nome;
          u.emailSecundario = projectMember.emailSecundario;
          u.email = projectMember.email;

          membros.add(u);
        }
      }
    ).toList();

    await _firestore.collection("projetos").document(project.projectId).updateData(
      {
        "membros": membros.map((user) => user.toMap()).toList()
      }
    ).then(
      (result) async {
        await _firestore.collection("usuarios").document(member.userId).collection("projetos").document(project.projectId).delete().then(
          (result){
            userModel.loadFeedProjects();
          }
        );
      }
    );
  }

  Future<Null> removeMember(User member) async {
    List<User> membros = [];

    project.membros.map(
      (projectMember){
        if(member.userId != projectMember.userId){
          User u = User(null);

          u.userId = projectMember.userId;
          u.urlFoto = projectMember.urlFoto;
          u.telefone = projectMember.telefone;
          u.sobre = projectMember.sobre;
          u.nome = projectMember.nome;
          u.emailSecundario = projectMember.emailSecundario;
          u.email = projectMember.email;

          membros.add(u);
        }
      }
    ).toList();

    await _firestore.collection("projetos").document(project.projectId).updateData(
      {
        "membros": membros.map((user) => user.toMap()).toList()
      }
    ).then(
      (result) async {
        await _firestore.collection("usuarios").document(member.userId).collection("projetos").document(project.projectId).delete();
      }
    );
  }

}