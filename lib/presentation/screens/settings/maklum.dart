import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:mukim_app/presentation/screens/settings/settings_screen.dart';
import 'package:mukim_app/providers/theme.dart';
import 'package:mukim_app/utils/get_theme_color.dart';
import 'package:provider/provider.dart';

class Maklum extends StatefulWidget {
  const Maklum({
    Key? key,
  }) : super(key: key);

  @override
  _MaklumState createState() => _MaklumState();
}

class _MaklumState extends State<Maklum> {
  final flutterWebViewPlugin = FlutterWebviewPlugin();
  StreamSubscription? _onDestroy;

  final Set<JavascriptChannel> jsChannels = [
    JavascriptChannel(
        name: 'Print',
        onMessageReceived: (JavascriptMessage message) {
          print(message.message);
        }),
  ].toSet();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    flutterWebViewPlugin.close();

    // Add a listener to on destroy WebView, so you can make came actions.
    _onDestroy = flutterWebViewPlugin.onDestroy.listen((_) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => SettingsScreen(checkSubscription: true)));
    });
  }

  @override
  void dispose() {
    _onDestroy?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String theme = Provider.of<ThemeNotifier>(context).appTheme;

    return WillPopScope(
      onWillPop: () async {
        flutterWebViewPlugin.close();

        return false;
      },
      child: WebviewScaffold(
        url:
            "https://docs.google.com/forms/d/e/1FAIpQLSeneim4dxAa5PBllw_SllxlS_tCAkt1mtaN5x1CfO0b_W9bYA/viewform?embedded=true",
        javascriptChannels: jsChannels,
        mediaPlaybackRequiresUserGesture: false,
        appBar: AppBar(
          leading: InkWell(
              onTap: () {
                flutterWebViewPlugin.close();
              },
              child: Icon(Icons.close_rounded)),
          title: Text("Maklum Balas"),
          backgroundColor: getColor(theme),
        ),
        withZoom: true,
        withLocalStorage: true,
        hidden: false,
      ),
    );
  }
}
