import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:skill_box/src/models/user_model.dart';
import 'package:skill_box/src/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  UserModel _userModel;

  @override
  void initState() {
    super.initState();

    _userModel = UserModel.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Skill Box",
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
                fontSize: 30.0
              )
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 20.0),
              child: RaisedButton.icon(
                color: Colors.white,
                textColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                icon: Icon(FontAwesomeIcons.google, color: Colors.deepPurple),
                label: Text("Login com Google"),
                onPressed: () {
                  _userModel.signIn(
                    onSuccess: _onSuccess,
                    onFail: _onFail
                  );                
                }
              )
            )
          ],
        ),
      )
    );
  }

  void _onSuccess(){
    if(UserModel.of(context).userHasProfile()){
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context)=>HomeScreen())
      );
    }
  }

  void _onFail(){
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text("Falha ao entrar"),
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 2),)
    );
  }
}