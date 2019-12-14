import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:skill_box/src/datas/interest.dart';
import 'package:skill_box/src/datas/project.dart';
import 'package:skill_box/src/datas/user.dart';

class UserModel extends Model{

  final _firebaseAuth = FirebaseAuth.instance;
  final _firestore = Firestore.instance;
  final _googleSignIn = GoogleSignIn();

  User user;

  bool isLoading = false;
  bool userLoggedIn = false;

  static UserModel of(BuildContext context) => ScopedModel.of<UserModel>(context);

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);

    _loadCurrentUser();
  }



  void signIn({@required VoidCallback onSuccess, @required VoidCallback onFail}) async {
    isLoading = true;
    notifyListeners();

    final googleUser = await _googleSignIn.signIn();
    final googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await _firebaseAuth.signInWithCredential(credential).then(
      (fireUser) async {

        user = User(fireUser.user);

        await _loadCurrentUser();

        onSuccess();

        isLoading = false;
        notifyListeners();
      }
    ).catchError((e){
      onFail();
      print(e);
      isLoading = false;
      notifyListeners();
    });
  }

  Future<bool> isLoggedIn() async {
    userLoggedIn = await _firebaseAuth.currentUser() != null;
    return userLoggedIn;
  }

  void signOut() async {
    isLoading = true;
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();

    user = null;
    userLoggedIn = false;

    isLoading = false;
    notifyListeners();
  }

  Future<Null> _loadCurrentUser() async {
    isLoading = true;
    notifyListeners();
    if(user == null)
      user = User(await _firebaseAuth.currentUser());
      if(user != null){
        if(user.interesses == null){
          if(await isLoggedIn()){
            DocumentSnapshot docUser = await Firestore.instance.collection("usuarios").
            document(user.userId).get();

            if(docUser.data != null)
              user.fromDocument(docUser);

            QuerySnapshot query = await _firestore.collection("usuarios").document(user.userId).collection("interesses").getDocuments();

            if(query.documents != null)
              user.interesses = query.documents.map((doc) => Interest.fromDocument(doc, true, doc.data["categoryId"])).toList();

            query = await _firestore.collection("usuarios").document(user.userId).collection("projetos").getDocuments();

            await loadProjects();
          }
        }
      }
    isLoading = false;
    notifyListeners();
  }

  Future<Null> loadProjects() async {

    QuerySnapshot query = await _firestore.collection("usuarios").document(user.userId).collection("projetos").orderBy('data_criacao', descending: false).getDocuments();

    if(query.documents != null){
      user.projetos = query.documents.map((doc) => Project.fromDocument(doc)).toList();

      user.projetos.map(
        (project) async {
         query = await _firestore.collection("projetos").document(project.projectId).collection("interesses").getDocuments();

         query.documents.map(
           (doc){
             project.interesses = query.documents.map((doc) => Interest.fromDocument(doc, true, doc.data["categoryId"])).toList();
           }
         ).toList();

         query = await _firestore.collection("projetos").document(project.projectId).collection("membros").getDocuments();

         query.documents.map(
           (doc){
             User user = User(null);

             user.fromDocument(doc);

             project.membros.add(user);
           }
         ).toList();
        }
      ).toList();
    }
  }

  bool userHasProfile(){
    if(user.interesses != null && user.interesses.isNotEmpty){
      return true;
    }else{
      return false;
    }
  }
 
  Future<Null> saveUserProfile({@required Map<String, dynamic> userData, @required List<Interest> interestList,@required VoidCallback onSuccess, @required VoidCallback onFail}) async {
    await _firestore.collection("usuarios").document(user.userId).setData(userData).then(
      (result) async {

        List<Interest> newInterests = [];

        interestList.map(
          (interest){
            if(interest.isSelected == true){
              _firestore.collection("usuarios").document(user.userId).
              collection("interesses").document(interest.interestId).setData(interest.toMap());

              newInterests.add(interest);
            }
          }
        ).toList();

        user.interesses.map(
          (interest){
            if(!interest.isSelected){
              _firestore.collection("usuarios").document(user.userId).
              collection("interesses").document(interest.interestId).delete();
            }
          }
        ).toList();

        user.emailSecundario = userData["email_secundario"];
        user.telefone = userData["telefone"];
        user.sobre = userData["sobre"];
        user.interesses = newInterests;

        onSuccess();

        notifyListeners();
      }
    ).catchError((e){
      onFail();
      isLoading = false;
      notifyListeners();
    });
  }

}