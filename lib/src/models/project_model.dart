import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:skill_box/src/datas/project.dart';
import 'package:skill_box/src/models/user_model.dart';

class ProjectModel extends Model{
  final _firestore = Firestore.instance;
  UserModel userModel;

  bool isLoading = false;

  List<Project> feedProjects = [];

  static Project project;

  ProjectModel(this.userModel);

  static ProjectModel of(BuildContext context) => ScopedModel.of<ProjectModel>(context);

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
  }

  void setEditingProject(Project p){
    isLoading = true;
    notifyListeners();

    project = p;

    isLoading = false;
    notifyListeners();
  }


Future<Null> addProject({@required Map<String, dynamic> projectData,@required VoidCallback onSuccess, @required VoidCallback onFail}) async {
  userModel.isLoading = true;
  userModel.notifyListeners();
  isLoading = true;
  notifyListeners();

  await _firestore.collection("projetos").add(projectData).then(
    (result) async {
      projectData["projectId"] = result.documentID;

      await _firestore.collection("usuarios").document(userModel.user?.userId).collection("projetos").document(result.documentID).setData({
        "projectId": result.documentID
      });

      userModel.loadUserProjects();

      onSuccess();

      userModel.isLoading = false;
      userModel.notifyListeners();
      isLoading = false;
      notifyListeners();
    }
  ).catchError((e){
    onFail();
    userModel.isLoading = false;
    userModel.notifyListeners();
    isLoading = false;
    notifyListeners();
  });
}

  Future<Null> saveProject({@required Map<String, dynamic> projectData,@required VoidCallback onSuccess, @required VoidCallback onFail}) async {
    userModel.isLoading = true;
    userModel.notifyListeners();
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
        userModel.loadUserProjects();
        onSuccess();

        userModel.isLoading = false;
        userModel.notifyListeners();
        isLoading = false;
        notifyListeners();
      }
    ).catchError((e){
      onFail();
      userModel.isLoading = false;
      userModel.notifyListeners();
      isLoading = false;
      notifyListeners();
    });
  }

}