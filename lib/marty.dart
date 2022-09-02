import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'rive_asset.dart';

class Marty extends RiveAsset {
  Marty({
    Key key,
    @required int index,
    bool isBackgroundTransparent = false,
  }) : super(
          key: key,
          asset: isBackgroundTransparent
              ? 'assets/marty_transparent.riv'
              : 'assets/marty_v6.riv',
          //animationIndex: index % 2,
          animationIndex: Random().nextInt(2),
        );
}
