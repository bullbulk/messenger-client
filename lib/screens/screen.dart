import 'package:flutter/material.dart';
import 'package:messenger/api/api.dart';
import 'package:messenger/screens/chats/screen.dart';
import 'package:messenger/screens/login.dart';

class ActualScreen extends StatefulWidget {
  ActualScreen({Key? key}) : super(key: key);

  final ApiClient apiClient = ApiClient();

  @override
  _ActualScreenState createState() => _ActualScreenState(apiClient);
}

class _ActualScreenState extends State<ActualScreen> {
  _ActualScreenState(this.apiClient);

  late ApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    return apiClient.checkCredentialsSync()
        ? ChatsScreen(apiClient)
        : LoginScreen(apiClient);
  }
}
