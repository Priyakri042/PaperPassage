import 'dart:ffi';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:kitaab/Services/database_services.dart';
import 'package:kitaab/main.dart';
import 'package:path/path.dart' as Path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kitaab/navigation_bar.dart';

class AddBook extends StatefulWidget {
  AddBook({super.key});

  @override
  State<AddBook> createState() => _AddBookState();
}

class _AddBookState extends State<AddBook> {
  File? imageFile;
  var bookName;
  var authorName;
  var category;
  var rentOrSell;
  late int price;
  var description;

  bool ifImagePicked = false;

  String? period;
  
  late int rentPrice;

  

  Future<String> uploadImage(File imageFile) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Create a reference to the location you want to upload to in Firebase Storage
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('books/$userId/${Path.basename(imageFile.path)}');

    // Upload the file to Firebase Storage
    UploadTask uploadTask = storageReference.putFile(imageFile);

    // Get the download URL
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  String? imageUrl;
  final _formKey = GlobalKey<FormState>();
  //form to add book details

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxWidth > 600) {
              return const Text('Add Book');
            } else {
              return const Text('Add Book');
            }
          },
        ),
        centerTitle: true,
      ),
      body:
          //show form to add book details
          SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              //form to add book details
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    //book name
                    TextFormField(
                      onSaved: (value) {
                        bookName = value;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Book Name',
                        hintText: 'Enter Book Name',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter book name';
                        }
                        return null;
                      },
                    ),
                    //author name
                    TextFormField(
                      onSaved: (value) {
                        authorName = value;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Author Name',
                        hintText: 'Enter Author Name',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter author name';
                        }
                        return null;
                      },
                    ),
                    //option to select category of book
                    DropdownButtonFormField(
                      onSaved: (value) {
                        category = value;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        hintText: 'Select Category',
                      ),
                      items: const [
                        //'Action',
                        // 'Fantasy',
                        // 'Horror',
                        // 'Romance',
                        // 'Science Fiction',
                        // 'Thriller'
                        DropdownMenuItem(
                          child: Text('Action'),
                          value: 'Action',
                        ),
                        DropdownMenuItem(
                          child: Text('Fantasy'),
                          value: 'Fantasy',
                        ),
                        DropdownMenuItem(
                          child: Text('Horror'),
                          value: 'Horror',
                        ),
                        DropdownMenuItem(
                          child: Text('Romance'),
                          value: 'Romance',
                        ),
                        DropdownMenuItem(
                          child: Text('Science Fiction'),
                          value: 'Science Fiction',
                        ),
                        DropdownMenuItem(
                          child: Text('Thriller'),
                          value: 'Thriller',
                        ),

                      ],
                      onChanged: (value) {
                        //select category
                        value = category;
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select category';
                        }
                        return null;
                      },
                    ),
                    //rent or sell option

                    //disk button to select rent or sell option
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Rent', style: TextStyle(fontSize: 15)),
                        Radio(
                          value: 'Rent',
                          groupValue: rentOrSell,
                          onChanged: (value) {
                            setState(() {
                              rentOrSell = value;
                            });
                          },
                        ),
                        const Text('Sell', style: TextStyle(fontSize: 15)),
                        Radio(
                          value: 'Sell',
                          groupValue: rentOrSell,
                          onChanged: (value) {
                            setState(() {
                              rentOrSell = value;
                            });
                          },
                        ),
                        const Text('Both', style: TextStyle(fontSize: 15)),
                        Radio(
                          value: 'Both',
                          groupValue: rentOrSell,
                          onChanged: (value) {
                            setState(() {
                              rentOrSell = value;
                            });
                          },
                        )
                      ],
                    ),
                    //price of book
                    //if rent option is selected, mention rent price per week
                    //if sell option is selected, mention selling price

                    //price of book
                   rentOrSell == 'Rent' || rentOrSell == 'Both'
                        ? TextFormField(
                            
                            onSaved: (value) {
                              rentPrice = int.parse(value!);
                            },
                            decoration: const InputDecoration(
                              labelText: 'Rent Price per day',
                            ),
                            //input type is number
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter rent price';
                              }
                              
                              return null;
                            },
                          )
                        : TextFormField(
                            onSaved: (value) {
                              price =int.parse(value!);
                            },
                            decoration: const InputDecoration(
                              labelText: 'Price',
                              hintText: 'Enter Price',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter price';
                              }
                              return null;
                            },
                          ),
                          rentOrSell == 'Buy' || rentOrSell == 'Both'?
                          TextFormField(
                            onSaved: (value) {
                              price = int.parse(value!);
                            },
                            decoration: const InputDecoration(
                              labelText: 'Price',
                              hintText: 'Enter Price',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter price';
                              }
                              return null;
                            },
                          ):Container(),
                    //description of book
                    TextFormField(
                      onSaved: (value) {
                        description = value;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter Description',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter description';
                        }
                        return null;
                      },
                    ),
                    //upload image of book
                    const SizedBox(
                      height: 10.0,
                    ),

                    ifImagePicked
                        ? Stack(
                            alignment: Alignment.topRight,
                            children: <Widget>[
                              Container(
                                height: 200,
                                width: 200,
                                child: Image.file(imageFile!),
                              ),
                              Positioned(
                                top: -13,
                                right: -13,
                                child: IconButton(
                                  icon: const Icon(Icons.cancel),
                                  onPressed: () {
                                    setState(() {
                                      imageFile = null;
                                      imageUrl = null;
                                      ifImagePicked = false;
                                    });
                                  },
                                ),
                              ),
                            ],
                          )
                        : ElevatedButton(
                            onPressed: () async {
                              final picker = ImagePicker();
                              final pickedFile = await picker.pickImage(
                                  source: ImageSource.gallery);

                              if (pickedFile != null) {
                                imageFile = File(pickedFile.path);
                                imageUrl = await uploadImage(imageFile!);
                                setState(() {
                                  //image is uploaded
                                  ifImagePicked = true;
                                });
                              } else {
                                print('No image selected.');
                              }
                            },
                            child: const Text('Upload Image'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.green[800],
                            ),
                          ),

                    //at the bottom of form, submit button
                    const SizedBox(
                      height: 10.0,
                    ),

                    ElevatedButton(
                      onPressed: () {
                        //submit book details
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();

                          if (imageUrl != null)

                          if(rentOrSell == 'Rent') {
                            addBook( FirebaseAuth.instance.currentUser!.uid,
                            //generate unique id for book
                                bookName + DateTime.now().toString(),
                              bookName, authorName, category, rentOrSell,
                              rentPrice, 0,
                                 description, imageUrl!, 
                                );
                          }
                          else if(rentOrSell == 'Sell') {
                            addBook( FirebaseAuth.instance.currentUser!.uid,
                            //generate unique id for book
                                bookName + DateTime.now().toString(),
                              bookName, authorName, category, rentOrSell,
                              0, price,
                                 description, imageUrl!
                                );
                          }
                          else {
                            addBook( FirebaseAuth.instance.currentUser!.uid,
                            //generate unique id for book
                                bookName + DateTime.now().toString(),
                              bookName, authorName, category, rentOrSell,
                              rentPrice, price,
                                 description, imageUrl!,
                                );
                          }


                                if(ifImagePicked == true)
                            navigatorKey.currentState!.pop();
                        
                          else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Please upload image of book'),
                            ));
                            
                          
                        }
                      }
                      },
                      //decorating the button
                      //height of button
                      style: ElevatedButton.styleFrom(
                        //shadow of button
                        //height of button
                        elevation: 5,
                        //background color of button
                        backgroundColor: Colors.green[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 100, vertical: 15),
                        textStyle: const TextStyle(
                          fontSize: 20,
                        ),
                      ),

                      child: const Text('Submit',
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BtmNavigationBar(),
    );
  }
}
