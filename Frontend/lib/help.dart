import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class coustomercare extends StatelessWidget{
  final int id;
  final String pic="assets/images/defaultpic.jpg";
  final String name;
  final String contact;
  final String email;
  const coustomercare({super.key,required this.id,required this.name,required this.contact,required this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.all(10),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.black12,
                    backgroundImage: AssetImage(pic),

                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  alignment: Alignment.topLeft,
                  width: MediaQuery.of(context).size.width*0.5,
                  child: Column(
                    children: [
                      Text(name),
                      Text("id: $id"),
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width*0.9,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey)
            ),
          ),
          Container(
            child: Column(
              children: [
                Container(
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.all(10),
                        child: Icon(Icons.phone),
                      ),
                      Text(contact,style: TextStyle(fontSize: 20),)
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.all(10),
                        child: Icon(Icons.mail_outline),
                      ),
                      Text(email,style: TextStyle(fontSize: 20),)
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

}
class Help extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Help"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            coustomercare(id: 123123567, name:"harsh patel", contact:"99*****30", email: "ph3658@gmail.com")
          ],
        ),
      ),
    );

  }

}