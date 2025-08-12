class Libbook {
  final int id;
  final String name;
  final String author;
  final String description;
  final String genre;
  final String img;
  final String library_Libbookid;
  final String Qntity;
  final String available;
  final String lid;


  Libbook({
    required this.id,
    required this.name,
    required this.author,
    required this.description,
    required this.genre,
    required this.img,
    required this.library_Libbookid,
    required this.Qntity,
    required this.available,
    required this.lid,

  });
  factory Libbook.fromJson(Map<String, dynamic> json) {
    return Libbook(
      name: json['name'],
      author: json['author'],
      library_Libbookid: json['library_book_id'].toString(),
      id: json['bid'],
      description: json['description'],
      genre: json['genres'] ?? '',
      img: json['cover'],
      Qntity: json['total_copies'].toString(),
      available: json['available_count'].toString(),
      lid: json['library_id'].toString(),
    );
  }

}


