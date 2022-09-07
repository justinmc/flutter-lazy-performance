import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef _CellBuilder = Widget Function(
    BuildContext context, int row, int column);

class TableBuilder extends StatelessWidget {
  const TableBuilder({
    required this.rowCount,
    required this.columnCount,
    required this.cellWidth,
    this.builder,
  })  : assert(rowCount > 0),
        assert(columnCount > 0);

  final int rowCount;
  final int columnCount;
  final double cellWidth;
  final _CellBuilder? builder;

  @override
  Widget build(BuildContext context) {
    return Table(
      // ignore: prefer_const_literals_to_create_immutables
      columnWidths: <int, TableColumnWidth>{
        for (int column = 0; column < columnCount; column++)
          column: FixedColumnWidth(cellWidth),
      },
      // ignore: prefer_const_literals_to_create_immutables
      children: <TableRow>[
        for (int row = 0; row < rowCount; row++)
          // ignore: prefer_const_constructors
          TableRow(
            // ignore: prefer_const_literals_to_create_immutables
            children: <Widget>[
              for (int column = 0; column < columnCount; column++)
                builder!(context, row, column),
            ],
          ),
      ],
    );
  }
}
