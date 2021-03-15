import 'package:rive/rive.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class Marty extends StatefulWidget {
  const Marty({
    Key key,
    @required this.index,
  }) : super(key: key);

  final int index;

  @override _MartyState createState() => _MartyState();
}

class _MartyState extends State<Marty> {
  Artboard _riveArtboard;
  RiveAnimationController _controller;

  @override
  void initState() {
    super.initState();

    rootBundle.load('assets/marty_v6.riv').then(
      (data) async {
        final file = RiveFile();

        if (file.import(data)) {
          final artboard = file.mainArtboard;
          _controller = SimpleAnimation(artboard.animations[widget.index % 2].name);
          artboard.addController(_controller);
          setState(() {
            _riveArtboard = artboard;
            _controller.isActive = true;
          });
        }
      },
    );
  }

  /*
  @override
  void dispose() {
    super.dispose();
    print('justin dipose ${widget.index}');
  }
  */

  @override
  Widget build(BuildContext context) {
    return _riveArtboard == null
      ? const SizedBox()
      : Rive(artboard: _riveArtboard);
  }
}
