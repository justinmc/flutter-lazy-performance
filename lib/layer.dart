import 'dart:ui' show Size;
import 'dart:math' show pow;

import 'constants.dart';

enum LayerType {
  local,
  terrestrial,
  solar,
  galactic,
}

class Layer {
  const Layer({
    this.scale,
    this.parent,
    this.child,
    this.level,
  })  : assert(scale == 1.0 || scale == 0.1 || scale == 0.01 || scale == 0.001),
        assert(level != null && level >= 0 && level < 4);

  // Each layer has 10x as many tiles as its parent.
  static const int layerScale = 10;

  final LayerType parent;
  final LayerType child;
  final double scale;
  final int level;

  Size get size {
    return Size(
      cellSize.width * pow(Layer.layerScale, level),
      cellSize.height * pow(Layer.layerScale, level),
    );
  }
}

final Map<LayerType, Layer> layers = <LayerType, Layer>{
  LayerType.local: Layer(
    parent: LayerType.terrestrial,
    scale: 1.0,
    level: 0,
  ),
  LayerType.terrestrial: Layer(
    parent: LayerType.solar,
    child: LayerType.local,
    scale: 0.1,
    level: 1,
  ),
  LayerType.solar: Layer(
    parent: LayerType.galactic,
    child: LayerType.terrestrial,
    scale: 0.01,
    level: 2,
  ),
  LayerType.galactic: Layer(
    child: LayerType.solar,
    scale: 0.001,
    level: 3,
  ),
};
