import 'package:rive/rive.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class ListViewBuilderPage extends StatefulWidget {
  const ListViewBuilderPage({ Key key }) : super(key: key);

  static const String routeName = '/list-view-builder';

  @override _ListViewBuilderPageState createState() => _ListViewBuilderPageState();
}

class _ListViewBuilderPageState extends State<ListViewBuilderPage> {
  static const _itemCount = 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ListView.builder'),
        actions: <Widget>[
        ],
      ),
      body: Center(
        child: Container(
          width: 400.0,
          height: 400.0,
          child: ListView.builder(
            itemCount: _itemCount,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                height: 200,
                color: Colors.teal.withOpacity(index / _itemCount),
                child: _Marty(
                  index: index,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Marty extends StatefulWidget {
  const _Marty({
    Key key,
    @required this.index,
  }) : super(key: key);

  final int index;

  @override _MartyState createState() => _MartyState();
}

class _MartyState extends State<_Marty> {
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

  @override
  void dispose() {
    super.dispose();
    print('justin dipose ${widget.index}');
  }

  @override
  Widget build(BuildContext context) {
    return _riveArtboard == null
      ? const SizedBox()
      : Rive(artboard: _riveArtboard);
  }
}
