import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:messenger/api/socket/controller.dart';
import 'package:path_provider/path_provider.dart';

import 'password.dart';
import 'device_id.dart';
import 'config.dart' as config;

class ApiClient {
  var client = http.Client();
  var host = Uri.parse(config.host);
  late SocketController socket;

  late int userId;

  String? accessToken;

  ApiClient() {
    getApplicationDocumentsDirectory().then((p) => {Hive.init(p.path)});
  }

  static Future<String?> get fingerprint async {
    return await getDeviceID();
  }

  Future<Map<String, dynamic>> signup(
      String nickname, String email, String password) async {
    var payload = {
      'nickname': nickname,
      'email': email,
      'password': encryptPassword(password),
    };

    var uri = host.replace(path: '/users/register');

    var res = await client.post(uri,
        body: json.encode(payload),
        headers: {'Content-Type': 'application/json'});
    print(res.body);
    return json.decode(res.body);
  }

  Future<Map<String, dynamic>> login(
      String email, String password) async {
    var payload = {
      'fingerprint': await fingerprint,
      'email': email,
      'password': encryptPassword(password)
    };

    var uri = host.replace(path: '/users/login');

    var res = await client.post(uri,
        body: json.encode(payload),
        headers: {'Content-Type': 'application/json'});

    if (res.statusCode == 200) {
      var json = jsonDecode(res.body);
      await saveTokens(json);

      var userDataBox = await Hive.openBox('user_data');
      userDataBox.put('is_logged_in', true);
      socket = SocketController(json['user_id']);
      userId = json['user_id'];
    }
    return json.decode(res.body);
  }

  Future<Map<String, dynamic>> createChat(List<int> ids) async {
    var payload = {
      'members_id': ids,
      'access_token': accessToken,
    };
    var uri = host.replace(path: '/chats/create');

    var res = await client.post(uri,
        body: json.encode(payload),
        headers: {'Content-Type': 'application/json'});
    if (res.statusCode == 401) {
      updateAccessToken();
      createChat(ids);
    }
    return json.decode(res.body);
  }

  Future<Map<String, dynamic>> sendMessage(String text, int chatId) async {
    var payload = {
      'text': text,
      'chat_id': chatId,
      'access_token': accessToken,
      'author_id': userId
    };

    var uri = host.replace(path: '/messages/send');
    var res = await client.post(uri,
        body: json.encode(payload),
        headers: {'Content-Type': 'application/json'});
    if (res.statusCode == 401) {
      updateAccessToken();
      sendMessage(text, chatId);
    }
    return json.decode(res.body);
  }

  Future<Map<String, dynamic>?> getAccessToken() async {
    var userDataBox = await Hive.openBox('user_data');

    var refreshToken = userDataBox.get('refresh_token');

    var uri = host.replace(path: '/users/update_session');

    var res = await client.post(uri,
        body: json.encode({'refresh_token': refreshToken}),
        headers: {'Content-Type': 'application/json'});

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
  }

  Future<bool> updateAccessToken() async {
    var res = await getAccessToken();
    if (res == null) {
      return false;
    }
    await saveTokens(res);
    return true;
  }

  Future<void> saveTokens(Map<String, dynamic> data) async {
    accessToken = data['access_token'];
    var userDataBox = await Hive.openBox('user_data');

    userDataBox.put('refresh_token', data['refresh_token']);
    userDataBox.put('access_token', data['access_token']);
  }
}
