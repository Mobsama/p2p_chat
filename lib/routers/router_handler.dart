import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';

import '../Chat.dart';
import '../Index.dart';

Handler indexHandler = Handler(
    handlerFunc: (BuildContext context,Map<String,List<String>> params){
      String userName = params['name'].first;
      String userIp = params['ip'].first;
      return Index(userName,userIp);
    }
);

Handler chatHandler = Handler(
  handlerFunc: (BuildContext context,Map<String,List<String>> params){
    String userName = params['name'].first;
    String userIp = params['ip'].first;
    int userColor = int.parse(params['color'].first);
    int index = int.parse(params['index'].first);
    return Chat(userIp:userIp,userName:userName,userColor:userColor,index:index);
  }
);