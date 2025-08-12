import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_library/librarian/editmember.dart';
import 'package:my_library/librarian/addmember.dart';
import 'package:http/http.dart' as http;
class Member {
  final int? uid;
  final int mlid;
  final String name;
  final String? email;
  final String? phone;
  final DateTime joinedOn;

  Member({
    required this.uid,
    required this.mlid,
    required this.name,
    this.email,
    this.phone,
    required this.joinedOn,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      uid: json['uid'] == null ? null : json['uid'],
      mlid: json['mlid'],
      name: json['name'],
      email: json['email'] == null ? null : json['email'],
      phone: json['phone'] == null ? null : json['phone'],
      joinedOn: DateTime.parse(json['joined_on']),
    );
  }
}


class MemberList extends StatefulWidget {
  const MemberList({super.key});

  @override
  _MemberListState createState() => _MemberListState();
}

class _MemberListState extends State<MemberList> {
  int check2=1;
  final TextEditingController _controller = TextEditingController();
  final String baseurl = "${dotenv.env['BASE_URL']}";
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  List<Member> filteredMembers = [];
  List<Member> members = [];
  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() async {
    final String? token = await secureStorage.read(key: "access_token");
    final response = await http.post(
      Uri.parse("$baseurl/libraries/members/search"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({}),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        members = data.map((json) => Member.fromJson(json)).toList();
        filteredMembers = members;
      });
    } else {
      print('Error fetching members.');
    }
  }

  void _deleteMember(String mlid) async {
    final String? token = await secureStorage.read(key: "access_token");
    final response = await http.delete(
      Uri.parse("$baseurl/libraries/members/$mlid"),
      headers: {
        'Authorization': 'Bearer $token',
        'content-type': 'application/json',
        'accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        members.removeWhere((member) => member.mlid.toString() == mlid);
        filteredMembers = List.from(members);
      });
    } else {
      // Handle error case
    }
  }
  void search() async{
      if(check2==0) {
        final String? token = await secureStorage.read(key: "access_token");
        final response = await http.post(
          Uri.parse("$baseurl/libraries/members/search"),
          headers: {
            'Authorization': 'Bearer $token',
            'content-type': 'application/json',
            'accept': 'application/json',
          },
          body: json.encode({
            'mlid': _controller.text,
            'name': _controller.text,
          }),
        );
        if (response.statusCode == 200) {
          final List<dynamic> memberList = json.decode(response.body);
          setState(() {
            members = memberList
                .map((memberJson) => Member.fromJson(memberJson))
                .toList();
            filteredMembers = List.from(members);
          });
        }//TODO: SET THIS LIST TO SHOW UP AND ELSE ERROR PART
      }
      if (check2 == 1) {
        setState(() {
          check2 = 0;
        });
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          child: Row(
            children: [
              if(check2==1)
                Container(
                  width: MediaQuery.of(context).size.width*0.60,
                  child: const Text("Members"),
                ),
              if(check2==0)
                Row(
                  children: [
                    Container(
                      height: 40,
                      margin: EdgeInsets.only(
                          left:5,
                          right:5,
                          top:5,
                          bottom:10
                      ),
                      width: MediaQuery.of(context).size.width*0.6,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(7))
                      ),
                      child: TextField(
                        controller: _controller,
                        style: TextStyle(fontSize: 20),
                        decoration: InputDecoration(
                          labelText: "search",
                          labelStyle: TextStyle(
                              fontSize: 12,
                              color: Colors.black
                          ),
                          border:OutlineInputBorder(),
                          hintText: "Book,Id,Author",
                          hintStyle: TextStyle(fontSize: 20,color: Colors.grey),
                          contentPadding: EdgeInsets.only(top: 2),

                        ),
                      ),
                    ),

                  ],
                ),
              IconButton(onPressed: search, icon: Icon(Icons.search))
            ],
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: filteredMembers.length,
        itemBuilder: (context, index) {
          final member = filteredMembers[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Text(
                member.mlid.toString(),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              title: Text(
                member.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.email ?? "No Email"),
                  Text(member.phone ?? "No Phone"),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditMember(MemberId: int.parse(member.mlid.toString()),)),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Delete Member', style: TextStyle(fontWeight: FontWeight.bold)),
                            content: const Text('Are you sure you want to remove this member?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('No', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _deleteMember(member.mlid.toString());
                                },
                                child: const Text('Yes', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMember()),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}