class FCMessage {
  final String title;
  final String body;
  final String image;
  final Map<String, String> data;

  FCMessage(
      {required this.title,
      required this.body,
      required this.image,
      required this.data});
}

FCMessage createEventJoinNotification(String eventName) {
  final title = '이벤트 참여 알림';
  final body = '고객님이 $eventName에 참여했습니다!';
  final image = "";
  final Map<String, String> data = {};
  return FCMessage(title: title, body: body, image: image, data: data);
}
