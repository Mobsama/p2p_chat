import 'package:fluro/fluro.dart';

import './router_handler.dart';

class Routes{
  static String root='/';
  static String indexPage = '/index';
  static String chatPage = '/chat';
  static void configureRoutes(Router router){
    router.define(indexPage,handler:indexHandler);
    router.define(chatPage,handler:chatHandler);
  }
}