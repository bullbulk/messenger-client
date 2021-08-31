import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;

String encryptPassword(String pwd) {
  return crypto.md5
      .convert(utf8.encode(pwd))
      .toString()
      .toLowerCase();
}