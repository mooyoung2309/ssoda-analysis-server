import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hashchecker_web/api.dart';
import 'package:hashchecker_web/models/event.dart';
import 'package:hashchecker_web/models/reward.dart';
import 'components/body.dart';
import 'package:http/http.dart' as http;

class EventJoinScreen extends StatefulWidget {
  final id;
  const EventJoinScreen({Key? key, this.id}) : super(key: key);

  @override
  _EventJoinScreenState createState() => _EventJoinScreenState();
}

class _EventJoinScreenState extends State<EventJoinScreen> {
  late Future<Map<String, dynamic>> data;

  @override
  void initState() {
    super.initState();
    data = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder<dynamic>(
      future: data,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Body(data: snapshot.data!);
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        // By default, show a loading spinner.
        return Center(child: const CircularProgressIndicator());
      },
    ));
  }

  Future<Map<String, dynamic>> fetchData() async {
    Map<String, dynamic> fetchedData = {};

    final eventResponse = await http
        .get(Uri.parse(getApi(API.GET_EVENT, parameter: widget.id)), headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "POST, GET, OPTIONS, PUT, DELETE, HEAD",
    });

    if (eventResponse.statusCode == 200) {
      fetchedData['event'] =
          Event.fromJson(jsonDecode(utf8.decode(eventResponse.bodyBytes)));

      final rewardsResponse = await http.get(
          Uri.parse(
              'http://ec2-3-37-85-236.ap-northeast-2.compute.amazonaws.com:8080/api/v1/events/${widget.id}/rewards'),
          headers: {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods":
                "POST, GET, OPTIONS, PUT, DELETE, HEAD",
          });
      if (rewardsResponse.statusCode == 200) {
        fetchedData['rewards'] = [];

        List<dynamic> rewards =
            jsonDecode(utf8.decode(rewardsResponse.bodyBytes));

        rewards.map((reward) {
          fetchedData['rewards'].add(Reward.fromJson(reward));
        });

        return fetchedData;
      } else {
        throw Exception('이벤트 보상 정보를 불러올 수 없습니다.');
      }
    } else {
      throw Exception('존재하지 않는 이벤트입니다.');
    }
  }
}
