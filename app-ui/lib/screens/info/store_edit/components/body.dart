import 'package:flutter/material.dart';
import 'package:hashchecker/constants.dart';
import 'package:hashchecker/models/store.dart';

import 'confirm_button.dart';
import 'store_category.dart';
import 'store_description.dart';
import 'store_image.dart';
import 'store_location.dart';
import 'store_logo.dart';
import 'store_name.dart';

class Body extends StatelessWidget {
  final Store store;
  const Body({Key? key, required this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  StoreLogo(store: store),
                  SizedBox(height: kDefaultPadding * 1.5),
                  StoreName(store: store),
                  SizedBox(height: kDefaultPadding),
                  StoreCate(store: store),
                  SizedBox(height: kDefaultPadding),
                  StoreImage(store: store),
                  SizedBox(height: kDefaultPadding),
                  StoreLocation(store: store),
                  SizedBox(height: kDefaultPadding),
                  StoreDescription(store: store),
                ],
              ),
            ),
          ),
          ConfirmButton(store: store),
        ],
      ),
    );
  }
}
