import 'package:flutter/material.dart';
import 'package:mukim_app/presentation/screens/Juzuk/juzuk_tajweed.dart';
import 'package:mukim_app/providers/theme.dart';
import 'package:mukim_app/resources/global.dart';
import 'package:provider/provider.dart';
import 'package:mukim_app/utils/get_theme_color.dart';

class JuzukCard extends StatefulWidget {
  final index;
  final data;
  final List? surahs;
  final Function? showQari;
  const JuzukCard({Key? key, this.index, this.data, this.surahs, this.showQari})
      : super(key: key);

  @override
  _JuzukCardState createState() => _JuzukCardState();
}

class _JuzukCardState extends State<JuzukCard> {
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var paranum = 0;
    String theme = Provider.of<ThemeNotifier>(context).appTheme;

    switch (widget.data.toString()) {
      case "Al-Fatihah (1) - Al-Baqarah (141)":
        paranum = 1;
        break;
      case "Al-Baqarah (142) - Al-Baqarah (252)":
        paranum = 2;
        break;
      case "Al-Baqarah (253) - Aali Imran (92)":
        paranum = 3;
        break;
      case "Aali Imran (93) - An-Nisa (23)":
        paranum = 4;
        break;
      case "An-Nisa (24) - An-Nisa (147)":
        paranum = 5;
        break;
      case "An-Nisa (148)- Al-Ma’idah (81)":
        paranum = 6;
        break;
      case "Al-Ma’idah (82)- Al-An’am (110)":
        paranum = 7;
        break;
      case "Al-An’am (111)- Al-A’raf (87)":
        paranum = 8;
        break;
      case "Al-A’raf (88)- Al-Anfal (40)":
        paranum = 9;
        break;
      case "Al-Anfal (41)- At-Taubah (92)":
        paranum = 10;
        break;
      case "At-Taubah (93) - Hud (5)":
        paranum = 11;
        break;
      case "Hud (6) - Yusuf (52)":
        paranum = 12;
        break;
      case "Yusuf (53) - Ibrahim (52)":
        paranum = 13;
        break;
      case "Al-Hijr (1) - An-Nahl (128)":
        paranum = 14;
        break;
      case "Al-Isra (1) - Al-Kahf (74)":
        paranum = 15;
        break;
      case "Al-Kahf (75) - Ta-Ha (135)":
        paranum = 16;
        break;
      case "Al-Anbiya (1) - Al-Haj (78)":
        paranum = 17;
        break;
      case "Al-Mu’minun (1) - Al-Furqan (20)":
        paranum = 18;
        break;
      case "Al-Furqan (21) - An-Naml (55)":
        paranum = 19;
        break;
      case "An-Naml (56) - Al-Ankabut (45)":
        paranum = 20;
        break;
      case "Al-Ankabut (46) - Al-Ahzab (30)":
        paranum = 21;
        break;
      case "Al-Ahzab (31) - Ya-Sin (27)":
        paranum = 22;
        break;
      case "Ya-Sin (28) - Az-Zumar (31)":
        paranum = 23;
        break;
      case "Az-Zumar (32) - Fusilat (46)":
        paranum = 24;
        break;
      case "Fusilat (47) - Al-Jathiyah (37)":
        paranum = 25;
        break;
      case "Al-Ahqaf (1) - Adz-Dzariyah (30)":
        paranum = 26;
        break;
      case "Adz-Dzariyah (31) - Al-Hadid (29)":
        paranum = 27;
        break;
      case "Al-Mujadilah (1) - At-Tahrim (12)":
        paranum = 28;
        break;
      case "Al-Mulk (1) - Al-Mursalat (50)":
        paranum = 29;
        break;
      case "An-Naba (1) - An-Nas (3)":
        paranum = 30;
        break;
    }

    return GestureDetector(
      onTap: () {
        Globals.globalInd = 0;
        Globals.globalIndex = 0;
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  JuzukTajweed.set((paranum).toString(), widget.surahs)),
        ).then((value) {
          if (value != null && value && widget.showQari != null) {
            widget.showQari!();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Column(
          children: [
            Row(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 30,
                  child: Text(
                    paranum.toString(),
                    style:
                        const TextStyle(color: Color(0xff929292), fontSize: 12),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 1.5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.data.toString(),
                        style: TextStyle(
                          color: getColor(theme),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              width: MediaQuery.of(context).size.width - 30,
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
