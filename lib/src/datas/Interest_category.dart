import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skill_box/src/datas/interest.dart';

class InterestCategory {
  String categoryId;
  String titulo;
  List<Interest> interests;
  bool isSelected;

  InterestCategory();

  InterestCategory.fromDocument(DocumentSnapshot document) {
    categoryId = document.documentID;
    titulo = document.data["titulo"];
    this.isSelected = false;
  }

  Map<String, dynamic> toMap() {
    return {
      "interestId": categoryId,
      "titulo": titulo,
      "interests": interests
    };
  }
}