import 'package:flutter/material.dart';
import 'package:hashchecker_web/constants.dart';
import 'package:hashchecker_web/models/event.dart';
import 'package:hashchecker_web/models/reward.dart';

class EventHashtags extends StatelessWidget {
  const EventHashtags({
    Key? key,
    required this.data,
  }) : super(key: key);

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('필수 해시태그',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
      SizedBox(height: kDefaultPadding),
      Wrap(
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8.0,
          children: List.generate(
              data['event'].hashtagList.length,
              (index) => Chip(
                    avatar: CircleAvatar(
                      radius: 14,
                      child: Icon(
                        Icons.tag,
                        color: Colors.white,
                        size: 18,
                      ),
                      backgroundColor: Colors.black,
                    ),
                    label: Text(data['event'].hashtagList[index]),
                    labelPadding: const EdgeInsets.fromLTRB(6, 2, 5, 2),
                    elevation: 3.0,
                    backgroundColor: Colors.white,
                  )))
    ]);
  }
}
