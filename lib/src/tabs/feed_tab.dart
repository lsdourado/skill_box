import 'package:flutter/material.dart';
import 'package:skill_box/src/models/user_model.dart';

class FeedTab extends StatefulWidget {
  @override
  _FeedTabState createState() => _FeedTabState();
}

class _FeedTabState extends State<FeedTab> {

  UserModel _userModel;

  @override
  void initState() {
    super.initState();
    _userModel = UserModel.of(context);
  }

  @override
  Widget build(BuildContext context) {
    if(_userModel.userLoggedIn){
      if(_userModel.isLoading || _userModel.user.feed == null)
        return Center(child: CircularProgressIndicator());

      return Container(
        child: _userModel.user.feed.isEmpty ? Center(child: Text("Nenhum projeto com seus interesses encontrado")) :
        ListView(
          children: _userModel.user.feed.map(
            (project){
              return Container(
                width: 200.0,
                height: 150.0,
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
                margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color:Colors.grey.withOpacity(0.5)
                  )
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        "Título",
                          style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          project.titulo,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        height: 12.0,
                      ),
                      Text(
                        "Descrição",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          project.descricao,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            "${project.dataCriacao.toDate().day.toString()}/${project.dataCriacao.toDate().month.toString()}/${project.dataCriacao.toDate().year.toString()}",
                          ),
                          Text(
                            project.membros.length > 1 ? "${project.membros.length} membros" : 
                            "${project.membros.length} membro"
                          )
                        ],
                      )
                    ],
                  )
              );
            }
          ).toList()
        )
      );
    }else{
      return Container();
    }
  }
}