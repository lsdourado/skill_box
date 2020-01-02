import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skill_box/src/datas/interest.dart';
class User {
  String userId;
  String urlFoto;
  String nome;
  String email;
  String emailSecundario;
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
    userId = docUser.documentID;
    nome = docUser.data["nome"];
    email = docUser.data["email"];
    emailSecundario = docUser.data["emailSecundario"];
    telefone = docUser.data["telefone"];
    sobre = docUser.data["sobre"];
    urlFoto = docUser.data["urlFoto"];
  }

  void fromDynamic(userData) {
    userId = userData["userId"];
    nome = userData["nome"];
    email = userData["email"];
    emailSecundario = userData["emailSecundario"];
    telefone = userData["telefone"];
    sobre = userData["sobre"];
    urlFoto = userData["urlFoto"];
  }

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "nome": nome,
      "email": email,
      "emailSecundario": emailSecundario,
      "sobre": sobre,
      "telefone": telefone,
      "urlFoto": urlFoto
    };
  }
}