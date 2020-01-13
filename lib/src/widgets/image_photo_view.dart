import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImagePhotoView extends StatelessWidget {
  String imgUrl;
  String imgName;

  ImagePhotoView(this.imgUrl, this.imgName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Container(
          height: 20.0,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              Text(imgName)
            ],
          )
        )
      ),
      body: PhotoView(
        imageProvider: NetworkImage(imgUrl),
      )
    );
  }
}