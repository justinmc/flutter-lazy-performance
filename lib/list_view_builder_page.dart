import 'package:flutter/material.dart';

import 'marty.dart';

class ListViewBuilderPage extends StatefulWidget {
  const ListViewBuilderPage({Key? key}) : super(key: key);

  static const String routeName = '/list-view-builder';

  @override
  _ListViewBuilderPageState createState() => _ListViewBuilderPageState();
}

class _ListViewBuilderPageState extends State<ListViewBuilderPage> {
  static const _itemCount = 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ListView.builder'),
        actions: <Widget>[],
      ),
      body: Center(
        child: Container(
          width: 400.0,
          height: 400.0,
          child: ListView.builder(
            itemCount: _itemCount,
            itemBuilder: (BuildContext context, int index) {
              // print('building item #$index');
              return Container(
                height: 200,
                color: Colors.teal.withOpacity(index / _itemCount),
                child: Marty(
                  index: index,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
