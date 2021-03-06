import 'dart:convert';
import 'dart:io';

import 'package:lumberdash/lumberdash.dart';
import 'package:http/http.dart' as http;

/// Sends Lumberdash logs to a logstash instance.
///
/// ```dart
/// import 'package:lumberdash/lumberdash.dart';
/// import 'package:flogged/flogged.dart';
/// // More imports
///
/// Future<void> main() async {
///   WidgetsFlutterBinding.ensureInitialised();
///   final pInfo = await PackageInfo.fromPlatform();
///   putLumberdashToWork(withClients: [
///     FloggedLumberdash(
///       appName: 'Flogged Test',
///       appVersionName: pInfo.version,
///       appVersionCode: int.parse(pInfo.buildNumber),
///       environment: kReleaseMode ? 'production' : 'debug',
///       logstashUrl: 'http://my.logstash.instance',
///       logstashPort: 5001,
///     ),
///   ]);
///   runApp(MyApp());
/// }
/// ```
class FloggedLumberdash extends LumberdashClient {
  FloggedLumberdash({
    required this.appName,
    required this.appVersionName,
    required this.appVersionCode,
    required this.environment,
    required this.logstashUrl,
    required this.logstashPort,
  });

  /// The name of the app e.g. "My App"
  final String appName;

  /// The version name of the app e.g. 2.0.0
  final String appVersionName;

  /// The version code of the app e.g. 1234
  final int appVersionCode;

  /// Either "production" or "debug" as appropriate
  final String environment;

  /// The hostname of the Logstash instance e.g. "http://my.logstash.instance"
  final String logstashUrl;

  /// The port of the Logstash instance e.g. 4000
  final int logstashPort;

  Map<String, dynamic> get _baseData => {
        'app': <String, dynamic>{
          'project': appName,
          'environment': environment,
          'version': '$appVersionName ($appVersionCode)',
        },
        'os': Platform.operatingSystem,
        'event': <String, dynamic>{
          'created': DateTime.now().toIso8601String(),
          'type': 'log',
        },
      };

  @override
  void logError(exception, [stacktrace]) {
    final data = _baseData;
    data['level'] = 'ERROR';
    data['message'] = exception?.toString() ?? 'Error';
    data['exception'] = <String, dynamic>{
      'data': <String, dynamic>{
        'stacktrace': (stacktrace as StackTrace).toString(),
      },
    };
    data['event'] = <String, dynamic>{
      'created': DateTime.now().toIso8601String(),
      'type': 'exception',
    };
    _sendLog(data);
  }

  @override
  void logFatal(String message, [Map<String, String>? extras]) {
    final data = _baseData;
    data['level'] = 'CRITICAL';
    data['message'] = message;
    data['extras'] = extras;
    data['event'] = <String, dynamic>{
      'created': DateTime.now().toIso8601String(),
      'type': 'exception',
    };
    _sendLog(data);
  }

  @override
  void logMessage(String message, [Map<String, String>? extras]) {
    final data = _baseData;
    data['level'] = 'INFO';
    data['message'] = message;
    data['extras'] = extras;
    _sendLog(data);
  }

  @override
  void logWarning(String message, [Map<String, String>? extras]) {
    final data = _baseData;
    data['level'] = 'WARN';
    data['message'] = message;
    data['extras'] = extras;
    _sendLog(data);
  }

  Future<void> _sendLog(
    Map<String, dynamic> data, {
    int delayMillis = 0,
  }) async {
    try {
      final r = await http.post(
        Uri.parse('$logstashUrl:$logstashPort/'),
        body: jsonEncode(data),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (r.statusCode == 429 && delayMillis <= _maxDelayMillis) {
        await _sendLog(data, delayMillis: delayMillis + 10000);
      }
    } catch (_) {
      if (delayMillis <= _maxDelayMillis) {
        await _sendLog(data, delayMillis: delayMillis + 10000);
      }
    }
  }

  static const _maxDelayMillis = 60000;
}
