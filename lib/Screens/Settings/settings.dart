// import 'dart:html';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kitaab/Screens/Book/book.dart';
import 'package:kitaab/Services/database_services.dart';
import 'package:kitaab/Services/theme_provider.dart';
import 'package:kitaab/main.dart';
import 'package:kitaab/navigation_bar.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool isEnterEmail = false;

  bool isEnterPassword = false;

  bool isEnterPhoneNumber = false;

  bool isEnterLocation = false;

  bool isDarkMode = false;
  String? name, email, profile;
  SharedPreferences? prefs;

  bool isEnterName = false;

  //getImage from the database
    FirebaseAuth auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> getUser() async {
    //get user details from database
    User? user = auth.currentUser;
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    if (documentSnapshot.exists) {
      Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
      return data;
    } else {
      return {};
    }
  }

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // return to home page
        navigatorKey.currentState?.pushReplacementNamed('/home');
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              navigatorKey.currentState?.pushReplacementNamed('/home');
            },
          ),
          
          title: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              if (constraints.maxWidth > 600) {
                return const Text('Profile', style: TextStyle(fontSize: 30, color: Colors.black));
              } else {
                return const Text('Profile', style: TextStyle(fontSize: 20, color: Colors.black));
              }
            },
          ),
                    backgroundColor: Colors.brown[200],

          centerTitle: true,
          //notification icon
          actions: [
              FutureBuilder(
                future: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).
                collection('soldBooks').get(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.data.docs.length == 0) {
                    return IconButton(
                      icon: const Icon(Icons.notifications, size: 20,color: Colors.black ,),
                      onPressed: () {
                        //navigate to notifications page
                        navigatorKey.currentState!.pushNamed('/notifications');
                      },
                    );
                  }
                  return  IconButton(
                icon:  Icon(Icons.notifications_active_outlined, size: 20,color: Colors.black ,),
                onPressed: () {
                  //navigate to notifications page
                  navigatorKey.currentState!.pushNamed('/notifications');
                },
                            );
                },
              ),
          ],
          
        ),
        body:
            //show profile details
            Column(
          children: [
            getUploadStatus(),
            Card(
              elevation: 5,
              shadowColor:            Colors.brown[200],

              child: Container(
                
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
                          child: FutureBuilder<Image>(
                      future: getImage(
                          FirebaseAuth.instance.currentUser!.uid
                      ),
                      builder: (BuildContext context,
                          AsyncSnapshot<Image> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container();// or some placeholder
                        } else {
                          if (snapshot.hasError) {
                            return Icon(Icons.error); // or some error widget
                          } else {
                            return Stack(
                              children: <Widget>[
                                CircleAvatar(
                                  radius: 80,
                                  backgroundColor: Colors.brown[800],
                                ),
                                Positioned(
                                  top: 2,
                                  left: 2,
                                  right: 2,
                                  bottom: 2,
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundImage: snapshot.data!.image,
                                  ),
                                ),
                              ],
                            );
                          }
                        }
                      },
                    ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          left: 0,
                          top: 63,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt),
                            onPressed: () async {
                              setState(() {
                                 
                              });
                              // Make the onPressed callback async
                              XFile? imageFile = await ImagePicker()
                                  .pickImage(source: ImageSource.gallery);
                              if (imageFile != null) {
                                await uploadProfileImage(File(imageFile.path),
                                    FirebaseAuth.instance.currentUser!.uid);
                                setState(() {});
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(
                      width: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello,',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        isEnterName
                            ? Container(
                                height: 50,
                                width: 270,
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Enter New Name',
                                    border: UnderlineInputBorder(),
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.save),
                                      onPressed: () async {
                                        SharedPreferences prefs =
                                            await SharedPreferences.getInstance();
                                        prefs.setString(
                                            'name', _nameController.text);
                                        setState(() {
                                          isEnterEmail = false;
                                          navigatorKey.currentState!
                                              .pushNamed('/settings');
                                          //also update the email in the database
                                          updateData({
                                            'name': _nameController.text,
                                          }, 'users', prefs.getString('userId')!);
                                          isEnterName = false;
                                        });
                                      },
                                    ),
                                  ),
                                  controller: _nameController,
                                  keyboardType: TextInputType.text,
                                  enabled: isEnterName,
                                ),
                              )
                            : FutureBuilder<Map<String, dynamic>>(
                                future: getUser(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<Map<String, dynamic>> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Text('Loading...');
                                  }
                                  return Text(
                                    snapshot.data!['name']?? 'Add Name',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                    //edit profile button
                    const Spacer(),
                    isEnterName
                        ? Container()
                        : IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              //navigate to edit profile page
                              setState(() {
                                isEnterName = true;
                              });
                            },
                          ),
                  ],
                ),
              ),
            ),
            //change email,change phone number,theme,location,change password,logout
            SingleChildScrollView(
              child: Column(
                children: [
            isEnterEmail
                ? TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter New Email',
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.save),
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.setString('email', _emailController.text);
                          setState(() {
                            isEnterEmail = false;
                            navigatorKey.currentState!.pushNamed('/settings');
                            //also update the email in the database
                            updateData({
                              'email': _emailController.text,
                            }, 'users', auth.currentUser!.uid);
                          });
                        },
                      ),
                    ),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: isEnterEmail,
                  )
                : ListTile(
                    leading: const Icon(Icons.email),
                    title: FutureBuilder<Map<String, dynamic>>(
                      future: getUser(),
                      builder: (BuildContext context,
                          AsyncSnapshot<Map<String, dynamic>> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Text('Loading...');
                        }
                        return Text(
                          snapshot.data!['email']?? 'Add Email',
                        );
                      },
                    ),
                    trailing: GestureDetector(
                      onTap: () {
                        //navigate to change email page
                        setState(() {
                          isEnterEmail = true;
                        });
                      },
                      child:  Text(
                        'Change',
                      ),
                    ),
                  ),
            isEnterPhoneNumber
                ? TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter New Phone Number',
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.save),
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.setString(
                              'phoneNumber', _phoneNumberController.text);
                          setState(() {
                            isEnterPhoneNumber = false;
                            navigatorKey.currentState!.pushNamed('/settings');
      
                            //also update the phone number in the database
                            updateData({
                              'phoneNumber': _phoneNumberController.text,
                            }, 'users',auth.currentUser!.uid);
                            prefs.setString(
                                'phoneNumber', _phoneNumberController.text);
                          });
                        },
                      ),
                    ),
                    controller: _phoneNumberController,
                    keyboardType: TextInputType.phone,
                    enabled: isEnterPhoneNumber,
                  )
                : ListTile(
                    leading: const Icon(Icons.phone),
                    title: FutureBuilder<Map<String, dynamic>>(
                      future: getUser(),
                      builder: (BuildContext context,
                          AsyncSnapshot<Map<String, dynamic>> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Text('Loading...');
                        }
      
                        return Text(
                          snapshot.data!['phoneNumber']?? 'Add Phone Number',
                        );
                      },
                    ),
                    trailing: GestureDetector(
                      onTap: () {
                        //navigate to change phone number page
                        setState(() {
                          isEnterPhoneNumber = true;
                        });
                      },
                      child:  Text(
                        'Change',
                      ),
                    )),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('My Wishlist',),
              onTap: () {
                //navigate to my wishlist page
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const MyWishlist();
                }));
              },
              trailing: Icon(Icons.bookmark, ),
            ),
            //my uploads
            ListTile(
              leading: const Icon(Icons.cloud_upload_rounded),
              title: const Text('My Uploads',),
              onTap: () {
                //navigate to my uploads page
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const MyUploads();
                }));
              },
              trailing:  Icon(Icons.my_library_books, ),
            ),
      
            isDarkMode
                ? //show theme options
      
                ListTile(
                    leading: const Icon(Icons.palette),
                    title: const Text('Theme'),
                    trailing: //a sliding bar to change theme
                          Icon(
                        Icons.brightness_4_outlined,
                      ),
                      onTap: () {
                        final themeProvider =
                            Provider.of<ThemeProvider>(context, listen: false);
                        setState(() {
                          isDarkMode = !isDarkMode;
                        }); // change the variable
      
                        isDarkMode // call the functions
                            ? themeProvider.setDarkmode()
                            : themeProvider.setLightMode();
                      },
                    
                  )
                : ListTile(
                    leading: const Icon(Icons.palette),
                    title: const Text('Theme'),
                    trailing: //a sliding bar to change theme
                        Icon(
                        Icons.brightness_4_outlined,
                      ),
                    onTap: () {
                        final themeProvider =
                            Provider.of<ThemeProvider>(context, listen: false);
                        setState(() {
                          isDarkMode = !isDarkMode;
                        }); // change the variable
      
                        isDarkMode // call the functions
                            ? themeProvider.setDarkmode()
                            : themeProvider.setLightMode();
                      },
                  ),
            isEnterLocation
                ? TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter New Location',
                      labelText: 'Location',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.save),
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.setString('location', _locationController.text);
                          setState(() {
                            isEnterLocation = false;
                            navigatorKey.currentState!.pushNamed('/settings');
                            //also update the location in the database
                            updateData({
                              'location': _locationController.text,
                            }, 'users', auth.currentUser!.uid);
                          });
                        },
                      ),
                    ),
                    controller: _locationController,
                    keyboardType: TextInputType.streetAddress,
                    enabled: isEnterLocation,
                  )
                : ListTile(
                    leading: const Icon(Icons.location_on),
                    title: FutureBuilder<Map<String, dynamic>>(
                      future: getUser(),
                      builder: (BuildContext context,
                          AsyncSnapshot<Map<String, dynamic>> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Text('Loading...');
                        }
                        return Text(
                         snapshot.data!['location']?? 'Add Location',
                        );
                      },
                    ),
                    trailing: GestureDetector(
                      onTap: () {
                        //navigate to change location page
                        setState(() {
                          isEnterLocation = true;
                        });
                      },
                      child:  Text(
                        'Change',
                      ),
                    ),
                  ),
            isEnterPassword
                ? TextField(
                    decoration: const InputDecoration(
                      hintText: 'Enter New Password',
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.visiblePassword,
                    enabled: isEnterPassword,
                  )
                : ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text('Change Password'),
                    trailing: GestureDetector(
                      onTap: () {
                        //navigate to change password page
                        setState(() {
                          isEnterPassword = true;
                        });
                      },
                      child:  Text(
                        'Change',
                      ),
                    )),
      
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setBool('isLoggedIn', false);
                Navigator.pushNamed(context, '/login');
                //navigate to logout page
              },
            ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: bottomAppBar(),
      ),
    );
  }
}

class MyUploads extends StatelessWidget {
  const MyUploads({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Uploads'),
        centerTitle: true,
          backgroundColor: Colors.brown[400],

      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('books')
            .where('sellerId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: LinearProgressIndicator(
                backgroundColor: Colors.brown,
          
              ),
            );
          }
          return ListView(
            
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              return Material(
                elevation: 5,
                child: InkWell(
                  
                  child: Container(
                    margin: const EdgeInsets.only(top: 5.0),
                      height: 150,
                      padding: const EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Dismissible(
                        key: Key(document.id), // Unique key for Dismissible widget
                        direction: DismissDirection.startToEnd, // Swipe direction
                        onDismissed: (direction) {
                          // Delete the book from the database
                          deleteData('books', document.id);
                        },
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: 20.0),
                          color: Colors.red[400],
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: 80,
                                  width: 80,
                                  padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                  margin: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                  color: Colors.grey,
                                  child: Image.network(
                                    document['imageUrl'],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Container(
                                  width:150 ,
                                  child: SingleChildScrollView(
                                    child: Text(
                                      document['bookTitle'],
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  document['bookAuthor'],
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
                                  ),
                                ),
                                ]),
                  
                                //show slide to delete button
                                const Spacer(),
                                Text('Swipe to delete', style: TextStyle(color: Colors.red,
                                fontSize: 15, fontWeight: FontWeight.bold
                                ),),
                                Icon(Icons.arrow_forward_ios, color: Colors.red,),
                  
                                  
                                
                              ],
                            ),
                          ],
                        ),
                      )),
                      onTap:  () {
                        //navigate to book details page
                        navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) {
                          return Book(bid: document.id);
                        }));
                      },
                ),
              );
            }).toList(),
          );
        },
      ),
      bottomNavigationBar: bottomAppBar(),
    );
  }
}


class MyWishlist extends StatelessWidget {
  const MyWishlist({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
        centerTitle: true,
          backgroundColor: Colors.brown[400],

      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('wishlist')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: LinearProgressIndicator(
                backgroundColor: Colors.brown,
          
              ),
            );
          }
          if (snapshot.data!.docs.length == 0) {
            return const Center(
              child: Text('No books in wishlist'),
            );
          }
          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            print(snapshot.data!.docs[i].id);
          }
          
          return ListView.builder(
           itemCount: snapshot.data!.docs.length,
           itemBuilder:  (BuildContext context, int index) {
              return Material(
                elevation: 5,
                child: InkWell(
                  child: Container(
                    margin: const EdgeInsets.only(top: 5.0),
                      height: 150,
                      padding: const EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Dismissible(
                        key: Key(snapshot.data!.docs[index].id), // Unique key for Dismissible widget
                        direction: DismissDirection.startToEnd, // Swipe direction
                        onDismissed: (direction) {
                          // Delete the book from the wishlist
                          deleteData('users/${FirebaseAuth.instance.currentUser!.uid}/wishlist', snapshot.data!.docs[index].id);
                        },
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: 20.0),
                          color: Colors.red[400],
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                               
                                const SizedBox(
                                  width: 20,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Container(
                                  width:150 ,
                                  child: SingleChildScrollView(
                                    child: FutureBuilder<dynamic>(
                                      future: getBookDetails(snapshot.data!.docs[index].id),
                                      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const Text('Loading...');
                                        }
                                        return ListTile(
                                           
                                          title: Text(
                                            snapshot.data['bookTitle'],
                                            style: const TextStyle(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          subtitle: Text(
                                            snapshot.data['bookAuthor'],
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        );
                                        
                                      },
                                    ),
                                  ),
                                ),
                               
                                ]),
                  
                                //show slide to delete button
                                const Spacer(),
                                Text('Swipe to delete', style: TextStyle(color: Colors.red,),
                                ),
                                Icon(Icons.arrow_forward_ios, color: Colors.red,)
                              ],
                            ),
                          ],
                        ),
                      )),
                      onTap:  () {
                        //navigate to book details page
                        navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) {
                          return Book(bid: snapshot.data!.docs[index].id);
                        }));
                      },
                ),
              );

                                
            
        },
          );
        },
      ),
      bottomNavigationBar: bottomAppBar(),
    );
  }
}

