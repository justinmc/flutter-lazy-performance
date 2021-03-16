import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'marty.dart';

class IVSlowPage extends StatefulWidget {
  const IVSlowPage({ Key key }) : super(key: key);

  static const String routeName = '/iv-slow';

  @override _IVSlowPageState createState() => _IVSlowPageState();
}

class _IVSlowPageState extends State<IVSlowPage> {
  final TransformationController _transformationController = TransformationController();

  static const double _cellWidth = 200.0;
  static const double _cellHeight = 200.0;
  static const int _rowCount = 10;
  static const int _columnCount = 10;

  void _onChangeTransformation() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onChangeTransformation);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onChangeTransformation);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Two Dimensions - Slow'),
        actions: <Widget>[
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          constrained: false,
          scaleEnabled: false,
          transformationController: _transformationController,
          child: Column(
            children: <Widget>[
              for (int row = 0; row < _rowCount; row++)
                Row(
                  children: <Widget>[
                    for (int column = 0; column < _columnCount; column++)
                      Container(
                        height: _cellHeight,
                        width: _cellWidth,
                        child: Marty(index: row * _columnCount + column),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

