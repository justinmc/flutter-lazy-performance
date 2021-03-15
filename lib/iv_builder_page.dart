import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'marty.dart';

class IVBuilderPage extends StatefulWidget {
  const IVBuilderPage({ Key key }) : super(key: key);

  static const String routeName = '/iv-builder';

  @override _IVBuilderPageState createState() => _IVBuilderPageState();
}

class _IVBuilderPageState extends State<IVBuilderPage> {
  final TransformationController _transformationController = TransformationController();

  static const double _cellWidth = 200.0;
  static const double _cellHeight = 200.0;
  static const int _rowCount = 60;
  static const int _columnCount = 10;

  // Returns true iff the given cell is currently visible. Caches viewport
  // calculations.
  Rect _cachedViewport;
  int _firstVisibleColumn;
  int _firstVisibleRow;
  int _lastVisibleColumn;
  int _lastVisibleRow;
  bool _isCellVisible(int row, int column, Rect viewport) {
    if (viewport != _cachedViewport) {
      _cachedViewport = viewport;
      _firstVisibleRow = (viewport.top / _cellHeight).floor();
      _firstVisibleColumn = (viewport.left / _cellWidth).floor();
      _lastVisibleRow = (viewport.bottom / _cellHeight).floor();
      _lastVisibleColumn = (viewport.right / _cellWidth).floor();
    }
    return row >= _firstVisibleRow && row <= _lastVisibleRow
        && column >= _firstVisibleColumn && column <= _lastVisibleColumn;
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
        ],
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return InteractiveViewer.builder(
              alignPanAxis: true,
              scaleEnabled: false,
              transformationController: _transformationController,
              builder: (BuildContext context, Rect viewport) {
                return Column(
                  children: <Widget>[
                    for (int row = 0; row < _rowCount; row++)
                      Row(
                        children: <Widget>[
                          for (int column = 0; column < _columnCount; column++)
                            _isCellVisible(row, column, viewport)
                              ? Container(
                                height: _cellHeight,
                                child: Marty(index: row * _columnCount + column),
                              )
                              : Container(height: _cellHeight),
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
