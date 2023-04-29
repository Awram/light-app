import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;
  final List<Widget> _pages = <Widget>[
    LuxDisplay(),
    InfoPage(),
  ];

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Lux Sensor',
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
          primarySwatch: Colors.green,
        ),
        home: Scaffold(
            appBar: AppBar(
              title: Text("Light App"),
            ),
            body: Row(
              children: <Widget>[
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: <NavigationRailDestination>[
                    NavigationRailDestination(
                        icon: Icon(Icons.lightbulb_outline),
                        label: Text("Lux Display")),
                    NavigationRailDestination(
                        icon: Icon(Icons.info_outline),
                        label: Text("Info Page"))
                  ],
                ),
                VerticalDivider(
                  thickness: 1,
                  width: 1,
                ),
                Expanded(
                  child: _pages[_selectedIndex],
                )
              ],
            )));
  }
}

class LuxDisplay extends StatefulWidget {
  @override
  _LuxDisplayState createState() => _LuxDisplayState();
}

class _LuxDisplayState extends State<LuxDisplay> {
  static const platform = const MethodChannel('com.example.myapp/light_sensor');
  double lux = 0;
  bool isLoading = false;
  String recommendation =
      'Go outside and face the front of your phone to the sun while pushing the button below.';
  bool buttonPressedOnce = false; // Add this state variable
  final numberFormatter =
      NumberFormat("#,##0", "en_US"); // Create a number formatter

  Future<double> getLuxValue() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final double luxValue =
          (await platform.invokeMethod('getLuxValue')).toDouble();
      return luxValue.roundToDouble();
    } on PlatformException catch (e) {
      // Handle any errors, like a missing sensor or permission issues
      print("Error: ${e.message}");
      return -1;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  String getRecommendation(double luxValue) {
    if (luxValue < 1000) {
      return "Very Overcast: Spend 30min outside to set your circadian clock.";
    } else if (luxValue >= 1000 && luxValue < 5000) {
      return "Overcast: Spend 20min outside to set your circadian clock.";
    } else if (luxValue >= 5000 && luxValue < 25000) {
      return "Sunny: Spend 15min outside to set your circadian clock.";
    } else if (luxValue >= 25000 && luxValue < 100000) {
      return "Very Sunny: Spend 10min outside to set your circadian clock.";
    } else {
      return "Holy shit it's bright. Just get 5min to set your circadian clock.";
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: SingleChildScrollView(
          // Wrap the Column widget with SingleChildScrollView
          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (recommendation.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    recommendation,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
              SizedBox(
                  height:
                      60), // Increased height of SizedBox to move recommendation text closer to the top
              Text(
                'Current Lux Value:',
                style: Theme.of(context).textTheme.headline5,
              ),
              Text(
                numberFormatter.format(lux),
                style: Theme.of(context).textTheme.headline3,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() {
                          isLoading = true;
                        });
                        double currentLuxValue = await getLuxValue();
                        setState(() {
                          lux = currentLuxValue;
                          recommendation = getRecommendation(currentLuxValue);
                          isLoading = false;
                          buttonPressedOnce = true;
                        });
                      },
                child: isLoading
                    ? CircularProgressIndicator()
                    : Text(buttonPressedOnce
                        ? 'Measure Light Again'
                        : 'Get Lux Value'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoPage extends StatefulWidget {
  const InfoPage({Key? key}) : super(key: key);

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '10 Takeaways from Huberman\'s Light Podcasts, Regarding the Health Benefits of Light',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildListItem(
              'Light exposure affects the body\'s circadian rhythm, which regulates sleep, wakefulness, and many other physiological processes.'),
          _buildListItem(
              'Blue light in particular can be used to shift the circadian rhythm and improve sleep quality, alertness, and mood.'),
          _buildListItem(
              'Morning exposure to bright blue light can help reset the circadian rhythm and alleviate symptoms of seasonal affective disorder (SAD).'),
          _buildListItem(
              'Red light, on the other hand, has anti-inflammatory effects and can promote healing and tissue repair.'),
          _buildListItem(
              'Infrared light has been shown to improve physical performance, reduce inflammation, and enhance recovery from injury.'),
          _buildListItem(
              'Light exposure can affect hormone levels, such as melatonin and cortisol, which in turn can influence mood, energy levels, and immune function.'),
          _buildListItem(
              'Light exposure can affect the brain\'s reward system, leading to increased motivation and positive affect.'),
          _buildListItem(
              'The eyes are not the only part of the body that respond to light; skin, for example, also has light-sensitive receptors that can trigger physiological responses.'),
          _buildListItem(
              'Bright light exposure can be used to treat jet lag and shift work disorder, which are characterized by disrupted circadian rhythms.'),
          _buildListItem(
              'Light exposure can have both positive and negative effects on health, depending on the timing, duration, and intensity of exposure, as well as individual differences in sensitivity and susceptibility. Therefore, it is important to tailor light exposure strategies to individual needs and goals.'),
        ],
      ),
    );
  }

  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
}
