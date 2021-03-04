import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class IVBuilderPage extends StatefulWidget {
  const IVBuilderPage({ Key key }) : super(key: key);

  static const String routeName = '/iv-builder';

  @override _IVBuilderPageState createState() => _IVBuilderPageState();
}

class _IVBuilderPageState extends State<IVBuilderPage> {
  final TransformationController _transformationController = TransformationController();

  static const double _minScale = 0.5;
  static const double _maxScale = 2.5;
  static const double _scaleRange = _maxScale - _minScale;

  void _onChangeTransformation() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onChangeTransformation);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onChangeTransformation);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyIVBuilder'),
        actions: <Widget>[
        ],
      ),
      body: Center(
        child: Container(
          width: 200.0,
          height: 200.0,
          child: InteractiveViewer(
            alignPanAxis: false,
            clipBehavior: Clip.none,
            boundaryMargin: EdgeInsets.all(double.infinity),
            constrained: false,
            transformationController: _transformationController,
            maxScale: _maxScale,
            minScale: _minScale,
            child: Builder(
              builder: (BuildContext context) {
                final double scale = _transformationController.value.getMaxScaleOnAxis();
                final Color color = Colors.red.withOpacity((scale - _minScale) / _scaleRange);
                return Container(width: 200, height: 200, color: color);
              },
            ),
          ),
        ),
      ),
    );
  }
}
