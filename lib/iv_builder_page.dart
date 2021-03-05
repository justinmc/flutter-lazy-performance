import 'package:vector_math/vector_math_64.dart' show Vector3, Vector4;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
            final Vector3 translation = _transformationController.value.getTranslation() * -1;
            // TODO(justinmc): This should actually use _transformViewport in IV.
            final Rect viewport = Rect.fromLTWH(
              translation.x,
              translation.y,
              constraints.maxWidth,
              constraints.maxHeight,
            );
            return InteractiveViewer(
              alignPanAxis: false,
              constrained: false,
              transformationController: _transformationController,
              maxScale: _maxScale,
              minScale: _minScale,
              child: Builder(
                builder: (BuildContext context) {
                  final double scale = _transformationController.value.getMaxScaleOnAxis();
                  final Color color = Colors.red.withOpacity((scale - _minScale) / _scaleRange);
                  //return Container(width: 200, height: 200, color: color);
                  return _TableBuilder(
                    rowCount: 60,
                    columnCount: 6,
                    builder: (BuildContext context, int row, int column) {
                      if (!_isCellVisible(row, column, viewport)) {
                        return Container(height: _cellHeight);
                      }
                      return Container(
                        height: _cellHeight,
                        //color: row % 2 + column % 2 == 1 ? Colors.white : Colors.grey.withOpacity(0.1),
                        color: color,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('$row x $column'),
                        ),
                      );
                    }
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

typedef _CellBuilder = Widget Function(BuildContext context, int row, int column);

class _TableBuilder extends StatelessWidget {
  const _TableBuilder({
    this.rowCount,
    this.columnCount,
    this.builder,
  }) : assert(rowCount != null && rowCount > 0),
       assert(columnCount != null && columnCount > 0);

  final int rowCount;
  final int columnCount;
  final _CellBuilder builder;

  @override
  Widget build(BuildContext context) {
    return Table(
      // ignore: prefer_const_literals_to_create_immutables
      columnWidths: <int, TableColumnWidth>{
        for (int column = 0; column < columnCount; column++)
          column: const FixedColumnWidth(_IVBuilderPageState._cellWidth),
      },
      // ignore: prefer_const_literals_to_create_immutables
      children: <TableRow>[
        for (int row = 0; row < rowCount; row++)
          // ignore: prefer_const_constructors
          TableRow(
            // ignore: prefer_const_literals_to_create_immutables
            children: <Widget>[
              for (int column = 0; column < columnCount; column++)
                builder(context, row, column),
            ],
          ),
      ],
    );
  }
}
