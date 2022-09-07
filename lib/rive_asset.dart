import 'package:rive/rive.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class RiveAsset extends StatefulWidget {
  const RiveAsset({
    Key key,
    @required this.asset,
    this.animationIndex = 0,
  }) : super(key: key);

  final String asset; // The path to the .riv file.
  final int animationIndex;

  @override
  _RiveAssetState createState() => _RiveAssetState();
}

class _RiveAssetState extends State<RiveAsset> {
  Artboard _riveArtboard;
  RiveAnimationController _controller;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();

    // This will naively reload the asset for every instance of this widget.
    rootBundle.load(widget.asset).then(
      (data) async {
        if (_disposed) {
          return;
        }
        final file = RiveFile();

        if (file.import(data)) {
          final artboard = file.mainArtboard;
          _controller =
              SimpleAnimation(artboard.animations[widget.animationIndex].name);
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
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _riveArtboard == null
        ? const SizedBox()
        : Rive(artboard: _riveArtboard);
  }
}
