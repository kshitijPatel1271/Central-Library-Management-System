import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_library/lib.dart';


class libpage extends StatefulWidget {
  final Library lib;
  const libpage({super.key, required this.lib});

  @override
  State<StatefulWidget> createState() => _libpage(lib: lib);
}

class _libpage extends State<libpage> {
  Library lib;
  _libpage({required this.lib});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
        ),
        body: SingleChildScrollView(
            child: Column(children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.30,
            alignment: Alignment.center,
            child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: Image.network(lib.picturePath)),
                ),
              Container(
                width: MediaQuery.of(context).size.width*1,
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey),top: BorderSide(color: Colors.grey))),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 10),
                      width: MediaQuery.of(context).size.width*0.7,
                      child:  Text(lib.name,textAlign: TextAlign.left, style: TextStyle(fontSize: 20)),
                    ),
                    IconButton(onPressed: (){}, icon: Icon(Icons.favorite)),
                    IconButton(onPressed: (){}, icon: Icon(Icons.share))
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 5),
                alignment: Alignment.centerLeft,
                child: Text(lib.address,textAlign: TextAlign.left, style: TextStyle(fontSize: 20)),
              ),
              Container(
                padding: EdgeInsets.only(left: 5),
                alignment: Alignment.centerLeft,
                child: Text("Librarian:${lib.librarianName}",textAlign: TextAlign.left, style: TextStyle(fontSize: 20)),
              ),
              Container(
                padding: EdgeInsets.only(left: 5),
                alignment: Alignment.centerLeft,
                child: Text("open🕒 :",textAlign: TextAlign.left, style: TextStyle(fontSize: 20)),
              ),
              Container(
                padding: EdgeInsets.only(left: 5),
                alignment: Alignment.centerLeft,
                child: Text("contact:${lib.contact}",textAlign: TextAlign.left, style: TextStyle(fontSize: 20)),
              )
        ])));
  }
}
