import 'dart:io';
import 'dart:async';
import 'package:final_project/menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class PostScreen extends StatefulWidget {
  static const String id = 'new_post_screen';
  final GlobalKey<ScaffoldState> globalKey;

  const PostScreen({Key key, this.globalKey}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

List<Asset> images = List<Asset>();
List<String> imageUrls = <String>[];

class _MyHomePageState extends State<PostScreen> {
  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final descripController = TextEditingController();
  bool _showUploadBtn = false;
  final _firestore = Firestore.instance;
  final _auth = FirebaseAuth.instance;
  FirebaseUser loggedInUser;
  String title;
  String price;
  String description;
  String _error = 'No Error Dectected';

  String _url;
  bool isUploading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  void _showScaffold(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: 'Go to Menu',
        onPressed: () {
          // Navigator.of(context).pushNamed(MenuScreen.id);
        },
      ),
    ));
  }

  void uploadImages(context) {
    for (var imageFile in images) {
      postImage(imageFile).then((downloadUrl) {
        imageUrls.add(downloadUrl.toString());
        print("*****************");
        print(imageUrls);
        if (imageUrls.length == images.length) {
          String documnetID =
              'timi_images/${DateTime.now().millisecondsSinceEpoch}';
          _firestore.collection('timi_post').add({
            'title': title,
            'price': price,
            'description': description,
            'path': imageUrls
          }).then((_) {
            Scaffold.of(context).showSnackBar(new SnackBar(
              content: new Text('subtmitted!'),
              action: SnackBarAction(
                  label: 'Go to Menu',
                  onPressed: () {
                    Navigator.of(context).pushNamed(MenuScreen.id);
                  }),
            ));
            titleController.clear();
            priceController.clear();
            descripController.clear();
            setState(() {
              images = [];
              imageUrls = [];
            });
          });
        }
      }).catchError((err) {
        print(err);
      });
    }
  }

  Future<dynamic> postImage(Asset imageFile) async {
    ByteData byteData = await imageFile.getByteData();
    List<int> imageData = byteData.buffer.asUint8List();
    String fileName =
        'timi_images/${DateTime.now().millisecondsSinceEpoch.toString()}';
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    // StorageUploadTask uploadTask =
    //     reference.putData((await imageFile.getByteData()).buffer.asUint8List());
    StorageUploadTask uploadTask = reference.putData(imageData);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    // return storageTaskSnapshot.ref.getDownloadURL();
    String imageUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return imageUrl;
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 4,
        enableCamera: false,
        selectedAssets: images,
        materialOptions: MaterialOptions(
          useDetailsView: true,
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    if (!mounted) return;

    setState(() {
      images = resultList;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                setState(() {
                  images = [];
                  imageUrls = [];
                });
                Navigator.pop(context);
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        title: Text('Hyper Barter'),
        backgroundColor: Colors.lightBlueAccent,
        actions: <Widget>[
          FlatButton(
            onPressed: null,
            child: Text(
              '---',
              style: TextStyle(
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            child: TextField(
              controller: titleController,
              maxLines: 2,
              minLines: 1,
              decoration: const InputDecoration(
                hintText: 'Enter title of the item*',
                filled: true,
                hintStyle: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              onTap: () {
                setState(() => _showUploadBtn = false);
              },
              onChanged: (value) {
                title = value;
              },
            ),
          ),
          Container(
            child: TextField(
              controller: priceController,
              maxLines: 2,
              minLines: 1,
              decoration: const InputDecoration(
                hintText: 'Enter the price*',
                filled: true,
                hintStyle: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              onTap: () {
                setState(() => _showUploadBtn = false);
              },
              onChanged: (value) {
                price = value;
              },
            ),
          ),
          Container(
            child: TextField(
              controller: descripController,
              maxLines: 12,
              minLines: 12,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10),
                hintText: 'Enter description*',
                filled: true,
                hintStyle: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              onTap: () {
                setState(() => _showUploadBtn = true);
              },
              onChanged: (value) {
                description = value;
              },
            ),
          ),
          Expanded(
            child: buildGridView(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _showUploadBtn
                  ? IconButton(
                      onPressed: loadAssets,
                      tooltip: 'Pick Image',
                      icon: Icon(
                        Icons.image,
                        size: 40,
                        color: Colors.lightBlueAccent,
                      ),
                    )
                  : SizedBox(),
              _showUploadBtn
                  ? Builder(
                      builder: (context) => RaisedButton(
                          color: Colors.lightBlueAccent,
                          textColor: Colors.white,
                          child: Text('Post'),
                          onPressed: () {
                            if (title == null ||
                                price == null ||
                                description == null) {
                              Scaffold.of(context).showSnackBar(new SnackBar(
                                content: new Text(
                                    'you have to fill all required content'),
                              ));
                            } else {
                              if (images.length != 0) {
                                Scaffold.of(context).showSnackBar(new SnackBar(
                                  content: new Text('wait.......'),
                                ));
                                uploadImages(context);
                              } else {
                                titleController.clear();
                                priceController.clear();
                                descripController.clear();
                                _firestore.collection('timi_post').add({
                                  'title': title,
                                  'price': price,
                                  "description": description,
                                  'path': "none",
                                });
                                Scaffold.of(context).showSnackBar(new SnackBar(
                                  content: new Text('submitted!'),
                                  action: SnackBarAction(
                                    label: 'Go to Menu',
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, MenuScreen.id);
                                    },
                                  ),
                                ));
                                //Navigator.pushNamed(context, MenuScreen.id);
                              }
                            }
                          }),
                    )
                  : SizedBox()
            ],
          )
        ],
      ),
    );
  }
}

class buildGridView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        return AssetThumb(
          asset: asset,
          width: 300,
          height: 300,
        );
      }),
    );
  }
}
