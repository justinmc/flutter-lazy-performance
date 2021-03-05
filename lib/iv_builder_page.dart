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
        child: InteractiveViewer(
          alignPanAxis: false,
          //boundaryMargin: EdgeInsets.all(double.infinity),
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
                  return Container(
                    height: 26,
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
          column: const FixedColumnWidth(200.0),
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
