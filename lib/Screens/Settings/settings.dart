// import 'dart:html';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
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

  Future<Map<String, String>> getUser() async {
    //get user details from database
    prefs = await SharedPreferences.getInstance();
    name = prefs!.getString('name');
    email = prefs!.getString('email');
    return {
      'name': name!,
      'email': email!,
    };
  }

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxWidth > 600) {
              return const Text('Settings');
            } else {
              return const Text('Settings');
            }
          },
        ),
        centerTitle: true,
      ),
      body:
          //show profile details
          Column(
        children: [
          Container(
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
                      child: FutureBuilder<Map<String, String>>(
                        future: getUser(),
                        builder: (BuildContext context,
                            AsyncSnapshot<Map<String, String>> snapshot) {
                          //circularprogressindicator while loading
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          return CircleAvatar(
                            backgroundImage: NetworkImage(
                              prefs!.getString('profileImageUrl') ??
                                  'https://www.pngfind.com/pngs/m/610-6104451_image-placeholder-png-user-profile-placeholder-image-png.png',
                            ),
                          );
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
                          // Make the onPressed callback async
                          XFile? imageFile = await ImagePicker()
                              .pickImage(source: ImageSource.gallery);
                          if (imageFile != null) {
                            await uploadProfileImage(File(imageFile.path),
                                prefs!.getString('userId')!);
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
                        : FutureBuilder<Map<String, String>>(
                            future: getUser(),
                            builder: (BuildContext context,
                                AsyncSnapshot<Map<String, String>> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text('Loading...');
                              }
                              return Text(
                                snapshot.data!['name']!,
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
          //change email,change phone number,theme,location,change password,logout
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
                          }, 'users', prefs.getString('userId')!);
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
                  title: FutureBuilder<Map<String, String>>(
                    future: getUser(),
                    builder: (BuildContext context,
                        AsyncSnapshot<Map<String, String>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text('Loading...');
                      }
                      return Text(
                        snapshot.data!['email']!,
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
                    child: const Text(
                      'Change',
                      style: TextStyle(color: Colors.blue),
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
                          }, 'users', prefs.getString('userId')!);
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
                  title: FutureBuilder<Map<String, String>>(
                    future: getUser(),
                    builder: (BuildContext context,
                        AsyncSnapshot<Map<String, String>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text('Loading...');
                      }

                      return Text(
                        prefs!.getString('phoneNumber') ?? 'Add Phone Number',
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
                    child: const Text(
                      'Change',
                      style: TextStyle(color: Colors.blue),
                    ),
                  )),

          //my uploads
          ListTile(
            leading: const Icon(Icons.cloud_upload_rounded),
            title: const Text('My Uploads'),
            onTap: () {
              //navigate to my uploads page
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const MyUploads();
              }));
            },
            trailing: const Icon(Icons.my_library_books, color: Colors.blue),
          ),

          isDarkMode
              ? //show theme options

              ListTile(
                  leading: const Icon(Icons.palette),
                  title: const Text('Theme'),
                  trailing: //a sliding bar to change theme
                      IconButton(
                    onPressed: () {
                      final themeProvider =
                          Provider.of<ThemeProvider>(context, listen: false);
                      setState(() {
                        isDarkMode = !isDarkMode;
                      }); // change the variable

                      isDarkMode // call the functions
                          ? themeProvider.setDarkmode()
                          : themeProvider.setLightMode();
                    },
                    icon: const Icon(
                      Icons.brightness_4_outlined,
                      color: Colors.blue,
                    ),
                  ),
                )
              : ListTile(
                  leading: const Icon(Icons.palette),
                  title: const Text('Theme'),
                  trailing: //a sliding bar to change theme
                      IconButton(
                    onPressed: () {
                      final themeProvider =
                          Provider.of<ThemeProvider>(context, listen: false);
                      setState(() {
                        isDarkMode = !isDarkMode;
                      }); // change the variable

                      isDarkMode // call the functions
                          ? themeProvider.setDarkmode()
                          : themeProvider.setLightMode();
                    },
                    icon: const Icon(
                      Icons.brightness_4_outlined,
                      color: Colors.blue,
                    ),
                  ),
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
                          }, 'users', prefs.getString('userId')!);
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
                  title: FutureBuilder<Map<String, String>>(
                    future: getUser(),
                    builder: (BuildContext context,
                        AsyncSnapshot<Map<String, String>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text('Loading...');
                      }
                      return Text(
                        prefs!.getString('location') ?? 'Add Location',
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
                    child: const Text(
                      'Change',
                      style: TextStyle(color: Colors.blue),
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
                    child: const Text(
                      'Change',
                      style: TextStyle(color: Colors.blue),
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
      bottomNavigationBar: BtmNavigationBar(),
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
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('books')
            .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              return Container(
                  height: 100,
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
                    direction: DismissDirection.endToStart, // Swipe direction
                    onDismissed: (direction) {
                      // Delete the book from the database
                      deleteData('books', document.id);
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20.0),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 80,
                              width: 80,
                              padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
                              child: Image.network(
                                document['imageUrl'],
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                            Text(
                              document['bookTitle'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              document['bookAuthor'],
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            ]),

                            //show slide to delete button
                            const Spacer(),
                            Text('Swipe to delete', style: TextStyle(color: Colors.red),),
                            Icon(Icons.arrow_forward_ios, color: Colors.red,),

                              
                            
                          ],
                        ),
                      ],
                    ),
                  ));
            }).toList(),
          );
        },
      ),
      bottomNavigationBar: BtmNavigationBar(),
    );
  }
}
