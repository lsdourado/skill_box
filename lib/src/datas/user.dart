import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skill_box/src/datas/interest.dart';
import 'package:skill_box/src/datas/project.dart';

class User {
  String userId;
  String urlFoto;
  String nome;
  String email;
  String emailSecundario;
  String sobre;
  String telefone;
  List<Interest> interesses;
  List<Project> projetos;

  User(FirebaseUser firebaseUser){
    this.userId = firebaseUser?.uid;
    this.urlFoto = firebaseUser?.photoUrl;
    this.nome = firebaseUser?.displayName;
    this.email = firebaseUser?.email;
  }

  void fromDocument(DocumentSnapshot docUser) {
    userId = docUser.documentID;
    nome = docUser.data["nome"];
    email = docUser.data["email"];
    emailSecundario = docUser.data["email_secundario"];
    telefone = docUser.data["telefone"];
    sobre = docUser.data["sobre"];
  }

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "nome": nome,
      "email": email,
      "emailSecundario": emailSecundario,
      "sobre": sobre,
      "telefone": telefone,
    };
  }
}