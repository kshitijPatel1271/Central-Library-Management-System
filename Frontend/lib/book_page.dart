import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_library/book_list.dart';
import 'package:http/http.dart' as http;
import 'package:my_library/Bookpage.dart';
class BookListPage extends StatefulWidget {
  final String selectedGenre;

  BookListPage({super.key, required this.selectedGenre});

  @override
  State<StatefulWidget> createState() {
    return _BookListPage(selectedGenre: selectedGenre);
  }
}
class _BookListPage extends State<BookListPage> {
  final String selectedGenre;
  List<Book> filteredBooks = [];
  final String baseurl = "${dotenv.env['BASE_URL']}";
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  _BookListPage({required this.selectedGenre});
  @override
  void initState(){
    super.initState();
    _fetch();
  }
  void _fetch() async{
    final String? token = await secureStorage.read(key: 'access_token');
    final response = await http.get(Uri.parse('$baseurl/books/genre/$selectedGenre'),headers: {'Authorization': 'Bearer $token'});
    if(response.statusCode == 200){
      final data = json.decode(response.body);//TODO: MAKE IT WORK
      setState(() {
        filteredBooks = data.map((bookJson) => Book.fromJson(bookJson)).toList();
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedGenre,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filteredBooks.map((book) {
              return Container(
                width: 150,
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context){return Bookpage(book: book);}));
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          book.img,
                          height: 180,
                          width: 140,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      book.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      book.author,
                      style: TextStyle(color: Colors.grey.shade600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}