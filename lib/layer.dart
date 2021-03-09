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
  }) : assert(scale == 1.0 || scale == 0.1 || scale == 0.01 || scale == 0.001);

  // Each layer has 10x as many tiles as its parent.
  static const int layerScale = 10;

  final LayerType parent;
  final LayerType child;
  final double scale;
}

final Map<LayerType, Layer> layers = <LayerType, Layer>{
  LayerType.local: Layer(
    parent: LayerType.terrestrial,
    scale: 1.0,
  ),
  LayerType.terrestrial: Layer(
    parent: LayerType.solar,
    child: LayerType.local,
    scale: 0.1,
  ),
  LayerType.solar: Layer(
    parent: LayerType.galactic,
    child: LayerType.terrestrial,
    scale: 0.01,
  ),
  LayerType.galactic: Layer(
    child: LayerType.solar,
    scale: 0.001,
  ),
};
