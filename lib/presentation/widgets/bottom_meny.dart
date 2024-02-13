import 'package:flutter/material.dart';

import 'package:mukim_app/presentation/widgets/menu_item.dart' as menuitem;

class BottomMent extends StatelessWidget {
  final bool expanded;
  final int index;
  final Map<String, Function()> functions;
  const BottomMent(
      {required this.expanded,
      required this.functions,
      required this.index,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // SharedPreferences.getInstance().then((value) => value.remove('walpaper'));
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: expanded ? 250 : 70,
      decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.vertical(top: Radius.circular(8.0))),
      child: !expanded
          ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              menuitem.MenuItem(
                svg: 'home',
                label: 'Utama',
                onTap: functions['home'],
              ),
              menuitem.MenuItem(
                svg: 'qiblat',
                label: 'Kiblat',
                onTap: functions['qiblat'],
              ),
              menuitem.MenuItem(
                svg: 'quran',
                label: 'Quran',
                onTap: functions['quran'],
              ),
              menuitem.MenuItem(
                svg: 'hadith',
                label: 'Hadith',
                onTap: functions['hadith'],
              ),
            ])
          : Center(
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            menuitem.MenuItem(
                              svg: 'home',
                              label: 'Utama',
                              onTap: functions['home'],
                            ),
                            menuitem.MenuItem(
                              svg: 'qiblat',
                              label: 'Kiblat',
                              onTap: functions['qiblat'],
                            ),
                            menuitem.MenuItem(
                              svg: 'quran',
                              label: 'Quran',
                              onTap: functions['home'],
                            ),
                            menuitem.MenuItem(
                              svg: 'hadith',
                              label: 'Hadith',
                              onTap: functions['quran'],
                            ),
                          ]),
                      const SizedBox(height: 4.0),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            menuitem.MenuItem(
                              svg: 'doa',
                              label: 'Doa',
                              onTap: functions['doa'],
                            ),
                            menuitem.MenuItem(
                              svg: 'article',
                              label: 'Artikel',
                              onTap: functions['article'],
                            ),
                            menuitem.MenuItem(
                              svg: 'donation',
                              label: 'Sumbangan',
                              onTap: functions['donation'],
                            ),
                            menuitem.MenuItem(
                              svg: 'mosque',
                              label: 'Masjid/Surau',
                              onTap: functions['mosque'],
                            ),
                          ]),
                      const SizedBox(height: 4.0),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            menuitem.MenuItem(
                              svg: 'calendar',
                              label: 'Kalendar',
                              onTap: functions['calendar'],
                            ),
                            menuitem.MenuItem(
                              svg: 'remembrance',
                              label: 'Zikir',
                              onTap: functions['remembrance'],
                            ),
                            menuitem.MenuItem(
                              svg: 'restaurant',
                              label: 'Restoran Halal',
                              onTap: functions['restaurant'],
                            ),
                            menuitem.MenuItem(
                              svg: 'sirah',
                              label: 'Sirah',
                              onTap: functions['sirah'],
                            ),
                          ]),
                      const SizedBox(height: 4.0),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            menuitem.MenuItem(
                              svg: 'calendar',
                              label: 'Motivasi',
                              onTap: functions['calendar'],
                            ),
                            menuitem.MenuItem(
                              svg: 'sirah',
                              label: 'Sirah',
                              onTap: functions['sirah'],
                            ),
                            menuitem.MenuItem(
                              svg: 'restaurant',
                              label: 'Restoran Halal',
                              onTap: functions['restaurant'],
                            ),
                            menuitem.MenuItem(
                              svg: 'settings',
                              label: 'Tetapan',
                              onTap: functions['settings'],
                            ),
                          ]),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // _goToSettings(BuildContext context) {
  //   Navigator.of(context)
  //       .push(MaterialPageRoute(builder: (context) => SettingsScreen()));
  // }
}
