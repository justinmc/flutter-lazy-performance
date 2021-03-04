import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:rive/rive.dart';

class ListViewBuilderPage extends StatefulWidget {
  const ListViewBuilderPage({ Key key }) : super(key: key);

  static const String routeName = '/list-view-builder';

  @override _ListViewBuilderPageState createState() => _ListViewBuilderPageState();
}

class _ListViewBuilderPageState extends State<ListViewBuilderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyListViewBuilder'),
        actions: <Widget>[
        ],
      ),
      body: Center(
        child: Container(
          width: 400.0,
          height: 400.0,
          child: ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              print('justin builder $index');
              return Container(
                height: 100,
                child: _UFO(
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

class _UFO extends StatefulWidget {
  const _UFO({
    Key key,
    @required this.index,
  }) : super(key: key);

  final int index;

  @override _UFOState createState() => _UFOState();
}

class _UFOState extends State<_UFO> {
  Artboard _riveArtboard;
  RiveAnimationController _bounceController;
  RiveAnimationController _blinkController;

  @override
  void initState() {
    super.initState();

    // Load the animation file from the bundle, note that you could also
    // download this. The RiveFile just expects a list of bytes.
    rootBundle.load('assets/UFO.riv').then(
      (data) async {
        final file = RiveFile();

        // Load the RiveFile from the binary data.
        if (file.import(data)) {
          // The artboard is the root of the animation and gets drawn in the
          // Rive widget.
          final artboard = file.mainArtboard;
          // Add a controller to play back a known animation on the main/default
          // artboard.We store a reference to it so we can toggle playback.
          _blinkController = SimpleAnimation('Blink');
          _bounceController = SimpleAnimation('Bounce');
          artboard.addController(_blinkController);
          artboard.addController(_bounceController);
          setState(() {
            _riveArtboard = artboard;
            _blinkController.isActive = true;
            _bounceController.isActive = true;
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
