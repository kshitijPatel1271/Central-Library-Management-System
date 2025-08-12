    class Book {
    final int id;
    final String name;
    final String author;
    final String description;
    final String? genre;
    final String img;

    Book({
        required this.id,
        required this.name,
        required this.author,
        required this.description,
        required this.genre,
        required this.img
    });
    factory Book.fromJson(Map<String, dynamic> json) {
        return Book(
            id: json['bid'],
            name: json['name'],
            author: json['author'],
            description: json['description'],
            genre: (json['genres'] as List).join(', '),
            img: json['cover'] ?? "assets/images/default.jpg",
        );
    }
    Map<String, dynamic> toJson() {
        return {
            'id': id,
            'name': name,
            'author': author,
            'description': description,
            'genre': genre,
            'img': img,
        };
    }
}
    List<Book> books = [//TODO: UPLOAD THIS TEST DATA
        Book(
            id: 201,
            name: "Introduction to the Theory of Computation",
            author: "Michael Sipser",
            description: "A comprehensive guide to computational theory, automata, and complexity.",
            genre: "Computer Science, Theory",
            img: "assets/images/img1.jpg"
        ),
        Book(
            id: 202,
            name: "Artificial Intelligence: A Modern Approach",
            author: "Stuart Russell, Peter Norvig",
            description: "The standard AI textbook covering search, learning, and deep AI concepts.",
            genre: "Artificial Intelligence, Machine Learning",
            img: "assets/images/img2.jpg"
        ),
        Book(
            id: 203,
            name: "Clean Code",
            author: "Robert C. Martin",
            description: "Guidelines for writing maintainable, high-quality, and clean software code.",
            genre: "Software Development, Best Practices",
            img: "assets/images/img3.jpg"
        ),
        Book(
            id: 204,
            name: "Computer Networking: A Top-Down Approach",
            author: "James F. Kurose, Keith W. Ross",
            description: "Explains networking concepts starting from application layer to the physical layer.",
            genre: "Networking, Computer Science",
            img: "assets/images/img4.jpg"
        ),
        Book(
            id: 205,
            name: "The C Programming Language",
            author: "Brian W. Kernighan, Dennis M. Ritchie",
            description: "A foundational book for learning the C programming language from the creators.",
            genre: "Programming, Systems",
            img: "assets/images/img5.jpg"
        ),
        Book(
            id: 206,
            name: "Introduction to Algorithms",
            author: "Thomas H. Cormen, Charles E. Leiserson, Ronald L. Rivest, Clifford Stein",
            description: "A detailed and theoretical guide on algorithms used in computing.",
            genre: "Algorithms, Computer Science",
            img: "assets/images/img6.jpg"
        ),
        Book(
            id: 207,
            name: "Design Patterns: Elements of Reusable Object-Oriented Software",
            author: "Erich Gamma, Richard Helm, Ralph Johnson, John Vlissides",
            description: "A classic book explaining fundamental design patterns in software development.",
            genre: "Software Engineering, Programming",
            img: "assets/images/img7.jpg"
        ),
        Book(
            id: 208,
            name: "Operating System Concepts",
            author: "Abraham Silberschatz, Peter B. Galvin, Greg Gagne",
            description: "Comprehensive knowledge of modern operating systems and their concepts.",
            genre: "Operating Systems, Computer Science",
            img: "assets/images/img8.jpg"
        ),
        Book(
            id: 209,
            name: "Database System Concepts",
            author: "Abraham Silberschatz, Henry F. Korth, S. Sudarshan",
            description: "A complete guide to database management systems and SQL.",
            genre: "Databases, Computer Science",
            img: "assets/images/img9.jpg"
        ),
        Book(
            id: 210,
            name: "Deep Learning",
            author: "Ian Goodfellow, Yoshua Bengio, Aaron Courville",
            description: "A fundamental book on deep learning concepts and neural networks.",
            genre: "Machine Learning, Artificial Intelligence",
            img: "assets/images/img10.jpg"
        ),
        Book(
            id: 211,
            name: "You Don't Know JS",
            author: "Kyle Simpson",
            description: "A deep dive into JavaScript concepts, closures, scope, and asynchronous programming.",
            genre: "Web Development, JavaScript",
            img: "assets/images/img11.jpg"
        ),
        Book(
            id: 212,
            name: "The Pragmatic Programmer",
            author: "Andrew Hunt, David Thomas",
            description: "A must-read book on software craftsmanship and best coding practices.",
            genre: "Software Engineering, Development",
            img: "assets/images/img12.jpg"
        ),
        Book(
            id: 213,
            name: "The Mythical Man-Month",
            author: "Frederick P. Brooks Jr.",
            description: "Insights into software project management and engineering principles.",
            genre: "Software Project Management",
            img: "assets/images/img13.jpg"
        ),
        Book(
            id: 214,
            name: "Structure and Interpretation of Computer Programs",
            author: "Harold Abelson, Gerald Jay Sussman",
            description: "A classic programming book emphasizing recursion, abstraction, and interpretation.",
            genre: "Programming, Computer Science",
            img: "assets/images/img14.jpg"
        ),
        Book(
            id: 215,
            name: "Cryptography and Network Security",
            author: "William Stallings",
            description: "A complete guide to cryptographic principles and secure communication.",
            genre: "Cybersecurity, Cryptography",
            img: "assets/images/img15.jpg"
        ),
        Book(
            id: 216,
            name: "The Design of Everyday Things",
            author: "Don Norman",
            description: "A UX design book explaining how to create user-friendly technology.",
            genre: "User Experience, Design",
            img: "assets/images/img16.jpg"
        ),
    ];
