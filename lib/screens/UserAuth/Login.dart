import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iosrecal/Constant/utils.dart';
import 'package:iosrecal/Endpoint/Api.dart';
import 'package:iosrecal/bloc/KeyboardBloc.dart';
import 'package:iosrecal/models/LoginData.dart';

import 'package:iosrecal/models/ResponseBody.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:iosrecal/models/User.dart';
import 'package:iosrecal/Constant/Constant.dart';
import 'package:iosrecal/Constant/ColorGlobal.dart';
import 'package:iosrecal/Constant/TextField.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Login extends StatefulWidget {
  @override
  LoginState createState() {
    return new LoginState();
  }
}

class LoginState extends State<Login> {
  var top = FractionalOffset.topCenter;
  var bottom = FractionalOffset.bottomCenter;
  bool _keyboard = false;
  bool args;
  KeyboardBloc _bloc = new KeyboardBloc();
  UIUtills uiUtills = new UIUtills();
  bool internetConnection=true;

  TextEditingController email =
      new TextEditingController(text: "narensai319@gmail.com");
  TextEditingController password =
      new TextEditingController(text: "1j7P1T3ync2I");
  TextEditingController newPassword = new TextEditingController(text: "");
  TextEditingController confirmPassword = new TextEditingController(text: "");

  FocusNode emailFocus = new FocusNode();
  FocusNode passwordFocus = new FocusNode();
  FocusNode newPasswordFocus = new FocusNode();
  FocusNode confirmPasswordFocus = new FocusNode();

  bool changePassword = false;
  String primaryButtonText = "SIGN IN";
  String secondaryButtonText = "Change Password";
  String pageTitle = "SIGN IN";

  ProgressDialog progressDialog;

  List<String> result = new List<String>();

  Color getColorFromColorCode(String code) {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  _initController() {
    email = new TextEditingController(text: "narensai319@gmail.com");
    password = new TextEditingController(text: "123456");
    newPassword = new TextEditingController(text: "");
    confirmPassword = new TextEditingController(text: "");

    emailFocus = new FocusNode();
    passwordFocus = new FocusNode();
    newPasswordFocus = new FocusNode();
    confirmPasswordFocus = new FocusNode();
    _bloc.start();
  }

  _disposeController() {
    email.clear();
    password.clear();
    newPassword.clear();
    confirmPassword.clear();
    emailFocus.unfocus();
    passwordFocus.unfocus();
    newPasswordFocus.unfocus();
    confirmPasswordFocus.unfocus();
    _bloc.dispose();
  }

  _deleteUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("email", null);
    prefs.setString("name", null);
    prefs.setString("user_id", null);
    prefs.setString("cookie", null);
  }

  Future<bool> _onBackPressed() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit the App'),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                color: Colors.green,
                child: Text("NO"),
              ),
              new GestureDetector(
                child: FlatButton(
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).pop(true),
                  color: Colors.red,
                  child: Text("YES"),
                ),
              )
            ],
          ),
        ) ??
        false;
  }

  _loginDialog(String show, String again, int flag) {
    if (progressDialog == null) {
      progressDialog = new ProgressDialog(
        context,
        type: ProgressDialogType.Normal,
        textDirection: TextDirection.rtl,
        showLogs: true,
        isDismissible: false,
//      customBody: LinearProgressIndicator(
//        valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
//        backgroundColor: Colors.white,
//      ),
      );

      progressDialog.style(
        message: changePassword == true ? "Sending mail" : "Logging In",
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        elevation: 10.0,
        progressWidget: Image.asset(
          "assets/images/ring.gif",
          height: 50,
          width: 50,
        ),
        insetAnimCurve: Curves.easeInOut,
        progressWidgetAlignment: Alignment.center,
        messageTextStyle: TextStyle(
            color: Colors.black,
            fontSize: getHeight(18, 1),
            fontWeight: FontWeight.w600),
      );
      progressDialog.show();
      Future.delayed(Duration(milliseconds: 1000)).then((value) {
        Widget prog = flag == 1
            ? Icon(
                Icons.check_circle,
                size: 50,
                color: Colors.green,
              )
            : Icon(
                Icons.close,
                size: 50,
                color: Colors.red,
              );
        progressDialog.update(
            message: show.replaceAll("!", ""), progressWidget: prog);
      });
      Future.delayed(Duration(milliseconds: 2000)).then((value) {
        progressDialog.update(progressWidget: null);
        progressDialog.hide();
        setState(() {
          progressDialog = null;
        });
      });
    }
  }

  Widget primaryWidget() {
    return Text(
      primaryButtonText,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: getHeight(18, 1),
        color: ColorGlobal.whiteColor,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget secondaryWidget() {
    return Text(
      secondaryButtonText,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: getHeight(16, 1),
        color: ColorGlobal.textColor.withOpacity(0.9),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Future<dynamic> passwordReset(String email) async {
    bool internetConnection = false;
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          internetConnection = true;
        });
      }
      else {

        setState(() {
          internetConnection = false;
        });
      }
    } on SocketException catch (_) {
      print('not connected');
      setState(() {
        internetConnection = false;
      });
    }
    if (internetConnection == true) {
      var url = Api.passwordReset;
      var body = {
        'email': email,
      };
      await http
          .post(
        url,
        body: body,
      )
          .then((_response) async {
        ResponseBody responseBody = new ResponseBody();
        print('Response body: ${_response.body}');

        if (_response.statusCode == 200) {
          responseBody = ResponseBody.fromJson(json.decode(_response.body));
          print(json.encode(responseBody.data));
          if (responseBody.status_code == 200) {
            print(responseBody.data);
            _loginDialog(
                "Email has been sent",
                "",
                1);
            Future.delayed(
                Duration(
                    milliseconds: 2000),
                    () {
                  Navigator
                      .pushNamed(
                      context, PASSWORD_RESET);
                }).then((value) {
                  setState(() {
                    _deleteUserDetails();
                    _initController();
                    uiUtills = new UIUtills();
                    internetConnection=false;
                    changePassword = false;
                    primaryButtonText = "SIGN IN";
                    secondaryButtonText = "Change Password";
                    pageTitle = "SIGN IN";
                  });
            });
          } else {
            _loginDialog("Error Sending Email", "Try Again", 2);
            print(responseBody.data);
          }
        } else {
          _loginDialog("Server Error", "Try Again", 2);
          print("server error");
        }
      }).catchError((error) {
        _loginDialog("Server Error", "Try Again", 2);
        print("server error catch");
      });
    }
    else {
      _loginDialog("No Internet Connection", "Try Again", 2);
    }
  }
  _emailDialog() {
    return  showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(getHeight(20, 1)),
              ),
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(getHeight(8, 1)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Text(
                        "Write an email to",
                        style: GoogleFonts.lato(
                          color: ColorGlobal.textColor,
                          fontSize: getHeight(20, 1),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: () => _sendMail(),
                        child: Text(
                          "recaluaechapter@gmail.com",
                          style: GoogleFonts.lato(
                            color: ColorGlobal.blueColor,
                            decoration: TextDecoration.underline,
                            fontSize: getHeight(20, 1),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: FlatButton(
                        color: ColorGlobal.textColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(getHeight(9,1)),
                        ),

                        onPressed: () {
                          Navigator.of(context)
                              .pop(); // To close the dialog
                        },
                        child: Text("OK",
                            style: GoogleFonts.lato(
                              color: ColorGlobal.whiteColor,
                              fontSize: getHeight(16, 1),
                              fontWeight: FontWeight.w700,
                            )),
                      ),
                    ),
                  ],
                ),
              )),
        ));
  }
  _sendMail() async {
    // Android and iOS
    const uri =
        'mailto:recaluaechapter@gmail.com?subject=Login Credentials';
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    _deleteUserDetails();
    _initController();
    uiUtills = new UIUtills();
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  double getHeight(double height, int choice) {
    return uiUtills.getProportionalHeight(height: height, choice: choice);
  }

  double getWidth(double width, int choice) {
    return uiUtills.getProportionalWidth(width: width, choice: choice);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    args = ModalRoute.of(context).settings.arguments;
    if (args == true) {
      print("auth is true");
    }
    uiUtills.updateScreenDimesion(width: width, height: height);
    return Scaffold(
      backgroundColor: ColorGlobal.whiteColor,
      body: WillPopScope(
        onWillPop: _onBackPressed,
        child: Provider<LoginData>(
          create: (context) => LoginData(),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(0.05 * width),
                    child: Container(
                      width: width,
                      height: width * 0.35,
                      padding:
                          EdgeInsets.symmetric(horizontal: getWidth(20, 1)),
                      decoration: new BoxDecoration(
                          color: ColorGlobal.colorPrimaryDark,
                          image: new DecorationImage(
                            image:
                                new AssetImage('assets/images/recal_logo.jpg'),
                            fit: BoxFit.fill,
                          ),
                          borderRadius: BorderRadius.circular(width * 0.1)),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: getHeight(10, 1)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'RECAL UAE CHAPTER',
                          style: GoogleFonts.lato(
                            color: ColorGlobal.textColor,
                            fontSize: getHeight(22, 1),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: getHeight(20, 1),
                        left: getWidth(20, 1),
                        right: getWidth(20, 1),
                      bottom: getHeight(20, 1),
                    ),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          side: BorderSide(
                              color: ColorGlobal.whiteColor.withOpacity(0.8),
                              width: 0.5),
                          borderRadius: BorderRadius.circular(getWidth(20, 1))),
                      child: Column(
                        children: <Widget>[
                          Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: getHeight(20, 1)),
                              child: Text(
                                pageTitle,
                                style: GoogleFonts.josefinSans(
                                  color: ColorGlobal.textColor,
                                  fontSize: getHeight(18, 1),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: EdgeInsets.all(getWidth(10, 1)),
                              child: TextFieldWidget(
                                hintText: 'Email',
                                obscureText: false,
                                prefixIconData: Icons.mail,
                                passwordVisible: true,
                                textEditingController: email,
                                focusNode: emailFocus,
                              ),
                            ),
                          ),
                          changePassword == false
                              ? Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(getWidth(10, 1)),
                                    child: TextFieldWidget(
                                      hintText: "Password",
                                      obscureText: true,
                                      prefixIconData: Icons.lock,
                                      passwordVisible: false,
                                      textEditingController: password,
                                      focusNode: passwordFocus,
                                    ),
                                  ),
                                )
                              : Container(),
//                          changePassword == true ?  Padding(
//                            padding: const EdgeInsets.all(10),
//                            child: TextFieldWidget(
//                              hintText: 'Confirm Password',
//                              obscureText: true,
//                              prefixIconData: Icons.lock,
//                              textEditingController: confirmPassword,
//                              focusNode: confirmPasswordFocus,
//                            ),
//                          ) : Container(),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                color: Colors.transparent,
                                child: Consumer<LoginData>(
                                  builder: (context, loginData, child) {
                                    return InkWell(
                                      onTap: () async {
                                        if (changePassword == false) {
                                          if (email.text != "" &&
                                              password.text != "") {
                                            await loginData.loginUser(
                                                email.text, password.text);
                                            if (loginData.user == null) {
                                              await _loginDialog(
                                                  "Invalid Credentials",
                                                  "Try again",
                                                  2);
                                            }
                                            else if(loginData.user.user_id==-1) {
                                              await _loginDialog(
                                                  "No Internet Connection",
                                                  "Try again",
                                                  2);
                                            }
                                            else {
                                              User user = loginData.user;
                                              await user.saveUserDetails();
                                              await _loginDialog(
                                                  "Login Successful",
                                                  "Proceed",
                                                  1);
                                              if (args != null &&
                                                  args == true) {
                                                Future.delayed(
                                                    Duration(
                                                        milliseconds: 2000),
                                                    () {
                                                  Navigator.pop(context);
                                                });
                                              } else {
                                                Future.delayed(
                                                    Duration(
                                                        milliseconds: 2000),
                                                    () {
                                                  Navigator
                                                      .pushReplacementNamed(
                                                          context, HOME_PAGE);
                                                });
                                              }
                                            }
                                          } else {
                                            await _loginDialog(
                                                "Enter all fields",
                                                "Try again",
                                                2);
                                          }
                                        } else {
                                          if (email.text != "") {
                                            await passwordReset(email.text);
                                          } else {
                                            _loginDialog("Enter all fields",
                                                "Try again", 2);
                                          }
                                        }
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        padding:
                                            EdgeInsets.all(getWidth(10, 1)),
                                        decoration: BoxDecoration(
                                          color: ColorGlobal.colorPrimary,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(
                                              (getWidth(10, 1)),
                                            ),
                                          ),
                                        ),
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: primaryWidget(),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: getHeight(20, 1),
                                bottom: getHeight(10, 1)),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  changePassword = !changePassword;
                                  primaryButtonText =
                                      primaryButtonText == "SIGN IN"
                                          ? "SUBMIT"
                                          : "SIGN IN";
                                  secondaryButtonText =
                                      secondaryButtonText == "Change Password"
                                          ? "Return to Sign in"
                                          : "Change Password";
                                  pageTitle = pageTitle == "SIGN IN"
                                      ? "RESET PASSWORD"
                                      : "SIGN IN";
                                  emailFocus.unfocus();
                                  passwordFocus.unfocus();
                                });
                              },
                              child: AnimatedSwitcher(
                                duration: Duration(seconds: 1),
                                child: secondaryWidget(),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(getWidth(10, 1)),
                            child: GestureDetector(
                              onTap: () => _emailDialog(),
                              child: AutoSizeText(
                                "Don't have credentials?",
                                maxLines: 4,
                                style: TextStyle(
                                  fontSize: getHeight(18, 1),
                                  color: ColorGlobal.blueColor.withOpacity(0.9),
                                  fontWeight: FontWeight.w300,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  StreamBuilder<double>(
                      stream: _bloc.stream,
                      builder: (BuildContext context,
                          AsyncSnapshot<double> snapshot) {
                        print(
                            'is keyboard open: ${_bloc.keyboardUtils.isKeyboardOpen}'
                            'Height: ${_bloc.keyboardUtils.keyboardHeight}');
                        return _bloc.keyboardUtils.isKeyboardOpen == true
                            ? Container(
                                height: _bloc.keyboardUtils.keyboardHeight,
                              )
                            : Container(
                                height: 0,
                                width: 0,
                              );
                      }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
