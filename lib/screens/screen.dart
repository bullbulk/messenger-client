import 'package:flutter/material.dart';
import 'package:messenger/api/api.dart';
import 'package:messenger/screens/login.dart';

class ActualScreen extends StatelessWidget {
  ActualScreen({Key? key}) : super(key: key);

  ApiClient apiClient = ApiClient();

  @override
  Widget build(BuildContext context) {
    return LoginScreen(apiClient);
  }
}
