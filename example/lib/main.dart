import 'package:flogged/flogged.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lumberdash/lumberdash.dart';
import 'package:package_info/package_info.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final pInfo = await PackageInfo.fromPlatform();
  putLumberdashToWork(withClients: [
    FloggedLumberdash(
      appName: 'Flogged Test',
      appVersionName: pInfo.version,
      appVersionCode: int.parse(pInfo.buildNumber),
      environment: kReleaseMode ? 'production' : 'debug',
      logstashUrl: 'http://my.logstash.instance',
      logstashPort: 5001,
    ),
  ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RaisedButton(
            child: const Text('Log Message'),
            onPressed: () {
              logMessage('This is a test message!');
            },
          ),
          RaisedButton(
            color: Colors.red,
            child: const Text('Log Exception'),
            onPressed: () {
              try {
                final l = <int>[0, 1, 2];
                final i = l[4];
              } on RangeError catch (e, stacktrace) {
                logError(e, stacktrace: stacktrace);
              }
            },
          ),
        ],
      ),
    );
  }
}
