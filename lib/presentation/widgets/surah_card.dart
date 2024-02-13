import 'package:flutter/material.dart';
import 'package:mukim_app/presentation/screens/Surah/surah_tajweed.dart';
import 'package:mukim_app/providers/theme.dart';
import 'package:mukim_app/resources/global.dart';
import 'package:mukim_app/utils/get_theme_color.dart';
import 'package:provider/provider.dart';

class SurahCard extends StatefulWidget {
  final data;
  final urduName;
  final surahs;
  final Function? showQari;

  const SurahCard(
      {Key? key, this.data, this.urduName, this.surahs, this.showQari})
      : super(key: key);

  @override
  _SurahCardState createState() => _SurahCardState();
}

class _SurahCardState extends State<SurahCard> {
  bool downloading = false;
  bool loading = true;
  bool loadingIcon = true;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String theme = Provider.of<ThemeNotifier>(context).appTheme;
    return GestureDetector(
      onTap: () {
        Globals.globalInd = 0;
        Globals.globalIndex = 0;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SurahTajweed.set(
                widget.data['id'].toString(),
                widget.urduName,
                widget.data['name']['simple'].trim(),
                widget.surahs,
                null,
                null),
          ),
        ).then((value) {
          if (value != null && value && widget.showQari != null) {
            widget.showQari!();
          }
        });
      },
      child: Container(
        height: 102,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 30,
                  child: Text(
                    widget.data['id'].toString(),
                    style:
                        const TextStyle(color: Color(0xff929292), fontSize: 12),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.data['name']['simple'].trim(),
                          style: TextStyle(
                            color: getColor(theme),
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Text(
                        widget.data['revelation']['place'] +
                            '. ' +
                            widget.data['ayat'].toString() +
                            'Ayat',
                        style: const TextStyle(
                            color: Color(0xff929292), fontSize: 10),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: Text(
                    widget.urduName,
                    style: TextStyle(
                      color: getColor(theme),
                      fontSize: 70,
                      fontFamily: 'Quran',
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
                SizedBox(width: 5),
              ],
            ),
            Spacer(),
            Container(
              width: MediaQuery.of(context).size.width - 50,
              height: 0.5,
              decoration: const BoxDecoration(
                color: Color(0xff929292),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
