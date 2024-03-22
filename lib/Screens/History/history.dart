import 'package:flutter/material.dart';
import 'package:kitaab/main.dart';
import 'package:kitaab/navigation_bar.dart';

class History extends StatelessWidget {
  const History({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // return to home page
        navigatorKey.currentState?.pushReplacementNamed('/home');
        return true;
      },
      child: Scaffold(
        appBar:AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              navigatorKey.currentState?.pushReplacementNamed('/home');
            },
          ),
          title: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              if (constraints.maxWidth > 600) {
                return const Text('History', style: TextStyle(fontSize: 30, color: Colors.black));
              } else {
                return const Text('History', style: TextStyle(fontSize: 20, color: Colors.black));
              }
            },
          ),
          centerTitle: true,
                    backgroundColor: Colors.brown[200],

        
          
        ),
        body: Container(
          child: Column(
            children: [
              Flexible(child: HistoryList()),
              SizedBox(
                height: 10.0,
              )
            ],
          ),
        ),
        bottomNavigationBar: bottomAppBar(),
      ),
    );
  }
}

class HistoryList extends StatelessWidget {
  const HistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          leading: Image.asset('assets/images/logo.png'),
          //mention title,date and price of the book
          title: Text('Book Title'),
          //date of purchase
          subtitle: Text('Dec 12, 2020'),
          //price of the book
          trailing: Text('Rs. 100'),
        );
      },
    );
  }
}