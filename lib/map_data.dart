import 'dart:math' show Random;
import 'dart:ui' show Offset, Size;

import 'constants.dart';
import 'layer.dart';

class MapData {
  MapData({
    this.seed,
  }) : assert(seed != null);

  final int seed;

  TileData getTileDataAt(Location location) {
    return TileData.generate(location, seed);
  }

  TileData getLowestTileDataAtScreenOffset(Offset offset) {
    return TileData.generate(
        Location(
          row: (offset.dy / cellSize.height).floor(),
          column: (offset.dx / cellSize.width).floor(),
          layerType: LayerType.local,
        ),
        seed);
  }
}

class TileData {
  TileData({
    this.location,
    this.aLocations,
    this.bLocations,
    this.parent,
    this.seed,
    this.terrain,
  })  : assert(location != null),
        assert(aLocations != null),
        assert(bLocations != null),
        assert(seed != null),
        assert(terrain != null);

  factory TileData.generate(Location location, int seed) {
    TileData parent;
    if (location.layerType != LayerType.galactic) {
      parent = TileData.generate(
        location.parent,
        seed,
      );
    }

    final Random random =
        Random('${location.row},${location.column},$seed'.hashCode);
    final TerrainType terrainType = _getTerrainType(parent, location, random);

    final List<Location> aLocations = <Location>[
      for (int i = 0; i < random.nextInt(_maxLocations); i++)
        Location(
          row: 1 + random.nextInt(Layer.layerScale - 2),
          column: 1 + random.nextInt(Layer.layerScale - 2),
          layerType: location.layerType,
        ),
    ];
    final List<Location> bLocations = <Location>[
      if (random.nextInt(1000) > 988)
        Location(
          row: 1 + random.nextInt(Layer.layerScale - 2),
          column: 1 + random.nextInt(Layer.layerScale - 2),
          layerType: location.layerType,
        ),
    ];

    return TileData(
      location: location,
      aLocations: aLocations,
      bLocations: bLocations,
      seed: seed,
      terrain: _typeToTerrain[terrainType],
      parent: parent,
    );
  }

  static const int _maxLocations = 3;

  static TerrainType _getTerrainType(
      TileData parent, Location location, Random random) {
    if (parent == null) {
      return _galacticTerrainTypes[
          random.nextInt(_galacticTerrainTypes.length)];
    }

    // Always put a planet near the origin.
    if (location.row == 0 && location.column == 0) {
      switch (location.layerType) {
        case LayerType.galactic:
          return TerrainType.solarSystem;
        case LayerType.solar:
          return TerrainType.planet;
        case LayerType.terrestrial:
        case LayerType.local:
          break;
        /*
        case LayerType.terrestrial:
          return TerrainType.continent;
        case LayerType.local:
          return TerrainType.grassland;
          */
      }
    }

    // Continents are surrounded by water.
    if (parent.terrain.terrainType == TerrainType.continent &&
        location.isInCircularEdge()) {
      return TerrainType.water;
    }

    // Planets are surrounded by space.
    if ((parent.terrain.terrainType == TerrainType.planet ||
            parent.terrain.terrainType == TerrainType.star) &&
        location.isInCircularEdge()) {
      return TerrainType.terrestrialSpace;
    }

    // Stars are surrounded by space.
    if (parent.terrain.terrainType == TerrainType.planet &&
        location.isInCircularEdge()) {
      return TerrainType.terrestrialSpace;
    }

    List<TerrainType> childTerrainTypes =
        List.from(parent.terrain.childTerrainTypes);

    // Only 1 star in a solar system.
    if (parent.terrain.terrainType == TerrainType.solarSystem) {
      if (location.row % 10 == 5 && location.column % 10 == 5) {
        return TerrainType.star;
      }
      if (location.isInCircularEdge()) {
        return TerrainType.solarSpace;
      }
      assert(childTerrainTypes.contains(TerrainType.star));
      childTerrainTypes.remove(TerrainType.star);
    }

    // Choose a random type that fits the parent.
    return childTerrainTypes[random.nextInt(childTerrainTypes.length)];
  }

  // Easy way to get a loation by row, column when stored in an iterable by a
  // 1D index.
  //
  // row and column are local to the parent, not global location.
  static TileData getByRowColumn(
      Iterable<TileData> tileDatas, int row, int column) {
    final int index = row * Layer.layerScale + column;
    assert(index >= 0 && index < tileDatas.length,
        'Invalid index $index for tileDatas of length ${tileDatas.length}.');
    return tileDatas.elementAt(index);
  }

  final Location location;
  final Iterable<Location> aLocations;
  final Iterable<Location> bLocations;
  final TileData parent;
  final int seed;
  final Terrain terrain;

  Iterable<TileData> _children;
  Iterable<TileData> get children {
    if (_children != null) {
      return _children;
    }
    _children =
        Iterable.generate(Layer.layerScale * Layer.layerScale, (int index) {
      return TileData.generate(location.children.elementAt(index), seed);
    });
    return _children;
  }

  Size get size => layers[location.layerType].size;

  @override
  String toString() {
    return 'TileData with terrain $terrain';
  }

  @override
  int get hashCode => location.hashCode;

  @override
  bool operator ==(dynamic other) {
    if (other is! TileData) {
      return false;
    }

    return other.location == location;
  }
}

class Terrain {
  const Terrain({
    this.layer,
    this.terrainType,
    this.childTerrainTypes,
    this.limitPerParent,
  });

  final TerrainType terrainType;
  final LayerType layer;
  final List<TerrainType> childTerrainTypes;
  final int limitPerParent;

  @override
  String toString() {
    return 'Terrain of type $terrainType with childTerrainTypes: $childTerrainTypes';
  }
}

const Map<TerrainType, Terrain> _typeToTerrain = <TerrainType, Terrain>{
  TerrainType.solarSystem: Terrain(
    terrainType: TerrainType.solarSystem,
    layer: LayerType.galactic,
    limitPerParent: 30,
    childTerrainTypes: <TerrainType>[
      TerrainType.star,
      TerrainType.planet,
      TerrainType.solarSpace,
      TerrainType.solarSpace,
      TerrainType.solarSpace,
      TerrainType.solarSpace,
      TerrainType.solarSpace,
    ],
  ),
  TerrainType.galacticSpace: Terrain(
    terrainType: TerrainType.galacticSpace,
    layer: LayerType.galactic,
    childTerrainTypes: <TerrainType>[
      TerrainType.solarSpace,
    ],
  ),
  TerrainType.solarSpace: Terrain(
    terrainType: TerrainType.solarSpace,
    layer: LayerType.solar,
    childTerrainTypes: <TerrainType>[
      TerrainType.terrestrialSpace,
    ],
  ),
  TerrainType.star: Terrain(
    terrainType: TerrainType.star,
    layer: LayerType.solar,
    childTerrainTypes: <TerrainType>[
      TerrainType.terrestrialStar,
    ],
  ),
  TerrainType.planet: Terrain(
    terrainType: TerrainType.planet,
    layer: LayerType.solar,
    childTerrainTypes: <TerrainType>[
      TerrainType.ocean,
      TerrainType.continent,
    ],
  ),
  TerrainType.continent: Terrain(
    terrainType: TerrainType.continent,
    layer: LayerType.terrestrial,
    childTerrainTypes: <TerrainType>[
      TerrainType.grassland,
      TerrainType.grassland,
      TerrainType.grassland,
      TerrainType.grassland,
      TerrainType.grassland,
      TerrainType.water,
    ],
  ),
  TerrainType.ocean: Terrain(
    terrainType: TerrainType.ocean,
    layer: LayerType.terrestrial,
    childTerrainTypes: <TerrainType>[
      TerrainType.water,
    ],
  ),
  TerrainType.terrestrialSpace: Terrain(
    terrainType: TerrainType.terrestrialSpace,
    layer: LayerType.terrestrial,
    childTerrainTypes: <TerrainType>[
      TerrainType.localSpace,
    ],
  ),
  TerrainType.terrestrialStar: Terrain(
    terrainType: TerrainType.terrestrialStar,
    layer: LayerType.terrestrial,
    childTerrainTypes: <TerrainType>[
      TerrainType.localStar,
    ],
  ),
  TerrainType.grassland: Terrain(
    terrainType: TerrainType.grassland,
    layer: LayerType.local,
  ),
  TerrainType.water: Terrain(
    terrainType: TerrainType.water,
    layer: LayerType.local,
  ),
  TerrainType.localSpace: Terrain(
    terrainType: TerrainType.localSpace,
    layer: LayerType.local,
  ),
  TerrainType.localStar: Terrain(
    terrainType: TerrainType.localStar,
    layer: LayerType.local,
  ),
};

const List<TerrainType> _galacticTerrainTypes = <TerrainType>[
  TerrainType.solarSystem,
  TerrainType.galacticSpace,
];

enum TerrainType {
  grassland,
  water,
  localSpace,
  localStar,
  continent,
  ocean,
  galacticSpace,
  solarSpace,
  terrestrialSpace,
  solarSystem,
  star,
  terrestrialStar,
  planet,
}

// Row and column are local to the given layerType.
class Location {
  Location({
    this.row,
    this.column,
    this.layerType,
  })  : assert(row != null),
        assert(column != null),
        assert(layerType != null);

  Location get parent {
    final LayerType parentLayerType = layers[layerType].parent;
    assert(parentLayerType != null);
    return Location(
      row: (row / Layer.layerScale).floor(),
      column: (column / Layer.layerScale).floor(),
      layerType: parentLayerType,
    );
  }

  bool isInCircularEdge() {
    final int normalRow = row % 10;
    final int normalColumn = column % 10;

    // Square edge.
    if (normalRow == 0 ||
        normalRow == 9 ||
        normalColumn == 0 ||
        normalColumn == 9) {
      return true;
    }

    // Top cut out.
    if (normalRow == 1 && (normalColumn == 1 || normalColumn == 8)) {
      return true;
    }

    // Bottom cut out.
    if (normalRow == 8 && (normalColumn == 1 || normalColumn == 8)) {
      return true;
    }

    return false;
  }

  final int row;
  final int column;
  final LayerType layerType;

  // The index goes like this:
  // 0: (0, 0)
  // 1: (0, 1)
  // ...
  // 9: (0, 9)
  // 10: (1, 0)
  // 11: (1, 1)
  // ...
  Iterable<Location> _children;
  Iterable<Location> get children {
    if (_children != null) {
      return _children;
    }
    assert(layerType != LayerType.local);

    final int startingRow = row * Layer.layerScale;
    final int startingColumn = column * Layer.layerScale;
    _children =
        Iterable.generate(Layer.layerScale * Layer.layerScale, (int index) {
      return Location(
        row: startingRow + (index / Layer.layerScale).floor(),
        column: startingColumn + index % Layer.layerScale,
        layerType: layers[layerType].child,
      );
    });
    return _children;
  }

  @override
  String toString() {
    return 'Location ($row, $column) in layer $layerType';
  }

  @override
  int get hashCode => '$row,$column,$layerType'.hashCode;

  @override
  bool operator ==(dynamic other) {
    if (other is! Location) {
      return false;
    }

    return other.row == row &&
        other.column == column &&
        other.layerType == layerType;
  }
}
