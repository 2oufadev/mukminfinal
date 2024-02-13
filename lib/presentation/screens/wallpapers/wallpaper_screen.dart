import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukim_app/business_logic/cubit/subscription/userstate_cubit.dart';
import 'package:mukim_app/data/models/wallpaper_model.dart';
import 'package:mukim_app/presentation/screens/settings/naik_taraf.dart';
import 'package:mukim_app/presentation/widgets/ShimmerLayouts/wallpaper_shimmer.dart';
import 'package:mukim_app/resources/Imageresources.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:mukim_app/utils/componants.dart';
import 'package:flutter/material.dart';
import 'package:mukim_app/providers/theme.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mukim_app/utils/get_theme_color.dart';

class WallpaperScreen extends StatefulWidget {
  const WallpaperScreen({Key? key}) : super(key: key);

  @override
  _WallpaperScreenState createState() => _WallpaperScreenState();
}

class _WallpaperScreenState extends State<WallpaperScreen> {
  List<WallPaperModel> wallpapers = [];
  SharedPreferences? pref;
  bool expanded = false;
  bool loading = true;
  bool subscribed = false;
  Map<String, dynamic>? userStateMap;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SharedPreferences.getInstance().then((value) {
      setState(() {
        pref = value;
      });
    });

    getWallPapers();
  }

  getWallPapers() async {
    try {
      String url = 'https://salam.mukminapps.com/api/Wallpaper';
      var result = await http
          .get(Uri.parse(url), headers: {"Accept": "application/json"});
      List responseBody = jsonDecode(result.body);
      wallpapers.add(WallPaperModel(ImageResource.wallBackground, 0));
      responseBody.forEach((element) {
        if (element['status'] == 'enable') {
          wallpapers.add(WallPaperModel(
              'https://salam.mukminapps.com/images/' + element['image'],
              element['order']));
        }

        wallpapers.sort((a, b) => a.order.compareTo(b.order));
      });

      if (mounted) {
        setState(() {
          loading = false;
        });
      }
      return responseBody;
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }

      return e;
    }
  }

  @override
  Widget build(BuildContext context) {
    String theme = Provider.of<ThemeNotifier>(context).appTheme;
    userStateMap = BlocProvider.of<UserStateCubit>(context).checkUserState();
    return SafeArea(
      top: false,
      child: Scaffold(
          backgroundColor: Color.fromRGBO(82, 82, 82, 1),
          appBar: AppBar(
            centerTitle: true,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    "assets/theme/${theme ?? "default"}/appbar.png",
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            title: Text("Tukar Wallpaper"),
          ),
          body:
              BlocBuilder<UserStateCubit, UserState>(builder: (context, state) {
            if (state is LoginState) {
              subscribed = state.userStateMap!['subscribed'];
            }
            return SlidingUpPanel(
              minHeight: 64,
              maxHeight: 265,

              // maxHeight: 265,
              color: Colors.black.withOpacity(0.5),
              panel: bottomNavBarWithOpacity(
                  context: context,
                  loggedIn: state is LoginState
                      ? state.userStateMap!['loggedIn']
                      : false),
              body: pref == null || loading
                  ? WallpaperShimmer()
                  : Column(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: NotificationListener(
                              onNotification: (n) {
                                if (n is ScrollStartNotification) {
                                  setState(() {
                                    expanded = false;
                                  });
                                }
                                return false;
                              },
                              child: GridView.builder(
                                  itemCount: wallpapers.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                    childAspectRatio: 0.5,
                                  ),
                                  itemBuilder: (c, index) {
                                    if (wallpapers[index].img ==
                                        ImageResource.wallBackground) {
                                      return GestureDetector(
                                        onTap: () async {
                                          showDialog(
                                              barrierDismissible: false,
                                              context: context,
                                              builder: (context) {
                                                return Center(
                                                    child: Container(
                                                        height: 30,
                                                        width: 30,
                                                        child:
                                                            CircularProgressIndicator(
                                                                color: getColor(
                                                                    theme))));
                                              });

                                          await pref?.setString(
                                            'walpaper',
                                            ImageResource.wallBackground,
                                          );
                                          await pref?.setString(
                                            'walpaperurl',
                                            ImageResource.wallBackground,
                                          );
                                          Navigator.of(context).pop();
                                          setState(() {});
                                        },
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            border: (pref?.getString(
                                                        'walpaperurl') ==
                                                    wallpapers[index])
                                                ? Border.all(
                                                    width: 4,
                                                    color: Colors.amber,
                                                  )
                                                : null,
                                          ),
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Image.asset(
                                                ImageResource.wallBackground,
                                                fit: BoxFit.cover,
                                              )),
                                        ),
                                      );
                                    } else {
                                      return GestureDetector(
                                        onTap: () async {
                                          if (!subscribed && index > 2) {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        NaikTarafScreen()));
                                          } else {
                                            showDialog(
                                                barrierDismissible: false,
                                                context: context,
                                                builder: (context) {
                                                  return Center(
                                                      child: Container(
                                                          height: 30,
                                                          width: 30,
                                                          child:
                                                              CircularProgressIndicator(
                                                                  color: getColor(
                                                                      theme))));
                                                });
                                            var response = await http.get(
                                                Uri.parse(
                                                    wallpapers[index].img));
                                            var directory =
                                                await getApplicationDocumentsDirectory();
                                            var firstPath =
                                                directory.path + '/images';
                                            var filePathAndName =
                                                directory.path +
                                                    '/images/' +
                                                    wallpapers[index]
                                                        .toString()
                                                        .split('/')
                                                        .last;
                                            await Directory(firstPath)
                                                .create(recursive: true);
                                            File file = File(filePathAndName);
                                            file.writeAsBytesSync(
                                                response.bodyBytes);
                                            await pref?.setString(
                                                'walpaper', filePathAndName);
                                            await pref?.setString('walpaperurl',
                                                wallpapers[index].img);
                                            Navigator.of(context).pop();
                                            setState(() {});
                                          }
                                        },
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            border: (pref?.getString(
                                                        'walpaperurl') ==
                                                    wallpapers[index])
                                                ? Border.all(
                                                    width: 4,
                                                    color: Colors.amber,
                                                  )
                                                : null,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Stack(
                                              children: [
                                                Positioned.fill(
                                                  child: Image.network(
                                                      wallpapers[index].img,
                                                      fit: BoxFit.cover,
                                                      frameBuilder: (context,
                                                          child,
                                                          frame,
                                                          wasSynchronouslyLoaded) {
                                                    if (frame == null) {
                                                      return Shimmer.fromColors(
                                                        enabled: true,
                                                        child: Container(
                                                            color: Color(
                                                                0xFF383838)),
                                                        baseColor:
                                                            Color(0xFF383838),
                                                        highlightColor:
                                                            Color(0xFF484848),
                                                      );
                                                    }

                                                    return child;
                                                  }),
                                                ),
                                                !subscribed && index > 2
                                                    ? Positioned.fill(
                                                        child: Container(
                                                        color:
                                                            Colors.transparent,
                                                        child: Icon(Icons.lock,
                                                            color: Colors.white,
                                                            size: 40),
                                                      ))
                                                    : Container()
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  }),
                            ),
                          ),
                        ),
                        SizedBox(height: 200)
                      ],
                    ),
            );
          })),
    );
  }

  _goToHome() {
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  _goToSettings() {
    Navigator.of(context).pop();
  }
}
