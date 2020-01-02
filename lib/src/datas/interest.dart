import 'package:cloud_firestore/cloud_firestore.dart';

class Interest {
  String categoryId;
  String interestId;
  String titulo;
  bool isSelected;

  Interest.fromDocument(DocumentSnapshot document, bool isSelected) {
    this.categoryId = document.data["categoryId"];
    interestId = document.documentID;
    titulo = document.data["titulo"];
    this.isSelected = isSelected;
  }

  Interest.fromDynamic(interestData, bool isSelected) {
    this.categoryId = interestData["categoryId"];
    interestId = interestData["interestId"];
    titulo = interestData["titulo"];
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