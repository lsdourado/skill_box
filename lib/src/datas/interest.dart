import 'package:cloud_firestore/cloud_firestore.dart';

class Interest {
  String categoryId;
  String interestId;
  String titulo;
  bool isSelected;

  Interest(this.categoryId,this.interestId,this.isSelected,this.titulo);

  Interest.fromDocument(DocumentSnapshot document, bool isSelected, String categoryId) {
    this.categoryId = categoryId;
    interestId = document.documentID;
    titulo = document.data["titulo"];
    this.isSelected = isSelected;
  }

  Map<String, dynamic> toMap() {
    return {
      "categoryId": categoryId,
      "interestId": interestId,
      "titulo": titulo,
    };
  }
}