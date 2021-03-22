import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'marty.dart';

class SingleChildScrollViewPage extends StatefulWidget {
  const SingleChildScrollViewPage({ Key key }) : super(key: key);

  static const String routeName = '/single-child-scroll-view';

  @override _SingleChildScrollViewPageState createState() => _SingleChildScrollViewPageState();
}

class _SingleChildScrollViewPageState extends State<SingleChildScrollViewPage> {
  static const _itemCount = 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SingleChildScrollView'),
        actions: <Widget>[
        ],
      ),
      body: Center(
        child: Container(
          width: 400.0,
          height: 400.0,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                for (int i = 0; i < _itemCount; i++)
                  Container(
                    height: 200,
                    color: Colors.teal.withOpacity(i / _itemCount),
                    child: Marty(
                      index: i,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
