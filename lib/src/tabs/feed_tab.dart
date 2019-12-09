import 'package:flutter/material.dart';

class FeedTab extends StatefulWidget {
  @override
  _FeedTabState createState() => _FeedTabState();
}

class _FeedTabState extends State<FeedTab> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text("feed"),
      )
    );
  }
}