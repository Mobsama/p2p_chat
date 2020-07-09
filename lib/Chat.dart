import 'dart:convert';
import 'dart:io';

import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:p2pchat/routers/Application.dart';
import 'package:p2pchat/VoiceWidget.dart';
import 'package:provide/provide.dart';

import 'Provide/userList.dart';

class Chat extends StatefulWidget {
  final String userName,userIp;
  final int userColor,index;
  const Chat({Key key,this.userIp,this.userName,this.userColor,this.index}):super(key:key);
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  bool _flag = true;
  User user;
  _ChatState();
  final myController = TextEditingController();
  bool _isComposing = false;
  AudioPlayer audioPlugin = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return Provide<UserList>(
        builder: (context,child,list){
          user = list.list[widget.index];
          return WillPopScope(
            onWillPop: () async{
              Provide.value<UserList>(context).isUnRead(widget.index, false);
              Application.router.pop(context);
              return true;
            },
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: (){
                    Provide.value<UserList>(context).isUnRead(widget.index, false);
                    Application.router.pop(context);
                  },
                ),
                title: Text(user.userName),
              ),
              body: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: (){FocusScope.of(context).requestFocus(FocusNode());},
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: ListView.builder(
                            reverse: true,
                            itemCount: user.msg.length,
                            itemBuilder: _tile,
                          ),
                        )
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFEDEDED),width: 2)),),
                        padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.all(2.5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: new Border.all(width: 1, color: Colors.grey),
                              ),
                              child: IconButton(
                                icon: Icon(_flag?Icons.mic:Icons.keyboard, color: Colors.grey),
                                onPressed: (){
                                  setState(() {
                                    if(_flag) {_flag=false;_isComposing = false;}
                                    else {
                                      _flag=true;
                                      if(myController.text.isNotEmpty) _isComposing = true;
                                      else _isComposing = false;
                                    }
                                  });
                                },
                              ),
                              width: 65,
                            ),
                            Flexible(
                              child: _input(),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 2.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: new Border.all(width: 1, color: Colors.grey),
                                color: _isComposing?Color(0xFF07C160):Colors.grey,
                              ),
                              width: 65,
                              alignment: Alignment.center,
                              child: IconButton(
                                icon: Icon(Icons.send,color: Colors.white,),
                                padding: EdgeInsets.only(left: 5),
                                onPressed: _isComposing?() async{
                                  Msg msg = Msg(
                                      sendIp: widget.userIp,
                                      receiveIp: user.userIp,
                                      own: true,
                                      type: 1,
                                      length: myController.text.length,
                                      msg: myController.text.toString());
                                  var socketClient = await Socket.connect(user.userIp, 4666,timeout: Duration(microseconds: 50000));
                                  socketClient.write('m'+json.encode(msg.toJson()));
                                  socketClient.listen((value) {
                                    if(utf8.decode(value)[0] == '1'){
                                      Provide.value<UserList>(context).addMsg(msg, true);
                                    }else{
                                      Fluttertoast.showToast(
                                          msg: "发送失败",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          fontSize: 16.0
                                      );
                                    }
                                    myController.clear();
                                  });
                                  socketClient.close();
                                  setState(() {
                                    _isComposing = false;
                                  });
                                }:null,
                              ),
                            )
                          ],
                        ),
                      ),
//            VoiceWidget()
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
  }

  Widget _tile(context,index){
    if(!user.msg[index].own){
      return Container(
        margin: EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipOval(
                child: Container(
                  color: Color(user.userColor),
                  height: 60,
                  width: 60,
                  alignment: Alignment.center,
                  child: Text(
                    user.userName[0],
                    style: TextStyle(fontSize: 26),
                  ),
                )
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(child: Text(user.msg[index].time),alignment: Alignment.centerLeft,margin: EdgeInsets.only(left: 5),),
                    Card(
                      child: user.msg[index].type==1?
                      Container(
                        child: Text(user.msg[index].msg,style: TextStyle(letterSpacing: 1),),
                        padding: EdgeInsets.all(10),
                      ) : InkWell(
                        onTap: (){audioPlugin.play(user.msg[index].msg);},
                        child: Container(
                          child: Icon(Icons.mic),
                          padding: EdgeInsets.all(10),
                        ),
                      ),
                      margin: EdgeInsets.fromLTRB(5, 5, 100, 5),
                      color: Colors.white,
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      );
    }else{
      return Container(
        margin: EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Container(
                margin: EdgeInsets.only(right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(child: Text(user.msg[index].time),alignment: Alignment.centerRight,margin: EdgeInsets.only(right: 5),),
                    Card(
                      child: user.msg[index].type==1?
                      Container(
                        child: Text(user.msg[index].msg,style: TextStyle(letterSpacing: 1),),
                        padding: EdgeInsets.all(10),
                      ) : InkWell(
                        onTap: () async {
                          audioPlugin.play(user.msg[index].msg);
                          },
                        child: Container(
                          child: Icon(Icons.mic),
                          padding: EdgeInsets.all(10),
                        ),
                      ),
                      margin: EdgeInsets.fromLTRB(100, 5, 5, 5),
                      color: Color(0xFF07C160),
                    )
                  ],
                ),
              ),
            ),
            ClipOval(
                child: Container(
                  color: Color(widget.userColor),
                  height: 60,
                  width: 60,
                  alignment: Alignment.center,
                  child: Text(
                    widget.userName[0],
                    style: TextStyle(fontSize: 26),
                  ),
                )
            ),
          ],
        ),
      );
    }
  }

  Widget _input(){
    if(_flag) return Container(
      constraints: BoxConstraints(maxHeight: 150.0,minHeight: 50.0),
      margin: EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: TextField(
        controller: myController,
        maxLines: null,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(15.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
          )
        ),
        onChanged: (String text){
          setState(() {
            _isComposing = text.length > 0;
          });
        },
      ),
    );
    else return Container(margin: EdgeInsets.fromLTRB(8, 0, 8, 0),child: Voice(stopRecord: _sendMag,));
  }

  void _sendMag(voicePath,flag) async {
    if(!flag){
      File file = File(voicePath);
      file.delete();
      return;
    }
    File file = File(voicePath);
    Msg msg = Msg(
        sendIp: widget.userIp,
        receiveIp: user.userIp,
        own: true,
        type: 2,
        length: file.readAsBytesSync().length,
        msg: voicePath);

    var socketClient = await Socket.connect(user.userIp, 4666,timeout: Duration(microseconds: 80000));
    print(json.encode(msg.toJson()));
    socketClient.write('m'+json.encode(msg.toJson()));

    print(file.readAsBytesSync().length);
    String str = file.readAsBytesSync().toString();
    str = str.substring(1,str.length-1);
    str = str.replaceAll(',', ' ');
    int num = (str.length/100).ceil();
    for(int i=0;i<num;i++){
      String temp = '';
      if(i==num-1)
        temp = str.substring(i*100)+'e';
      else
        temp = str.substring(i*100,(i+1)*100);
      socketClient.write(temp);
    }

    socketClient.listen((value) async {
      if(utf8.decode(value)[0] == '1'){
        Provide.value<UserList>(context).addMsg(msg, true);
      } else{
        Fluttertoast.showToast(
            msg: "发送失败",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0
        );
      }
    });
    socketClient.close();
  }

}
