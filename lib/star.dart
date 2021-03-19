import 'package:rive/rive.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'rive_asset.dart';

class Star extends RiveAsset {
  const Star({
    Key key,
  }) : super(
    key: key,
    asset: 'assets/star.riv',
  );
}
