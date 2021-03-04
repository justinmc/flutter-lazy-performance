import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class IVBuilderPage extends StatefulWidget {
  const IVBuilderPage({ Key key }) : super(key: key);

  static const String routeName = '/iv-builder';

  @override _IVBuilderPageState createState() => _IVBuilderPageState();
}

class _IVBuilderPageState extends State<IVBuilderPage> {
  final TransformationController _transformationController = TransformationController();

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
            maxScale: 2.5,
            minScale: 0.5,
            child: Builder(
              builder: (BuildContext context) {
                final Color color = _transformationController.value.getMaxScaleOnAxis() > 1.0
                    ? Colors.red
                    : Colors.blue;
                return Container(width: 400, height: 400, color: color);
              },
            ),
          ),
        ),
      ),
    );
  }
}
