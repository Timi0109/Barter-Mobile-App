import 'package:flutter/material.dart';
import 'Todo.dart';
import 'package:final_project/image_url.dart';
import 'package:final_project/image_full_screen.dart';

List<String> ls;

class DetailScreen extends StatelessWidget {
  static const String id = 'detail_screen';

  @override
  Widget build(BuildContext context) {
    final Todo todo = ModalRoute.of(context).settings.arguments;

    if (todo.url != "none") {
      String str = todo.url.substring(1, todo.url.length - 1);
      str = str.replaceAll(" ", "");
      ls = str.split(',');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(todo.title),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
              child: Text(
                "Price: ${todo.price}",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 18.0,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
              child: Text(
                "Description: ${todo.description}",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 18.0,
                  // fontWeight: FontWeight.bold,
                ),
              ),
            ),
            todo.url != "none" ? ImageStream() : SizedBox()
          ],
        ),
      ),
    );
  }
}

class ImageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
          itemCount: ls.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              child: Hero(
                tag: '${index}',
                child: Image.network(ls[index]),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullImgScreen(),
                    settings: RouteSettings(
                      arguments: (ImageUrl(ls[index], index)),
                    ),
                  ),
                );
              },
            );
          }),
    );
  }
}
