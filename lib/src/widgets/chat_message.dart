import 'package:flutter/material.dart';
import 'package:skill_box/src/models/user_model.dart';

class ChatMessage extends StatelessWidget {

  final Map<String, dynamic> mensagem;

  ChatMessage(this.mensagem);
  

  @override
  Widget build(BuildContext context) {
    UserModel _userModel = UserModel.of(context);
    
    return Row(
      mainAxisAlignment: mensagem["senderId"] != _userModel.user.userId ? MainAxisAlignment.start : MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        mensagem["senderId"] != _userModel.user.userId ? 
          Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: CircleAvatar(
              radius: 15.0,
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(mensagem["senderPhotoUrl"]),
            )
          )
        : Container(),
        Flexible(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            margin: EdgeInsets.only(top: 15.0, left: 5.0, right: 10.0),
            decoration: BoxDecoration(
              color: mensagem["senderId"] != _userModel.user.userId ? Colors.white : Colors.deepPurple[200],
              border: Border.all(
                color: Colors.grey[300],
              ),
              borderRadius: mensagem["senderId"] != _userModel.user.userId ? 
                BorderRadius.only(bottomLeft: Radius.circular(20.0), bottomRight: Radius.circular(20.0), topRight: Radius.circular(20.0))
              : BorderRadius.only(bottomLeft: Radius.circular(20.0), bottomRight: Radius.circular(20.0), topLeft: Radius.circular(20.0)),
            ),
            child: mensagem["senderId"] != _userModel.user.userId ? 
              Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 5.0),
                  child: Text(
                    mensagem["senderName"],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    )
                  )
                ),
                Text(mensagem["text"])
              ],
            )
          : Text(
              mensagem["text"],
              style: TextStyle(
                color: Colors.white
              ),
            )
          ),
        )
      ],
    );
  }
}