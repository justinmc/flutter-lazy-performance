import 'package:vector_math/vector_math_64.dart' show Vector3;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'table_builder.dart';

// This page shows how to achieve a similar effect as InteractiveViewer.builder
// but before builder was implemented in the framework.
class IVBuilderlessPage extends StatefulWidget {
  const IVBuilderlessPage({Key? key}) : super(key: key);

  static const String routeName = '/iv-builder';

  @override
  _IVBuilderlessPageState createState() => _IVBuilderlessPageState();
}

class _IVBuilderlessPageState extends State<IVBuilderlessPage> {
  final TransformationController _transformationController =
      TransformationController();

  static const double _cellWidth = 200.0;
  static const double _cellHeight = 26.0;

  late Rect _cachedViewport;
  late int _firstVisibleColumn;
  late int _firstVisibleRow;
  late int _lastVisibleColumn;
  late int _lastVisibleRow;

  bool _isCellVisible(int row, int column, Rect viewport) {
    if (viewport != _cachedViewport) {
      _calculateVisibleCells(viewport);
    }
    return row >= _firstVisibleRow &&
        row <= _lastVisibleRow &&
        column >= _firstVisibleColumn &&
        column <= _lastVisibleColumn;
  }

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
        title: const Text('MyIVBuilderless'),
        actions: <Widget>[],
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final Vector3 translation =
                _transformationController.value.getTranslation() * -1;
            // This does not handle scale. You'd need access to
            // _transformViewport in the framework, or you'd have to do that
            // calculation yourself.
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
              scaleEnabled: false,
              child: Builder(
                builder: (BuildContext context) {
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
                          //color: row % 2 + column % 2 == 1 ? Colors.white : Colors.grey.withOpacity(0.1),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('$row x $column'),
                          ),
                        );
                      });
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
