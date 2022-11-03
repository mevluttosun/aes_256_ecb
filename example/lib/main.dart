import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:aes_ecb_pkcs5_flutter/aes_ecb_pkcs5_flutter.dart';
import 'package:convert/convert.dart';
void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String pkcs5Progress;

    //string format
    var data = hex.encode([99, 99, 121, 119, 233, 9, 140, 117, 127, 45, 1, 1, 0, 0, 0, 0]);
    print('data = $data');
    //create 16 byte random key
    // var key = hex.encode([12,34,56,78,12,34,56,78,32,34,56,78,12,34,56,78,12,34,56,78,12,34,56,78,32,34,56,78,12,34,56,78]);
    var key = "afae0029348ee9098c757f2d66796263aa65be6c6c95c9574049d54ac9f65cd5";
    print('key: $key');
    //encrypt
    var encryptText = await FlutterAesEcbPkcs5.encryptString("13DA6A67C0F7FE572A257260E6DDF3C0", "0c22384e0c22384e2022384e0c22384e0c22384e0c22384e2022384e0c22384e");

    print('encryptText: $encryptText');
    //decrypt
    var decryptText = await FlutterAesEcbPkcs5.decryptString('13DA6A67C0F7FE572A257260E6DDF3C0','0c22384e0c22384e2022384e0c22384e0c22384e0c22384e2022384e0c22384e');

    print('decryptText: ${ hex.encode( utf8.encode(decryptText) )}');

    // pkcs5Progress = "data:" +
    //     data +
    //     "\n" +
    //     "create key:" +
    //     key +
    //     "\n" +
    //     "encryptText :" +
    //     encryptText +
    //     "\n" +
    //     "decryptText :" +
    //     decryptText +
    //     "\n";

    // print(pkcs5Progress);
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    // setState(() {
    //   _platformVersion = pkcs5Progress;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('flutter_aes_ecb_pkcs5'),
        ),
        body: Center(
          child: Text('pkcs5Progress:\n $_platformVersion\n'),
        ),
      ),
    );
  }
}
