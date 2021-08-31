import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:messenger/api/api.dart';
import 'package:messenger/screens/chats/screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen(this.apiClient, {Key? key}) : super(key: key);

  final ApiClient apiClient;

  @override
  _SignupScreenState createState() => _SignupScreenState(apiClient);
}

class _SignupScreenState extends State<SignupScreen> {
  late ApiClient apiClient;

  _SignupScreenState(this.apiClient);

  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _pwdController = TextEditingController();

  var _passwordVisible = true;

  final _formNicknameKey = GlobalKey<FormFieldState>();
  final _formLoginKey = GlobalKey<FormFieldState>();
  final _formPasswordKey = GlobalKey<FormFieldState>();

  bool nicknameAlreadyExists = false;
  bool emailAlreadyExists = false;

  Future<void> register() async {
    if (!(_formLoginKey.currentState!.validate() &&
        _formPasswordKey.currentState!.validate())) {
      return;
    }
    var res = await apiClient.signup(
        _nicknameController.text, _emailController.text, _pwdController.text);
    var statusCode = res['status_code'];
    if (statusCode == 409) {
      if (res['reason'] == 'email') {
        emailAlreadyExists = true;
      }
      if (res['reason'] == 'nickname') {
        nicknameAlreadyExists = true;
      }
      _formNicknameKey.currentState!.validate();
      _formLoginKey.currentState!.validate();
    } else if (statusCode == 200) {
      res = await apiClient.login(
          _emailController.text, _pwdController.text);
      statusCode = res['status_code'];
      if (statusCode == 200) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ChatsScreen(apiClient)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Sign Up'),
        ),
        body: Center(
          child: Padding(
              padding: const EdgeInsets.all(15),
              child: Form(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                    TextFormField(
                      key: _formNicknameKey,
                      validator: (value) {
                        if (nicknameAlreadyExists) {
                          return 'User with this nickname already exists';
                        }
                      },
                      onChanged: (_) {
                        if (nicknameAlreadyExists) {
                          _formNicknameKey.currentState!.validate();
                          nicknameAlreadyExists = false;
                        }
                      },
                      controller: _nicknameController,
                      decoration: const InputDecoration(
                          labelText: 'Nickname',
                          icon: Padding(
                            padding: EdgeInsets.only(top: 15.0),
                            child: Icon(Icons.account_circle),
                          )),
                      onFieldSubmitted: (_) async => await register(),
                    ),
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
                              if (emailAlreadyExists) {
                                return 'Email already registered';
                              }

                              if (!EmailValidator.validate(value)) {
                                return 'Please enter valid email';
                              }
                            },
                            onChanged: (value) {
                              emailAlreadyExists = false;
                              if (EmailValidator.validate(value)) {
                                _formLoginKey.currentState!.validate();
                              }
                            },
                            onFieldSubmitted: (_) async => await register(),
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              icon: Padding(
                                  padding: EdgeInsets.only(top: 15.0),
                                  child: Icon(Icons.alternate_email)),
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters long';
                          }
                        },
                        onChanged: (value) {
                          if (value.length >= 8) {
                            _formPasswordKey.currentState!.validate();
                          }
                        },
                        onFieldSubmitted: (_) async => await register(),
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
                          await register();
                        },
                        child: const Text('Sign up',
                            style: TextStyle(fontSize: 20)),
                      ),
                    )
                  ]))),
        ));
  }
}
