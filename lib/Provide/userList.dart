import 'package:flutter/material.dart';

class Msg{
  String sendIp,receiveIp;
  bool own;
  String time = DateTime.now().toString().substring(0,16);
  int type;
  int length;
  String msg;

  Msg({this.sendIp,this.receiveIp,this.own,this.type,this.length,this.msg});

  factory Msg.fromJson(Map<String,dynamic> json){
    return Msg(
      sendIp: json['sendIp'],
      receiveIp: json['receiveIp'],
      own:json['own']=='true'?true:false,
      type:json['type'],
      length: json['length'],
      msg:json['msg']
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sendIp'] = this.sendIp;
    data['receiveIp'] = this.receiveIp;
    data['own'] = this.own;
    data['time'] = this.time;
    data['type'] = this.type;
    data['length'] = this.length;
    data['msg'] = this.msg;
    return data;
  }
}

class User{
  String userName;
  String userIp;
  int userColor;
  bool isUnread = false;
  List<Msg> msg = [];

  User({this.userName,this.userIp,this.userColor});

  factory User.fromJson(Map<String,dynamic> json){
    return User(
      userName:json['userName'],
      userIp:json['userIp'],
      userColor:json['userColor']
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userName'] = this.userName;
    data['userIp'] = this.userIp;
    data['userColor'] = this.userColor;
    if (this.msg != null) {
      data['msg'] = this.msg.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UserList with ChangeNotifier{
  List<User> list = [];

  addList(User value){
    bool flag = true;
    for(var l in list){
      if(l.userIp == value.userIp) {
        flag = false;
        l.userName = value.userName;
      }
    }
    if(flag) list.add(value);
    notifyListeners();
  }

  isUnRead(index,bool){
    list[index].isUnread = bool;
    notifyListeners();
  }

  addMsg(Msg msg,bool own){
    msg.own = own;
    if(!own){
      for(var l in list){
        if(l.userIp == msg.sendIp){
          l.msg.insert(0, msg);
          l.isUnread = true;
        }
      }
    }else{
      for(var l in list){
        if(l.userIp == msg.receiveIp){
          l.msg.insert(0, msg);
        }
      }
    }
    notifyListeners();
  }

}