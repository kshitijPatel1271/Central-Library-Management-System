import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:my_library/UserBorrow.dart';
import 'package:my_library/book_list.dart';
import 'package:my_library/book_page.dart';
import 'package:my_library/favorites_page.dart';
import 'package:my_library/help.dart';
import 'package:my_library/loginpage.dart';
import 'package:my_library/profilepage.dart';
import 'package:my_library/sign_up.dart';
import 'package:my_library/Searchpage.dart';
import 'package:my_library/Bookpage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<String> imageList = [
    'assets/images/andrews-library-best-libraries-in-surat-264x300.jpg',
    'assets/images/narbad_library_after.jpg',
    'assets/images/shri-keshubhai-patel-smc-library-surat-libraries-1536x864.webp',
  ];
  bool isLoggedIn = true;
  List<String?> genres = books.map((book) => book.genre).toSet().toList();
  String? selectedGenre;
  List<Book> favoriteBooks = [];

 void _logout() async{
   final String apiurl = "${dotenv.env['BASE_URL']}/auth/logout";
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
  void _showSuccess(String msg){
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Success"),
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

  void toggleFavorite(Book book) {
    setState(() {
      if (favoriteBooks.contains(book)) {
        favoriteBooks.remove(book);
      } else {
        favoriteBooks.add(book);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(35),
        child: AppBar(
          title: const Text(
            "My Library",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          toolbarHeight: 35,
          backgroundColor: Colors.white,
          actions: [
            isLoggedIn
                ? GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.black,
                        child: Icon(Icons.person, color: Colors.blue, size: 20),
                      ),
                    ),
                  )
                : Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(color: Colors.black, fontSize: 15),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignupPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Signup",
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration:
                  BoxDecoration(color: Color.fromARGB(255, 232, 234, 235)),
              child: Text(
                "Welcome!",
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text("Books"),
               onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context){return UserBorrow();}));
              }
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text("My favorites books"),
              onTap: () => Navigator.push(
                  context,
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return FavoritesPage();
                      },
                    ),
                  ) as Route<Object?>),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: books.map((book) => book.genre).toSet().length,
                itemBuilder: (context, index) {
                  List<String?> uniqueGenres =
                      books.map((book) => book.genre).toSet().toList();
                  String? genre = uniqueGenres[index];
                  if (books.where((book) => book.genre == genre).isEmpty) {
                    return SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => selectedGenre = genre);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    BookListPage(selectedGenre: '${genre}')));
                      },
                      child: Chip(
                        label: Text(
                          '${genre}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        backgroundColor: Colors.blue.shade100,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            CarouselSlider(
              options: CarouselOptions(
                height: 200.0,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                enlargeCenterPage: true,
                viewportFraction: 1.0,
              ),
              items: imageList.map((imagePath) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: genres.map((genre) {
                  List<Book> genreBooks =
                      books.where((book) => book.genre == genre).toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          '${genre}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: 180,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: genreBooks.length,
                          itemBuilder: (context, index) {
                            Book book = genreBooks[index];
                            bool isFavorite = favoriteBooks.contains(book);
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context){return Bookpage(book: book);}));
                              },
                              child: Container(
                                width: 130,
                                margin: const EdgeInsets.only(right: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.asset(book.img,
                                                fit: BoxFit.cover,
                                                width: 130,
                                                height: 150),
                                          ),
                                          Positioned(
                                            top: 5,
                                            right: 5,
                                            child: IconButton(onPressed:() {
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: Text(book.name),
                                                  content: const Text(
                                                      "Would you like to add this book to your favorites?"),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        toggleFavorite(book);
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(isFavorite
                                                          ? "Remove from Favorites"
                                                          : "Add to Favorites"),
                                                    ),
                                                    TextButton(
                                                      onPressed:() async{
                                                        final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
                                                        final String? token = await secureStorage.read(key: 'access_token');
                                                        if(!isFavorite){
                                                          final apiurl = "${dotenv.env['BASE_URL']}/users/add-to-fav/${book.id}";
                                                          final response = await http.post(
                                                            Uri.parse(apiurl),
                                                            headers: {"accept": "application/json","Content-Type": "application/json",'Authorization': 'Bearer $token'},
                                                          );
                                                          if (response.statusCode == 200){
                                                            final msg = json.decode(response.body)['message'];
                                                            _showSuccess(msg);
                                                          } else {
                                                            final error = json.decode(response.body);
                                                            _showError(error);
                                                          }
                                                        } else {
                                                          final apiurl = "${dotenv.env['BASE_URL']}/users/rem-fav/${book.id}";
                                                          final response = await http.delete(Uri.parse(apiurl),headers: {'accept':'application/json','Content-Type':'application/json','Authorization': 'Bearer $token'});
                                                          if (response.statusCode == 200) {
                                                            final msg = json.decode(response.body);
                                                            _showSuccess(msg);
                                                          } else {
                                                            final msg = json.decode(response.body);
                                                            _showError(msg);
                                                          }
                                                        }
                                                      },
                                                      child: const Text("Cancel"),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }, icon: Icon(
                                              isFavorite
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: isFavorite
                                                  ? Colors.red
                                                  : Colors.grey,
                                            )),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      book.name,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                      )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: GestureDetector(onTap:(){
            Navigator.push(context, MaterialPageRoute(builder: (context){return Searchpage();}));
          } ,
            child: Icon(Icons.search),), label: 'Search',),
          BottomNavigationBarItem(icon: GestureDetector(onTap:(){
            Navigator.push(context, MaterialPageRoute(builder: (context){return Help();}));
          } ,
            child: Icon(Icons.help),), label: 'Help',),
        ],
      ),
    );
  }
}
