import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Quad;

import 'helpers.dart';
import 'marty.dart';

class IVBuilderPage extends StatefulWidget {
  const IVBuilderPage({Key? key}) : super(key: key);

  static const String routeName = '/iv-builder';

  @override
  _IVBuilderPageState createState() => _IVBuilderPageState();
}

class _IVBuilderPageState extends State<IVBuilderPage> {
  final TransformationController _transformationController =
      TransformationController();

  static const double _cellWidth = 200.0;
  static const double _cellHeight = 200.0;
  static const int _rowCount = 10;
  static const int _columnCount = 10;

  // Returns true iff the given cell is currently visible. Caches viewport
  // calculations.
  Quad? _cachedViewport;
  late int _firstVisibleColumn;
  late int _firstVisibleRow;
  late int _lastVisibleColumn;
  late int _lastVisibleRow;
  bool _isCellVisible(int row, int column, Quad viewport) {
    if (viewport != _cachedViewport) {
      final Rect aabb = axisAlignedBoundingBox(viewport);
      _cachedViewport = viewport;
      _firstVisibleRow = (aabb.top / _cellHeight).floor();
      _firstVisibleColumn = (aabb.left / _cellWidth).floor();
      _lastVisibleRow = (aabb.bottom / _cellHeight).floor();
      _lastVisibleColumn = (aabb.right / _cellWidth).floor();
    }
    return row >= _firstVisibleRow &&
        row <= _lastVisibleRow &&
        column >= _firstVisibleColumn &&
        column <= _lastVisibleColumn;
  }

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
        title: const Text('Two Dimensions'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add_alert),
            tooltip: 'Show Snackbar',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('This is a snackbar')));
            },
          ),
        ],
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return InteractiveViewer.builder(
              scaleEnabled: false,
              transformationController: _transformationController,
              builder: (BuildContext context, Quad viewport) {
                return Column(
                  children: <Widget>[
                    for (int row = 0; row < _rowCount; row++)
                      Row(
                        children: <Widget>[
                          for (int column = 0; column < _columnCount; column++)
                            _isCellVisible(row, column, viewport)
                                ? Container(
                                    height: _cellHeight,
                                    width: _cellWidth,
                                    child: Marty(
                                        index: row * _columnCount + column),
                                  )
                                : Container(
                                    width: _cellWidth, height: _cellHeight),
                        ],
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
