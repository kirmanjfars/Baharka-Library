import 'package:librarygenocide/Screens/aboutUs.dart';
import 'package:librarygenocide/Screens/category_list.dart';
import 'package:librarygenocide/Screens/favoritesList.dart';
import 'package:librarygenocide/elements/searchWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int i = 0;
  List<Map> catMap;
  List<DocumentSnapshot> categoris;

  safeTotalOfCategories() {
    FirebaseFirestore.instance.collection("categories").get().then((value) {
      setState(() {
        categoris = value.docs;
      });
    }).whenComplete(() {
      categoris.forEach((element) {
        FirebaseFirestore.instance
            .collection("books")
            .where('categoryId', isEqualTo: element.id)
            .get()
            .then((value) {
          FirebaseFirestore.instance
              .collection("categories")
              .doc(element.id)
              .update({"total": value.docs.length.toString()});
        });
      });
    });

    if (categoris != null) {
      categoris.forEach((element) {
        FirebaseFirestore.instance
            .collection("books")
            .where('categoryId', isEqualTo: element.id)
            .get()
            .then((value) {
          FirebaseFirestore.instance
              .collection("categories")
              .doc()
              .update({"total": value.docs.length});
        });
      });
    }
  }

  getBook() {
    FirebaseFirestore.instance.collection("categories").get().then((value) {
      catMap = new List<Map>(value.docs.length);
      value.docs.forEach((element) async {
        Reference storage = FirebaseStorage.instance
            .ref()
            .child('cats/${element['imagePath']}');
        String url = await storage.getDownloadURL();
        catMap[i] = {
          'name': element['name'],
          'url': url,
          'id': element.id,
          'total': element['total']
        };
        // print(catMap);
        setState(() {
          i++;
        });
      });
    }).whenComplete(() {
      setState(() {
        catMap = catMap;
        i = i;
      });
    });
  }

  getTotal(String str) {
    List input = str.toString().split("");
    List output = [];
    for (int i = 0; i < input.length; i++) {
      if (input[i] == "0") {
        output.add("٠");
      } else if (input[i] == "1") {
        output.add("١");
      } else if (input[i] == "2") {
        output.add("٢");
      } else if (input[i] == "3") {
        output.add("٣");
      } else if (input[i] == "4") {
        output.add("٤");
      } else if (input[i] == "5") {
        output.add("٥");
      } else if (input[i] == "6") {
        output.add("٦");
      } else if (input[i] == "7") {
        output.add("٧");
      } else if (input[i] == "8") {
        output.add("٨");
      } else if (input[i] == "9") {
        output.add("٩");
      }
    }
    return output.join() + " " + "پەرتووک";
  }

  @override
  void initState() {
    safeTotalOfCategories();
    getBook();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          body: SingleChildScrollView(
            child: Container(
              color: Theme.of(context).accentColor,
              width: width,
              height: height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.home,
                            size: 30, color: Theme.of(context).highlightColor),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AboutUs()));
                        },
                      ),
                      Text(
                        'کتێبخانەی جینوسایدی گەلی کورد',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                          icon: Icon(
                            Icons.favorite,
                            size: 26,
                            color: Theme.of(context).highlightColor,
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        FavoritesListScreen()));
                          }),
                    ],
                  ),
                  SearchWidget(),
                  SizedBox(
                    height: 10,
                  ),
                  catMap == null
                      ? Container()
                      : catMap.length != i
                          ? Container()
                          : Container(
                              height: height * 0.85,
                              child: GridView.count(
                                primary: false,
                                padding: const EdgeInsets.all(20),
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                crossAxisCount: 2,
                                children: <Widget>[
                                  for (var i in catMap)
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (crl) => CategoryList(
                                                    i['id'], i['name'])));
                                      },
                                      child: Container(
                                          //   color: Colors.red,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Theme.of(context)
                                                  .highlightColor,
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Container(
                                                width: width,
                                                height: height * 0.23,
                                                child: Image.network(
                                                  i['url'],
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top: height * 0.14),
                                                child: Container(
                                                    width: width,
                                                    height: height * 0.045,
                                                    color: Colors.black87,
                                                    child: Center(
                                                        child: Text(
                                                      i['name'],
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor),
                                                    ))),
                                              ),
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      top: height * 0.185),
                                                  child: Container(
                                                      width: width,
                                                      height: height * 0.045,
                                                      color: Colors.black87,
                                                      child: Center(
                                                          child: Text(
                                                        getTotal(i['total']),
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor),
                                                      )))),
                                            ],
                                          )),
                                    )
                                ],
                              ),
                            )
                ],
              ),
            ),
          )),
    );
  }
}