import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:blufi_plugin/blufi_plugin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String contentJson = 'Unknown';

  Map<String, dynamic> scanResult = Map<String, dynamic>();

  @override
  void initState() {
    super.initState();
    initPlatformState();

    BlufiPlugin.instance.onMessageReceived(successCallback: (String? data) {
      print("receive data: $data");
      setState(() {
        contentJson = data!;
        Map<String, dynamic> mapData = json.decode(data);
        if (mapData.containsKey('key')) {
          String key = mapData['key'];
          if (key == 'ble_scan_result') {
            Map<String, dynamic> peripheral = mapData['value'];

            String address = peripheral['address'];
            String name = peripheral['name'];
            // int rssi = peripheral['rssi'];
            // print(rssi);
            scanResult[address] = name;
          }
        }
      });
    },
    errorCallback: (String? error) {

    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String? platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await BlufiPlugin.instance.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            TextButton(onPressed: () async {
              await BlufiPlugin.instance.scanDeviceInfo(filterString: '123456');
            }, child: Text('Scan')),
            TextButton(onPressed: () async {
             await BlufiPlugin.instance.stopScan();
            }, child: Text('Stop Scan')),
            TextButton(onPressed: () async {
             await BlufiPlugin.instance.connectPeripheral(peripheralAddress: scanResult.keys.first);
            }, child: Text('Connect Peripheral')),
            TextButton(onPressed: () async {
             await BlufiPlugin.instance.requestCloseConnection();
            }, child: Text('Close Connect')),
            TextButton(onPressed: () async {
             await BlufiPlugin.instance.configProvision(username: 'ABCXYZ', password: '0913456789');
            }, child: Text('Config Provision')),

            TextButton(onPressed: () async {
              String command ='{"cmd": "wifi_get","dev_sn": "","token": "123","info": {}}';
              await BlufiPlugin.instance.postCustomData(command);
            }, child: Text('Send Custom Data')),

            Text(contentJson ?? '')

          ],
        ),
      ),
    );
  }
}
