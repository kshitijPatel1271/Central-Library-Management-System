import 'package:flutter/material.dart';
import 'package:my_library/book_list.dart';
import 'package:my_library/lib.dart';
import 'package:my_library/Bookpage.dart';
import 'package:my_library/libpage.dart';
import 'package:my_library/libbooks.dart';
import 'package:my_library/Borrowdata.dart';
import 'package:my_library/transactiondetailspage.dart';
import 'dart:io';
import 'package:my_library/LibbookPage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_library/Addbookpage.dart';
import 'package:my_library/usertp.dart';
class Bookcardbuilder extends StatelessWidget {
  final List<Book> libook;
  const Bookcardbuilder({super.key, required this.libook,});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: libook.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, i) {
          final book = libook[i];

          return Container(

            width: 180,
              child: GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context){return Bookpage(book: book);}));
                },
                child: Card(
                  elevation:6,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 5),
                        height: 140,
                        child: Image.network(book.img,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        width: 160,
                        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black))),
                      ),
                      Container(padding:EdgeInsets.only(left: 5),child: Text(book.name))
                    ],
                  ),
                ),
              ),
          );
        });
  }
}
class libcardbuilder extends StatelessWidget {
  final List<Library> lilist;
  const libcardbuilder({super.key, required this.lilist,});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: lilist.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, i) {
          final lib = lilist[i];

          return Container(

            width: 350,
            child: GestureDetector(
              onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context){return libpage(lib: lib);}));},
              child: Card(
                elevation: 6,
                child: Column(
                  children: [
                    Container(
                      height: 170,
                      child: Container(
                        padding: EdgeInsets.only(top: 5),
                        child: Image.network(lib.picturePath,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      width: 330,
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black))),
                    ),
                    Text(lib.name,style: TextStyle(fontSize: 20),)
                  ],
                ),
              ),
            ),
          );
        });
  }
}
class libbooksBuild extends StatelessWidget {
  final List<Libbook> lilist;
  const libbooksBuild({super.key, required this.lilist,});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: lilist.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, i) {
          final book = lilist[i];

          return Container(

            width: 180,
            child: GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context){return LibBookPage(book: book);}));
              },
              child: Card(
                elevation:6,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 5),
                      height: 140,
                      child: Image.network(book.img,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      width: 160,
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black))),
                    ),

                    Container(padding:EdgeInsets.only(left: 5),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Id: ${book.library_Libbookid}",
                          style: TextStyle(fontSize: 16),
                        )
                    ),
                    Container(padding:EdgeInsets.only(left: 5),
                        child: Text(
                          "Name: ${book.name}",
                          maxLines: 1, // Limits the text to one line
                          overflow: TextOverflow.ellipsis, // Adds "..." if the text overflows
                          style: TextStyle(fontSize: 16),
                        )
                    ),
                    if(int.parse(book.available)>0)
                      Container(padding:EdgeInsets.only(left: 5),
                          child: Text(
                            "Available",
                            style: TextStyle(fontSize: 16,color: Colors.green),
                          )
                      ),
                    if(int.parse(book.available)<=0)
                      Container(padding:EdgeInsets.only(left: 5),
                          child: Text(
                            "Not Available",
                            style: TextStyle(fontSize: 16,color: Color(0xFFFF0000)),
                          )

                      )
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class DatePickerWidget extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  const DatePickerWidget({Key? key, required this.onDateSelected}) : super(key: key);

  @override
  _DatePickerWidgetState createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  DateTime? selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
      widget.onDateSelected(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed:() => _selectDate(context), icon: Icon(Icons.calendar_month_sharp));
  }
}
class Borowlistbilt extends StatelessWidget{
  final List<Borrow> bolist;
  const Borowlistbilt({super.key, required this.bolist});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: bolist.length,
      itemBuilder: (BuildContext context,i){
        final borrow=bolist[i];
        return Container(
          margin: EdgeInsets.all(5),
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: Colors.black26,
            borderRadius: BorderRadius.circular(15)
          ),
          width: MediaQuery.of(context).size.width*8,
          child: GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context){return TransactionPage(borrow: borrow);}));
            },
            child: Column(
              children: [
                Row(
                  children: [Container(

                    width: MediaQuery.of(context).size.width*0.4,
                    child: Text(
                      "Book Id : ${borrow.bookId}",
                      maxLines: 1, // Limits the text to one line
                      overflow: TextOverflow.ellipsis, // Adds "..." if the text overflows
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                    Container(
                      decoration: BoxDecoration(border: Border(left: BorderSide(color: Colors.black))),
                      width: 1,
                      height: 25,
                    ),

                     Container(
                       width: MediaQuery.of(context).size.width*0.5,
                       padding: EdgeInsets.only(left: 5),
                       child: Text(
                          "Transaction : ${borrow.transactionId}",
                          maxLines: 1, // Limits the text to one line
                          overflow: TextOverflow.ellipsis, // Adds "..." if the text overflows
                          style: TextStyle(fontSize: 20),
                                         ),
                     ),

                  ],
                ),
                Container(
                  margin: EdgeInsets.all(2),
                  width: MediaQuery.of(context).size.width*8,
                  height: 1,
                  color: Colors.black,
                ),
                Container(
                  width: MediaQuery.of(context).size.width*8,
                    alignment: Alignment.centerLeft,
                    child: Text("Assign To: #${borrow.userId}",
                    style: TextStyle(fontSize: 18),),
                ),

                Container(
                  width: MediaQuery.of(context).size.width*8,
                  alignment: Alignment.centerLeft,
                  child: Text("🕒: ${(borrow.issueDate).toString().split(" ")[0]} ~ ${borrow.deadline.toString().split(" ")[0]}",
                    style: TextStyle(fontSize: 18),),
                ),
                if(borrow.penalty>0)
                  Container(
                    width: MediaQuery.of(context).size.width*8,
                    alignment: Alignment.centerLeft,
                    child: Text("penalty: ${borrow.penalty} Rs",
                      style: TextStyle(fontSize: 18,color: Colors.red),),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
class CustomImagePicker extends StatefulWidget {
  final Function(File?) onImageSelected;

  const CustomImagePicker({Key? key, required this.onImageSelected}) : super(key: key);

  @override
  _CustomImagePickerState createState() => _CustomImagePickerState();
}

class _CustomImagePickerState extends State<CustomImagePicker> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      widget.onImageSelected(_imageFile);
    }
  }

  void _showPickerDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Gallery'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Camera'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPickerDialog(context),
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: _imageFile == null
            ? const Icon(Icons.image, size: 50, color: Colors.grey)
            : ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(_imageFile!, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
class addBookcardbuilder extends StatelessWidget {
  final List<Book> libook;
  const addBookcardbuilder({super.key, required this.libook,});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: libook.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, i) {
          final book = libook[i];

          return Container(

            width: 180,
            child: GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context){return AddBookdetailspage(book: book);}));
              },
              child: Card(
                elevation:6,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 5),
                      height: 140,
                      child: Image.network(book.img,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      width: 160,
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black))),
                    ),
                    Container(padding:EdgeInsets.only(left: 5),child: Text(book.name))
                  ],
                ),
              ),
            ),
          );
        });
  }
}
class Borowlistbilt2 extends StatelessWidget{
  final List<Borrow> bolist;
  const Borowlistbilt2({super.key, required this.bolist});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: bolist.length,
      itemBuilder: (BuildContext context,i){
        final borrow=bolist[i];
        return Container(
          margin: EdgeInsets.all(5),
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(15)
          ),
          width: MediaQuery.of(context).size.width*8,
          child: GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context){return TransactionPage2(borrow: borrow);}));
            },
            child: Column(
              children: [
                Row(
                  children: [Container(

                    width: MediaQuery.of(context).size.width*0.4,
                    child: Text(
                      "Book Id : ${borrow.bookId}",
                      maxLines: 1, // Limits the text to one line
                      overflow: TextOverflow.ellipsis, // Adds "..." if the text overflows
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                    Container(
                      decoration: BoxDecoration(border: Border(left: BorderSide(color: Colors.black))),
                      width: 1,
                      height: 25,
                    ),

                    Container(
                      width: MediaQuery.of(context).size.width*0.5,
                      padding: EdgeInsets.only(left: 5),
                      child: Text(
                        "Transaction : ${borrow.transactionId}",
                        maxLines: 1, // Limits the text to one line
                        overflow: TextOverflow.ellipsis, // Adds "..." if the text overflows
                        style: TextStyle(fontSize: 20),
                      ),
                    ),

                  ],
                ),
                Container(
                  margin: EdgeInsets.all(2),
                  width: MediaQuery.of(context).size.width*8,
                  height: 1,
                  color: Colors.black,
                ),
                Container(
                  width: MediaQuery.of(context).size.width*8,
                  alignment: Alignment.centerLeft,
                  child: Text("Assign To: #${borrow.userId}",
                    style: TextStyle(fontSize: 18),),
                ),

                Container(
                  width: MediaQuery.of(context).size.width*8,
                  alignment: Alignment.centerLeft,
                  child: Text("🕒: ${(borrow.issueDate).toString().split(" ")[0]} ~ ${borrow.deadline.toString().split(" ")[0]}",
                    style: TextStyle(fontSize: 18),),
                ),
                if(borrow.penalty>0)
                  Container(
                    width: MediaQuery.of(context).size.width*8,
                    alignment: Alignment.centerLeft,
                    child: Text("penalty: ${borrow.penalty} Rs",
                      style: TextStyle(fontSize: 18,color: Colors.red),),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}