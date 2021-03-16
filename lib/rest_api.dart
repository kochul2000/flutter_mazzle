import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:io';
import 'package:mazzle/models/user_model.dart';


class Uris {
  static const String flutter_localhost = '10.0.2.2';
  static const String prod_host = 'app.theocompany.co.kr';
  static const String http_scheme = 'http';
  static const String https_scheme = 'https';

  static const String scheme = http_scheme;
  static const String host = flutter_localhost;

  static const String version = '/version/';

  static const String user = '/user/';
  static const String login = '/user/login/';
  static const String recommender = '/user/recommender/';


  static Uri getUri(String path, {Map<String, String> queryParameters}){
    return Uri(
      scheme: scheme,
      host: host,
      path: path,
      queryParameters: queryParameters
    );
  }

}

Future<Object> requestWithMazzleAuth(Uri uri, String mazzleAuthToken) async {
  final response = await http.get(
    uri,
    headers: {HttpHeaders.authorizationHeader: "Token $mazzleAuthToken"},
  );

  if (response.statusCode == 200) {
    return response.body;
  } else {
    // 만약 요청이 실패하면, 에러를 던집니다.
    throw Exception('status=${response.statusCode}, body=${response.body}');
  }
}

Future<http.Response> getUser(naverAccessToken) { // naver access token 으로 mazzle auth token 획득
  return http.get(
    Uris.getUri(Uris.user, queryParameters: {'access_token': naverAccessToken}),
  );
}

Future<http.Response> postUser(naverAccessToken, recommender) { // 회원 가입
  return http.post(
    Uris.getUri(Uris.user, queryParameters: {'access_token': naverAccessToken, 'recommender': recommender}),
  );
}

Future<http.Response> getRecommender(recommender) { // 추천인 확인
  return http.get(
    Uris.getUri(Uris.recommender, queryParameters: {'recommender': recommender})
  );
}


Future<http.Response> getLogin(mazzleAuthToken) { // mazzle login
  return http.get(
    Uris.getUri(Uris.login),
    headers: {HttpHeaders.authorizationHeader: "Token $mazzleAuthToken"},
  );
}



// Future<UserData> getUser(naverAccessToken) async {
//   final response = await http.get(
//     Uris.getUri(Uris.user, queryParameters: {'access_token': naverAccessToken}),
//   );
//
//   if (response.statusCode == 200) {
//     // 만약 서버로의 요청이 성공하면, JSON을 파싱합니다.
//     return UserData.fromJson(json.decode(response.body));
//   } else {
//     // 만약 요청이 실패하면, 에러를 던집니다.
//     throw Exception('Failed to get user: status=${response.statusCode}, body=${response.body}');
//   }
// }

// class _MyAppState extends State<MyApp> {
//   Future<Post> post;
//
//   @override
//   void initState() {
//     super.initState();
//     post = getLogin();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Fetch Data Example',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Fetch Data Example'),
//         ),
//         body: Center(
//           child: FutureBuilder<Post>(
//             future: post,
//             builder: (context, snapshot) {
//               if (snapshot.hasData) {
//                 return Text(snapshot.data.title);
//               } else if (snapshot.hasError) {
//                 return Text("${snapshot.error}");
//               }
//
//               // 기본적으로 로딩 Spinner를 보여줍니다.
//               return CircularProgressIndicator();
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }