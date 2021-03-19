import 'package:rive/rive.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'rive_asset.dart';

class Marty extends RiveAsset {
  const Marty({
    Key key,
    @required int index,
    bool isBackgroundTransparent = false,
  }) : super(
    key: key,
    asset: isBackgroundTransparent ? 'assets/marty_transparent.riv' : 'assets/marty_v6.riv',
    animationIndex: index,
  );
}
