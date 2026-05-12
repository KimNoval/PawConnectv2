import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/colors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifications = true;
  bool _rememberMe = true;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _initializeNotifications();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notifications = prefs.getBool('notifications') ?? true;
      _rememberMe = prefs.getBool('remember_me') ?? true;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _notificationsPlugin.initialize(initializationSettings);
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.notification.request();
  }

  Future<void> _showTestNotification() async {
    if (!_notifications) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable notifications first')),
      );
      return;
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'paw_connect_channel',
          'PawConnect Notifications',
          channelDescription: 'Notifications from PawConnect app',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      0,
      'PawConnect',
      'This is a test notification! 🐾',
      platformChannelSpecifics,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCard([
              SwitchListTile(
                secondary: const Icon(
                  Icons.notifications,
                  color: AppColors.primary,
                ),
                title: const Text('Notifications'),
                subtitle: const Text('Get app notifications'),
                value: _notifications,
                onChanged: (value) async {
                  setState(() => _notifications = value);
                  await _saveSetting('notifications', value);

                  if (value) {
                    await _requestPermissions();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notifications enabled! 🐾'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notifications disabled'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
                activeColor: AppColors.primary,
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(
                  Icons.remember_me,
                  color: AppColors.primary,
                ),
                title: const Text('Remember Me'),
                subtitle: const Text('Keep you logged in'),
                value: _rememberMe,
                onChanged: (value) {
                  setState(() => _rememberMe = value);
                  _saveSetting('remember_me', value);
                },
                activeColor: AppColors.primary,
              ),
            ]),
            const SizedBox(height: 24),

            _buildCard([
              ListTile(
                leading: const Icon(
                  Icons.notifications_active,
                  color: AppColors.primary,
                ),
                title: const Text('Test Notification'),
                subtitle: const Text('Send a test notification'),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                ),
                onTap: () => _showTestNotification(),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.clear, color: AppColors.primary),
                title: const Text('Clear Cache'),
                subtitle: const Text('Remove temporary files'),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                ),
                onTap: () => _clearCache(),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Sign Out'),
                subtitle: const Text('Sign out of your account'),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                ),
                onTap: () => _signOut(),
              ),
            ]),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(children: children),
    );
  }

  void _clearCache() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cache cleared!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _signOut() {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}
