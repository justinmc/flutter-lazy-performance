import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class IVBuilderPage extends StatefulWidget {
  const IVBuilderPage({ Key key }) : super(key: key);

  static const String routeName = '/iv-builder';

  @override _IVBuilderPageState createState() => _IVBuilderPageState();
}

class _IVBuilderPageState extends State<IVBuilderPage> {
  final TransformationController _transformationController = TransformationController();

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
            boundaryMargin: EdgeInsets.all(double.infinity),
            constrained: false,
            transformationController: _transformationController,
            scaleEnabled: false,
            child: Container(width: 400, height: 400, color: Colors.red),
          ),
        ),
      ),
    );
  }
}
