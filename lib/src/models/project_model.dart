import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:skill_box/src/datas/interest.dart';
import 'package:skill_box/src/datas/project.dart';
import 'package:skill_box/src/datas/user.dart';

class ProjectModel extends Model{
  final _firestore = Firestore.instance;

  bool isLoading = false;

  Project project;

  static ProjectModel of(BuildContext context) => ScopedModel.of<ProjectModel>(context);

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
  }

  Future<Null> addProject({@required Map<String, dynamic> projectData, @required List<User> membersList, @required List<Interest> interestList,@required VoidCallback onSuccess, @required VoidCallback onFail}) async {
    await _firestore.collection("projetos").add(projectData).then(
      (result) async {

        interestList.map(
          (interest){
            if(interest.isSelected == true){
              _firestore.collection("projetos").document(result.documentID).
              collection("interesses").document(interest.interestId).setData(interest.toMap());
            }
          }
        ).toList();

        membersList.map(
          (member){
            _firestore.collection("projetos").document(result.documentID).
              collection("membros").document(member.userId).setData(member.toMap());

              _firestore.collection("usuarios").document(member.userId).
              collection("projetos").document(result.documentID).setData(projectData);
          }
        ).toList();

        notifyListeners();

        onSuccess();
      }
    ).catchError((e){
      onFail();
      isLoading = false;
      notifyListeners();
    });
  }

}