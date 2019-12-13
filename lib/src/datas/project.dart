import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skill_box/src/datas/interest.dart';
import 'package:skill_box/src/datas/user.dart';

class Project {
  String adminId;
  String projectId;
  String titulo;
  String descricao;
  List<User> membros = [];
  List<Interest> interesses = [];

  Project(this.adminId, this.projectId, this.titulo, this.descricao);

  Project.fromDocument(DocumentSnapshot document) {
    projectId = document.documentID;
    adminId = document.data["adminId"];
    titulo = document.data["titulo"];
    descricao = document.data["descricao"];
  }
  
}