import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hashchecker/api.dart';
import 'package:hashchecker/constants.dart';
import 'package:hashchecker/models/user_social_account.dart';
import 'package:kakao_flutter_sdk/auth.dart';
import 'package:kakao_flutter_sdk/user.dart';
import 'package:kakao_flutter_sdk/common.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:http/http.dart' as http;

import 'components/kakao_sign_in_button.dart';
import 'components/naver_sign_in_button.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text('ㅎㅇ'),
                  ),
                  Column(
                    children: [
                      NaverSignInButton(
                        size: size,
                        signIn: naverLoginPressed,
                      ),
                      SizedBox(height: kDefaultPadding / 3 * 2),
                      KakaoSignInButton(
                        size: size,
                        signIn: kakaoLoginPressed,
                      ),
                    ],
                  ),
                ])),
      ),
    );
  }

  Future<void> naverLoginPressed() async {
    // try login
    NaverLoginResult loginResult = await FlutterNaverLogin.logIn();

    // on login success
    if (loginResult.status == NaverLoginStatus.loggedIn) {
      // get token
      NaverAccessToken token = await FlutterNaverLogin.currentAccessToken;

      // get account info
      NaverAccountResult account = await FlutterNaverLogin.currentAccount();

      // authorize to spring server with user account info
      signIn(UserSocialAccount(
          name: account.name,
          email: account.email,
          image: account.profileImage));

      // on login error
    } else if (loginResult.status == NaverLoginStatus.error) {
      showLoginFailDialog();
    }
  }

  Future<void> naverLogoutPressed() async {
    FlutterNaverLogin.logOut();
  }

  Future<void> kakaoLoginPressed() async {
    try {
      // check if is kakaotalk installed
      final installed = await isKakaoTalkInstalled();

      final String authCode;

      // login & get auth code via kakaotalk app
      if (installed) {
        await UserApi.instance.loginWithKakaoTalk();

        authCode = await AuthCodeClient.instance.requestWithTalk();

        // login & get auth code kakao web
      } else {
        await UserApi.instance.loginWithKakaoAccount();

        authCode = await AuthCodeClient.instance.request();
      }

      // get token
      AccessTokenResponse token =
          await AuthApi.instance.issueAccessToken(authCode);

      // get account info
      User user = await UserApi.instance.me();

      // if email isn't connected to kakao account
      if (user.kakaoAccount!.email == null) {
        showLoginFailDialog();
        return;
      }

      // authorize to spring server with user account info
      signIn(UserSocialAccount(
          name: user.kakaoAccount!.profile!.nickname,
          email: user.kakaoAccount!.email!,
          image: user.kakaoAccount!.profile!.profileImageUrl!));
    } catch (e) {
      showLoginFailDialog();
    }
  }

  Future<void> signIn(UserSocialAccount account) async {
    late String xAuthToken;

    final response = await http.post(Uri.parse(getApi(API.LOGIN)),
        body: jsonEncode(account.toJson()),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json"
        });

    if (response.statusCode == 200) {
      xAuthToken = jsonDecode(response.body)['message'];

      // apiTest
      final apiTest = await http.get(
        Uri.parse(getApi(API.GET_ALL_EVENTS)),
        headers: {'x-auth-token': xAuthToken},
      );
      print(apiTest.body);
    } else {
      showLoginFailDialog();
    }
  }

  void showLoginFailDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
            title: Center(
                child: Text(
              "로그인 오류",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            )),
            content: IntrinsicHeight(
              child: Column(children: [
                Text("로그인 도중 오류가 발생하였습니다.", style: TextStyle(fontSize: 14)),
                SizedBox(height: kDefaultPadding / 3),
                Text("네트워크 연결 상태를 확인해주세요.", style: TextStyle(fontSize: 14)),
              ]),
            ),
            contentPadding: const EdgeInsets.fromLTRB(15, 15, 15, 5),
            actions: [
              Center(
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('확인')),
              )
            ],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15))));
  }
}