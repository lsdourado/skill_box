import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:skill_box/src/datas/interest.dart';
import 'package:skill_box/src/datas/user.dart';
import 'package:skill_box/src/models/interest_model.dart';
import 'package:skill_box/src/models/user_model.dart';
import 'package:skill_box/src/screens/login_screen.dart';

class ProfileTab extends StatefulWidget {
  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final ScrollController _scrollController = ScrollController();

  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _aboutController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    User _user = UserModel.of(context).user;

    _emailController.text = _user?.email_secundario;
    _phoneController.text = _user?.telefone;
    _aboutController.text  = _user?.sobre;

    return Scaffold(
      appBar: AppBar(
        title: Text("Perfil de usuário"),
        centerTitle: true,
      ),
      key: _scaffoldKey,
      body: ScopedModelDescendant<InterestModel>(
        builder: (context, child, model) {
          model.setUserInterests(_user?.interesses);
          if(model.isLoading)
              return Center(child: CircularProgressIndicator());
          else{
            return Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.fromLTRB(16.0, 25.0, 16.0, 25.0),
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 50.0,
                        backgroundColor: Colors.grey[400],
                        foregroundColor: Colors.black,
                        backgroundImage: UserModel.of(context).user != null ? NetworkImage(UserModel.of(context).user.urlFoto) : null,
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        UserModel.of(context).user?.nome,
                        style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                      SizedBox(height: 2.0),
                      Text(
                        UserModel.of(context).user?.email,
                        style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.w500
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(top: 25.0, bottom: 8.0),
                        child: TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: "E-mail secundário",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0)
                            )
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      
                      Padding(
                        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: "Telefone",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0)
                            )
                          ),
                          validator: (text){
                            if(text.isEmpty) return "Campo obrigatório";
                          },
                          keyboardType: TextInputType.phone,
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: TextFormField(
                          maxLines: 5,
                          controller: _aboutController,
                          decoration: InputDecoration(
                            alignLabelWithHint: true,
                            labelText: "Sobre você",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0)
                            )
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(top: 8.0, bottom: 16.0),
                        child: Card(
                          child: ExpansionTile(
                            title: Text("Áreas de interesse"),
                            leading: Icon(Icons.list),
                            initiallyExpanded: _user?.interesses != null && _user.interesses.isNotEmpty ? true : false,
                            children: model.interestCategories.map(
                              (category){
                                return Ink(
                                  child: ExpansionTile(
                                    initiallyExpanded: model.isCategorySelected(category) ? true : false,
                                    title: Text(
                                      category.titulo,
                                    ),
                                    children: <Widget>[
                                      ScopedModelDescendant<InterestModel>(
                                        builder: (context, child, model){
                                          if(category.interests != null && category.interests.isNotEmpty) {
                                            return Container(
                                              child: ListView(
                                                shrinkWrap: true,
                                                controller: _scrollController,
                                                children: category.interests.map(
                                                  (interest){
                                                    model.userInterestsSelected.map(
                                                      (userInterest){
                                                        if(userInterest.interestId == interest.interestId){
                                                          interest.isSelected = userInterest.isSelected;
                                                        }
                                                      }
                                                    ).toList();
                                                    return GestureDetector(
                                                      child: Ink(
                                                        color: interest.isSelected ? Colors.green[200] : Colors.grey[100],
                                                        child: ListTile(
                                                          title: Text(interest.titulo),
                                                          contentPadding: EdgeInsets.only(left: 30.0),
                                                        )
                                                      ),
                                                      onTap: () {
                                                        model.onTapInterest(interest);
                                                      }
                                                    );
                                                  }
                                                ).toList(),
                                              )
                                            );
                                          }else{
                                            return Container();
                                          }
                                        },
                                      )
                                    ],
                                  )
                                );
                            }).toList(),
                          )
                        ),
                      ),

                      SizedBox(
                        height: 44.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            RaisedButton(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                              child: Text(
                                "Cancelar",
                                style: TextStyle(
                                  fontSize: 18.0
                                ),
                              ),
                              textColor: Colors.white,
                              color: Colors.red,
                              onPressed: (){
                                UserModel.of(context).signOut();
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (context)=>LoginScreen())
                                );
                              }
                            ),
                            SizedBox(width: 15.0),
                            RaisedButton(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                              child: Text(
                                "Salvar",
                                style: TextStyle(
                                  fontSize: 18.0
                                ),
                              ),
                              textColor: Colors.white,
                              color: Colors.green,
                              onPressed: (){
                                List<Interest> interests = [];
                                InterestModel.of(context).interestCategories.map(
                                  (category){
                                    category.interests.map(
                                      (interest){
                                        if(interest.isSelected)
                                          interests.add(interest);
                                      }
                                    ).toList();
                                  }
                                ).toList();

                                Map<String, dynamic> userData = {
                                  "nome": UserModel.of(context).user?.nome,
                                  "email": UserModel.of(context).user?.email,
                                  "email_secundario": _emailController.text,
                                  "telefone": _phoneController.text,
                                  "sobre": _aboutController.text,
                                };

                                UserModel.of(context).saveUserProfile(
                                  userData: userData,
                                  interestList: interests,
                                  onSuccess: onSuccess,
                                  onFail: onFail
                                );
                              }
                            )
                          ],
                        )
                      )
                    ],
                  ),

                  
                ],
              ),
            );
          }
        },
      )
    );
  }

  void onSuccess(){
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
      content: Text(
        "Perfil salvo com sucesso",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 3),)
    );
  }

  void onFail(){
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text("Falha ao tentar salvar"),
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 3),)
    );
  }
}
