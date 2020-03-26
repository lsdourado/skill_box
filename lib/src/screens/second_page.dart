import 'package:flutter/material.dart';

class SecondPage extends StatelessWidget {
  final String payload;

  const SecondPage(
    {
      @required this.payload,
      Key key
    }
  ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Second Page - Payload: ",
          ),
          SizedBox(height: 8.0),
          Text(
            payload
          ),
          RaisedButton(
            child: Text("Back"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }
}