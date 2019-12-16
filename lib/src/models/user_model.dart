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

  static List<Project> feedProjects = [];

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
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();

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
            DocumentSnapshot doc = await Firestore.instance.collection("usuarios").
            document(user.userId).get();

            if(doc.data != null)
              user.fromDocument(doc);

            QuerySnapshot query = await _firestore.collection("usuarios").document(user.userId).collection("interesses").getDocuments();

            if(query.documents != null){
              user.interesses = query.documents.map((doc) => Interest.fromDocument(doc, true, doc.data["categoryId"])).toList();

              loadFeedProjects();
              loadUserProjects();  
            }
               
          }
        }
      }
    isLoading = false;
    notifyListeners();
  }

  Future<Null> loadFeedProjects() async {
    if(user?.interesses != null) {
      user.feed = [];
      user.interesses.map(
        (userInterest) async {
          QuerySnapshot query =  await _firestore.collection("projetos").where("interesses", arrayContains: userInterest.toMap()).getDocuments();

          if(query.documents != null){
            query.documents.map(
              (doc){
                Project p = Project.fromDocument(doc);
                
                for(int i =0; i<doc.data["interesses"].length; i++){
                  p.interesses.add(Interest(doc.data["interesses"][i]["categoryId"],doc.data["interesses"][i]["interestId"],true,doc.data["interesses"][i]["titulo"]));
                }

                for(int i =0; i<doc.data["membros"].length; i++){
                  User u = User(null);

                  u.userId = doc.data["membros"][i]["userId"];
                  u.email = doc.data["membros"][i]["email"];
                  u.emailSecundario = doc.data["membros"][i]["emailSecundario"];
                  u.nome = doc.data["membros"][i]["nome"];
                  u.sobre = doc.data["membros"][i]["sobre"];
                  u.telefone = doc.data["membros"][i]["telefone"];

                  p.membros.add(u);
                }

                bool projectExists = false;
                for(int i=0; i<user.feed.length; i++){
                  if(user.feed[i].projectId == p.projectId)
                    projectExists = true;
                }

                if(!projectExists && p.adminId != user.userId){
                  user.feed.add(p);
                }
              }
            ).toList();
          }
          user.feed.sort((a, b) => b.dataCriacao.compareTo(a.dataCriacao));
        }
      ).toList();
    }
  }

  Future<Null> loadUserProjects() async {
    QuerySnapshot query = await _firestore.collection("projetos").where("membros", arrayContains: user.toMap()).getDocuments();

    if(query.documents != null){
      List<Project> projects = [];

      query.documents.map(
        (doc){
          Project p =  Project.fromDocument(doc);
          
          for(int i =0; i<doc.data["interesses"].length; i++){
            p.interesses.add(Interest(doc.data["interesses"][i]["categoryId"],doc.data["interesses"][i]["interestId"],true,doc.data["interesses"][i]["titulo"]));
          }

          for(int i =0; i<doc.data["membros"].length; i++){
            User u = User(null);

            u.userId = doc.data["membros"][i]["userId"];
            u.email = doc.data["membros"][i]["email"];
            u.emailSecundario = doc.data["membros"][i]["emailSecundario"];
            u.nome = doc.data["membros"][i]["nome"];
            u.sobre = doc.data["membros"][i]["sobre"];
            u.telefone = doc.data["membros"][i]["telefone"];

            p.membros.add(u);
          }

          projects.add(p);
        }
      ).toList();
      user.projetos = projects;
      user.projetos.sort((a, b) => b.dataCriacao.compareTo(a.dataCriacao));
    }
  }

  bool userHasProfile(){
    if(user.interesses == null || user.interesses.isEmpty){
      return false;
    }else{
      return true;
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

        await loadFeedProjects();

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