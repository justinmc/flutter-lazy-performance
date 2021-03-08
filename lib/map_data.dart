import 'dart:math' show Random;
import 'dart:ui';

import 'constants.dart';

class MapData {
  MapData({
    this.seed,
  }) : assert(seed != null);

  final int seed;

  TileData getTileDataAt(int x, int y) {
    return TileData.generate(x, y, seed);
  }
}

class TileData {
  TileData({
    this.x,
    this.y,
    this.aOffsets,
    this.bOffsets,
  }) : assert(x != null),
       assert(y != null),
       assert(aOffsets != null),
       assert(bOffsets != null);

  factory TileData.generate(int x, int y, int seed) {
    // TODO(justinmc): Something better than x + y + seed.
    final Random random = Random(x + y + seed);
    final List<Offset> aOffsets = <Offset>[
      for(int i = 0; i < random.nextInt(_maxLocations); i++)
         Offset(
           random.nextDouble() * _maxX,
           random.nextDouble() * _maxY,
         ),
    ];
    final List<Offset> bOffsets = <Offset>[
      for(int i = 0; i < random.nextInt(_maxLocations); i++)
         Offset(
           random.nextDouble() * _maxX,
           random.nextDouble() * _maxY,
         ),
    ];

    return TileData(
      x: x,
      y: y,
      aOffsets: aOffsets,
      bOffsets: bOffsets,
    );
  }

  static const int _maxLocations = 8;
  static final double _maxX = cellSize.width - 10.0;
  static final double _maxY = cellSize.height - 10.0;

  final int x;
  final int y;
  final Iterable<Offset> aOffsets;
  final Iterable<Offset> bOffsets;
  // TODO(justinmc): This needs major cleanup... Layered/two-level enum.
  final TileType tileType = TileType(layer: Layers.terrestrial, terrain: TerrestrialTerrain());
}

class TileType {
  TileType({
    this.layer,
    this.terrain,
  }) : assert(layer == terrain.layer);

  final Layers layer;
  final Terrain terrain;
}

abstract class Terrain {
  const Terrain();

  Terrains get terrainType;
  Layers get layer;
}

class TerrestrialTerrain extends Terrain {
  const TerrestrialTerrain();

  final Terrains terrainType = Terrains.grassland;
  final Layers layer = Layers.terrestrial;
}

enum Terrains {
  grassland,
  water,
}

enum Layers {
  terrestrial,
  planetary,
  solar,
  galactic,
}

/*
class Location {
  const Location({
    this.x,
    this.y,
  }) : assert(x != null),
       assert(y != null);

  final int x;
  final int y;
}
*/
