import 'dart:math' show Random;
import 'dart:ui' show Offset;

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
    return TileData.generate(Location(
      row: (offset.dy / Layer.layerScale).floor(),
      column: (offset.dx / Layer.layerScale).floor(),
      layerType: LayerType.local,
    ), seed);
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
  }) : assert(location != null),
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

    // TODO(justinmc): Something better than x + y + seed.
    final Random random = Random(location.row + location.column + seed);

    final TerrainType terrainType = parent == null
        ? _galacticTerrainTypes[random.nextInt(_galacticTerrainTypes.length)]
        : parent.terrain.childTerrainTypes[random.nextInt(parent.terrain.childTerrainTypes.length)];

    final List<Location> aLocations = <Location>[
      for(int i = 0; i < random.nextInt(_maxLocations); i++)
         Location(
           row: random.nextInt(Layer.layerScale),
           column: random.nextInt(Layer.layerScale),
           layerType: location.layerType,
         ),
    ];
    final List<Location> bLocations = <Location>[
      for (int i = 0; i < random.nextInt(_maxLocations); i++)
         Location(
           row: random.nextInt(Layer.layerScale),
           column: random.nextInt(Layer.layerScale),
           layerType: location.layerType,
         ),
    ];

    if ( _terrainToType[terrainType] == null) {
      print('justin null terrain $terrainType');
    }
    return TileData(
      location: location,
      aLocations: aLocations,
      bLocations: bLocations,
      seed: seed,
      terrain: _terrainToType[terrainType],
      parent: parent,
    );
  }

  /*
  TileData generateChild(Location location) {
    if (layerType != LayerType.galactic) {
      parent = TileData.generate(
        location.parent,
        layers[layerType].parent,
        seed,
      );
    }
  }
  */

  static const int _maxLocations = 8;
  static final double _maxX = cellSize.width - 10.0;
  static final double _maxY = cellSize.height - 10.0;

  // Easy way to get a loation by row, column when stored in an iterable by a
  // 1D index.
  // TODO pass Location instead of row and column?
  static TileData getByRowColumn(Iterable<TileData> tileDatas, int row, int column) {
    return tileDatas.elementAt(row * Layer.layerScale + column);
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
    _children = Iterable.generate(Layer.layerScale * Layer.layerScale, (int index) {
      return TileData.generate(location.children.elementAt(index), seed);
    });
    return _children;
  }

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

/*
abstract class Terrain {
  const Terrain();

  TerrainType get terrainType;
  LayerType get layer;
}

class TerrestrialTerrain extends Terrain {
  const TerrestrialTerrain();

  final TerrainType terrainType = TerrainType.grassland;
  final LayerType layer = LayerType.terrestrial;
}

class GrasslandTerrain extends Terrain {
  const GrasslandTerrain();

  final TerrainType terrainType = TerrainType.grassland;
  final LayerType layer = LayerType.local;
  final List<TerrainType> childTerrainTypes = null;
}
*/

class Terrain {
  const Terrain({
    this.layer,
    this.terrainType,
    this.childTerrainTypes,
  });

  final TerrainType terrainType;
  final LayerType layer;
  final List<TerrainType> childTerrainTypes;

  @override
  String toString() {
    return 'Terrain of type $terrainType with childTerrainTypes: $childTerrainTypes';
  }
}

// TODO(justinmc): This name is reversed...
const Map<TerrainType, Terrain> _terrainToType = <TerrainType, Terrain>{
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

  TerrainType.continent: Terrain(
    terrainType: TerrainType.continent,
    layer: LayerType.terrestrial,
    childTerrainTypes: <TerrainType>[
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

  TerrainType.solarSpace: Terrain(
    terrainType: TerrainType.solarSpace,
    layer: LayerType.solar,
    childTerrainTypes: <TerrainType>[
      TerrainType.terrestrialSpace,
    ],
  ),

  TerrainType.solarSystem: Terrain(
    terrainType: TerrainType.solarSystem,
    layer: LayerType.galactic,
    childTerrainTypes: <TerrainType>[
      TerrainType.star,
      TerrainType.planet,
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
  }) : assert(row != null),
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
    _children = Iterable.generate(Layer.layerScale * Layer.layerScale, (int index) {
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

    return other.row == row
        && other.column == column
        && other.layerType == layerType;
  }
}
