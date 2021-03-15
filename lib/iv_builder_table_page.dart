import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'table_builder.dart';

class IVBuilderTablePage extends StatefulWidget {
  const IVBuilderTablePage({ Key key }) : super(key: key);

  static const String routeName = '/iv-builder-table';

  @override _IVBuilderTablePageState createState() => _IVBuilderTablePageState();
}

class _IVBuilderTablePageState extends State<IVBuilderTablePage> {
  final TransformationController _transformationController = TransformationController();

  static const double _cellWidth = 200.0;
  static const double _cellHeight = 26.0;

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
              //maxScale: _maxScale,
              //minScale: _minScale,
              builder: (BuildContext context, Rect viewport) {
                return TableBuilder(
                  rowCount: 60,
                  columnCount: 6,
                  cellWidth: _cellWidth,
                  builder: (BuildContext context, int row, int column) {
                    if (!_isCellVisible(row, column, viewport)) {
                      return Container(height: _cellHeight);
                    }
                    return Container(
                      height: _cellHeight,
                      color: row % 2 + column % 2 == 1 ? Colors.white : Colors.grey.withOpacity(0.1),
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


