import 'package:flutter/material.dart';
import 'package:hashchecker/constants.dart';
import 'package:hashchecker/models/event.dart';
import 'package:hashchecker/models/event_report_item.dart';
import 'package:hashchecker/models/store_report_overview.dart';
import 'package:hashchecker/screens/marketing_report/store_report/components/event_report_card.dart';
import 'package:number_display/number_display.dart';

import 'components/custom_sliver_appbar.dart';
import 'components/report_overview.dart';

class StoreReportScreen extends StatefulWidget {
  const StoreReportScreen({Key? key}) : super(key: key);

  @override
  _StoreReportScreenState createState() => _StoreReportScreenState();
}

class _StoreReportScreenState extends State<StoreReportScreen> {
  List<String> eventSortDropdownItemList = [
    '최신 등록 순',
    '높은 객단가 순',
    '낮은 객단가 순',
    '높은 참가자 순',
    '낮은 참가자 순',
    '높은 좋아요 순',
    '낮은 좋아요 순'
  ];

  String dropdownValue = '최신 등록 순';

  final numberDisplay = createDisplay();

  late List<EventReportItem> eventReportList;
  late StoreReportOverview storeReportOverview;

  @override
  void initState() {
    super.initState();
    eventReportList = [
      EventReportItem(
          eventName: '우리가게 SNS 해시태그 이벤트',
          guestPrice: 7,
          joinCount: 839,
          likeCount: 12341,
          rewardNameList: ['콜라', '샌드위치', '3000원 쿠폰'],
          thumbnail: 'assets/images/event1.jpg',
          status: EventStatus.PROCEEDING),
      EventReportItem(
          eventName: '우리가게 7월 한정 쿠폰 이벤트',
          guestPrice: 10,
          joinCount: 423,
          likeCount: 7318,
          rewardNameList: ['5000원 쿠폰', '10000원 쿠폰'],
          thumbnail: 'assets/images/event2.jpg',
          status: EventStatus.ENDED),
    ];

    storeReportOverview = StoreReportOverview(
        guestPrice: 7.13, joinCount: 62345, likeCount: 8201543);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, ext) => [
          CustomSliverAppBar(eventReportList: eventReportList, size: size),
        ],
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 20, 15, 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '종합',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                ),
                SizedBox(height: kDefaultPadding),
                ReportOverview(
                    size: size, storeReportOverview: storeReportOverview),
                SizedBox(height: kDefaultPadding / 3 * 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '이벤트 별 보고서',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                      DropdownButton(
                          dropdownColor: Colors.white.withOpacity(0.9),
                          value: dropdownValue,
                          icon: const Icon(
                            Icons.sort,
                            color: Colors.black87,
                            size: 20,
                          ),
                          iconSize: 24,
                          elevation: 0,
                          style: TextStyle(color: Colors.black87, fontSize: 13),
                          underline: Container(
                            height: 1.2,
                            color: Colors.black87,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              dropdownValue = newValue!;
                            });
                          },
                          items: eventSortDropdownItemList.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: SizedBox(
                                  width: 85,
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.black87),
                                    textAlign: TextAlign.center,
                                  )),
                            );
                          }).toList())
                    ],
                  ),
                ),
                SizedBox(height: kDefaultPadding / 3 * 1),
                Column(
                    children: List.generate(
                  eventReportList.length,
                  (index) => EventReportCard(
                      index: index,
                      size: size,
                      eventReportList: eventReportList,
                      numberDisplay: numberDisplay),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}