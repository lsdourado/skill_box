import 'package:configurable_expansion_tile/configurable_expansion_tile.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:skill_box/src/datas/interest.dart';
import 'package:skill_box/src/models/interest_model.dart';
import 'package:skill_box/src/models/user_model.dart';
import 'package:skill_box/src/screens/home_screen.dart';
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

  UserModel _userModel;
  InterestModel _interestModel;

  @override
  void initState() {
    super.initState();

    _userModel = UserModel.of(context);
    _interestModel = InterestModel.of(context);

    _interestModel.setInterestsSelected(_userModel.user?.interesses);

    _emailController.text = _userModel.user?.emailSecundario;
    _phoneController.text = _userModel.user?.telefone;
    _aboutController.text  = _userModel.user?.sobre;

    KeyboardVisibilityNotification().addNewListener(
      onHide: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if(!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    if(_userModel.userLoggedIn){
      return Scaffold(
        appBar: _userModel.userHasProfile() ? null : AppBar(
          title: Text("Perfil de usuário"),
          centerTitle: true,
        ),
        key: _scaffoldKey,
        body: _interestModel.isLoading ? Center(child: CircularProgressIndicator()) :

        Form(
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
                    child: ConfigurableExpansionTile(
                        header: Flexible(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.0),
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.list),
                                Text(
                                  " ÁREAS DE INTERESSE",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            )
                          )
                        ),
                        animatedWidgetFollowingHeader: const Icon(
                          Icons.expand_more,
                        ),
                        children: _interestModel.interestCategories.map(
                          (category){
                            return ConfigurableExpansionTile(
                              initiallyExpanded: _interestModel.isCategorySelected(category) ? true : false,
                              header: Flexible(
                                child: Container(
                                  padding: EdgeInsets.only(left: 15.0, top: 10.0, bottom: 10.0),
                                  child: Row(
                                    children: <Widget>[
                                      Text(category.titulo)
                                    ],
                                  )
                                )
                              ),
                              animatedWidgetFollowingHeader: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15.0),
                                child: const Icon(
                                  Icons.expand_more,
                                )
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
                                              model.interestsSelected.map(
                                                (userInterest){
                                                  if(userInterest.interestId == interest.interestId){
                                                    interest.isSelected = userInterest.isSelected;
                                                  }
                                                }
                                              ).toList();
                                              return GestureDetector(
                                                child: Padding(
                                                  padding: EdgeInsets.only(left: 25.0),
                                                  child: Row(
                                                  children: <Widget>[
                                                    Chip(
                                                      avatar: interest.isSelected ? Padding(
                                                        padding: EdgeInsets.only(left: 5.0),
                                                        child: Icon(
                                                          Icons.check,
                                                          color: Colors.white, size: 20.0,
                                                        )
                                                      ) : null,
                                                      elevation: 4.0,
                                                      label: Row(
                                                        children: <Widget>[
                                                          Text(
                                                            interest.titulo,
                                                            style: TextStyle(
                                                              color: interest.isSelected ? Colors.white : null
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      backgroundColor: interest.isSelected ? Colors.deepPurple[200] : null,
                                                    )
                                                  ],
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
                            );
                        }).toList(),
                      )
                  ),

                  SizedBox(
                    height: 44.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        !_userModel.userHasProfile() ?
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
                        ) : Row(),
                        
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
                              "emailSecundario": _emailController.text,
                              "telefone": _phoneController.text,
                              "sobre": _aboutController.text,
                              "urlFoto": UserModel.of(context).user?.urlFoto
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
        )
      );
    }else{
      return Container();
    }
  }

  void onSuccess(){
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context)=>HomeScreen())
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
