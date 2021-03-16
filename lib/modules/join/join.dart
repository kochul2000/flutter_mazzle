import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mazzle/home.dart';
import 'package:mazzle/rest_api.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mazzle/models/user_model.dart';

class JoinPage extends StatefulWidget {
  final String naverAccessToken;
  JoinPage(this.naverAccessToken);

  @override
  _JoinPageState createState() => _JoinPageState(naverAccessToken);
}

class _JoinPageState extends State<JoinPage> {
  // 1약관동의 2추천인입력 3까페가입확인 이후 서버에서 추천인, 엑세스토큰을 전송하며, 해당 정보로 까페에 글을 씀.
  // 4 가입 진행 화면.
  // 3-1 가입된 상태 ->
  // 3-2 가입 안된 상태 -> 닉네임 입력 -> 가입진행 -> 가입성공화면
  // 5 가입성공
  String naverAccessToken;
  _JoinPageState(this.naverAccessToken);

  // 공통
  int _currentStep = 0;
  // _currentStep
  // 0 약관
  // 1 추천인
  // 2 카페연동
  // 3 완료

  bool _isContinuable = false;  // 다음 버튼 활성화 여부
  bool _isCancelable = true;  // 이전 버튼 활성화 여부

  void setStep(step) {
    initStep(step);
    setState(() {
      _currentStep = step;
    });
  }

  void initStep(int step) {
    switch (step) {
      case 0:  // 약관
        _isContinuable = _agreeEula && _agreePrivacy;
        break;
      case 1:  // 추천인
        _isContinuable = _errorRecommender == null;
        _isCancelable = true;
        break;
      case 2:  // 카페연동
        _isContinuable = _hasCafeSync;
        _isCancelable = _hasCafeSync;

        if (!_hasCafeSync) {
          attemptJoin();
        }
        break;
      case 3:  // 완료
        _isContinuable = true;
        _isCancelable = false;
        // test
        break;
    }
  }

  tapped(int step) {
    if (_isCancelable) {
      setStep(step);
    }
  }

  continued(){
    if (_currentStep == 3) {  // 마지막 완료 단계라면 홈으로
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(
              userData: null,
            )),
            (Route<dynamic> route) => false,
      );
    } else {  // 이외에는 다음 단계로
      setStep(++_currentStep);
    }
  }

  cancel(){
    (_currentStep > 0 && _currentStep !=3 && _isCancelable) ?
    setStep(--_currentStep) : null;
  }

  // 약관
  bool _agreeAll = false;
  bool _agreeEula = false;
  bool _agreePrivacy = false;
  bool _agreeAd = false;

  isAllCheck() {
    if (_agreeEula && _agreePrivacy && _agreeAd) {
      return true;
    } else {
      return false;
    }
  }

  // 추천인
  String _errorRecommender;
  final TextEditingController _recommenderController = TextEditingController();
  void checkRecommender() async {
    _isContinuable = false;
    _isCancelable = false;

    final response = await getRecommender(_recommenderController.value.text);

    switch (response.statusCode) {
      case 200:
        Fluttertoast.showToast(
            msg: "추천인 확인 성공!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            textColor: Colors.black,
            fontSize: 16.0
        );
        setState(() {
          _errorRecommender = null;
          initStep(_currentStep);
        });
        break;
      case 404:
        setState(() {
          _errorRecommender = "유효하지 않은 추천인입니다";
          initStep(_currentStep);
        });
        break;
      default:
        Fluttertoast.showToast(
            msg: "알수 없는 에러가 발생했습니다. 앱을 재시작 해보시고 지속시 관리자에게 알려주십시오.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            textColor: Colors.black,
            fontSize: 16.0
        );
        break;
    }
  }

  // 카페연동
  bool _hasCafeSync = false;
  void attemptJoin() async {
    final response = await postUser(naverAccessToken, _recommenderController.value.text);
    print('test*** ${response.statusCode}');
    print('test*** ${naverAccessToken}');
    print('test*** ${_recommenderController.value.text}');
    print('${response.body}');
    switch (response.statusCode) {
      case 200:
        UserData userData = UserData.fromJson(json.decode(response.body));
        FirebaseAuth.instance.signInWithCustomToken(userData.firebase_auth_token).then((value) => {
          print('firebaseauth***: $value')
        });
        setStep(++_currentStep);
        // 성공! 완료 페이지로.
        break;
      case 401:  // 네이버 권한 설정 문제
        // 네이버 권한 팝업
        break;
      case 404:  // Access token 문제. ex. 만료..
        // 네이버 권한 리뉴
        break;
      case 406:  // 까페 미가입
        break;
      default:
        Fluttertoast.showToast(
            msg: "알수 없는 에러가 발생했습니다. 앱을 재시작 해보시고 지속시 관리자에게 알려주십시오.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            textColor: Colors.black,
            fontSize: 16.0
        );
        break;
    }
  }


  // 완료


  @override
  void initState() {
    super.initState();
    _recommenderController.addListener(() {
      final recommenderInput = _recommenderController.value.text;
      if (recommenderInput.isEmpty) {  // 추천인이 비어있다면 입력하지 않겠다는 의사로 취급해서 valid 로 값을 설정함.
        setState(() {
          _errorRecommender = null;
          initStep(_currentStep);
        });
      } else {
        setState(() {
          _errorRecommender = "추천인 확인이 필요합니다";
          initStep(_currentStep);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text('회원가입'),
        centerTitle: true,

      ),
      body:  Container(
        child: Column(
          children: [
            Expanded(
              child: Stepper(
                type: StepperType.vertical,
                physics: ScrollPhysics(),
                currentStep: _currentStep,
                onStepTapped: (step) => tapped(step),
                onStepContinue: continued,
                onStepCancel: cancel,
                controlsBuilder: (BuildContext context, {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
                  var buttonList = [
                    FlatButton(
                      onPressed: _isContinuable ? onStepContinue : null,
                      child: const Text('다음'),
                      textColor: Colors.white,
                      color: Colors.red,
                    )
                  ];

                  if (0 < _currentStep && _currentStep < 3) {
                    buttonList.add(
                        FlatButton(
                      onPressed: _isCancelable ? onStepCancel : null,
                      child: const Text('이전'),
                    ));
                  }

                  return Row(
                    children: buttonList,
                  );
                },
                steps: <Step>[
                  Step(
                    title: new Text('약관'),
                    content: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: _agreeAll,
                              onChanged: (value) {
                                setState(() {
                                  _agreeAll = value;
                                  _agreeEula = value;
                                  _agreePrivacy = value;
                                  _agreeAd = value;
                                  initStep(_currentStep);
                                });
                              },
                            ),
                            Text(
                              '전체동의',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: _agreeEula,
                              onChanged: (value) {
                                setState(() {
                                  _agreeEula = value;
                                  _agreeAll = isAllCheck();
                                  initStep(_currentStep);
                                });
                              },
                            ),
                            Text(
                              '(필수) 이용약관에 동의합니다',
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: _agreePrivacy,
                              onChanged: (value) {
                                setState(() {
                                  _agreePrivacy = value;
                                  _agreeAll = isAllCheck();
                                  initStep(_currentStep);
                                });
                              },
                            ),
                            Text(
                              '(필수) 개인정보 처리방침에 동의합니다',
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: _agreeAd,
                              onChanged: (value) {
                                setState(() {
                                  _agreeAd = value;
                                  _agreeAll = isAllCheck();
                                  initStep(_currentStep);
                                });
                              },
                            ),
                            Text(
                              '(선택) 광고 알림에 동의합니다',
                            )
                          ],
                        ),
                      ],
                    ),
                    isActive: _currentStep >= 0,
                    state: _currentStep >= 0 ?
                    StepState.complete : StepState.disabled,
                  ),
                  Step(
                    title: new Text('추천인'),
                    content: Column(
                      children: <Widget>[
                        Row(
                          children: [Text('(선택사항) 추천인 입력시 매즐 포인트를 드립니다.\n추천인 없이 가입하시려면 빈칸으로 두십시오.', textAlign: TextAlign.start)],
                          mainAxisAlignment: MainAxisAlignment.start ,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 16.0),
                          child: TextFormField(
                            controller: _recommenderController,
                            decoration: InputDecoration(
                                hintText: '카페 닉네임',
                                errorText: _errorRecommender == null ? null : _errorRecommender,
                                suffixIcon: FlatButton(
                                    // icon: Icon(Icons.check),
                                    child: Text('확인'),
                                    textColor: Colors.red,
                                    onPressed: () {
                                      checkRecommender();
                                    })),
                          ),
                        ),
                      ],
                    ),
                    isActive: _currentStep >= 0,
                    state: _currentStep >= 1 ?
                    StepState.complete : StepState.disabled,
                  ),
                  Step(
                    title: new Text('카페연동'),
                    content:
                    _hasCafeSync ?
                    Column(  // 카페 가입을 확인했으며, 미가입자인 경우
                      children: <Widget>[
                        Container(
                          alignment: Alignment.centerLeft,
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: '네이버 카페 닉네임', helperText: '닉네임만 입력하시면 네이버 카페가 연동 가입됩니다'),
                        ),
                      ],
                    ):
                    Container(  // 카페 가입을 확인하기 전인 경우.
                      alignment: Alignment.center,
                      margin: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text('카페연동중...'),
                          LinearProgressIndicator()
                        ],
                      ),
                    ),
                    isActive:_currentStep >= 0,
                    state: _currentStep >= 2 ?
                    StepState.complete : StepState.disabled,
                  ),
                  Step(
                    title: new Text('완료'),
                    content: Container(
                      margin: EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'ooo 님',
                              style: TextStyle(
                                fontSize: 18.0
                              ),
                            ),
                          ),
                          Text(
                            "회원가입을 환영합니다!\n다음을 눌러 매즐을 시작하세요.",
                          ),
                        ],
                      ),
                    ),
                    isActive:_currentStep >= 0,
                    state: _currentStep >= 3 ?
                    StepState.complete : StepState.disabled,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
