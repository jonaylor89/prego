import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Dynamic Theme allows for dark to light mode
    // transition during runtime
    return new DynamicTheme(
        defaultBrightness: Brightness.light,
        data: (brightness) => new ThemeData(
              primarySwatch: Colors.blue,
              brightness: brightness,
            ),
        themedWidgetBuilder: (context, theme) {
          return MaterialApp(
            title: 'Prego',
            theme: theme,
            home: MyHomePage(title: 'Prego'),
          );
        });
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
  int sleepTime = 3000; // Time to think in milliseconds
  int percentageOfPregnancy =
      25; // Percentage of times it will say pregnant is true
  int numberOfChildren = 0;
  int timerText = 0;

  bool isPregnant = false; // Is the result pregnant
  bool isThinking = false; // Are we thinking for the result

  Stopwatch sw = new Stopwatch();

  final rng = new Random();

  void _startDataCollection() {
    setState(() {
      sw.start();
    });

    Timer _timer;
    _timer = new Timer.periodic(
        Duration(milliseconds: 100),
        (Timer timer) => setState(() {
              if (!sw.isRunning) {
                _timer.cancel();
              } else {
                timerText = timerText + 100;
              }
            }));
  }

  void _stopDataCollection() {
    setState(() {
      sw.stop();
      isThinking = true;
    });
  }

  Text startStopButtonText() {
    return sw.isRunning
        ? Text('Stop', style: TextStyle(fontSize: 40))
        : Text('Start', style: TextStyle(fontSize: 40));
  }

  Future<Duration> _onLoading() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            child: Container(
                height: 75,
                width: 100,
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    CircularProgressIndicator(),
                    Padding(padding: EdgeInsets.all(10.0)),
                    Text("Crunching Numbers")
                  ],
                )));
      },
    );

    // Determine if pregnant
    isPregnant = rng.nextInt(100) > percentageOfPregnancy;

    if (isPregnant) {
      // Determine number of children
      numberOfChildren = rng.nextInt(10) + 1;
    }

    return await Future.delayed(new Duration(milliseconds: sleepTime), () {
      Navigator.pop(context); //pop dialog
    });
  }

  void toggleDataCollection() async {
    if (sw.isRunning) {
      // Stop data collection
      _stopDataCollection();

      // Loading message while thinking
      await _onLoading();

      // show dialog of the "results"
      _showResults();
    } else {
      // Start timer and "data collection"
      _startDataCollection();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String twoDigitMilli = twoDigits(duration.inMilliseconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds:$twoDigitMilli";
  }

  void _changeThemeInApp() async {
    // Get dark mode preference from phone local storage
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // If setting isn't set then default to dark mode
    bool darkMode = (prefs.getBool('darkMode') ?? true);

    // Save opposite setting to local storage
    await prefs.setBool('darkMode', !darkMode);

    if (darkMode) {
      DynamicTheme.of(context).setBrightness(Brightness.dark);
    } else {
      DynamicTheme.of(context).setBrightness(Brightness.light);
    }
  }

  void _showResults() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Results',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Pregnant: ',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                Text('$isPregnant', style: TextStyle(fontSize: 20)),
                Text('Number of children: ',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                Text('$numberOfChildren', style: TextStyle(fontSize: 20)),
                Text('Total time for data collection: ',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                Text('${_formatDuration(sw.elapsed)}',
                    style: TextStyle(fontSize: 20))
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  // Reset the stopwatch for another go
                  sw.reset();
                  timerText = 0;

                  // Go back to start again
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
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
              Text(_formatDuration(Duration(milliseconds: timerText)),
                  style: TextStyle(fontSize: 50)),
              RaisedButton(
                onPressed: () {
                  toggleDataCollection();
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0))),
                textColor: Colors.white,
                padding: const EdgeInsets.all(0.0),
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    gradient: LinearGradient(
                      colors: <Color>[
                        Color(0xFF6699FF),
                        Color(0xFFFF99FF),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(10.0),
                  child: startStopButtonText(),
                ),
              ),
            ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {_changeThemeInApp()},
        tooltip: 'Change Theme',
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
