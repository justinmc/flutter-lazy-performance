import 'dart:math' show pow, max;

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Quad;

import 'cloud.dart';
import 'constants.dart';
import 'fire.dart';
import 'grass.dart';
import 'helpers.dart';
import 'layer.dart';
import 'map_data.dart';
import 'marty.dart';
import 'planet.dart';
import 'star.dart';
import 'star_close.dart';
import 'ufo.dart';
import 'wave.dart';

class ProceduralGenerationPage extends StatefulWidget {
  const ProceduralGenerationPage({Key key}) : super(key: key);

  static const String routeName = '/procedural-generation';

  @override
  _ProceduralGenerationPageState createState() =>
      _ProceduralGenerationPageState();
}

class _ProceduralGenerationPageState extends State<ProceduralGenerationPage> {
  final TransformationController _transformationController =
      TransformationController();

  static const double _minScale = 0.006;
  static const double _maxScale = 10.5;

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
        actions: <Widget>[],
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return InteractiveViewer.builder(
              transformationController: _transformationController,
              maxScale: _maxScale,
              minScale: _minScale,
              boundaryMargin: EdgeInsets.all(double.infinity),
              builder: (BuildContext context, Quad viewport) {
                return _MapGrid(
                  viewport: axisAlignedBoundingBox(viewport),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _MapGrid extends StatefulWidget {
  _MapGrid({
    Key key,
    this.viewport,
  }) : super(key: key);

  final Rect viewport;

  @override
  _MapGridState createState() => _MapGridState();
}

class _MapGridState extends State<_MapGrid> {
  final MapData _mapData = MapData(seed: 80);
  Set<TileData> _visibleTileDatas = Set<TileData>();

  Rect _cachedViewport;
  int _firstVisibleColumn;
  int _firstVisibleRow;
  int _lastVisibleColumn;
  int _lastVisibleRow;
  bool _isCellVisible(int row, int column, final LayerType layerType) {
    if (widget.viewport != _cachedViewport) {
      _cachedViewport = widget.viewport;
      int layerExponent = 0;
      LayerType currentLayerType = layers[layerType].child;
      while (currentLayerType != null) {
        layerExponent++;
        currentLayerType = layers[currentLayerType].child;
      }
      final int layerScale = pow(10, layerExponent);
      _firstVisibleRow =
          (widget.viewport.top / (cellSize.height * layerScale)).floor();
      _firstVisibleColumn =
          (widget.viewport.left / (cellSize.width * layerScale)).floor();
      _lastVisibleRow =
          (widget.viewport.bottom / (cellSize.height * layerScale)).floor();
      _lastVisibleColumn =
          (widget.viewport.right / (cellSize.width * layerScale)).floor();
    }

    return row >= _firstVisibleRow &&
        row <= _lastVisibleRow &&
        column >= _firstVisibleColumn &&
        column <= _lastVisibleColumn;
  }

  void _updateVisibleTileDatas(LayerType parentLayerType, TileData center) {
    Set<TileData> nextVisibleTileDatas = Set<TileData>();
    for (int row = center.location.row - 1;
        row <= center.location.row + 1;
        row++) {
      for (int column = center.location.column - 1;
          column <= center.location.column + 1;
          column++) {
        final TileData tileData = _mapData.getTileDataAt(Location(
          row: row,
          column: column,
          layerType: parentLayerType,
        ));
        if (_visibleTileDatas.contains(tileData)) {
          nextVisibleTileDatas.add(_visibleTileDatas.lookup(tileData));
        } else {
          nextVisibleTileDatas.add(tileData);
        }
      }
    }
    _visibleTileDatas = nextVisibleTileDatas;
  }

  @override
  Widget build(BuildContext context) {
    //LayerType parentLayerType = _visibleTileDatas.first.location.layerType;
    LayerType parentLayerType;
    if (max(widget.viewport.width, widget.viewport.height) < 100) {
      parentLayerType = LayerType.local;
    } else if (max(widget.viewport.width, widget.viewport.height) < 1000) {
      parentLayerType = LayerType.terrestrial;
    } else if (max(widget.viewport.width, widget.viewport.height) < 10000) {
      parentLayerType = LayerType.solar;
    } else {
      parentLayerType = LayerType.galactic;
    }

    TileData center =
        _mapData.getLowestTileDataAtScreenOffset(widget.viewport.center);
    while (center.location.layerType != parentLayerType) {
      assert(center.location.layerType != null);
      center = center.parent;
    }
    _updateVisibleTileDatas(parentLayerType, center);

    final Size size = layers[parentLayerType].size;

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
                for (int row = center.location.row - 1;
                    row <= center.location.row + 1;
                    row++)
                  Row(
                    children: <Widget>[
                      for (int column = center.location.column - 1;
                          column <= center.location.column + 1;
                          column++)
                        _isCellVisible(row, column, parentLayerType)
                            ? _ParentMapTile(
                                viewport: widget.viewport,
                                tileData: _visibleTileDatas
                                    .lookup(_mapData.getTileDataAt(Location(
                                  row: row,
                                  column: column,
                                  layerType: parentLayerType,
                                ))),
                              )
                            : Container(
                                width: size.width,
                                height: size.height,
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
  _ParentMapTile(
      {Key key,
      // Render all the children tiles of this given tile.
      @required this.tileData,
      @required this.viewport})
      : assert(tileData != null),
        assert(viewport != null),
        super(key: key ?? GlobalObjectKey(tileData));

  final TileData tileData;
  final Rect viewport;

  // The visibility of child tiles.
  int _firstRow;
  int _firstColumn;
  int _firstVisibleColumn;
  int _firstVisibleRow;
  int _lastVisibleColumn;
  int _lastVisibleRow;
  void _calculateVisibility() {
    // Only calculate this once. Also, not needed at all for local.
    if (_firstVisibleRow != null ||
        tileData.location.layerType == LayerType.local) {
      return;
    }

    final int layerExponent = layers[tileData.location.layerType].level;
    final int childLayerScale = pow(10, layerExponent - 1);
    _firstRow = tileData.location.row * Layer.layerScale;
    _firstColumn = tileData.location.column * Layer.layerScale;
    _firstVisibleRow =
        (viewport.top / (cellSize.height * childLayerScale)).floor();
    _firstVisibleColumn =
        (viewport.left / (cellSize.width * childLayerScale)).floor();
    _lastVisibleRow =
        (viewport.bottom / (cellSize.height * childLayerScale)).floor();
    _lastVisibleColumn =
        (viewport.right / (cellSize.width * childLayerScale)).floor();
  }

  bool _isCellVisible(int row, int column) {
    final bool visible = row >= _firstVisibleRow &&
        row <= _lastVisibleRow &&
        column >= _firstVisibleColumn &&
        column <= _lastVisibleColumn;
    return visible;
  }

  @override
  Widget build(BuildContext context) {
    _calculateVisibility();

    // Local tiles have no children. Just render one big _MapTile.
    if (tileData.location.layerType == LayerType.local) {
      return _MapTile(tileData: tileData);
    }

    final Layer parentLayer = layers[tileData.location.layerType];
    final Size size = layers[parentLayer.child].size;

    return Column(
      children: <Widget>[
        for (int row = _firstRow; row < _firstRow + Layer.layerScale; row++)
          Row(
            children: <Widget>[
              for (int column = _firstColumn;
                  column < _firstColumn + Layer.layerScale;
                  column++)
                _isCellVisible(row, column)
                    ? _MapTile(
                        tileData: TileData.getByRowColumn(tileData.children,
                            row % Layer.layerScale, column % Layer.layerScale))
                    : SizedBox(width: size.width, height: size.height),
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

  Color get color {
    switch (tileData.terrain.terrainType) {
      case TerrainType.grassland:
        return Color(0xffa0ffa0);
      case TerrainType.continent:
        return Colors.lightGreenAccent;
      case TerrainType.planet:
      case TerrainType.solarSpace:
      case TerrainType.galacticSpace:
      case TerrainType.localSpace:
      case TerrainType.terrestrialSpace:
      case TerrainType.star:
        return Colors.black;
      case TerrainType.solarSystem:
      case TerrainType.terrestrialStar:
      case TerrainType.localStar:
        return Colors.yellow;
      case TerrainType.water:
      case TerrainType.ocean:
        return Colors.blue;
    }
  }

  // TODO(justinmc): These a and b location tile widgets should be cached so
  // that they aren't rebuilt on every pan/zoom.
  Widget get _aLocation {
    switch (tileData.terrain.terrainType) {
      case TerrainType.grassland:
        return Grass();
      case TerrainType.continent:
      case TerrainType.ocean:
        return Cloud();
      case TerrainType.water:
        return SizedBox(
          width: 20.0,
          height: 20.0,
          child: Wave(),
        );
      case TerrainType.galacticSpace:
      case TerrainType.solarSpace:
      case TerrainType.terrestrialSpace:
      case TerrainType.localSpace:
      case TerrainType.solarSystem:
        return SizedBox(
          width: 20.0,
          height: 20.0,
          child: Star(),
        );
      case TerrainType.terrestrialStar:
      case TerrainType.localStar:
        return SizedBox(
          width: 20.0,
          height: 20.0,
          child: Fire(),
        );
      case TerrainType.planet:
      case TerrainType.star:
        return null;
    }
  }

  Widget get _bLocation {
    switch (tileData.terrain.terrainType) {
      case TerrainType.grassland:
        return Marty(index: 0, isBackgroundTransparent: true);
      case TerrainType.localSpace:
        return SizedBox(
          width: 20.0,
          height: 20.0,
          child: UFO(),
        );
      case TerrainType.continent:
      case TerrainType.planet:
      case TerrainType.solarSpace:
      case TerrainType.galacticSpace:
      case TerrainType.terrestrialSpace:
      case TerrainType.star:
      case TerrainType.solarSystem:
      case TerrainType.localStar:
      case TerrainType.terrestrialStar:
      case TerrainType.ocean:
      case TerrainType.water:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int layerExponent = layers[tileData.location.layerType].level;
    final int layerScale = pow(10, layerExponent);
    return Container(
      width: tileData.size.width,
      height: tileData.size.height,
      /*
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black)
      ),
      */
      color: color,
      child: Stack(
        children: <Widget>[
          if (tileData.terrain.terrainType == TerrainType.star)
            Positioned(
              top: 0,
              left: 0,
              child: SizedBox(
                width: tileData.size.width,
                height: tileData.size.height,
                child: StarClose(),
              ),
            ),
          if (tileData.terrain.terrainType == TerrainType.planet)
            Positioned(
              top: 20.0 * layerScale,
              left: 20.0 * layerScale,
              child: SizedBox(
                width: tileData.size.width - 40.0 * layerScale,
                height: tileData.size.height - 40.0 * layerScale,
                child: Planet(),
              ),
            ),
          Positioned(
            top: 0,
            left: 0,
            child: Text(
              '${tileData.terrain.terrainType.toString().substring(12)}\n${tileData.location.row}, ${tileData.location.column}',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 10.0 * layerScale,
              ),
            ),
          ),
          for (Location location in tileData.aLocations)
            if (location != null)
              Positioned(
                left: location.column *
                    cellSize.width /
                    Layer.layerScale *
                    layerScale,
                top: location.row *
                    cellSize.height /
                    Layer.layerScale *
                    layerScale,
                child: SizedBox(
                  width: 20.0 * layerScale,
                  height: 20.0 * layerScale,
                  child: _aLocation,
                ),
              ),
          for (Location location in tileData.bLocations)
            if (location != null)
              Positioned(
                /*
                left: location.column * cellSize.width / Layer.layerScale * layerScale,
                top: location.row * cellSize.height / Layer.layerScale * layerScale,
                */
                left: 25.0 * layerScale,
                top: 25.0 * layerScale,
                child: SizedBox(
                  width: 50.0 * layerScale,
                  height: 50.0 * layerScale,
                  child: _bLocation,
                ),
              ),
        ],
      ),
    );
  }
}
