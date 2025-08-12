class Library {
  String name;
  String address;
  String librarianName;
  String contact;
  String picturePath;

  Library({
    required this.name,
    required this.address,
    required this.librarianName,
    required this.contact,
    required this.picturePath,
  });

  factory Library.fromJson(Map<String, dynamic> json) {
    return Library(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      librarianName: json['librarianName'] ?? '',
      contact: json['contact'] ?? '',
      picturePath: json['picturePath'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'librarianName': librarianName,
      'contact': contact,
      'picturePath': picturePath,
    };
  }
}