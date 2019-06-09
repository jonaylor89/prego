import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prego',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Prego'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int sleepTime = 10000; // Time to think in milliseconds
  int percentageOfPregnancy =
      25; // Percentage of times it will say pregnant is true
  bool isCollecting = false; // Are we collection data
  bool isPregnant = false; // Is the result pregnant
  bool isThinking = false; // Are we thinking for the result

  Stopwatch sw = new Stopwatch();

  final rng = new Random();

  void _checkPregnancy() async {
    setState(() {
      isThinking = true;
    });

    await Future.delayed(new Duration(milliseconds: sleepTime));

    setState(() {
      isPregnant = rng.nextInt(100) < percentageOfPregnancy;
      isThinking = false;
    });
  }

  void _startDataCollection() {
    setState(() {
      sw.start();
      isCollecting = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the checkPregnancy method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
            // Column is also layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Invoke "debug painting" (press "p" in the console, choose the
            // "Toggle Debug Paint" action from the Flutter Inspector in Android
            // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
            // to see the wireframe for each widget.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                child: const Text('Start'),
                color: Theme.of(context).accentColor,
                elevation: 4.0,
                splashColor: Colors.blueGrey,
                onPressed: () {
                  // Start timer and "data collection"
                  _startDataCollection();
                },
              ),
              RaisedButton(
                  child: const Text('Stop'),
                  color: Theme.of(context).accentColor,
                  elevation: 4.0,
                  splashColor: Colors.blueGrey,
                  onPressed: () {
                    // Stop data collection
                    // show dialog of the "results"
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Results'),
                            content: const Text('Here are your results'),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('Ok'),
                                onPressed: () {
                                  sw.reset();
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        });
                  }),
            ]),
      ),
      floatingActionButton: FloatingActionButton(
        // TODO: This button can be a help button???
        onPressed: null,
        tooltip: 'Pregnancy Check',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
