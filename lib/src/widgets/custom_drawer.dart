import 'package:flutter/material.dart';
import 'package:skill_box/src/models/user_model.dart';
import 'package:skill_box/src/screens/login_screen.dart';
import 'package:skill_box/src/widgets/drawer_tile.dart';

class CustomDrawer extends StatelessWidget {

  final PageController pageController;

  CustomDrawer(this.pageController);

  @override
  Widget build(BuildContext context) {

    UserModel _userModel = UserModel.of(context);

    return Drawer(
      child: _userModel.userLoggedIn ? 
        ListView(
              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 50.0),
              children: <Widget>[
                _userModel.isLoading ? 
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator()
                    ]
                  )
                ) :
                Column(
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircleAvatar(
                          radius: 35.0,
                          backgroundColor: Colors.grey[400],
                          foregroundColor: Colors.black,
                          backgroundImage: _userModel.user != null ? NetworkImage(_userModel.user.urlFoto) : Icon(Icons.person),
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          _userModel.user?.nome,
                          style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                        SizedBox(height: 2.0),
                        Text(
                          _userModel.user?.email,
                          style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                    DrawerTile(Icons.home,"Início", pageController, 0),
                    DrawerTile(Icons.featured_play_list,"Projetos", pageController, 1),
                    DrawerTile(Icons.person,"Perfil", pageController, 2),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: FloatingActionButton(
                      onPressed: (){
                        _userModel.signOut();
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context)=>LoginScreen())
                        );
                      },
                      child: Icon(
                        Icons.exit_to_app,
                        size: 20.0
                      ),
                      mini: true,
                      backgroundColor: Colors.red,
                    ),
                    )
                  ],
                )
              ],
            ) :
            Container()
    );
  }
}