# Flogged

A logger for [Lumberdash](https://pub.dev/packages/lumberdash) which sends logs to a Logstash instance.

## Installation and Setup

1. Include the package as a Git dependency:

```yaml
dependencies:
  # ...
  lumberdash: ^2.1.1 # Required for Flogged to work
  flogged:
    git: git@github.com:netsells/flogged
```

2. Set up your `AndroidManifest.xml` file by adding the following to the `application` tag:

```xml
android:usesCleartextTraffic="true"
```

3. Add the following to your `Info.plist` file, being sure to replace example entries:

```plist
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>my.logstash.instance</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
            <key>NSIncludesSubdomains</key>
            <true/>
        </dict>
    </dict>
</dict>
```

4. In `main.dart`, before calling `runApp`, add these lines, replacing example content:

```dart
WidgetsFlutterBinding.ensureInitialized();
putLumberdashToWork(withClients: [
    FloggedLumberdash(
        appName: 'Flogged Test',
        appVersionName: '2.0.0',
        appVersionCode: 234,
        environment: kReleaseMode ? 'production' : 'debug',
        logstashUrl: 'http://my.logstash.instance',
        logstashPort: 5001,
    ),
]);
```

_Use the [`package_info`](https://pub.dev/packages/package_info) package to dynamically retrieve app version information._

5. Log some stuff!
