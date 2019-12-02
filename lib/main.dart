import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:skill_box/src/models/interest_model.dart';
import 'package:skill_box/src/models/user_model.dart';
import 'package:skill_box/src/screens/home_screen.dart';
import 'package:skill_box/src/screens/login_screen.dart';
import 'package:skill_box/src/tabs/feed_tab.dart';

void main() async {
  UserModel userModel = new UserModel();
  bool isLoggedIn = await userModel.isLoggedIn();

  runApp(
    ScopedModel<UserModel>(
      model: userModel,
      child: ScopedModelDescendant<UserModel>(
        builder: (context, child, model) {
          return ScopedModel<InterestModel>(
            model: InterestModel(),
            child: MaterialApp(
              title: "Skill Box",
              theme: ThemeData(
                primarySwatch: Colors.blue,
                primaryColor: Colors.lightBlue,
              ),
              debugShowCheckedModeBanner: false,
              home: isLoggedIn ? HomeScreen() : LoginScreen(),
            ),
          );
        },
      )
    )
  );
}
