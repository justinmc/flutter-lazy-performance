import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'table_builder.dart';

class IVBuilderPage extends StatefulWidget {
  const IVBuilderPage({ Key key }) : super(key: key);

  static const String routeName = '/iv-builder';

  @override _IVBuilderPageState createState() => _IVBuilderPageState();
}

class _IVBuilderPageState extends State<IVBuilderPage> {
  final TransformationController _transformationController = TransformationController();

  static const double _minScale = 0.5;
  static const double _maxScale = 2.5;
  static const double _scaleRange = _maxScale - _minScale;
  static const double _cellWidth = 200.0;
  static const double _cellHeight = 26.0;

  bool _isCellVisible(int row, int column, Rect viewport) {
    if (viewport != _cachedViewport) {
      _calculateVisibleCells(viewport);
    }
    return row >= _firstVisibleRow && row <= _lastVisibleRow
        && column >= _firstVisibleColumn && column <= _lastVisibleColumn;
  }

  Rect _cachedViewport;
  int _firstVisibleColumn;
  int _firstVisibleRow;
  int _lastVisibleColumn;
  int _lastVisibleRow;
  void _calculateVisibleCells(Rect viewport) {
    _cachedViewport = viewport;
    _firstVisibleRow = (viewport.top / _cellHeight).floor();
    _firstVisibleColumn = (viewport.left / _cellWidth).floor();
    _lastVisibleRow = (viewport.bottom / _cellHeight).floor();
    _lastVisibleColumn = (viewport.right / _cellWidth).floor();
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
        title: const Text('MyIVBuilder'),
        actions: <Widget>[
        ],
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return InteractiveViewer.builder(
              alignPanAxis: false,
              constrained: false,
              transformationController: _transformationController,
              maxScale: _maxScale,
              minScale: _minScale,
              builder: (BuildContext context, Rect viewport) {
                final double scale = _transformationController.value.getMaxScaleOnAxis();
                final Color color = Colors.red.withOpacity((scale - _minScale) / _scaleRange);
                return TableBuilder(
                  rowCount: 60,
                  columnCount: 6,
                  cellWidth: _cellWidth,
                  builder: (BuildContext context, int row, int column) {
                    if (!_isCellVisible(row, column, viewport)) {
                      print('justin $row, $column invisible');
                      return Container(height: _cellHeight);
                    }
                    print('justin $row, $column visible');
                    return Container(
                      height: _cellHeight,
                      color: color,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('$row x $column'),
                      ),
                    );
                  }
                );
              },
            );
          },
        ),
      ),
    );
  }
}
