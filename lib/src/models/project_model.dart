import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:skill_box/src/datas/interest.dart';
import 'package:skill_box/src/datas/project.dart';
import 'package:skill_box/src/datas/user.dart';
import 'package:skill_box/src/models/user_model.dart';

class ProjectModel extends Model{
  final _firestore = Firestore.instance;
  UserModel userModel;

  bool isLoading = false;

  Project project;

  ProjectModel(this.userModel);

  static ProjectModel of(BuildContext context) => ScopedModel.of<ProjectModel>(context);

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
  }

  Future<Null> loadProjectInfo(Project p) async {
    project = p;

    isLoading = true;
    notifyListeners();

    QuerySnapshot query = await _firestore.collection("projetos").document(project.projectId).collection("interesses").getDocuments();

    if(query.documents != null){
      project.interesses = query.documents.map((doc) => Interest.fromDocument(doc, true, doc.data["categoryId"])).toList();
    }

    query = await _firestore.collection("projetos").document(project.projectId).collection("membros").getDocuments();

    if(query.documents != null){
      query.documents.map(
        (doc){
          User user = User(null);

          user.fromDocument(doc);

          project.membros.add(user);
        }
      ).toList();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<Null> addProject({@required Map<String, dynamic> projectData, @required List<Interest> interestList,@required VoidCallback onSuccess, @required VoidCallback onFail}) async {
    projectData["adminId"] = userModel.user.userId;

    await _firestore.collection("projetos").add(projectData).then(
      (result) async {

        interestList.map(
          (interest) async {
            if(interest.isSelected == true){
              await _firestore.collection("projetos").document(result.documentID).
              collection("interesses").document(interest.interestId).setData(interest.toMap());
            }
          }
        ).toList();

        await _firestore.collection("projetos").document(result.documentID).collection("membros").document(projectData["adminId"]).setData(userModel.user.toMap());

        await _firestore.collection("usuarios").document(userModel.user.userId).collection("projetos").document(result.documentID).setData(projectData);

        project = Project(projectData["adminId"], result.documentID, projectData["titulo"], projectData["descricao"]);

        userModel.user.projetos.add(project);
        
        onSuccess();

        notifyListeners();
      }
    ).catchError((e){
      onFail();
      isLoading = false;
      notifyListeners();
    });
  }

  Future<Null> saveProject({@required Map<String, dynamic> projectData, @required List<Interest> interestList,@required VoidCallback onSuccess, @required VoidCallback onFail}) async {
    isLoading = true;
    notifyListeners();

    await _firestore.collection("projetos").document(projectData["projectId"]).setData(projectData).then(
      (result) async {

        await _firestore.collection("usuarios").document(projectData["adminId"]).collection("projetos").document(projectData["projectId"]).setData(projectData);

        notifyListeners();

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

}