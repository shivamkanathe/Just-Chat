import 'package:flutter/material.dart';

class ViewImage extends StatelessWidget {
  String? image;
  ViewImage({this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body:  Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Image.network("${image}",fit: BoxFit.fill,),
      ),
    );
  }
}
