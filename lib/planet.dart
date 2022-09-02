import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'rive_asset.dart';

class Planet extends RiveAsset {
  const Planet({
    Key key,
  }) : super(
          key: key,
          asset: 'assets/planet.riv',
        );
}
