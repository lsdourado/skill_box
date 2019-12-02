import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skill_box/src/datas/interest.dart';

class User {
  String userId;
  String urlFoto;
  String nome;
  String email;
  String email_secundario;
  String sobre;
  String telefone;
  List<Interest> interesses;

  User(FirebaseUser firebaseUser){
    this.userId = firebaseUser?.uid;
    this.urlFoto = firebaseUser?.photoUrl;
    this.nome = firebaseUser?.displayName;
    this.email = firebaseUser?.email;
  }

  void fromDocument(DocumentSnapshot docUser) {
    email_secundario = docUser.data["email_secundario"];
    telefone = docUser.data["telefone"];
    sobre = docUser.data["sobre"];
  }

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "nome": nome,
      "email": email,
      "email_secundario": email_secundario,
      "sobre": sobre,
      "telefone": telefone,
    };
  }
}