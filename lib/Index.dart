import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:p2pchat/Provide/userList.dart';
import 'package:p2pchat/routers/Application.dart';
import 'package:provide/provide.dart';

import 'Provide/userList.dart';

class Index extends StatelessWidget {
  final String userName;
  final String userIp;
  final Color userColor = slRandomColor();
  String lan;
  var user = UserList();
  bool flag;
  Index(this.userName,this.userIp, {this.flag=false});
  @override
  Widget build(BuildContext context) {
    lan = userIp.substring(0,userIp.lastIndexOf('.'));
    if(!flag){
      server(context, userName, userIp);
      flag = true;
    }
    for(int i=2;i>1&&i<255;i++){
      client(context, lan+'.'+i.toString(), userName, userIp);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('快聊'),
        actions: <Widget>[
        IconButton(icon: Icon(Icons.refresh), onPressed: (){
            for(int i=2;i>1&&i<255;i++){
              client(context, lan+'.'+i.toString(), userName, userIp);
            }
          })
        ],
        elevation: 0.0,
      ),
      body: Container(
        padding: EdgeInsets.all(8),
        child: Provide<UserList>(
            builder:(context,child,list){
              if(!flag){
                server(context, userName, userIp);
                flag = true;
              }
              user = list;
              if(user.list.length!=0){
                return ListView.builder(
                  itemCount: list.list.length,
                  itemBuilder: _wrapList,
                );
              }else{
                return Text(' ');
              }
            }
        ),
      ),
    );
  }

  Widget _wrapList(context,index){
    String name = user.list[index].userName;
    String ip = user.list[index].userIp;
    int color = user.list[index].userColor;
    return InkWell(
      child: Container(
        color: Colors.white,
        height: 100.0,
        width: double.infinity,
        child: Row(
          children: <Widget>[
            ClipOval(
                child: Container(
                  color: Color(color),
                  height: 70,
                  width: 70,
                  alignment: Alignment.center,
                  child: Text(
                    '${name[0]}',
                    style: TextStyle(fontSize: 30),
                  ),
                )
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFFEDEDED),width: 1))
                ),
                margin: EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(children: <Widget>[
                      Container(
                        child: Text(
                          name,
                          style: TextStyle(fontSize: 22),
                        ),
                        padding: EdgeInsets.fromLTRB(5, 5, 15, 5),
                      ),
                      Expanded(
                        child: Container(
                          child: Text(
                            ip,
                            style: TextStyle(fontSize: 22,color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                          padding: EdgeInsets.fromLTRB(5, 5, 15, 5),
                        ),
                      )],
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            child: Text(
                              user.list[index].msg.isEmpty?'':user.list[index].msg[0].type==2?'[语音]':user.list[index].msg[0].msg,
                              style: TextStyle(fontSize: 25,color: Colors.grey[600]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                          ),
                        ),
                        Container(
                          width: 50,
                          height: 20,
                          child: Text(
                            user.list[index].msg.isEmpty?'':user.list[index].msg[0].time.substring(11),
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            Offstage(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(5)
                ),
                margin: EdgeInsets.fromLTRB(10, 0, 5, 0),
              ),
              offstage: user.list[index].isUnread?false:true,
            )
          ],
        ),
      ),
      onTap: (){
        Provide.value<UserList>(context).isUnRead(index, false);
        Application.router.navigateTo(context, '/chat?name=${Uri.encodeComponent(userName)}&ip=$userIp&color=${userColor.value}&index=$index');
      },
    );
  }

  void server(context,userName,userIp) async{
    try{
      var serverSocket = await ServerSocket.bind(userIp.toString(), 4666);
      Msg msg;
      bool isAudio = false;
      String str = '';
      await for (var socket in serverSocket) {
        socket.listen((value) async {
          if(!isAudio) {
            int index = utf8.decode(value).indexOf('{');
            if (utf8.decode(value)[index-1] == 'i') {
              User user = User.fromJson(
                  json.decode(utf8.decode(value).substring(index)));
              Provide.value<UserList>(context).addList(user);
              socket.write('i' + json.encode(User(
                  userName: userName,
                  userIp: userIp,
                  userColor: userColor.value)
                  .toJson()));
            } else if (utf8.decode(value)[index-1] == 'm') {
              msg = Msg.fromJson(
                  json.decode(utf8.decode(value).substring(index)));
              if (msg.type == 1) {
                Provide.value<UserList>(context).addMsg(msg, false);
                socket.write('1');
              }
              if (msg.type == 2) {
                isAudio = true;
              }
            }
          } else {
            int length = utf8.decode(value).length;
            if(utf8.decode(value)[length-1] == 'e'){
              isAudio = false;
              str+=utf8.decode(value).substring(0,length-1);
              str = str.replaceAll('  ', ' ');
              if(str[0]==' ') str = str.substring(1);
              if(str[str.length-1]==' ') str = str.substring(0,str.length-1);
              var x1 = str.split(' ');
              List<int> l = x1.map(int.parse).toList();
              Uint8List list = Uint8List.fromList(l);
              File file = new File(msg.msg);
              sleep(Duration(microseconds: 2000));
              file.writeAsBytesSync(list);
              Provide.value<UserList>(context).addMsg(msg, false);
              str = '';
              socket.write('1');
            }else{
              str+=utf8.decode(value);
            }
            socket.flush();
          }
        });
      }
    }catch(e){

    }
  }

  void client(context,serverIp,userName,userIp) async{
    try{
      if(serverIp.toString() == userIp.toString()) return;
      var socketClient = await Socket.connect(
          serverIp,
          4666,
          timeout: Duration(microseconds: 50000)
      );
      socketClient.write('i'+json.encode(User(
          userName: userName,
          userIp: userIp,
          userColor: userColor.value)
          .toJson()));
      socketClient.listen(
          (value){
            if(utf8.decode(value)[0]=='i') {
              User user = User.fromJson(json.decode(utf8.decode(value).substring(1)));
              Provide.value<UserList>(context).addList(user);
            }
          }
        );
      await socketClient.close();
    }catch(e){

    }
  }

  static Color slRandomColor({int r = 255, int g = 255, int b = 255, a = 255}) {
    if (r == 0 || g == 0 || b == 0) return Colors.black;
    if (a == 0) return Colors.white;
    return Color.fromARGB(
      a,
      r != 255 ? r : Random.secure().nextInt(r),
      g != 255 ? g : Random.secure().nextInt(g),
      b != 255 ? b : Random.secure().nextInt(b),
    );
  }
}