import 'package:rive/rive.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'constants.dart';
import 'map_data.dart';

class ProceduralGenerationPage extends StatefulWidget {
  const ProceduralGenerationPage({ Key key }) : super(key: key);

  static const String routeName = '/procedural-generation';

  @override _ProceduralGenerationPageState createState() => _ProceduralGenerationPageState();
}

class _ProceduralGenerationPageState extends State<ProceduralGenerationPage> {
  final TransformationController _transformationController = TransformationController();

  static const double _minScale = 0.5;
  static const double _maxScale = 2.5;
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
              constrained: false,
              transformationController: _transformationController,
              maxScale: _maxScale,
              minScale: _minScale,
              builder: (BuildContext context, Rect viewport) {
                return _MapGrid(
                  columns: (viewport.width / cellSize.width).ceil(),
                  rows: (viewport.height / cellSize.height).ceil(),
                  firstColumn: (viewport.left / cellSize.width).floor(),
                  firstRow: (viewport.top / cellSize.height).floor(),
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
    this.viewport,
    this.columns,
    this.rows,
    this.firstColumn,
    this.firstRow,
  }) : super(key: key);

  // TODO(justinmc): UI for choosing a seed.
  final MapData _mapData = MapData(seed: 80);
  final Rect viewport;

  final int columns;
  final int rows;
  final int firstColumn;
  final int firstRow;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (int row = firstRow; row < firstRow + rows; row++)
          Row(
            children: <Widget>[
              for (int column = firstColumn; column < firstColumn + columns; column++)
                _MapTile(tileData: _mapData.getTileDataAt(row, column)),
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
    if (tileData.tileType.layer == Layers.terrestrial && tileData.tileType.terrain.terrainType == Terrains.grassland) {
      child = _Grassland(
        aOffsets: tileData.aOffsets,
        bOffsets: tileData.bOffsets,
      );
    } else {
      throw new FlutterError('Invalid tile type');
    }

    return Container(
      width: cellSize.width,
      height: cellSize.height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black)
      ),
      child: child,
    );
  }
}

class _Grassland extends StatelessWidget {
  const _Grassland({
    this.aOffsets,
    this.bOffsets,
  });

  final List<Offset> aOffsets;
  final List<Offset> bOffsets;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        for (Offset offset in aOffsets)
          Positioned(
            left: offset.dx,
            top: offset.dy,
            child: _Grass(),
          ),
        // TODO(justinmc): Something besides grass
          /*
        for (Offset offset in bOffsets)
          Positioned(
            left: 50.0,
            top: 0.0,
            child: _Grass(),
          ),
          */
      ],
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
