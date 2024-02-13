import 'package:flutter/material.dart';
import 'package:mukim_app/presentation/screens/Surah/surah_tajweed.dart';
import 'package:mukim_app/resources/global.dart';
import 'package:mukim_app/utils/app_localization.dart';

class BookmarksCard extends StatelessWidget {
  final int page;
  final int juz;
  final int surahId;
  final String surahName;
  final bool bookmark;
  final List surahs;
  final String surahUrdu;
  final bool moveScroll;
  final String verse;
  const BookmarksCard(
      {Key? key,
      required this.page,
      required this.juz,
      required this.surahName,
      required this.bookmark,
      required this.surahId,
      required this.surahs,
      required this.surahUrdu,
      required this.moveScroll,
      required this.verse})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 15),
        InkWell(
          onTap: () {
            Globals.globalInd = 0;
            Globals.globalIndex = 0;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SurahTajweed.set(
                    surahId.toString(),
                    surahUrdu,
                    surahName,
                    surahs,
                    moveScroll ? moveScroll : null,
                    moveScroll ? verse : null),
              ),
            );
          },
          child: Container(
              child: Row(
            children: [
              Container(
                  child: Icon(bookmark ? Icons.bookmark : Icons.book,
                      color: Colors.white)),
              SizedBox(width: 15),
              Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          child: Text('Surah $surahName',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 18))),
                      SizedBox(height: 5),
                      Container(
                          child: Text(
                              "${AppLocalizations.of(context)!.translate('page')} ${page.toString()}, Juz' ${juz.toString()}",
                              style: TextStyle(
                                color: Colors.white,
                              )))
                    ],
                  )),
              SizedBox(width: 15),
              Container(
                  child: Text(page.toString(),
                      style: TextStyle(color: Colors.white)))
            ],
          )),
        ),
      ],
    );
  }
}
