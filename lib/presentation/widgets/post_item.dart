import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:mukim_app/business_logic/cubit/bottom_bar/cubit.dart';
import 'package:mukim_app/presentation/screens/doa/Doa_Taubat.dart';
import 'package:mukim_app/presentation/screens/ayat.dart';
import 'package:mukim_app/presentation/screens/hadith/hadeth_detail_screens.dart';
import 'package:mukim_app/presentation/screens/motivasi.dart';
import 'package:mukim_app/presentation/widgets/svg_icon.dart';
import 'package:mukim_app/utils/app_localization.dart';
import 'package:mukim_app/utils/componants.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'package:mukim_app/utils/get_theme_color.dart';
import 'package:mukim_app/providers/theme.dart';

class PostItem extends StatefulWidget {
  final String img, categoryName, reference, description, description2;
  final int type, categoryId;
  final bool loggedIn;
  final bool subscribed;
  final bool loading;
  const PostItem(
      {required this.img,
      required this.categoryName,
      required this.type,
      required this.categoryId,
      required this.reference,
      required this.loading,
      required this.loggedIn,
      required this.subscribed,
      required this.description,
      required this.description2,
      Key? key})
      : super(key: key);

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  @override
  Widget build(BuildContext context) {
    MukminCubit cubit = MukminCubit.getCubitObj(context);
    String theme = Provider.of<ThemeNotifier>(context).appTheme;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.0),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // const SizedBox(height: 8.0),

          Container(
              height: 397,
              color: widget.loading || widget.img.isEmpty
                  ? Colors.transparent
                  : Colors.black,
              child: widget.loading || widget.img.isEmpty
                  ? Shimmer.fromColors(
                      enabled: true,
                      child: Container(color: Color(0xFF383838)),
                      baseColor: Color(0xFF383838),
                      highlightColor: Color(0xFF484848),
                    )
                  : Image.network(
                      widget.img,
                      height: 397,
                      fit: BoxFit.fitHeight,
                      frameBuilder:
                          (context, child, frame, wasSynchronouslyLoaded) {
                        if (frame == null) {
                          return Shimmer.fromColors(
                            enabled: true,
                            child: Container(
                                width: MediaQuery.of(context).size.width,
                                color: Color(0xFF383838)),
                            baseColor: Color(0xFF383838),
                            highlightColor: Color(0xFF484848),
                          );
                        }

                        return child;
                      },
                    )),
          Container(
            color: Colors.black54,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: SvgIcon(
                    svg: widget.type == 1
                        ? 'hadith'
                        : widget.type == 2
                            ? 'quran'
                            : widget.type == 3
                                ? 'doa'
                                : 'motivasi',
                    h: 18,
                    w: 18,
                  ),
                  label: Text(widget.categoryName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      )),
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () async {
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              return Center(
                                  child: Container(
                                      height: 30,
                                      width: 30,
                                      child: CircularProgressIndicator(
                                          color: getColor(theme))));
                            });
                        try {
                          print(widget.description);
                          http.Response response =
                              await http.get(Uri.parse(widget.img));

                          final DynamicLinkParameters dynamicLinkParams =
                              DynamicLinkParameters(
                                  link: Uri.parse(
                                      'https://mukminapps.com/${widget.description2}'),
                                  uriPrefix: "https://mukminapps.page.link",
                                  androidParameters: const AndroidParameters(
                                    packageName:
                                        "com.alamintijarahresources.mukminapps",
                                    minimumVersion: 30,
                                  ),
                                  iosParameters: const IOSParameters(
                                    bundleId:
                                        "com.alamintijarahresources.mukminapps",
                                    appStoreId: "376771144",
                                    minimumVersion: "1.0.1",
                                  ),
                                  socialMetaTagParameters:
                                      SocialMetaTagParameters(
                                    title: '',
                                    description: '',
                                  ));

                          final dynamicLink = await FirebaseDynamicLinks
                              .instance
                              .buildShortLink(dynamicLinkParams);
                          final Uri shortUrl = dynamicLink.shortUrl;

                          await Share.shareXFiles(
                            [
                              XFile.fromData(
                                response.bodyBytes,
                                mimeType: 'image/png',
                              )
                            ],
                            text:
                                widget.description + ' ${shortUrl.toString()}',
                            subject: 'Share Image',
                          );
                          Navigator.pop(context);
                        } catch (e) {
                          print('error: $e');
                          Navigator.pop(context);
                        }
                      },
                      icon: SvgIcon(
                        svg: 'share',
                        shader: false,
                      ),
                      label:
                          Text(AppLocalizations.of(context)!.translate('share'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                              )),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        if (widget.type == 1) {
                          cubit.hadithItemIndex = widget.categoryId;
                          navigateTo(
                              context: context,
                              leftToRightTransasion: true,
                              screen: HadithDetailScreen(
                                widget.categoryId.toString(),
                                widget.categoryName,
                              ));
                        } else if (widget.type == 2) {
                          navigateTo(
                              context: context,
                              leftToRightTransasion: true,
                              screen: AyatScreen());
                        } else if (widget.type == 3) {
                          navigateTo(
                              context: context,
                              leftToRightTransasion: true,
                              screen: Doa_Taubat(
                                  fromHome: true,
                                  screenHeight:
                                      MediaQuery.of(context).size.height,
                                  title: widget.categoryName,
                                  id: widget.categoryId.toString()));
                        } else {
                          navigateTo(
                              context: context,
                              leftToRightTransasion: true,
                              screen: MotivasiScreen());
                        }
                      },
                      icon: SvgIcon(
                        svg: 'more',
                        shader: false,
                      ),
                      label:
                          Text(AppLocalizations.of(context)!.translate('more'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                              )),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
