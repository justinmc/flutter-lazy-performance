import 'dart:math' show pow, max;

import 'package:rive/rive.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'constants.dart';
import 'layer.dart';
import 'map_data.dart';
import 'marty.dart';

class ProceduralGenerationPage extends StatefulWidget {
  const ProceduralGenerationPage({ Key key }) : super(key: key);

  static const String routeName = '/procedural-generation';

  @override _ProceduralGenerationPageState createState() => _ProceduralGenerationPageState();
}

class _ProceduralGenerationPageState extends State<ProceduralGenerationPage> {
  final TransformationController _transformationController = TransformationController();

  static const double _minScale = 0.1;
  static const double _maxScale = 10.5;
  static const double _scaleRange = _maxScale - _minScale;

  /*
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
  */

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
        title: const Text('Procedural Generation'),
        actions: <Widget>[
        ],
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return InteractiveViewer.builder(
              transformationController: _transformationController,
              maxScale: _maxScale,
              minScale: _minScale,
              boundaryMargin: EdgeInsets.all(double.infinity),
              builder: (BuildContext context, Rect viewport) {
                final int columns = (viewport.width / cellSize.width).ceil();
                final int rows = (viewport.height / cellSize.height).ceil();

                // TODO lots of these calculations are not used right now.
                LayerType layer;
                if (columns > 1000 || rows > 1000) {
                  layer = LayerType.galactic;
                } else if (columns > 100 || rows > 100) {
                  layer = LayerType.solar;
                } else if (columns > 10 || rows > 10) {
                  layer = LayerType.terrestrial;
                } else {
                  layer = LayerType.local;
                }

                return _MapGrid(
                  //columns: (viewport.width / cellSize.width).ceil(),
                  //rows: (viewport.height / cellSize.height).ceil(),
                  columns: columns,
                  rows: rows,
                  firstColumn: (viewport.left / cellSize.width).floor(),
                  firstRow: (viewport.top / cellSize.height).floor(),
                  layer: layer,
                  viewport: viewport,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _MapGrid extends StatelessWidget {
  _MapGrid({
    Key key,
    this.columns,
    this.rows,
    this.firstColumn,
    this.firstRow,
    this.layer,
    this.viewport,
  }) : super(key: key);

  // TODO(justinmc): UI for choosing a seed.
  final MapData _mapData = MapData(seed: 80);
  final Rect viewport;

  final int columns;
  final int rows;
  final int firstColumn;
  final int firstRow;
  final LayerType layer;

  Rect _cachedViewport;
  int _firstVisibleColumn;
  int _firstVisibleRow;
  int _lastVisibleColumn;
  int _lastVisibleRow;
  bool _isCellVisible(int row, int column, final LayerType layerType) {
    // TODO Deduplicate with other _isCellVisible.
    // TODO(justinmc): Make sure this works when tileData.location.layerType is local.
    if (viewport != _cachedViewport) {
      _cachedViewport = viewport;
      int layerExponent = 0;
      LayerType currentLayerType = layers[layerType].child;
      while (currentLayerType != null) {
        layerExponent++;
        currentLayerType = layers[currentLayerType].child;
      }
      final int layerScale = pow(10, layerExponent);
      _firstVisibleRow = (viewport.top / (cellSize.height * layerScale)).floor();
      _firstVisibleColumn = (viewport.left / (cellSize.width * layerScale)).floor();
      _lastVisibleRow = (viewport.bottom / (cellSize.height * layerScale)).floor();
      _lastVisibleColumn = (viewport.right / (cellSize.width * layerScale)).floor();
    }

    /*
    final bool visible = row >= _firstVisibleRow && row <= _lastVisibleRow
        && column >= _firstVisibleColumn && column <= _lastVisibleColumn;
    print('justin is $row, $column visible? $visible b/c firsts $_firstVisibleRow - $_lastVisibleRow, $_firstVisibleColumn - $_lastVisibleColumn for $viewport');
    */
    return row >= _firstVisibleRow && row <= _lastVisibleRow
        && column >= _firstVisibleColumn && column <= _lastVisibleColumn;
  }

  @override
  Widget build(BuildContext context) {
    LayerType parentLayerType;
    if (max(viewport.width, viewport.height) < 100) {
      parentLayerType = LayerType.local;
    } else if (max(viewport.width, viewport.height) < 1000) {
      parentLayerType = LayerType.terrestrial;
    } else if (max(viewport.width, viewport.height) < 10000) {
      parentLayerType = LayerType.solar;
    } else {
      parentLayerType = LayerType.galactic;
    }
    //final TileData center = _mapData.getLowestTileDataAtScreenOffset(viewport.center).parent;
    TileData center = _mapData.getLowestTileDataAtScreenOffset(viewport.center);
    while (center.location.layerType != parentLayerType) {
      assert(center.location.layerType != null);
      center = center.parent;
    }

    final Size size = Size(
      cellSize.width * pow(Layer.layerScale, layers[parentLayerType].level),
      cellSize.height * pow(Layer.layerScale, layers[parentLayerType].level),
    );

    //print('justin I think the big tiles should be at layer $parentLayerType and center is ${center.location} at ${viewport.center}, size $size');

    // TODO Can I use keys to avoid rebuilding _ParentMapTiles here?
    return Container(
      width: size.width * 3,
      height: size.height * 3,
      clipBehavior: Clip.none,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned(
            top: center.location.row * size.width - size.width,
            left: center.location.column * size.height - size.height,
            child: Column(
              children: <Widget>[
                for (int row = center.location.row - 1; row <= center.location.row + 1; row++)
                  Row(
                    children: <Widget>[
                      for (int column = center.location.column - 1; column <= center.location.column + 1; column++)
                        // TODO(justinmc): Dynamically get layer type.
                        _isCellVisible(row, column, parentLayerType)
                          ? _ParentMapTile(
                            viewport: viewport,
                            tileData: _mapData.getTileDataAt(Location(
                              row: row,
                              column: column,
                              layerType: parentLayerType,
                            )),
                          )
                          : Container(
                              width: size.width,
                              height: size.height,
                              color: Colors.green.withOpacity(0.3),
                              /*
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black)
                              ),
                              */
                            ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Render all of the children tiles of the given parent tile.
class _ParentMapTile extends StatelessWidget {
  _ParentMapTile({
    Key key,
    // Render all the children tiles of this given tile.
    @required this.tileData,
    @required this.viewport
  }) : assert(tileData != null),
       assert(viewport != null),
       super(key: key);

  final TileData tileData;
  final Rect viewport;

  // TODO These variables aren't ok in a stateless widget.
  // The visibility of child tiles.
  int _firstRow;
  int _firstColumn;
  int _firstVisibleColumn;
  int _firstVisibleRow;
  int _lastVisibleColumn;
  int _lastVisibleRow;
  void _calculateVisibility() {
    // Only calculate this once. Also, not needed at all for local.
    if (_firstVisibleRow != null || tileData.location.layerType == LayerType.local) {
      return;
    }

    final int layerExponent = layers[tileData.location.layerType].level;
    /*
    int layerExponent = 0;
    LayerType currentLayerType = layers[tileData.location.layerType].child;
    while (currentLayerType != null) {
      layerExponent++;
      currentLayerType = layers[currentLayerType].child;
    }
    print('justin layerExponent $layerExponent vs $quickLayerExponent');
    */
    final int layerScale = pow(10, layerExponent);
    final int childLayerScale = pow(10, layerExponent - 1);
    _firstRow = tileData.location.row * layerScale;
    _firstColumn = tileData.location.column * layerScale;
    _firstVisibleRow = (viewport.top / (cellSize.height * childLayerScale)).floor();
    _firstVisibleColumn = (viewport.left / (cellSize.width * childLayerScale)).floor();
    _lastVisibleRow = (viewport.bottom / (cellSize.height * childLayerScale)).floor();
    _lastVisibleColumn = (viewport.right / (cellSize.width * childLayerScale)).floor();
  }

  bool _isCellVisible(int row, int column) {
    //print('justin is $row, $column visible in $viewport for tiledata ${tileData.location}? ${row >= _firstVisibleRow && row <= _lastVisibleRow && column >= _firstVisibleColumn && column <= _lastVisibleColumn} for $_firstVisibleRow - $_lastVisibleRow, $_firstVisibleColumn - $_lastVisibleColumn, firstRow,col $_firstRow, $_firstColumn');
    //return row >= _firstVisibleRow && row <= _lastVisibleRow
    //    && column >= _firstVisibleColumn && column <= _lastVisibleColumn;
    final bool visible = row >= _firstVisibleRow && row <= _lastVisibleRow
        && column >= _firstVisibleColumn && column <= _lastVisibleColumn;
    //print('justin $row, $column is visible? $visible');
    return visible;
  }

  @override
  Widget build(BuildContext context) {
    _calculateVisibility();

    // Local tiles have no children. Just render one big _MapTile.
    if (tileData.location.layerType == LayerType.local) {
      return _MapTile(tileData: tileData);
    }

    return Column(
      children: <Widget>[
        for (int row = _firstRow; row < _firstRow + Layer.layerScale; row++)
          Row(
            children: <Widget>[
              for (int column = _firstColumn; column < _firstColumn + Layer.layerScale; column++)
                _isCellVisible(row, column)
                  ? _MapTile(tileData: TileData.getByRowColumn(tileData.children, row % Layer.layerScale, column % Layer.layerScale))
                  : SizedBox(width: cellSize.width, height: cellSize.height),
            ],
          ),
      ],
    );
  }
}


class _MapTile extends StatelessWidget {
  _MapTile({
    Key key,
    @required this.tileData,
  }) : super(key: key);

  final TileData tileData;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (tileData.terrain.layer == LayerType.terrestrial && tileData.terrain.terrainType == TerrainType.grassland) {
      child = _Grassland(
        tileData: tileData,
      );
    } else {
      // TODO(justinmc): Different visuals for different terrains.
      //child = SizedBox.shrink();
      child = _Grassland(
        tileData: tileData,
      );
    }
      /*
    } else {
      throw new FlutterError('Invalid tile type');
    }
    */

    return Container(
      width: cellSize.width,
      height: cellSize.height,
      /*
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black)
      ),
      */
      child: child,
    );
  }
}

class _Grassland extends StatelessWidget {
  const _Grassland({
    this.tileData,
  });

  final TileData tileData;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xffa0ffa0),
      child: Stack(
        children: <Widget>[
          // TODO(justinmc): This is for debug, remove.
          Positioned(
            top: 0,
            left: 0,
            child: Text('${tileData.location.row}, ${tileData.location.column}'),
          ),
          // TODO bring back grass!
          for (Location location in tileData.aLocations)
            Positioned(
              left: location.column * cellSize.width / Layer.layerScale,
              top: location.row * cellSize.height / Layer.layerScale,
              // TODO(justinmc): Make this _Grassland widget a generic widget, and
              // choose child here based on type.
              child: _Grass(),
            ),
          // TODO(justinmc): Something besides grass
          for (Location location in tileData.bLocations)
            Positioned(
                /*
              left: location.column * cellSize.width / Layer.layerScale,
              top: location.row * cellSize.height / Layer.layerScale,
              */
              left: 25,
              top: 25,
              // TODO(justinmc): Make this _Grassland widget a generic widget, and
              // choose child here based on type.
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: Marty(index: 0, isBackgroundTransparent: true),
              ),
            ),
        ],
      ),
    );
  }
}

class _Grass extends StatefulWidget {
  const _Grass({
    Key key,
  }) : super(key: key);

  @override _GrassState createState() => _GrassState();
}

class _GrassState extends State<_Grass> {
  Artboard _riveArtboard;
  RiveAnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Load the animation file from the bundle, note that you could also
    // download this. The RiveFile just expects a list of bytes.
    rootBundle.load('assets/grass.riv').then(
      (data) async {
        final file = RiveFile();

        // Load the RiveFile from the binary data.
        if (file.import(data)) {
          // The artboard is the root of the animation and gets drawn in the
          // Rive widget.
          final artboard = file.mainArtboard;
          // Add a controller to play back a known animation on the main/default
          // artboard.We store a reference to it so we can toggle playback.
          _controller = SimpleAnimation('sway');
          artboard.addController(_controller);
          setState(() {
            _riveArtboard = artboard;
            _controller.isActive = true;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _riveArtboard == null
      ? const SizedBox()
      : SizedBox(
          width: 20.0,
          height: 20.0,
          child: Rive(artboard: _riveArtboard),
        );
  }
}
