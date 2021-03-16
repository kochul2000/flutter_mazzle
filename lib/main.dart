import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:http/http.dart';
import 'package:mazzle/models/user_model.dart';
import 'package:mazzle/modules/join/join.dart';
import 'package:mazzle/rest_api.dart';
import 'package:mazzle/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.red,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyMainPage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyMainPage extends StatefulWidget {
  MyMainPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyMainPageState createState() => _MyMainPageState();
}

class _MyMainPageState extends State<MyMainPage> {
  Future<UserData> userData;

  @override
  void initState() {
    super.initState();
    // todo 인터넷 연결 상태 확인
    // todo check version
    // todo 전체 공지 팝업, 추후 home에는 회원 공지 팝업.
    // todo mazzleAuthToken 저장여부 확인
  }

  Future<NaverAccessToken> _get_naver_access_token() async {
    NaverLoginResult _ = await FlutterNaverLogin.logIn();
    NaverAccessToken naverAccessTokenData = await FlutterNaverLogin.currentAccessToken;
    return naverAccessTokenData;
  }

  void _naverLogin() async {
    setState(() {
      var isBusy = true;  // todo delete sample code
    });

    // todo naver logout 이후 로그인
    NaverAccessToken naverAccessTokenData = await _get_naver_access_token();
    String naverAccessToken = naverAccessTokenData.accessToken;

    if (naverAccessToken == null) {  // 로그인 취소 대응
      Fluttertoast.showToast(
          msg: "네이버 로그인 취소",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          textColor: Colors.black,
          fontSize: 16.0
      );
      return;
    }

    Response response = await getUser(naverAccessToken);
    print('main.dart  response code: ${response.statusCode}');

    switch(response.statusCode) {
      case 200: {
        // statements;
        // _login 으로 넘어감.
        _login();
      }
      break;

      case 401: {
        //statements;  join 으로 넘어감
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => JoinPage(
                naverAccessToken,
              ))
        );
      }
      break;

      case 404: {
        //statements; 네이버 로그인 문제.
        // "네이버 로그인에 문제가 있습니다. 네이버 앱 및 브라우저에서 재로그인을 해보시고 문제가 지속되면 관리자에게 연락해 주세요."
      }
      break;

      default: {
        //statements;
        // "네이버 로그인중 알수없는 오류가 발생했습니다. 네이버 앱 및 브라우저에서 재로그인을 해보시고, 다시 매즐 로그인을 시도해 보세요."
      }
      break;
    }

    // userData.then((userData) => {
    //   FirebaseAuth.instance.signInWithCustomToken(userData.firebase_auth_token).then((value) => {
    //     Navigator.pushAndRemoveUntil(
    //       context,
    //       MaterialPageRoute(
    //           builder: (context) => HomePage(
    //             userData: userData,
    //           )),
    //           (Route<dynamic> route) => false,
    //     )
    //   })
    // });
  }

  void _login() {
    Fluttertoast.showToast(  // todo test code delete
        msg: "_login() called",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        textColor: Colors.black,
        fontSize: 16.0
    );
    // String mazzleAuthToken = 'get from secure storage';
    // var response = getLogin(mazzleAuthToken);
    // response.then((response) => {
    //   userData = UserData.fromJson(json.decode(response.body));
    // });
    //
    // userData.then((userData) => {
    //   FirebaseAuth.instance.signInWithCustomToken(userData.firebase_auth_token).then((value) => {
    //     Navigator.pushAndRemoveUntil(
    //       context,
    //       MaterialPageRoute(
    //           builder: (context) => HomePage(
    //             userData: userData,
    //           )),
    //           (Route<dynamic> route) => false,
    //     )
    //   })
    // });
    //
    //
    // if (response.statusCode == 200) {
    //   // 만약 서버로의 요청이 성공하면, JSON을 파싱합니다.
    //   return UserData.fromJson(json.decode(response.body));
    // } else {
    //   // 만약 요청이 실패하면, 에러를 던집니다.
    //   throw Exception('Failed to get user: status=${response.statusCode}, body=${response.body}');
    // }
  }


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: Colors.red,
      body: Stack(children: [
        Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Invoke "debug painting" (press "p" in the console, choose the
            // "Toggle Debug Paint" action from the Flutter Inspector in Android
            // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
            // to see the wireframe for each widget.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(
                image: AssetImage('assets/images/logo.png'),
              ),
              Text(
                '네이버아이디로 간편하게 시작하세요',
                textScaleFactor: 1.2,
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        Align(
          alignment: FractionalOffset.bottomCenter,
          child: Container(
            padding: EdgeInsets.only(bottom: 48),
            child: MaterialButton(
              onPressed: _naverLogin,
              child: Text('네이버 로그인', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              color: Colors.white,
            ),
          ),
        ),
      ]),
    ); // This trailing comma makes auto-formatting nicer for build methods.
  }
}
