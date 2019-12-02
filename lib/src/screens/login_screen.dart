import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:skill_box/src/models/user_model.dart';
import 'package:skill_box/src/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlutterLogo(size: 72.0),
            SizedBox(height: 50.0),
            ScopedModelDescendant<UserModel>(
              builder: (context, child, model) {
                return RaisedButton.icon(
                  color: Colors.red,
                  textColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  icon: Icon(FontAwesomeIcons.google, color: Colors.white),
                  label: Text("Login com Google"),
                  onPressed: () {
                    model.signIn(
                      onSuccess: _onSuccess,
                      onFail: _onFail
                    );                  
                  }
                );
              },
            )
          ],
        ),
      )
    );
  }

  void _onSuccess(){
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context)=>HomeScreen())
    );
  }

  void _onFail(){
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text("Falha ao entrar"),
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 2),)
    );
  }
}