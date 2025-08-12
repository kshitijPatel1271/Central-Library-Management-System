import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_library/libbooks.dart';
class LibBookPage extends StatefulWidget{
  final Libbook book;

  const LibBookPage({super.key, required this.book});
  @override
  State<LibBookPage> createState() => _LibBookPage(book: book);
}
class _LibBookPage extends State<LibBookPage>{
  final Libbook book;
  _LibBookPage({required Libbook book}): book=book;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("#${book.library_Libbookid}"),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height*1,
        color: Color(0xFFD5DDE4),
        child: SingleChildScrollView(
          child: Container(

            padding: EdgeInsets.only(top: 10),
            child: Column(
              children: [

                Container(
                  margin: EdgeInsets.only(bottom: 5),
                  height: MediaQuery.of(context).size.height*0.4,
                  alignment: Alignment.center,
                  child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                      ),
                      child: Image.asset(book.img)),
                ),
                Container(
                  width: MediaQuery.of(context).size.width*1,
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey),top: BorderSide(color: Colors.grey))),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 10),
                        width: MediaQuery.of(context).size.width*0.7,
                        child:  Text("#${book.library_Libbookid}",textAlign: TextAlign.left, style: TextStyle(fontSize: 20),),),
                      IconButton(onPressed: (){}, icon: Icon(Icons.favorite)),
                      IconButton(onPressed: (){}, icon: Icon(Icons.share))
                    ],
                  ),
                ),
                Container(
                  child: Column(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left:5),
                          child:  Text("Name: ${book.name}", style: TextStyle(fontSize: 20), maxLines: 1, // Limits the text to one line
                            overflow: TextOverflow.ellipsis,),
                        ),

                        Container(
                            padding: EdgeInsets.only(left: 10),
                            child: Text("Author:${book.author}", style: TextStyle(fontSize: 20), maxLines: 1, // Limits the text to one line
                              overflow: TextOverflow.ellipsis,),
                            alignment: Alignment.centerLeft),
                        Container(
                            padding: EdgeInsets.only(left: 10),
                            child: Text("Genre:${book.genre}", style: TextStyle(fontSize: 20)),
                            alignment: Alignment.centerLeft),
                        Container(
                            padding: EdgeInsets.only(left: 10),
                            child: Text("Description:${book.description}", style: TextStyle(fontSize: 20)),
                            alignment: Alignment.centerLeft),
                        Container(
                            padding: EdgeInsets.only(left: 10),
                            child: Text("Total Quantity:${book.Qntity}", style: TextStyle(fontSize: 20)),
                            alignment: Alignment.centerLeft),
                        if(int.parse(book.available)>=1)
                          Container(
                              padding: EdgeInsets.only(left: 10),
                              child: Text("Available Quantity:${book.available}", style: TextStyle(fontSize: 20,color: Colors.green)),
                              alignment: Alignment.centerLeft),
                        if(int.parse(book.available)<1)
                          Container(
                              padding: EdgeInsets.only(left: 10),
                              child: Text("Available Quantity:${book.available}", style: TextStyle(fontSize: 20,color: Colors.red)),
                              alignment: Alignment.centerLeft),

                      ]
                  ),
                )

              ],
            ),
          ),
        ),
      )
    );
  }

}