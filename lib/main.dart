// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Local Notifications',
//       theme: ThemeData(
//         primarySwatch: Colors.pink,
//       ),
//       home: NotificationSettingsPage(),
//       debugShowCheckedModeBanner: false, // Remove the debug label
//     );
//   }
// }

// class NotificationSettingsPage extends StatefulWidget {
//   @override
//   _NotificationSettingsPageState createState() =>
//       _NotificationSettingsPageState();
// }

// class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
//   int _selectedGender = 0; // 0 for female, 1 for male
//   TimeOfDay? _selectedTime1;
//   TimeOfDay? _selectedTime2;
//   bool _isTime1Enabled = false;
//   bool _isTime2Enabled = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadPreferences();
//   }

//   _loadPreferences() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _selectedGender = prefs.getInt('selectedGender') ?? 0;
//       _isTime1Enabled = prefs.getBool('isTime1Enabled') ?? false;
//       _isTime2Enabled = prefs.getBool('isTime2Enabled') ?? false;
//       // Load times (use default time if not found)
//       _selectedTime1 = TimeOfDay(
//         hour: prefs.getInt('selectedTime1Hour') ?? 12,
//         minute: prefs.getInt('selectedTime1Minute') ?? 0,
//       );
//       _selectedTime2 = TimeOfDay(
//         hour: prefs.getInt('selectedTime2Hour') ?? 12,
//         minute: prefs.getInt('selectedTime2Minute') ?? 0,
//       );
//     });
//   }

//   _savePreferences() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.setInt('selectedGender', _selectedGender);
//     prefs.setBool('isTime1Enabled', _isTime1Enabled);
//     prefs.setBool('isTime2Enabled', _isTime2Enabled);
//     if (_selectedTime1 != null) {
//       prefs.setInt('selectedTime1Hour', _selectedTime1!.hour);
//       prefs.setInt('selectedTime1Minute', _selectedTime1!.minute);
//     }
//     if (_selectedTime2 != null) {
//       prefs.setInt('selectedTime2Hour', _selectedTime2!.hour);
//       prefs.setInt('selectedTime2Minute', _selectedTime2!.minute);
//     }
//   }

//   _pickTime(int timeIndex) async {
//     TimeOfDay? pickedTime = await showTimePicker(
//       context: context,
//       initialTime: timeIndex == 1
//           ? _selectedTime1 ?? TimeOfDay.now()
//           : _selectedTime2 ?? TimeOfDay.now(),
//     );
//     if (pickedTime != null) {
//       setState(() {
//         if (timeIndex == 1) {
//           _selectedTime1 = pickedTime;
//         } else {
//           _selectedTime2 = pickedTime;
//         }
//         _savePreferences();
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Local Notifications'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Select Gender', style: TextStyle(fontSize: 18)),
//             Row(
//               children: [
//                 Expanded(
//                   child: RadioListTile(
//                     contentPadding:EdgeInsets.zero,
//                     title: Row(
//                       children: [
//                         Icon(Icons.female, color: Colors.pink),
//                         SizedBox(width: 10),
//                         Text('Female'),
//                       ],
//                     ),
//                     value: 0,
//                     groupValue: _selectedGender,
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedGender = value as int;
//                         _savePreferences();
//                       });
//                     },
//                   ),
//                 ),
//                 Expanded(
//                   child: RadioListTile(
//                     title: Row(
//                       children: [
//                         Icon(Icons.male, color: Colors.blue),
//                         SizedBox(width: 10),
//                         Text('Male'),
//                       ],
//                     ),
//                     value: 1,
//                     groupValue: _selectedGender,
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedGender = value as int;
//                         _savePreferences();
//                       });
//                     },
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 20),
//             Row(
//               children: [
//                 Checkbox(
//                   value: _isTime1Enabled,
//                   onChanged: (value) {
//                     setState(() {
//                       _isTime1Enabled = value!;
//                       _savePreferences();
//                     });
//                   },
//                 ),
//                 Expanded(
//                   child: ListTile(
//                     title: Text('Time 1'),
//                     subtitle:
//                     Text(_selectedTime1?.format(context) ?? 'Not set'),
//                     onTap: () => _pickTime(1),
//                   ),
//                 ),
//               ],
//             ),
//             Row(
//               children: [
//                 Checkbox(
//                   value: _isTime2Enabled,
//                   onChanged: (value) {
//                     setState(() {
//                       _isTime2Enabled = value!;
//                       _savePreferences();
//                     });
//                   },
//                 ),
//                 Expanded(
//                   child: ListTile(
//                     title: Text('Time 2'),
//                     subtitle:
//                     Text(_selectedTime2?.format(context) ?? 'Not set'),
//                     onTap: () => _pickTime(2),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationController.initializeLocalNotifications();
  await NotificationController.initializeIsolateReceivePort();
  runApp(const MyApp());
}

class NotificationController {
  static ReceivedAction? initialAction;
  static void showScheduledNotification() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: -1,
          channelKey: 'alerts',
          title: 'Scheduled Notification',
          body: 'This is your scheduled notification!',
          notificationLayout: NotificationLayout.Default),
    );
  }

  static Future<void> initializeLocalNotifications() async {
    await AwesomeNotifications().initialize(
        null, //'resource://drawable/res_app_icon',//
        [
          NotificationChannel(
              channelKey: 'alerts',
              channelName: 'Alerts',
              channelDescription: 'Notification tests as alerts',
              playSound: true,
              onlyAlertOnce: true,
              groupAlertBehavior: GroupAlertBehavior.Children,
              importance: NotificationImportance.High,
              defaultPrivacy: NotificationPrivacy.Private,
              defaultColor: Colors.deepPurple,
              ledColor: Colors.deepPurple)
        ],
        debug: true);

    // Get initial notification action is optional
    initialAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: false);
  }

  static ReceivePort? receivePort;
  static Future<void> initializeIsolateReceivePort() async {
    receivePort = ReceivePort('Notification action port in main isolate')
      ..listen(
          (silentData) => onActionReceivedImplementationMethod(silentData));

    IsolateNameServer.registerPortWithName(
        receivePort!.sendPort, 'notification_action_port');
  }

  static Future<void> startListeningNotificationEvents() async {
    AwesomeNotifications()
        .setListeners(onActionReceivedMethod: onActionReceivedMethod);
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (receivedAction.actionType == ActionType.SilentAction ||
        receivedAction.actionType == ActionType.SilentBackgroundAction) {
      // For background actions, you must hold the execution until the end
      print(
          'Message sent via notification input: "${receivedAction.buttonKeyInput}"');
      await executeLongTaskInBackground();
    } else {
      // this process is only necessary when you need to redirect the user
      // to a new page or use a valid context, since parallel isolates do not
      // have valid context, so you need redirect the execution to main isolate
      if (receivePort == null) {
        print(
            'onActionReceivedMethod was called inside a parallel dart isolate.');
        SendPort? sendPort =
            IsolateNameServer.lookupPortByName('notification_action_port');

        if (sendPort != null) {
          print('Redirecting the execution to main isolate process.');
          sendPort.send(receivedAction);
          return;
        }
      }

      return onActionReceivedImplementationMethod(receivedAction);
    }
  }

  static Future<void> onActionReceivedImplementationMethod(
      ReceivedAction receivedAction) async {
    MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/notification-page',
        (route) =>
            (route.settings.name != '/notification-page') || route.isFirst,
        arguments: receivedAction);
  }

  static Future<bool> displayNotificationRationale() async {
    bool userAuthorized = false;
    BuildContext context = MyApp.navigatorKey.currentContext!;
    await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('Get Notified!',
                style: Theme.of(context).textTheme.titleLarge),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Image.asset(
                        'assets/images/animated-bell.gif',
                        height: MediaQuery.of(context).size.height * 0.3,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                    'Allow Awesome Notifications to send you beautiful notifications!'),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'Deny',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.red),
                  )),
              TextButton(
                  onPressed: () async {
                    userAuthorized = true;
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'Allow',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.deepPurple),
                  )),
            ],
          );
        });
    return userAuthorized &&
        await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  static Future<void> executeLongTaskInBackground() async {
    print("starting long task");
    await Future.delayed(const Duration(seconds: 4));
    final url = Uri.parse("http://google.com");
    print("long task done");
  }

  static Future<void> createNewNotification() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) isAllowed = await displayNotificationRationale();
    if (!isAllowed) return;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: -1,
          channelKey: 'alerts',
          title: 'Huston! The eagle has landed!',
          body:
              "A small step for a man, but a giant leap to Flutter's community!",
          notificationLayout: NotificationLayout.BigPicture,
          payload: {'notificationId': '1234567890'}),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Color mainColor = const Color(0xFF9D50DD);

  @override
  State<MyApp> createState() => _AppState();
}

class _AppState extends State<MyApp> {
  static const String routeHome = '/', routeNotification = '/notification-page';

  @override
  void initState() {
    NotificationController.startListeningNotificationEvents();
    super.initState();
  }

  List<Route<dynamic>> onGenerateInitialRoutes(String initialRouteName) {
    List<Route<dynamic>> pageStack = [];
    pageStack.add(MaterialPageRoute(
        builder: (_) =>
            const MyHomePage(title: 'Awesome Notifications Example App')));
    if (initialRouteName == routeNotification &&
        NotificationController.initialAction != null) {}
    return pageStack;
  }

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case routeHome:
        return MaterialPageRoute(
            builder: (_) =>
                const MyHomePage(title: 'Awesome Notifications Example App'));

      case routeNotification:
        ReceivedAction receivedAction = settings.arguments as ReceivedAction;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Awesome Notifications - Simple Example',
      navigatorKey: MyApp.navigatorKey,
      onGenerateInitialRoutes: onGenerateInitialRoutes,
      onGenerateRoute: onGenerateRoute,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedGender = 0; // 0 for female, 1 for male
  TimeOfDay? _selectedTime1;
  TimeOfDay? _selectedTime2;
  bool _isTime1Enabled = false;
  bool _isTime2Enabled = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedGender = prefs.getInt('selectedGender') ?? 0;
      _isTime1Enabled = prefs.getBool('isTime1Enabled') ?? false;
      _isTime2Enabled = prefs.getBool('isTime2Enabled') ?? false;
      // Load times (use default time if not found)
      _selectedTime1 = TimeOfDay(
        hour: prefs.getInt('selectedTime1Hour') ?? 12,
        minute: prefs.getInt('selectedTime1Minute') ?? 0,
      );
      _selectedTime2 = TimeOfDay(
        hour: prefs.getInt('selectedTime2Hour') ?? 12,
        minute: prefs.getInt('selectedTime2Minute') ?? 0,
      );
    });
  }

  _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('selectedGender', _selectedGender);
    prefs.setBool('isTime1Enabled', _isTime1Enabled);
    prefs.setBool('isTime2Enabled', _isTime2Enabled);
    if (_selectedTime1 != null) {
      prefs.setInt('selectedTime1Hour', _selectedTime1!.hour);
      prefs.setInt('selectedTime1Minute', _selectedTime1!.minute);
    }
    if (_selectedTime2 != null) {
      prefs.setInt('selectedTime2Hour', _selectedTime2!.hour);
      prefs.setInt('selectedTime2Minute', _selectedTime2!.minute);
    }
  }

  _pickTime(int timeIndex) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: timeIndex == 1
          ? _selectedTime1 ?? TimeOfDay.now()
          : _selectedTime2 ?? TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        if (timeIndex == 1) {
          _selectedTime1 = pickedTime;
        } else {
          _selectedTime2 = pickedTime;
        }
        _savePreferences();
      });
    }
  }

  void _scheduleNotification(int id, TimeOfDay selectedTime) async {
    final now = DateTime.now();
    DateTime scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await AndroidAlarmManager.oneShotAt(
      scheduledTime,
      id,
      NotificationController.showScheduledNotification,
      exact: true,
      wakeup: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Gender', style: TextStyle(fontSize: 18)),
            Row(
              children: [
                Expanded(
                  child: RadioListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Row(
                      children: [
                        Icon(Icons.female, color: Colors.pink),
                        SizedBox(width: 10),
                        Text('Female'),
                      ],
                    ),
                    value: 0,
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value as int;
                        _savePreferences();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile(
                    title: Row(
                      children: [
                        Icon(Icons.male, color: Colors.blue),
                        SizedBox(width: 10),
                        Text('Male'),
                      ],
                    ),
                    value: 1,
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value as int;
                        _savePreferences();
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: _isTime1Enabled,
                  onChanged: (value) {
                    setState(() {
                      _isTime1Enabled = value!;
                      _savePreferences();
                    });
                  },
                ),
                Expanded(
                  child: ListTile(
                    title: Text('Time 1'),
                    subtitle:
                        Text(_selectedTime1?.format(context) ?? 'Not set'),
                    onTap: () => _pickTime(1),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: _isTime2Enabled,
                  onChanged: (value) {
                    setState(() {
                      _isTime1Enabled = value!;
                      if (_isTime1Enabled && _selectedTime1 != null) {
                        _scheduleNotification(1, _selectedTime1!);
                      }
                      _savePreferences();
                    });
                  },
                ),
                Expanded(
                  child: ListTile(
                    title: Text('Time 2'),
                    subtitle:
                        Text(_selectedTime2?.format(context) ?? 'Not set'),
                    onTap: () => _pickTime(2),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 20),
            FloatingActionButton(
              heroTag: '1',
              onPressed: () => NotificationController.createNewNotification(),
              tooltip: 'Create New notification',
              child: const Icon(Icons.outgoing_mail),
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
