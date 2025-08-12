import 'package:flutter/material.dart';
import 'book_list.dart';
import 'package:my_library/Bookpage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FavoritesPage extends StatefulWidget {
  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Book> favoriteBooks = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() async {
    print("ITS TRYING TO FETCH :D");
    final String apiurl = "${dotenv.env["BASE_URL"]}/users/fav-list";
    final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
    final String? token = await secureStorage.read(key: 'access_token');
    final response = await http.get(Uri.parse(apiurl),headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      print(json.decode(response.body));
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        favoriteBooks = data.map((bookJson) => Book.fromJson(bookJson)).toList();
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Favorite Books"),
        backgroundColor: Colors.blueAccent,
      ),
      body: favoriteBooks.isEmpty
          ? const Center(
              child: Text(
                "No Favorite Books Yet!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: GridView.builder(
                itemCount: favoriteBooks.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 books per row
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index) {
                  Book book = favoriteBooks.elementAt(index);
                  return GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context){return Bookpage(book: book);}));
                    },
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                              child: Image.network(book.img, fit: BoxFit.cover, width: double.infinity),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              book.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async{
                              final String apiurl = "${dotenv.env['BASE_URL']}/users/rem-fav/${book.id}";
                              final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
                              final String? token = await secureStorage.read(key: 'access_token');
                              final response = await http.delete(Uri.parse(apiurl),headers: {'Authorization': 'Bearer $token'});
                              if(response.statusCode == 200){
                                //TODO: +VE & -VE RESPONSE
                              }
                              (context as Element).markNeedsBuild();
                              favoriteBooks.remove(book);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
