import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:hashchecker/models/template.dart';
import 'dart:io';

final List<String> templateList = [
  'assets/images/create_event_step_help/draft.png',
  'assets/images/create_event_step_help/draft.png',
  'assets/images/create_event_step_help/draft.png'
];

class EventTemplate extends StatefulWidget {
  Template selectedTemplate;
  EventTemplate({Key? key, required this.selectedTemplate}) : super(key: key);

  @override
  _EventTemplateState createState() => _EventTemplateState();
}

class _EventTemplateState extends State<EventTemplate> {
  final List<Widget> imageSliders = templateList
      .map((item) => Container(
            child: Container(
              margin: EdgeInsets.all(5.0),
              child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  child: Stack(
                    children: <Widget>[
                      Image.file(File(item), fit: BoxFit.cover, width: 1000.0),
                      Positioned(
                        bottom: 0.0,
                        left: 0.0,
                        right: 0.0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color.fromARGB(200, 0, 0, 0),
                                Color.fromARGB(0, 0, 0, 0)
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          child: Text(
                            '${templateList.indexOf(item)}번째 템플릿',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
          ))
      .toList();

  final CarouselController _carouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 300,
          child: CarouselSlider(
            items: imageSliders,
            carouselController: _carouselController,
            options: CarouselOptions(
                enlargeCenterPage: true,
                aspectRatio: 2.0,
                onPageChanged: (index, reason) {
                  setState(() {
                    widget.selectedTemplate.id = index;
                  });
                }),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: templateList.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => _carouselController.animateToPage(entry.key),
              child: Container(
                width: 12.0,
                height: 12.0,
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Theme.of(context).primaryColor)
                        .withOpacity(widget.selectedTemplate.id == entry.key
                            ? 0.9
                            : 0.4)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
