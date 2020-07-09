import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:p2pchat/Provide/userList.dart';
import './routers/routers.dart';
import './routers/Application.dart';
import 'package:provide/provide.dart';

import 'Login.dart';

void main(){
  var userChange = UserList();
  var providers = Providers();
  providers
    ..provide(Provider<UserList>.value(userChange));
  runApp(ProviderNode(child: MyApp(), providers: providers));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final router = Router();
    Routes.configureRoutes(router);
    Application.router = router;

    return Container(
      child: MaterialApp(
        title: '快聊',
        onGenerateRoute: Application.router.generator,
        theme: ThemeData(
          primaryColor: Color(0xFF07C160)
        ),
        home: Login(),
      ),
    );
  }
}
