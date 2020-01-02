import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:skill_box/src/models/user_model.dart';
import 'package:skill_box/src/screens/login_screen.dart';
import 'package:skill_box/src/screens/profile_screen.dart';
import 'package:skill_box/src/tabs/chats_tab.dart';
import 'package:skill_box/src/tabs/feed_tab.dart';
import 'package:skill_box/src/tabs/my_projects_tab.dart';
import 'package:skill_box/src/tabs/notifications_tab.dart';
import 'package:skill_box/src/widgets/notifications_icon.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedPage = 2;
  String title = "Skill Box";

  UserModel _userModel;

  @override
  void initState() {
    super.initState();

    _userModel = UserModel.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          title,
          style: _selectedPage == 2 ?
            TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              color: Colors.amber
            )
          : null,
        ),
        actions: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0),
                child: _userModel.user != null ?
                PopupMenuButton(
                  child: CircleAvatar(
                    radius: 14.0,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.white,
                    backgroundImage: NetworkImage(_userModel.user.urlFoto)
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
                  onSelected: (result){
                    switch (result) {
                      case "editar":
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context)=>ProfileScreen())
                        );
                      break;
                      default:
                        _userModel.signOut();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context)=>LoginScreen())
                        );
                      break;
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                    const PopupMenuItem(
                      value: "editar",
                      child: Text('Editar perfil'),
                    ),
                    const PopupMenuItem(
                      value: "sair",
                      child: Text('Sair da conta'),
                    )
                  ]
                )
              : Icon(Icons.account_circle)
              )
            ]
          )
        ],
      ),
      body: _buildPage(_selectedPage),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: Colors.deepPurple,
        height: 50.0,
        animationDuration: Duration(milliseconds: 100),
        animationCurve: Curves.bounceInOut,
        index: 2,
        items: <Widget>[
          Icon(Icons.chat_bubble, size: 20.0, color: Colors.white),
          Icon(Icons.featured_play_list, size: 20.0, color: Colors.white),
          Icon(Icons.home, size: 20.0, color: Colors.white),
          Icon(Icons.search, size: 20.0, color: Colors.white),
          NotificationsIcon()
        ],
        onTap: (index){
          setState(() {
            _selectedPage = index;

            switch (index) {
              case 0:
                title = "Conversas";
              break;
              case 1:
                title = "Projetos"; 
              break;
              case 3:
                title = "Busca"; 
              break;
              case 4:
                title = "Notificações";
              break;
              default:
                title = "Skill Box";
              break;
            }
          });
        },
      )
    );
  }

  Widget _buildPage(int page){
    switch (page) {
      case 0:
        return ChatsTab();
      break;
      case 1:
        return MyProjectsTab();
      break;
      case 3:
        return Container();
      break;
      case 4:
        return NotificationsTab();
      break;
      default:
        return FeedTab();
      break;
    }
  }
}