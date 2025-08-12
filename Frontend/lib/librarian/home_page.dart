import 'package:flutter/material.dart';
import 'package:my_library/Addbooklist.dart';
import 'package:my_library/booklistpage.dart';
import 'package:my_library/help.dart';
import 'package:my_library/libeditpage.dart';
import 'package:my_library/librarian/Member_list.dart';
import 'package:my_library/librarian/book.dart';
import 'package:my_library/librarian/dashboardcard.dart';
import 'package:my_library/librarian/issue_book.dart';
import 'package:my_library/librarian/profile.dart';
import 'package:my_library/loginpage.dart';
import 'package:my_library/return_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final String baseurl = "${dotenv.env['BASE_URL']}";
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  Map<String,dynamic> data = {};
  @override
  void initState(){
    super.initState();
    _fetch();
  }
  void _fetch() async{
    final String? token = await secureStorage.read(key: 'access_token');
    final response = await http.get(
      Uri.parse("$baseurl/libraries/dashboard-summary"),
      headers: {
        'Authorization': 'Bearer $token',
        'content-type': 'application/json'
      }
    );
    if (response.statusCode == 200){
      setState(() {
        data = json.decode(response.body);
      });
      print(data);
    }
  }
  void _logout() async{
    final String apiurl = "$baseurl/auth/logout";
    final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
    final String? refreshToken = await secureStorage.read(key: "refresh_token");
    final response = await http.post(
      Uri.parse(apiurl),
      headers: {
        "Authorization": "Bearer $refreshToken",
        "Content-Type": "application/json",
      },
    );
    if (response.statusCode == 200){
      await secureStorage.delete(key: "access_token");
      await secureStorage.delete(key: "refresh_token");
      await secureStorage.delete(key: "remember_me");
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()
          )
      );
    }else{
      final error = json.decode(response.body)['detail'];
      _showError(error);
    }
  }
  void _showError(String msg){
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Login Failed"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Library',
          style: TextStyle(
            fontSize: 25,
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.italic,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 4, 52, 91),
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(
              height: 150,
              child: UserAccountsDrawerHeader(
                margin: EdgeInsets.only(bottom: 0),
                accountName: Text(
                  'User',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: Text(
                  'user@example.com',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/library.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            _buildDrawerItem(Icons.home, "Home",Page:Homepage()),
            _buildDrawerItem(Icons.person, "Profile",Page:ProfileScreen()),
            _buildDrawerItem(Icons.menu_book, "Add Book",Page:ADDBooklist()),
            _buildDrawerItem(Icons.menu, "Book List",Page:Booklist()),
            _buildDrawerItem(Icons.menu, "Member List", Page: MemberList()),
            _buildDrawerItem(Icons.menu_book, "Issue Book",Page:IssueBook()),
            _buildDrawerItem(Icons.menu_book, "Return Book",Page:Returnpage()),
            _buildDrawerItem(Icons.help, "help",Page:Help()),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("logout"),
              onTap: () {
                _logout();
              },
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(5),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Libeditpage()));
                    },
                    child: Image.asset(
                      'assets/images/bookstack.jpg',
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Positioned(
                    left: 20,
                    bottom: 10,
                    child: Text(
                      'Library Management system',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 10,
                children: [
                  DashboardCard(
                      title: 'Total books',
                      iconPath: 'assets/images/book_icon.jpg',
                      count: '${data['total_books']}',
                      page: book()),
                  DashboardCard(
                      title: 'Total members',
                      iconPath: 'assets/images/book_icon.jpg',
                      count: '${data['total_members']}',
                      page: book()),
                  DashboardCard(
                      title: 'Issued today',
                      iconPath: 'assets/images/book_icon.jpg',
                      count: '${data['issued_today']}',
                      page: book()),
                  DashboardCard(
                      title: 'Issued (7 days)',
                      iconPath: 'assets/images/book_icon.jpg',
                      count: '${data['issued_week']}',
                      page: book()),
                  DashboardCard(
                      title: 'Issued all',
                      iconPath: 'assets/images/book_icon.jpg',
                      count: '${data['total_issued']}',
                      page: book()),
                  DashboardCard(
                      title: 'Due books',
                      iconPath: 'assets/images/book_icon.jpg',
                      count: '${data['total_dues']}',
                      page: book()),
                  DashboardCard(
                      title: 'Fine collection',
                      iconPath: 'assets/images/book_icon.jpg',
                      count: '${data['fine_collection']}',
                      page: book()),
                  DashboardCard(
                      title: 'Return all',
                      iconPath: 'assets/images/book_icon.jpg',
                      count: '${data['returned_books']}',
                      page: book()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title,{required Page}) {

    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => Page));
      },
    );
  }
}