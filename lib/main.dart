import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'custom_flare_controller.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chicago Flutter',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: MyHomePage(title: 'Chicago Flutter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  ///our class that extends the FlareController
  CustomFlareController controller = CustomFlareController();

  ///simple check to see if we have reached the max number of taps to fill our radial
  bool _isFull = false;

  void _incrementCounter()
  {
    controller.incrementFill();

    setState(() {
      ///we need to know if it's full so we can reset it
      _isFull = controller.isFull();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Stack(
          children: <Widget>[
            ///Actor must have a sized parent
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              ///Here we set up our Actor with the .flr File
              child: FlareActor("assets/FlutterChicago.flr",
                fit: BoxFit.contain,
                /// intro animation
                animation: "Intro",
                ///set our custom class to be the controller for [FlareActor]
                controller: controller,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(
          /// if we are done, then we need to restart everything, so change the icon
          _isFull ? Icons.refresh : Icons.add,
          size: 40.0,
        ),
      ),
    );
  }
}
