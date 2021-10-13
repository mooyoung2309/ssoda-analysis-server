import 'package:flutter/material.dart';
import 'package:hashchecker/constants.dart';
import 'package:hashchecker/models/event_rank.dart';
import 'package:number_display/number_display.dart';

import 'components/first_ranking_tile.dart';
import 'components/ranking_tile.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({Key? key}) : super(key: key);

  @override
  _RankingScreenState createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  late List<EventRank> eventRankList;
  final rankingSortDropdownItemList = [
    '객단가 순위',
    '참가자 순위',
    '좋아요 순위',
  ];

  String dropdownValue = '객단가 순위';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(),
        body: SingleChildScrollView(
          child: Column(
            children: List.generate(
              5,
              (index) =>
                  index == 0 ? FirstRankingTile() : RankingTile(ranking: index),
            ),
          ),
        ));
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '이벤트 랭킹',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: kDefaultFontColor),
          ),
          SizedBox(height: kDefaultPadding / 5),
          Text(
            '매일 오전 12:00 마다 업데이트 됩니다',
            style: TextStyle(color: kLiteFontColor, fontSize: 10),
          )
        ],
      ),
      backgroundColor: kScaffoldBackgroundColor,
      elevation: 6,
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Center(
            child: DropdownButton(
                dropdownColor: kScaffoldBackgroundColor.withOpacity(0.9),
                value: dropdownValue,
                icon: const Icon(
                  Icons.format_list_numbered_rounded,
                  color: kDefaultFontColor,
                  size: 20,
                ),
                iconSize: 24,
                elevation: 0,
                style: TextStyle(
                  color: kDefaultFontColor,
                  fontSize: 13,
                ),
                underline: Container(
                  height: 0,
                  color: kDefaultFontColor,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                  });
                },
                items: rankingSortDropdownItemList.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: SizedBox(
                        width: 75,
                        child: Text(
                          value,
                          style:
                              TextStyle(fontSize: 13, color: kDefaultFontColor),
                          textAlign: TextAlign.center,
                        )),
                  );
                }).toList()),
          ),
        )
      ],
    );
  }
}
