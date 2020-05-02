import 'package:flutter/material.dart';
import 'package:final_project/image_url.dart';

class FullImgScreen extends StatelessWidget {
  static const String id = 'full_screen';
  @override
  Widget build(BuildContext context) {
    final ImageUrl result = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: '${result.index}',
            child: Image.network(result.url),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
