import 'package:animations/animations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:hashchecker/constants.dart';
import 'package:hashchecker/models/event.dart';
import 'package:hashchecker/models/event_list_item.dart';
import 'package:hashchecker/screens/event_list/components/event_edit_modal.dart';
import 'package:hashchecker/screens/event_list/event_detail/event_detail_screen.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'event_options_modal.dart';

class EventListTile extends StatelessWidget {
  const EventListTile({
    Key? key,
    required this.index,
    required this.size,
    required this.eventList,
    required Map<EventStatus, String> statusStringMap,
    required Map<EventStatus, Color> statusColorMap,
  })  : _statusStringMap = statusStringMap,
        _statusColorMap = statusColorMap,
        super(key: key);

  final Size size;
  final int index;
  final List<EventListItem> eventList;
  final Map<EventStatus, String> _statusStringMap;
  final Map<EventStatus, Color> _statusColorMap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 144,
      child: OpenContainer<bool>(
          openColor: Colors.white.withOpacity(0),
          openElevation: 0,
          openShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12))),
          closedColor: Colors.white.withOpacity(0),
          closedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12))),
          closedElevation: 0,
          transitionType: ContainerTransitionType.fade,
          openBuilder: (context, _) =>
              EventDetailScreen(eventListItem: eventList[index]),
          closedBuilder: (context, openContainer) => Stack(children: [
                Positioned(
                    bottom: 15,
                    right: 20,
                    child: Container(
                        width: size.width * 0.7,
                        height: 100,
                        child: Material(
                          color: Colors.white.withOpacity(0.0),
                          child: InkWell(
                            highlightColor: kShadowColor,
                            overlayColor:
                                MaterialStateProperty.all<Color>(kShadowColor),
                            borderRadius: BorderRadius.circular(12),
                            onTap: openContainer,
                            onLongPress: () => showMaterialModalBottomSheet(
                                backgroundColor: Colors.transparent,
                                expand: false,
                                context: context,
                                builder: (context) => EventOptionsModal(
                                    eventId: eventList[index].id,
                                    eventStatus: eventList[index].status,
                                    isAlreadyInPreview: false)),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 15, 10),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: size.width * 0.20,
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        AutoSizeText(
                                          eventList[index].title,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: kDefaultFontColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          minFontSize: 8,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: kDefaultPadding / 3),
                                        Text(
                                            '${eventList[index].startDate} ~ ${eventList[index].finishDate}',
                                            style: TextStyle(
                                                color: kLiteFontColor,
                                                fontSize: 11)),
                                        SizedBox(height: kDefaultPadding),
                                        IntrinsicHeight(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 4, 8, 4),
                                                child: Text(
                                                    _statusStringMap[
                                                        eventList[index]
                                                            .status]!,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: _statusColorMap[
                                                            eventList[index]
                                                                .status],
                                                        fontWeight: eventList[
                                                                        index]
                                                                    .status ==
                                                                EventStatus
                                                                    .PROCEEDING
                                                            ? FontWeight.bold
                                                            : FontWeight
                                                                .normal)),
                                              ),
                                              VerticalDivider(
                                                  width: 0,
                                                  color: kShadowColor
                                                      .withOpacity(0.6)),
                                              GestureDetector(
                                                onTap: () =>
                                                    showBarModalBottomSheet(
                                                  expand: true,
                                                  context: context,
                                                  builder: (context) =>
                                                      EventEditModal(
                                                    eventId:
                                                        eventList[index].id,
                                                  ),
                                                ),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          8, 4, 8, 4),
                                                  child: Icon(
                                                      Icons.edit_rounded,
                                                      color: Colors.blueGrey,
                                                      size: 18),
                                                ),
                                              ),
                                              VerticalDivider(
                                                  width: 0,
                                                  color: kShadowColor
                                                      .withOpacity(0.6)),
                                              GestureDetector(
                                                onTap: () =>
                                                    showMaterialModalBottomSheet(
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        expand: false,
                                                        context: context,
                                                        builder: (context) =>
                                                            EventOptionsModal(
                                                                eventId:
                                                                    eventList[
                                                                            index]
                                                                        .id,
                                                                eventStatus:
                                                                    eventList[
                                                                            index]
                                                                        .status,
                                                                isAlreadyInPreview:
                                                                    false)),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          8, 4, 0, 4),
                                                  child: Icon(
                                                      Icons.more_vert_rounded,
                                                      color: Colors.blueGrey,
                                                      size: 18),
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: kShadowColor,
                                spreadRadius: 1,
                                blurRadius: 7,
                                offset:
                                    Offset(3, 3), // changes position of shadow
                              ),
                            ],
                            color: kScaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(12)))),
                Positioned(
                    top: 15,
                    left: 20,
                    child: Container(
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        child: Image.asset(
                          eventList[index].thumbnail,
                          width: size.width * 0.37,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )),
              ])),
    );
  }
}
