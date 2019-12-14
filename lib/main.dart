import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:skill_box/src/models/interest_model.dart';
import 'package:skill_box/src/models/project_model.dart';
import 'package:skill_box/src/models/user_model.dart';
import 'package:skill_box/src/screens/home_screen.dart';
import 'package:skill_box/src/screens/login_screen.dart';
import 'package:skill_box/src/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  
  UserModel userModel = new UserModel();
  bool isLoggedIn = await userModel.isLoggedIn();

  runApp(
    ScopedModel<UserModel>(
      model: userModel,
      child: ScopedModelDescendant<UserModel>(
        builder: (context, child, userModel) {
          return ScopedModel<InterestModel>(
            model: InterestModel(),
            child: ScopedModelDescendant<InterestModel>(
              builder: (context, child, interestModel){
                return ScopedModel<ProjectModel>(
                  model: ProjectModel(userModel),
                  child: ScopedModelDescendant<ProjectModel>(
                    builder: (context, child, projectModel){
                      if(!userModel.isLoading && !interestModel.isLoading && !projectModel.isLoading){
                        return MaterialApp(
                          title: "Skill Box",
                          theme: ThemeData(
                            primarySwatch: Colors.blue,
                            primaryColor: Colors.lightBlue,
                          ),
                          debugShowCheckedModeBanner: false,
                          home: isLoggedIn ? HomeScreen() : LoginScreen(),
                        );
                      }else{
                        return SplashScreen();
                      }
                    },
                  ),
                );
              }
            )
          );
        },
      )
    )
  );
}