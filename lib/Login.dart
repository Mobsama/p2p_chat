import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import './routers/Application.dart';
import 'package:connectivity/connectivity.dart';

class Login extends StatelessWidget {
  String userIp;
  String userName;
  final myController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('快聊'),elevation: 0.0,),
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(20, 80, 20, 10),
            child: Text(
              '开始使用快聊',
              style: TextStyle(fontSize: 50,fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: TextField(
              controller: myController,
              maxLength: 8,
              decoration: InputDecoration(
                hintText: '昵称',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(width: 2.0,style: BorderStyle.solid)
                )
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
            height: 60,
            width: double.infinity,
            child: RaisedButton(
              color: Color(0xFF07C160),
              textColor: Colors.white,
              child: Text('开始聊天',style: TextStyle(fontSize: 20.0),),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
              onPressed: () async {
                var connectivityResult = await (Connectivity().checkConnectivity());
                if(connectivityResult == ConnectivityResult.mobile){
                  Fluttertoast.showToast(
                      msg: "请连接WIFI",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      fontSize: 16.0
                  );
                }else {
                  userName = myController.text.toString();
                  userIp = await Connectivity().getWifiIP();
                  if (userName.isEmpty) {
                    Fluttertoast.showToast(
                        msg: "昵称不能为空",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        fontSize: 16.0
                    );
                  } else {
                    Application.router.navigateTo(context,
                        '/index?name=${Uri.encodeComponent(
                            userName)}&ip=$userIp', clearStack: true);
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
