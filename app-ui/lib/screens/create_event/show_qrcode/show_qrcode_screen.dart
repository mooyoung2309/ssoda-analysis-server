import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hashchecker/api.dart';
import 'package:hashchecker/constants.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';

class ShowQrcodeScreen extends StatefulWidget {
  final String eventId;
  const ShowQrcodeScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  _ShowQrcodeScreenState createState() => _ShowQrcodeScreenState();
}

class _ShowQrcodeScreenState extends State<ShowQrcodeScreen> {
  late String qrcodeUrl;

  @override
  void initState() {
    super.initState();
    qrcodeUrl = '$eventJoinUrl/${widget.eventId}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: kDefaultPadding),
              SizedBox(
                  child: QrImage(
                    data: qrcodeUrl,
                    version: QrVersions.auto,
                    size: 220,
                  ),
                  height: 150,
                  width: 150),
              SizedBox(height: kDefaultPadding / 3),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.check_circle_outlined),
                SizedBox(width: kDefaultPadding / 3),
                Text(
                  '이벤트가 등록되었습니다 ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ]),
              SizedBox(height: kDefaultPadding * 1.75),
              TextButton(
                child: Text(
                  'QR코드 저장하기',
                  style: TextStyle(
                    color: kThemeColor,
                    fontSize: 12,
                  ),
                ),
                onPressed: saveQrImgToGallery,
                style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.fromLTRB(12, 10, 12, 10)),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        kThemeColor.withOpacity(0.2)),
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)))),
              )
            ],
          )),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 50,
            child: TextButton(
              child: Text(
                '확인',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () {},
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(kThemeColor),
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27.0)))),
            ),
          )
        ],
      ),
    ));
  }

  Future<void> writeToFile(ByteData data, String path) async {
    final buffer = data.buffer;
    await File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  Future<String> createQrImg(String url) async {
    // check qrcode validation
    final qrValidationResult = QrValidator.validate(
      data: qrcodeUrl,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );

    if (qrValidationResult.status == QrValidationStatus.valid) {
      final qrCode = qrValidationResult.qrCode;
      final painter = QrPainter.withQr(
        qr: qrCode!,
      );

      // get temp directory for exporting qrcode image
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      final ts = DateTime.now().millisecondsSinceEpoch.toString();
      String qrImgPath = '$tempPath/event-qrcode-$ts.png';

      // write to bytefile
      final picData = await painter.toImageData(512);
      await writeToFile(picData!, qrImgPath);
      return qrImgPath;
    } else
      return ""; // invalid qr code
  }

  Future<void> saveQrImgToGallery() async {
    String path = await createQrImg(qrcodeUrl);

    final success = await GallerySaver.saveImage(path);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(success! ? 'QR 코드 이미지를 갤러리에 저장하였습니다.' : 'QR 코드 저장에 실패하였습니다.'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 2000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }
}
