import 'package:flutter/material.dart';
import 'package:kitaab/navigation_bar.dart';

class History extends StatelessWidget {
  const History({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxWidth > 600) {
              return Text('My Orders');
            } else {
              return Text('My Orders');
            }
          },
        ),
        centerTitle: true,
      
        
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
      bottomNavigationBar: BtmNavigationBar(),
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