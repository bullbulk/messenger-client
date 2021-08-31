import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:messenger/api/api.dart';
import 'package:messenger/screens/chats/screen.dart';
import 'package:messenger/screens/signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen(this.apiClient, {Key? key, this.title}) : super(key: key);

  final String? title;
  final ApiClient apiClient;

  @override
  _LoginScreenState createState() => _LoginScreenState(apiClient);
}

class _LoginScreenState extends State<LoginScreen> {
  late ApiClient apiClient;

  _LoginScreenState(this.apiClient);

  late TextEditingController _mailController;
  late TextEditingController _pwdController;

  var _passwordVisible = true;
  final _formLoginKey = GlobalKey<FormFieldState>();
  final _formPasswordKey = GlobalKey<FormFieldState>();

  var isPasswordIncorrect = false;
  var isUserNotExists = false;

  Future<void> auth() async {
    var res =
        await apiClient.login(_mailController.text, _pwdController.text);

    int statusCode = res['status_code'];

    switch (statusCode) {
      case 404:
        {
          isUserNotExists = true;
          _formLoginKey.currentState!.validate();
          break;
        }
      case 401:
        {
          isPasswordIncorrect = true;
          break;
        }
      case 200:
        {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ChatsScreen(apiClient)));
          break;
        }
      default:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _mailController = TextEditingController();
    _pwdController = TextEditingController();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _mailController.dispose();
    _pwdController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (_formLoginKey.currentState!.validate() &&
        _formPasswordKey.currentState!.validate()) {
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.
      await auth();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
        ),
        body: Center(
          child: Padding(
              padding: const EdgeInsets.all(15),
              child: Form(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                    const Spacer(),
                    FocusScope(
                        onFocusChange: (v) {
                          if (v) {
                            return;
                          }
                          _formLoginKey.currentState != null &&
                              _formLoginKey.currentState!.validate();
                        },
                        child: TextFormField(
                            key: _formLoginKey,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              if (isUserNotExists) {
                                return 'User does not exists';
                              }
                              if (!EmailValidator.validate(value)) {
                                return 'Please enter valid email';
                              }
                            },
                            onChanged: (value) {
                              isUserNotExists = false;
                              if (EmailValidator.validate(value)) {
                                _formLoginKey.currentState!.validate();
                              }
                            },
                            onFieldSubmitted: (_) async => await login(),
                            controller: _mailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              icon: Padding(
                                padding: EdgeInsets.only(top: 15.0),
                                child: Icon(Icons.alternate_email),
                              ),
                            ))),
                    FocusScope(
                      onFocusChange: (v) {
                        if (v) {
                          return;
                        }
                        _formPasswordKey.currentState != null &&
                            _formPasswordKey.currentState!.validate();
                      },
                      child: TextFormField(
                        key: _formPasswordKey,
                        autocorrect: false,
                        cursorColor: Colors.white,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          if (isPasswordIncorrect) {
                            return 'Password incorrect';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters long';
                          }
                        },
                        onChanged: (value) {
                          isPasswordIncorrect = false;
                          if (value.length >= 8) {
                            _formPasswordKey.currentState!.validate();
                          }
                        },
                        onFieldSubmitted: (_) async => await login(),
                        controller: _pwdController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          icon: const Padding(
                              padding: EdgeInsets.only(top: 15.0),
                              child: Icon(Icons.lock)),
                          suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Theme.of(context).primaryColorLight,
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              }),
                        ),
                        obscureText: _passwordVisible,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: TextButton(
                        onPressed: () async {
                          await login();
                        },
                        child:
                            const Text('Login', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      SignupScreen(apiClient)));
                        },
                        child: const Text('Sign up',
                            style: TextStyle(
                              fontSize: 14,
                            )))
                  ]))),
        ));
  }
}
