import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mukim_app/presentation/screens/settings/settings_screen.dart';
import 'package:mukim_app/providers/theme.dart';
import 'package:provider/provider.dart';

import '../../../business_logic/cubit/subscription/userstate_cubit.dart';

class SubscriptionWebView extends StatefulWidget {
  final int mode;
  final String url;
  final String title;
  final int amount;
  const SubscriptionWebView(
      {Key? key,
      required this.url,
      required this.amount,
      required this.mode,
      required this.title})
      : super(key: key);

  @override
  _SubscriptionWebViewState createState() => _SubscriptionWebViewState();
}

class _SubscriptionWebViewState extends State<SubscriptionWebView> {
  final flutterWebViewPlugin = FlutterWebviewPlugin();
  StreamSubscription? _onDestroy;
  bool notificationShown = false;
  DateTime endDate = DateTime.now();
  final Set<JavascriptChannel> jsChannels = [
    JavascriptChannel(
        name: 'Print',
        onMessageReceived: (JavascriptMessage message) {
          print('!!!!!${message.message}');
        }),
  ].toSet();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // flutterWebViewPlugin.close();

    // Add a listener to on destroy WebView, so you can make came actions.
    _onDestroy = flutterWebViewPlugin.onDestroy.listen((_) {
      print(widget.url);
      print('Destroyed ~~~~~~~ ${widget.mode}   ${widget.mode}');
      if (widget.mode != null && widget.mode == 1) {
        FlutterLocalNotificationsPlugin().show(
          Random().nextInt(pow(2, 31).toInt()),
          'Congratulations!',
          'Your sponsor has been added successfully',
          NotificationDetails(
              android: AndroidNotificationDetails(
                  'high_importance_channel', // id
                  'High Importance Notifications', // title
                  channelDescription: 'your channel description',
                  playSound: true,
                  priority: Priority.high,
                  importance: Importance.high,
                  color: Colors.green,
                  styleInformation: BigTextStyleInformation(''))),
        );
        Navigator.pop(context);
      } else if (widget.mode != null && widget.mode == 2) {
        if (widget.amount == 250) {
          endDate = DateTime.now().add(Duration(days: 30));
        } else if (widget.amount == 1150) {
          endDate = DateTime.now().add(Duration(days: 365));
        } else {
          endDate = DateTime.now().add(Duration(days: 1095));
        }
        print('!!!!! ${widget.amount}');

        BlocProvider.of<UserStateCubit>(context).checkUserFirstState();
      } else {
        Navigator.pop(context);
      }
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
      child:
          BlocConsumer<UserStateCubit, UserState>(listener: (context, state) {
        if (state is LoginState) {
          bool subscribed = state.userStateMap!['subscribed'];
          if (subscribed && !notificationShown) {
            notificationShown = true;
            FlutterLocalNotificationsPlugin().show(
              Random().nextInt(pow(2, 31).toInt()),
              'Congratulations!',
              'Your subscription have Success and Expires at ${DateFormat("dd/MM/yyyy").format(endDate)} based on Subscription',
              NotificationDetails(
                  android: AndroidNotificationDetails(
                      'high_importance_channel', // id
                      'High Importance Notifications', // title
                      channelDescription: 'your channel description',
                      playSound: true,
                      priority: Priority.high,
                      importance: Importance.high,
                      color: Colors.green,
                      styleInformation: BigTextStyleInformation(''))),
            );
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => SettingsScreen(
                          checkSubscription: true,
                        )));
          } else if (widget.mode != null && widget.mode == 1) {
          } else if (!subscribed && !notificationShown) {
            Fluttertoast.showToast(
                msg: 'Payment not completed, Please try again',
                toastLength: Toast.LENGTH_LONG);
            Navigator.pop(context);
          }
        }
      }, builder: (context, state) {
        return WebviewScaffold(
          url: widget.url,
          // javascriptChannels: jsChannels,
          mediaPlaybackRequiresUserGesture: false,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(100),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 100,
              decoration: BoxDecoration(
                  image: new DecorationImage(
                      image: AssetImage(
                        "assets/theme/${theme ?? "default"}/appbar.png",
                      ),
                      fit: BoxFit.cover)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 50, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                        onTap: () {
                          flutterWebViewPlugin.close();
                        },
                        child: Icon(Icons.close_rounded, color: Colors.white)),
                    Expanded(
                      flex: 1,
                      child: Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          withZoom: true,
          withLocalStorage: true,
          hidden: false,
        );
      }),
    );
  }
}
